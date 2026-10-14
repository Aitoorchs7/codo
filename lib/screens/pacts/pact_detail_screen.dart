import 'package:codo/models/pact.dart';
import 'package:flutter/material.dart';

class PactDetailArgs {
  const PactDetailArgs({required this.pact});

  final Pact pact;
}

class PactDetailScreen extends StatelessWidget {
  const PactDetailScreen({super.key, required this.args});

  final PactDetailArgs args;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: Text(args.pact.title)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(args.pact.title, style: textTheme.titleMedium),
            const SizedBox(height: 4),
            Text("Con ${args.pact.partnerName}", style: textTheme.bodyMedium),
            const SizedBox(height: 12),
            LinearProgressIndicator(value: args.pact.progress),
            const SizedBox(height: 8),
            Text(
              "${args.pact.daysDone} / ${args.pact.daysTotal} días",
              style: textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
