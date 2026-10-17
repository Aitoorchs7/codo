import 'package:codo/models/medal.dart';
import 'package:codo/repositories/medal_repository.dart';
import 'package:codo/widgets/glass_button.dart';
import 'package:flutter/material.dart';

class MedalGrid extends StatefulWidget {
  const MedalGrid({super.key});

  @override
  State<MedalGrid> createState() => _MedalGridState();
}

class _MedalGridState extends State<MedalGrid> {
  final _repository = MedalRepository();
  late Stream<List<Medal>> _medals;

  @override
  void initState() {
    super.initState();
    _medals = _repository.watchMedals();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Medal>>(
        stream: _medals,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('No se pudieron cargar las medallas.'),
                  const SizedBox(height: 12),
                  GlassButton(
                    primary: true,
                    onPressed: () => setState(() => _medals = _repository.watchMedals()),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final medals = snapshot.data ?? [];
          if (medals.isEmpty) {
            return const Center(child: Text('Todavía no hay medallas.'));
          }
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 160,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.8,
            ),
            itemCount: medals.length,
            itemBuilder: (context, index) => _MedalCard(medal: medals[index]),
          );
        },
    );
  }
}

class _MedalCard extends StatelessWidget {
  const _MedalCard({required this.medal});

  final Medal medal;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Image.network(
              medal.imageUrl,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return const Center(child: CircularProgressIndicator());
              },
              errorBuilder: (context, error, stackTrace) =>
              const Center(child: Icon(Icons.emoji_events_outlined)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  medal.name,
                  style: textTheme.titleSmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                Text('${medal.xpReward} XP', style: textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}