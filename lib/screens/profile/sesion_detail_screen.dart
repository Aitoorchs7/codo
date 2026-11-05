import 'package:codo/models/live_session.dart';
import 'package:codo/models/proof.dart';
import 'package:codo/repositories/live_session_repository.dart';
import 'package:codo/repositories/session_failure.dart';
import 'package:flutter/material.dart';

class SessionDetailScreen extends StatefulWidget {
  const SessionDetailScreen({super.key, required this.session});

  final LiveSession session;

  @override
  State<SessionDetailScreen> createState() => _SessionDetailScreenState();
}

class _SessionDetailScreenState extends State<SessionDetailScreen> {
  final _repository = LiveSessionRepository();
  late Future<Proof?> _proof;

  @override
  void initState() {
    super.initState();
    _load();
  }

  // La prueba del creador; si no eres participante, las reglas la deniegan
  void _load() => _proof = _repository.getProof(widget.session.id, widget.session.creatorId);

  @override
  Widget build(BuildContext context) {
    final s = widget.session;
    final d = s.startedAt;
    return Scaffold(
      appBar: AppBar(title: const Text('Detalle de la sesión')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(s.description, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 4),
          Text('${d.day}/${d.month}/${d.year} · ${s.durationMinutes} min · '
              '${s.status == SessionStatus.active ? 'En curso' : 'Terminada'}'),
          const SizedBox(height: 16),
          Text('Prueba', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          FutureBuilder<Proof?>(
            future: _proof,
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snap.hasError) return _buildError(snap.error);
              final proof = snap.data;
              if (proof == null) return const Text('Todavía no hay prueba de esta sesión');
              return ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.memory(proof.bytes, fit: BoxFit.contain),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildError(Object? error) {
    // Sin permiso no es un fallo que se arregle reintentando
    final denied = error is SessionFailure && error.error == SessionError.permissionDenied;
    return Column(children: [
      Text(denied
          ? 'Solo los participantes de la sesión pueden ver la prueba'
          : 'No se pudo cargar la prueba'),
      if (!denied)
        TextButton(
          onPressed: () => setState(_load),   // nuevo Future → el FutureBuilder vuelve a cargar
          child: const Text('Reintentar'),
        ),
    ]);
  }
}