import 'package:codo/models/pact.dart';
import 'package:codo/repositories/pact_repository.dart';
import 'package:flutter/material.dart';

class PactsScreen extends StatefulWidget {
  const PactsScreen({super.key,});

  @override
  State<PactsScreen> createState() => _PactsScreenState();
}

class _PactsScreenState extends State<PactsScreen> {
  final _repository = PactRepository();
  late Stream<List<Pact>> _pacts;

  @override
  void initState() {
    super.initState();
    _pacts = _repository.watchPacts();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: StreamBuilder<List<Pact>>(
        stream: _pacts,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('No se pudieron cargar los pactos.'),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () => setState(() => _pacts = _repository.watchPacts()),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final pacts = snapshot.data ?? [];
          if (pacts.isEmpty) {
            return const Center(child: Text('Todavía no hay pactos.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: pacts.length,
            itemBuilder: (context, index) => _PactCard(pact: pacts[index]),
          );
        },
      ),
    );
  }
}

class _PactCard extends StatelessWidget {
  const _PactCard({ required this.pact});
  final Pact pact;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Card(
        child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(pact.title, style: textTheme.titleMedium),
                const SizedBox(height: 4),
                Text("Con ${pact.partnerName}", style: textTheme.bodyMedium),
                const SizedBox(height: 12),
                LinearProgressIndicator(value: pact.progress),
                const SizedBox(height: 8),
                Text("${pact.daysDone} / ${pact.daysTotal} días",
                    style: textTheme.bodySmall),
              ],
            )
        )
    );
  }
}