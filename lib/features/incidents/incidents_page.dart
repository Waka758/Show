import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/repositories/providers.dart';
import '../shared/app_state.dart';
import '../shared/auth_providers.dart';

class IncidentsPage extends ConsumerWidget {
  const IncidentsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orgId = ref.watch(activeOrgIdProvider);
    final siteId = ref.watch(currentSiteIdProvider);
    final incidentsStream = ref.watch(incidentRepositoryProvider).watchIncidents(orgId, siteId);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Incidents'),
        actions: [
          IconButton(
            onPressed: () => context.go('/incidents/new'),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: StreamBuilder(
        stream: incidentsStream,
        builder: (context, snapshot) {
          final incidents = snapshot.data ?? [];
          if (incidents.isEmpty) {
            return const Center(child: Text('No incidents reported.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: incidents.length,
            itemBuilder: (context, index) {
              final incident = incidents[index];
              return Card(
                child: ListTile(
                  title: Text(incident.title),
                  subtitle: Text('${incident.category} · ${incident.severity}'),
                  trailing: Text(incident.status),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
