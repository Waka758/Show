import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/repositories/providers.dart';
import '../shared/app_state.dart';
import '../shared/auth_providers.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orgId = ref.watch(activeOrgIdProvider);
    final siteId = ref.watch(currentSiteIdProvider);
    final role = ref.watch(currentUserRoleProvider);
    final isSuperAdmin = ref.watch(isSuperAdminProvider).value ?? false;
    final canAccessAdmin = role == 'OWNER' || role == 'ADMIN' || isSuperAdmin;

    final checklistsStream = ref.watch(checklistRepositoryProvider).watchChecklists(orgId, siteId, role);
    final tasksStream = ref.watch(taskRepositoryProvider).watchTasks(orgId, siteId);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Today's Playbook"),
        actions: [
          if (canAccessAdmin)
            IconButton(
              onPressed: () => context.go('/admin'),
              icon: const Icon(Icons.admin_panel_settings),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Streak', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  const Text('🔥 4-day completion streak'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text('Assigned Checklists', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          StreamBuilder(
            stream: checklistsStream,
            builder: (context, snapshot) {
              final items = snapshot.data ?? [];
              if (items.isEmpty) {
                return const Text('No checklists assigned yet.');
              }
              return Column(
                children: items
                    .map(
                      (checklist) => ListTile(
                        title: Text(checklist.title),
                        subtitle: Text('Frequency: ${checklist.frequency}'),
                        trailing: ElevatedButton(
                          onPressed: () => context.go('/checklists/run/${checklist.id}'),
                          child: const Text('Start'),
                        ),
                      ),
                    )
                    .toList(),
              );
            },
          ),
          const SizedBox(height: 16),
          Text('Open Tasks', style: Theme.of(context).textTheme.titleMedium),
          StreamBuilder(
            stream: tasksStream,
            builder: (context, snapshot) {
              final items = snapshot.data ?? [];
              if (items.isEmpty) {
                return const Text('No open tasks.');
              }
              return Column(
                children: items
                    .map(
                      (task) => ListTile(
                        title: Text(task.title),
                        subtitle: Text(task.status),
                      ),
                    )
                    .toList(),
              );
            },
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => context.go('/incidents/new'),
            icon: const Icon(Icons.report),
            label: const Text('Quick Incident'),
          ),
        ],
      ),
    );
  }
}
