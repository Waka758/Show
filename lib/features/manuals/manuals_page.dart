import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/repositories/providers.dart';
import '../shared/app_state.dart';

class ManualsPage extends ConsumerStatefulWidget {
  const ManualsPage({super.key});

  @override
  ConsumerState<ManualsPage> createState() => _ManualsPageState();
}

class _ManualsPageState extends ConsumerState<ManualsPage> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final orgId = ref.watch(activeOrgIdProvider);
    final manualStream = ref.watch(manualRepositoryProvider).watchManuals(orgId);
    final sopsStream = ref.watch(manualRepositoryProvider).searchSops(orgId, _searchController.text);

    return Scaffold(
      appBar: AppBar(title: const Text('Manuals & SOPs')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Search SOPs',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView(
                children: [
                  Text('Manuals', style: Theme.of(context).textTheme.titleMedium),
                  StreamBuilder(
                    stream: manualStream,
                    builder: (context, snapshot) {
                      final manuals = snapshot.data ?? [];
                      if (manuals.isEmpty) {
                        return const Text('No manuals yet.');
                      }
                      return Column(
                        children: manuals
                            .map(
                              (manual) => ListTile(
                                title: Text(manual.title),
                                subtitle: Text('${manual.status} · v${manual.version}'),
                              ),
                            )
                            .toList(),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  Text('SOP Search Results', style: Theme.of(context).textTheme.titleMedium),
                  StreamBuilder(
                    stream: sopsStream,
                    builder: (context, snapshot) {
                      final sops = snapshot.data ?? [];
                      if (sops.isEmpty) {
                        return const Text('Search for SOPs by title.');
                      }
                      return Column(
                        children: sops
                            .map(
                              (sop) => ListTile(
                                title: Text(sop.title),
                                subtitle: Text(sop.status),
                                trailing: const Icon(Icons.chevron_right),
                                onTap: () => context.go('/sops/${sop.id}'),
                              ),
                            )
                            .toList(),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
