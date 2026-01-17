import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/providers.dart';
import '../shared/app_state.dart';

class SopDetailPage extends ConsumerWidget {
  const SopDetailPage({super.key, required this.sopId});

  final String sopId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orgId = ref.watch(activeOrgIdProvider);
    final sopFuture = ref.watch(manualRepositoryProvider).fetchSop(orgId, sopId);

    return Scaffold(
      appBar: AppBar(title: const Text('SOP Detail')),
      body: FutureBuilder(
        future: sopFuture,
        builder: (context, snapshot) {
          final sop = snapshot.data;
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (sop == null) {
            return const Center(child: Text('SOP not found.'));
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(sop.title, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text(sop.purpose),
              const SizedBox(height: 12),
              Text('Scope', style: Theme.of(context).textTheme.titleMedium),
              Text(sop.scope),
              const SizedBox(height: 12),
              Text('Steps', style: Theme.of(context).textTheme.titleMedium),
              for (final step in sop.steps)
                ListTile(
                  leading: const Icon(Icons.check_circle_outline),
                  title: Text(step),
                ),
              const SizedBox(height: 12),
              Text('Standards', style: Theme.of(context).textTheme.titleMedium),
              Text(sop.standards),
              const SizedBox(height: 12),
              Text('Common Failures', style: Theme.of(context).textTheme.titleMedium),
              for (final failure in sop.commonFailures) Text('• $failure'),
              const SizedBox(height: 12),
              Text('Escalation Triggers', style: Theme.of(context).textTheme.titleMedium),
              for (final trigger in sop.escalationTriggers) Text('• $trigger'),
            ],
          );
        },
      ),
    );
  }
}
