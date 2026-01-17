import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/providers.dart';
import '../shared/app_state.dart';
import '../shared/auth_providers.dart';

class AdminPage extends ConsumerStatefulWidget {
  const AdminPage({super.key});

  @override
  ConsumerState<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends ConsumerState<AdminPage> {
  final _userFormKey = GlobalKey<FormState>();
  final _siteFormKey = GlobalKey<FormState>();
  final _userNameController = TextEditingController();
  final _siteNameController = TextEditingController();
  final _timezoneController = TextEditingController(text: 'America/Chicago');
  final _orgIdController = TextEditingController();
  String _role = 'STAFF';
  String? _selectedSiteId;

  @override
  void dispose() {
    _userNameController.dispose();
    _siteNameController.dispose();
    _timezoneController.dispose();
    _orgIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final orgId = ref.watch(activeOrgIdProvider);
    final role = ref.watch(currentUserRoleProvider);
    final isSuperAdmin = ref.watch(isSuperAdminProvider).value ?? false;
    final canAccessAdmin = role == 'OWNER' || role == 'ADMIN' || isSuperAdmin;
    if (isSuperAdmin && _orgIdController.text.isEmpty) {
      _orgIdController.text = orgId;
    }

    final manualsStream = ref.watch(manualRepositoryProvider).watchManuals(orgId);
    final sopsStream = ref.watch(manualRepositoryProvider).watchSops(orgId);
    final checklistsStream = ref.watch(checklistRepositoryProvider).watchAllChecklists(orgId);
    final usersStream = ref.watch(orgRepositoryProvider).watchUsers(orgId);
    final sitesStream = ref.watch(orgRepositoryProvider).watchSites(orgId);
    final subscriptionStream = ref.watch(orgRepositoryProvider).watchSubscription(orgId);

    if (!canAccessAdmin) {
      return Scaffold(
        appBar: AppBar(title: const Text('Admin Console')),
        body: const Center(child: Text('Admin access required.')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Admin Console')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (isSuperAdmin) ...[
            Text('Platform Super Admin', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            TextFormField(
              controller: _orgIdController,
              decoration: const InputDecoration(
                labelText: 'Active org ID',
                helperText: 'Switch which org is currently loaded in the app.',
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: FilledButton(
                onPressed: () {
                  final nextOrgId = _orgIdController.text.trim();
                  if (nextOrgId.isNotEmpty) {
                    ref.read(activeOrgIdStateProvider.notifier).state = nextOrgId;
                    FocusScope.of(context).unfocus();
                  }
                },
                child: const Text('Set Active Org'),
              ),
            ),
            const SizedBox(height: 16),
          ],
          Text('Plan & Credits', style: Theme.of(context).textTheme.titleMedium),
          StreamBuilder(
            stream: subscriptionStream,
            builder: (context, snapshot) {
              final subscription = snapshot.data;
              if (subscription == null) {
                return const Text('No subscription found.');
              }
              return Card(
                child: ListTile(
                  title: Text(subscription.plan),
                  subtitle: Text('Credits remaining: ${subscription.aiCreditsRemaining}'),
                  trailing: Text(subscription.status),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          Text('Draft Approvals', style: Theme.of(context).textTheme.titleMedium),
          StreamBuilder(
            stream: manualsStream,
            builder: (context, snapshot) {
              final manuals = snapshot.data ?? [];
              final drafts = manuals.where((manual) => manual.isDraft).toList();
              if (drafts.isEmpty) {
                return const Text('No manuals awaiting approval.');
              }
              return Column(
                children: drafts
                    .map(
                      (manual) => Card(
                        child: ListTile(
                          title: Text(manual.title),
                          subtitle: const Text('Manual · DRAFT'),
                          trailing: FilledButton(
                            onPressed: () async {
                              await ref
                                  .read(manualRepositoryProvider)
                                  .updateManualStatus(orgId, manual.id, 'PUBLISHED');
                            },
                            child: const Text('Publish'),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              );
            },
          ),
          StreamBuilder(
            stream: sopsStream,
            builder: (context, snapshot) {
              final sops = snapshot.data ?? [];
              final drafts = sops.where((sop) => sop.status == 'DRAFT').toList();
              if (drafts.isEmpty) {
                return const SizedBox.shrink();
              }
              return Column(
                children: drafts
                    .map(
                      (sop) => Card(
                        child: ListTile(
                          title: Text(sop.title),
                          subtitle: const Text('SOP · DRAFT'),
                          trailing: FilledButton(
                            onPressed: () async {
                              await ref
                                  .read(manualRepositoryProvider)
                                  .updateSopStatus(orgId, sop.id, 'PUBLISHED');
                            },
                            child: const Text('Publish'),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              );
            },
          ),
          StreamBuilder(
            stream: checklistsStream,
            builder: (context, snapshot) {
              final checklists = snapshot.data ?? [];
              final drafts = checklists.where((checklist) => checklist.status == 'DRAFT').toList();
              if (drafts.isEmpty) {
                return const SizedBox.shrink();
              }
              return Column(
                children: drafts
                    .map(
                      (checklist) => Card(
                        child: ListTile(
                          title: Text(checklist.title),
                          subtitle: const Text('Checklist · DRAFT'),
                          trailing: FilledButton(
                            onPressed: () async {
                              await ref
                                  .read(checklistRepositoryProvider)
                                  .updateChecklistStatus(orgId, checklist.id, 'PUBLISHED');
                            },
                            child: const Text('Publish'),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              );
            },
          ),
          const SizedBox(height: 16),
          Text('Manage Users', style: Theme.of(context).textTheme.titleMedium),
          StreamBuilder(
            stream: usersStream,
            builder: (context, snapshot) {
              final users = snapshot.data ?? [];
              return Column(
                children: users
                    .map(
                      (user) => ListTile(
                        title: Text(user.fullName),
                        subtitle: Text(user.role),
                        trailing: Text(user.siteId ?? 'All sites'),
                      ),
                    )
                    .toList(),
              );
            },
          ),
          const SizedBox(height: 8),
          Form(
            key: _userFormKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _userNameController,
                  decoration: const InputDecoration(labelText: 'Full name'),
                  validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 8),
                StreamBuilder(
                  stream: sitesStream,
                  builder: (context, snapshot) {
                    final sites = snapshot.data ?? [];
                    return DropdownButtonFormField<String?>(
                      value: _selectedSiteId,
                      items: [
                        const DropdownMenuItem(value: null, child: Text('All sites')),
                        ...sites
                            .map((site) => DropdownMenuItem(value: site.id, child: Text(site.name)))
                            .toList(),
                      ],
                      onChanged: (value) => setState(() => _selectedSiteId = value),
                      decoration: const InputDecoration(labelText: 'Site assignment'),
                    );
                  },
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _role,
                  items: const [
                    DropdownMenuItem(value: 'OWNER', child: Text('OWNER')),
                    DropdownMenuItem(value: 'ADMIN', child: Text('ADMIN')),
                    DropdownMenuItem(value: 'SITE_MANAGER', child: Text('SITE_MANAGER')),
                    DropdownMenuItem(value: 'STAFF', child: Text('STAFF')),
                  ],
                  onChanged: (value) => setState(() => _role = value ?? 'STAFF'),
                  decoration: const InputDecoration(labelText: 'Role'),
                ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () async {
                    if (!_userFormKey.currentState!.validate()) {
                      return;
                    }
                    await ref.read(orgRepositoryProvider).createUser(
                          orgId: orgId,
                          fullName: _userNameController.text,
                          role: _role,
                          siteId: _selectedSiteId,
                        );
                    _userNameController.clear();
                    setState(() => _selectedSiteId = null);
                  },
                  child: const Text('Add User'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text('Sites', style: Theme.of(context).textTheme.titleMedium),
          StreamBuilder(
            stream: sitesStream,
            builder: (context, snapshot) {
              final sites = snapshot.data ?? [];
              return Column(
                children: sites
                    .map(
                      (site) => ListTile(
                        title: Text(site.name),
                        subtitle: Text(site.timezone),
                      ),
                    )
                    .toList(),
              );
            },
          ),
          const SizedBox(height: 8),
          Form(
            key: _siteFormKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _siteNameController,
                  decoration: const InputDecoration(labelText: 'Site name'),
                  validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _timezoneController,
                  decoration: const InputDecoration(labelText: 'Timezone'),
                  validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () async {
                    if (!_siteFormKey.currentState!.validate()) {
                      return;
                    }
                    await ref.read(orgRepositoryProvider).createSite(
                          orgId: orgId,
                          name: _siteNameController.text,
                          timezone: _timezoneController.text,
                        );
                    _siteNameController.clear();
                  },
                  child: const Text('Add Site'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
