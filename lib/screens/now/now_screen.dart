import 'package:codo/models/live_session.dart';
import 'package:flutter/material.dart';
import 'package:codo/repositories/live_session_repository.dart';

class NowScreen extends StatefulWidget {
  const NowScreen({super.key});

  @override
  State<NowScreen> createState() => _NowScreenState();
}

class _NowScreenState extends State<NowScreen> {
  SessionCategory? _category; // null = «Recientes»
  late Stream<List<LiveSession>> _sessions;
  final _repository = LiveSessionRepository();

  @override
  void initState() {
    super.initState();
    _sessions = _load();
  }

  Stream<List<LiveSession>> _load() => _category == null
      ? _repository.watchRecentPublic()
      : _repository.watchPublicByCategory(_category!);

  void _select(SessionCategory? category) {
    if (category == _category) return;
    setState(() {
      _category = category;
      _sessions = _load();
    });
  }

  String _label(SessionCategory category) => switch (category) {
    SessionCategory.study => 'Estudiar',
    SessionCategory.train => 'Entrenar',
    SessionCategory.read => 'Leer',
    SessionCategory.work => 'Trabajar',
    SessionCategory.other => 'Otros',
  };

  Widget _chip(SessionCategory? category, String text) => Padding(
    padding: const EdgeInsets.only(right: 8),
    child: ChoiceChip(
      label: Text(text),
      selected: _category == category,
      onSelected: (_) => _select(category),
    ),
  );

  Widget _buildFilters() => SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    child: Row(
      children: [
        _chip(null, 'Recientes'),
        for (final c in SessionCategory.values) _chip(c, _label(c)),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildFilters(),
        Expanded(child: _buildList()),
      ],
    );
  }

  Widget _buildList() {
    return StreamBuilder<List<LiveSession>>(
      stream: _sessions,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('No se pudieron cargar las sesiones'),
                TextButton(
                  onPressed: () => setState(() => _sessions = _load()),
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          );
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final sessions = snapshot.data ?? const <LiveSession>[];
        if (sessions.isEmpty) {
          return const Center(
            child: Text('Ahora mismo no hay nadie con una sesión abierta'),
          );
        }
        return ListView.builder(
          itemCount: sessions.length,
          itemBuilder: (context, i) {
            final s = sessions[i];
            return ListTile(
              title: Text(s.description),
              subtitle: Text(
                '${s.creatorName} · ${_label(s.category)} · ${s.durationMinutes} min',
              ),
            );
          },
        );
      },
    );
  }
}
