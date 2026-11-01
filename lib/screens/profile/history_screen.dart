import 'package:codo/admins/auth_service.dart';
import 'package:codo/models/live_session.dart';
import 'package:codo/repositories/live_session_repository.dart';
import 'package:flutter/material.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final _repository = LiveSessionRepository();
  final List<LiveSession> _sessions = [];   // se va ampliando con cada página
  bool _loading = true;
  bool _hasError = false;
  bool _hasMore = true;
  DateTimeRange? _range;   // null = historial paginado

  @override
  void initState() {
    super.initState();
    _loadPage();
  }

  Future<void> _loadPage({bool reset = false}) async {
    setState(() {
      if (reset) _sessions.clear();   // filtro nuevo: empezar de cero
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
            uid, range.start, range.end.add(const Duration(days: 1)));
      if (!mounted) return;
      setState(() {
        _sessions.addAll(page);
        // Si llega una página incompleta, ya no quedan más
        _hasMore = range == null && page.length == LiveSessionRepository.historyPageSize;
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
    if (picked == null || !mounted) return;   // canceló o salió de la pantalla
    _range = picked;
    _loadPage(reset: true);
  }

  void _clearRange() {
    _range = null;
    _loadPage(reset: true);
  }

  String _formatDate(DateTime d) => '${d.day}/${d.month}/${d.year}';

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
        child: Text(_range == null
            ? 'Todavía no has hecho ninguna sesión'
            : 'No hay sesiones entre esas fechas'),
      );
    }
    return ListView.builder(
      itemCount: _sessions.length + 1,   // +1: el pie con «Cargar más»
      itemBuilder: (context, i) {
        if (i == _sessions.length) return _buildFooter();
        final s = _sessions[i];
        return ListTile(
          title: Text(s.description),
          subtitle: Text('${_formatDate(s.startedAt)} · ${s.durationMinutes} min'),
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
        child: TextButton(onPressed: _loadPage, child: const Text('Cargar más')),
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