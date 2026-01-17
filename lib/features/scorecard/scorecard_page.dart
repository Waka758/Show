import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/firebase/firebase_providers.dart';
import '../shared/app_state.dart';
import '../shared/auth_providers.dart';

class ScorecardPage extends ConsumerWidget {
  const ScorecardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orgId = ref.watch(activeOrgIdProvider);
    final userId = ref.watch(currentUserIdProvider);
    final firestore = ref.watch(firestoreProvider);
    final checklistRunsStream =
        firestore.collection('orgs').doc(orgId).collection('checklistRuns').snapshots();
    final incidentsStream = firestore.collection('orgs').doc(orgId).collection('incidents').snapshots();
    final tasksStream = firestore.collection('orgs').doc(orgId).collection('tasks').snapshots();
    final userStatsStream = userId == null
        ? const Stream<DocumentSnapshot<Map<String, dynamic>>>.empty()
        : firestore.collection('orgs').doc(orgId).collection('userStats').doc(userId).snapshots();

    return Scaffold(
      appBar: AppBar(title: const Text('Scorecard')),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: checklistRunsStream,
        builder: (context, runSnapshot) {
          final runs = runSnapshot.data?.docs ?? [];
          return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: incidentsStream,
            builder: (context, incidentSnapshot) {
              final incidents = incidentSnapshot.data?.docs ?? [];
              return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: tasksStream,
                builder: (context, taskSnapshot) {
                  final tasks = taskSnapshot.data?.docs ?? [];
                  return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                    stream: userStatsStream,
                    builder: (context, statsSnapshot) {
                      final now = DateTime.now();
                      final cutoff = now.subtract(const Duration(days: 7));
                      final recentRuns = runs.where((doc) {
                        final runDate = _parseDate(doc.data()['runDate']);
                        return runDate != null && runDate.isAfter(cutoff);
                      }).toList();
                      final completionAverage = recentRuns.isEmpty
                          ? 0
                          : recentRuns
                                  .map((doc) => (doc.data()['completionPercent'] as num?) ?? 0)
                                  .reduce((a, b) => a + b) /
                              recentRuns.length;
                      final recentIncidents = incidents.where((doc) {
                        final createdAt = _parseDate(doc.data()['createdAt']);
                        return createdAt != null && createdAt.isAfter(cutoff);
                      }).length;
                      final recentTasks = tasks.where((doc) {
                        final createdAt = _parseDate(doc.data()['createdAt']);
                        return createdAt != null && createdAt.isAfter(cutoff);
                      }).length;
                      final stats = statsSnapshot.data?.data() ?? {};
                      final xpTotal = stats['xpTotal'] ?? 0;
                      final streakDays = stats['streakDays'] ?? 0;

                      return ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          Text('7-Day Metrics', style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 12),
                          _MetricCard(
                            title: 'Checklist Completion',
                            value: '${completionAverage.toStringAsFixed(0)}%',
                          ),
                          _MetricCard(title: 'Checklist Runs', value: '${recentRuns.length}'),
                          _MetricCard(title: 'Incidents Logged', value: '$recentIncidents'),
                          _MetricCard(title: 'Tasks Created', value: '$recentTasks'),
                          _MetricCard(title: 'XP Total', value: '$xpTotal XP'),
                          _MetricCard(title: 'Streak Days', value: '$streakDays'),
                        ],
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(title),
        trailing: Text(value, style: Theme.of(context).textTheme.titleMedium),
      ),
    );
  }
}

DateTime? _parseDate(dynamic value) {
  if (value == null) {
    return null;
  }
  if (value is Timestamp) {
    return value.toDate();
  }
  if (value is String) {
    return DateTime.tryParse(value);
  }
  return null;
}
