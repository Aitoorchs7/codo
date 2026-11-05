import 'dart:typed_data';

import 'package:codo/admins/auth_service.dart';
import 'package:codo/models/live_session.dart';
import 'package:codo/models/proof.dart';
import 'package:codo/repositories/live_session_repository.dart';
import 'package:codo/repositories/session_failure.dart';
import 'package:codo/screens/profile/edit_session_dialog.dart';
import 'package:codo/screens/profile/sesion_detail_screen.dart';
import 'package:codo/utils/photo_compressor.dart';
import 'package:flutter/material.dart';
import 'package:codo/admins/photo_admin.dart';
import 'package:codo/admins/photo_failure.dart';

enum _SessionAction { edit, finish, delete, proof }

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final _photos = PhotoAdmin();
  final _compressor = PhotoCompressor();
  final _repository = LiveSessionRepository();
  final List<LiveSession> _sessions = []; // se va ampliando con cada página
  bool _loading = true;
  bool _hasError = false;
  bool _hasMore = true;
  DateTimeRange? _range; // null = historial paginado
  // Una petición por sesión: el FutureBuilder no puede crear el Future en build
  final Map<String, Future<Proof?>> _proofs = {};

  Future<Proof?> _proofFor(LiveSession s) =>
      _proofs.putIfAbsent(s.id, () => _repository.getProof(s.id, s.creatorId));

  @override
  void initState() {
    super.initState();
    _loadPage();
  }

  Future<void> _loadPage({bool reset = false}) async {
    setState(() {
      if (reset){
        _sessions.clear();
        _proofs.clear();
      } // filtro nuevo: empezar de cero
      _loading = true;
      _hasError = false;
    });
    try {
      final uid = (await AuthService().currentUser())?.uid;
      if (uid == null) throw StateError('Sin sesión');
      final range = _range;
      final page = range == null
          ? await _repository.getHistoryPage(uid, reset: reset)
          // +1 día: el picker da el último día a las 00:00 y la consulta usa isLessThan
          : await _repository.getHistoryBetween(
              uid,
              range.start,
              range.end.add(const Duration(days: 1)),
            );
      if (!mounted) return;
      setState(() {
        _sessions.addAll(page);
        // Si llega una página incompleta, ya no quedan más
        _hasMore =
            range == null &&
            page.length == LiveSessionRepository.historyPageSize;
        _loading = false;
      });
    } catch (e) {
      debugPrint('HistoryScreen: $e');
      if (!mounted) return;
      setState(() {
        _loading = false;
        _hasError = true;
      });
    }
  }

  Future<void> _pickRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 1),
      lastDate: now,
      initialDateRange: _range,
    );
    if (picked == null || !mounted) return; // canceló o salió de la pantalla
    _range = picked;
    _loadPage(reset: true);
  }

  void _clearRange() {
    _range = null;
    _loadPage(reset: true);
  }

  String _formatDate(DateTime d) => '${d.day}/${d.month}/${d.year}';

  Future<void> _onAction(_SessionAction action, LiveSession s) async {
    try {
      switch (action) {
        case _SessionAction.edit:
          final result = await showDialog<({String description, int minutes})>(
            context: context,
            builder: (_) => EditSessionDialog(session: s),
          );
          if (result == null) return; // canceló
          await _repository.updateSession(
            s.id,
            description: result.description,
            durationMinutes: result.minutes,
          );
        case _SessionAction.finish:
          await _repository.finishSession(s.id);
        case _SessionAction.delete:
          if (!await _confirmDelete()) return;
          await _repository.deleteSession(s.id, s.creatorId);
        case _SessionAction.proof:
          await _addProof(s);
          if (!mounted) return;
          setState(() => _proofs.remove(s.id)); // olvida la miniatura vieja y la vuelve a pedir
          return;
      }
      if (!mounted) return;
      _loadPage(reset: true); // releer para ver el cambio
    } on SessionFailure catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(_errorText(e.error))));
    }
  }

  Future<bool> _confirmDelete() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Borrar la sesión?'),
        content: const Text('No se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Borrar'),
          ),
        ],
      ),
    );
    return ok ?? false; // tocar fuera del diálogo cuenta como cancelar
  }

  String _errorText(SessionError e) => switch (e) {
    SessionError.permissionDenied => 'No puedes modificar esta sesión',
    SessionError.notFound => 'La sesión ya no existe',
    SessionError.network => 'Sin conexión. Inténtalo de nuevo',
    SessionError.unknown => 'No se pudo guardar el cambio',
  };

  Future<void> _addProof(LiveSession s) async {
    // Hoja inferior para elegir el origen; devuelve null si la cierra
    final source = await showModalBottomSheet<PhotoSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Hacer foto'),
              onTap: () => Navigator.pop(context, PhotoSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Elegir de la galería'),
              onTap: () => Navigator.pop(context, PhotoSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;
    try {
      final bytes = await _photos.pick(source);
      if (bytes == null || !mounted) return; // canceló la cámara o la galería
      final small = await _compressWithProgress(bytes);
      if (!mounted) return;
      // Vista previa y confirmación antes de guardar
      final save = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Guardar'),
            ),
          ],
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.memory(small, height: 240),
              const SizedBox(height: 8),
              Text(
                '${(bytes.length / 1024).round()} KB → ${(small.length / 1024).round()} KB',
              ),
            ],
          ),
        ),
      );
      if (save != true || !mounted) return;
      final uid = (await AuthService().currentUser())?.uid;
      if (uid == null) return;
      await _repository.saveProof(s.id, uid, small);
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Prueba guardada')));
    } on PhotoFailure catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(_photoErrorText(e.error))));
    } on SessionFailure catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(_errorText(e.error))));
    }
  }

  String _photoErrorText(PhotoError e) => switch (e) {
    PhotoError.cameraDenied => 'Sin permiso de cámara. Actívalo en Ajustes > Aplicaciones > Codo > Permisos, o elige una foto de la galería',
    PhotoError.galleryDenied => 'Sin permiso de fotos. Actívalo en Ajustes > Aplicaciones > Codo > Permisos',
    PhotoError.noCamera =>
    'Este dispositivo no tiene cámara. Elige una foto de la galería',
    PhotoError.unknown => 'No se pudo abrir la foto. Inténtalo de nuevo',
    PhotoError.compressFailed =>
    'No se pudo comprimir la foto. Inténtalo de nuevo',
  };

  Future<Uint8List> _compressWithProgress(Uint8List bytes) async {
    final progress = ValueNotifier<double>(0);
    showDialog(
      context: context,
      barrierDismissible: false, // no se puede cerrar a mitad
      builder: (_) => AlertDialog(
        title: const Text('Preparando la foto'),
        content: ValueListenableBuilder<double>(
          valueListenable: progress,
          builder: (_, value, _) => LinearProgressIndicator(value: value),
        ),
      ),
    );
    try {
      return await _compressor.compress(
        bytes,
        onProgress: (p) => progress.value = p,
      );
    } finally {
      if (mounted) {
        Navigator.pop(context); // cierra el diálogo, salga bien o mal
      }
      progress.dispose();
    }
  }

  Widget _buildThumbnail(LiveSession s) => SizedBox(
    width: 48,
    height: 48,
    child: FutureBuilder<Proof?>(
      future: _proofFor(s),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(
            child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
          );
        }
        if (snap.hasError) {
          return const Icon(Icons.error_outline, semanticLabel: 'No se pudo cargar la prueba');
        }
        final proof = snap.data;
        if (proof == null) {
          return const Icon(Icons.photo_outlined, semanticLabel: 'Sin prueba');
        }
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.memory(proof.bytes, fit: BoxFit.cover, semanticLabel: 'Foto de prueba'),
        );
      },
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi historial'),
        actions: [
          if (_range != null)
            IconButton(
              tooltip: 'Quitar filtro de fechas',
              icon: const Icon(Icons.close),
              onPressed: _loading ? null : _clearRange,
            ),
          IconButton(
            tooltip: 'Filtrar por fechas',
            icon: const Icon(Icons.date_range),
            onPressed: _loading ? null : _pickRange,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_sessions.isEmpty) {
      if (_loading) return const Center(child: CircularProgressIndicator());
      if (_hasError) return Center(child: _buildError());
      return Center(
        child: Text(
          _range == null
              ? 'Todavía no has hecho ninguna sesión'
              : 'No hay sesiones entre esas fechas',
        ),
      );
    }
    return ListView.builder(
      itemCount: _sessions.length + 1, // +1: el pie con «Cargar más»
      itemBuilder: (context, i) {
        if (i == _sessions.length) return _buildFooter();
        final s = _sessions[i];
        return ListTile(
          leading: _buildThumbnail(s),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => SessionDetailScreen(session: s)),
          ),
          trailing: PopupMenuButton<_SessionAction>(
            tooltip: 'Opciones de la sesión',
            onSelected: (action) => _onAction(action, s),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: _SessionAction.proof,
                child: Text('Añadir prueba'),
              ),
              const PopupMenuItem(
                value: _SessionAction.edit,
                child: Text('Editar'),
              ),
              if (s.status == SessionStatus.active)
                const PopupMenuItem(
                  value: _SessionAction.finish,
                  child: Text('Terminar'),
                ),
              if (s.participantIds.length <= 1)
                const PopupMenuItem(
                  value: _SessionAction.delete,
                  child: Text('Borrar'),
                ),
            ],
          ),
          title: Text(s.description),
          subtitle: Text(
            '${_formatDate(s.startedAt)} · ${s.durationMinutes} min',
          ),
        );
      },
    );
  }

  Widget _buildFooter() {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (_hasError) return _buildError();
    if (!_hasMore) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: TextButton(
          onPressed: _loadPage,
          child: const Text('Cargar más'),
        ),
      ),
    );
  }

  Widget _buildError() => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      const Text('No se pudo cargar el historial'),
      TextButton(onPressed: _loadPage, child: const Text('Reintentar')),
    ],
  );
}
