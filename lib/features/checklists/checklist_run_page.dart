import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

import '../../data/firebase/firebase_providers.dart';
import '../../data/models/checklist.dart';
import '../../data/models/checklist_run.dart';
import '../../data/repositories/providers.dart';
import '../shared/app_state.dart';
import '../shared/auth_providers.dart';

class ChecklistRunPage extends ConsumerStatefulWidget {
  const ChecklistRunPage({super.key, required this.checklistId});

  final String checklistId;

  @override
  ConsumerState<ChecklistRunPage> createState() => _ChecklistRunPageState();
}

class _ChecklistRunPageState extends ConsumerState<ChecklistRunPage> {
  final _notes = <String, TextEditingController>{};
  final _values = <String, TextEditingController>{};
  final _photos = <String, TextEditingController>{};
  final _status = <String, String>{};
  final _uploading = <String, bool>{};
  String? _runId;
  final _imagePicker = ImagePicker();

  @override
  void dispose() {
    for (final controller in _notes.values) {
      controller.dispose();
    }
    for (final controller in _values.values) {
      controller.dispose();
    }
    for (final controller in _photos.values) {
      controller.dispose();
    }
    super.dispose();
  }

  TextEditingController _controllerFor(Map<String, TextEditingController> map, String key) {
    return map.putIfAbsent(key, () => TextEditingController());
  }

  String _itemKey(ChecklistItem item) {
    return item.label.replaceAll(' ', '_').toLowerCase();
  }

  Future<void> _startRun(Checklist checklist) async {
    if (_runId != null) {
      return;
    }
    final orgId = ref.read(activeOrgIdProvider);
    final userId = ref.read(currentUserIdProvider) ?? '';
    final siteId = ref.read(currentSiteIdProvider) ?? '';
    final run = await ref.read(checklistRepositoryProvider).startRun(orgId, checklist, userId, siteId);
    setState(() => _runId = run.id);
  }

  Future<void> _saveItem(ChecklistItem item) async {
    if (_runId == null) {
      return;
    }
    final itemId = _itemKey(item);
    final status = _status[itemId] ?? 'DONE';
    final comment = _controllerFor(_notes, itemId).text;
    final valueText = _controllerFor(_values, itemId).text;
    final photoUrl = _controllerFor(_photos, itemId).text;

    final runItem = ChecklistRunItem(
      id: itemId,
      status: status,
      comment: comment.isEmpty ? null : comment,
      valueText: valueText.isEmpty ? null : valueText,
      photoUrl: photoUrl.isEmpty ? null : photoUrl,
      updatedAt: DateTime.now(),
    );
    await ref.read(checklistRepositoryProvider).updateRunItem(ref.read(activeOrgIdProvider), _runId!, runItem);
  }

  Future<void> _pickAndUploadPhoto(ChecklistItem item) async {
    if (_runId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Start a run first.')));
      }
      return;
    }
    final key = _itemKey(item);
    setState(() => _uploading[key] = true);
    final picked = await _imagePicker.pickImage(source: ImageSource.camera);
    if (picked == null) {
      setState(() => _uploading[key] = false);
      return;
    }
    final bytes = await picked.readAsBytes();
    final orgId = ref.read(activeOrgIdProvider);
    final storage = ref.read(firebaseStorageProvider);
    final refPath = storage.ref('orgs/$orgId/checklistRuns/${_runId!}/$key.jpg');
    await refPath.putData(bytes, SettableMetadata(contentType: 'image/jpeg'));
    final url = await refPath.getDownloadURL();
    _controllerFor(_photos, key).text = url;
    await _saveItem(item);
    setState(() => _uploading[key] = false);
  }

  Future<void> _completeRun(Checklist checklist) async {
    if (_runId == null) {
      return;
    }
    final missingComments = checklist.items.where((item) {
      final key = _itemKey(item);
      final status = _status[key] ?? 'DONE';
      final comment = _controllerFor(_notes, key).text;
      return item.isCritical && status == 'SKIPPED' && comment.trim().isEmpty;
    }).toList();
    final missingProof = checklist.items.where((item) {
      final key = _itemKey(item);
      final status = _status[key] ?? 'DONE';
      if (status != 'DONE') {
        return false;
      }
      final valueText = _controllerFor(_values, key).text;
      final photoUrl = _controllerFor(_photos, key).text;
      final missingValue = item.requiresValue && valueText.trim().isEmpty;
      final missingPhoto = item.requiresPhoto && photoUrl.trim().isEmpty;
      return missingValue || missingPhoto;
    }).toList();
    if (missingComments.isNotEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Add comments for all critical skipped items before completing.')),
        );
      }
      return;
    }
    if (missingProof.isNotEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Capture required photos/values for all completed items.')),
        );
      }
      return;
    }
    final completed = checklist.items.where((item) {
      final status = _status[_itemKey(item)] ?? 'DONE';
      return status == 'DONE';
    }).length;
    final completionPercent = checklist.items.isEmpty ? 0 : completed / checklist.items.length * 100;
    await ref.read(checklistRepositoryProvider).completeRun(ref.read(activeOrgIdProvider), _runId!, completionPercent);
    await ref.read(gamificationRepositoryProvider).recordChecklistCompletion(
          orgId: ref.read(activeOrgIdProvider),
          userId: ref.read(currentUserIdProvider) ?? '',
          siteId: ref.read(currentSiteIdProvider) ?? '',
          checklistRunId: _runId!,
          points: 25,
        );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Checklist completed! XP awarded.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final orgId = ref.watch(activeOrgIdProvider);
    final siteId = ref.watch(currentSiteIdProvider);
    final role = ref.watch(currentUserRoleProvider);
    final stream = ref.watch(checklistRepositoryProvider).watchChecklists(orgId, siteId, role);

    return Scaffold(
      appBar: AppBar(title: const Text('Checklist Run')),
      body: StreamBuilder<List<Checklist>>(
        stream: stream,
        builder: (context, snapshot) {
          final checklists = snapshot.data ?? [];
          final checklist = checklists.firstWhere(
            (item) => item.id == widget.checklistId,
            orElse: () => const Checklist(
              id: '',
              title: '',
              frequency: '',
              roleTarget: '',
              items: [],
              active: false,
              status: 'DRAFT',
              version: 1,
            ),
          );
          if (checklist.id.isEmpty) {
            return const Center(child: Text('Checklist not found.'));
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(checklist.title, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => _startRun(checklist),
                child: Text(_runId == null ? 'Start Run' : 'Run in Progress'),
              ),
              const SizedBox(height: 16),
              for (final item in checklist.items)
                _ChecklistItemCard(
                  item: item,
                  status: _status[_itemKey(item)] ?? 'DONE',
                  notesController: _controllerFor(_notes, _itemKey(item)),
                  valueController: _controllerFor(_values, _itemKey(item)),
                  photoController: _controllerFor(_photos, _itemKey(item)),
                  isUploading: _uploading[_itemKey(item)] ?? false,
                  onStatusChanged: (value) {
                    setState(() => _status[_itemKey(item)] = value ?? 'DONE');
                    _saveItem(item);
                  },
                  onFieldBlur: () => _saveItem(item),
                  onPhotoUpload: () => _pickAndUploadPhoto(item),
                ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => _completeRun(checklist),
                icon: const Icon(Icons.check_circle),
                label: const Text('Complete Run'),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ChecklistItemCard extends StatelessWidget {
  const _ChecklistItemCard({
    required this.item,
    required this.status,
    required this.notesController,
    required this.valueController,
    required this.photoController,
    required this.isUploading,
    required this.onStatusChanged,
    required this.onFieldBlur,
    required this.onPhotoUpload,
  });

  final ChecklistItem item;
  final String status;
  final TextEditingController notesController;
  final TextEditingController valueController;
  final TextEditingController photoController;
  final bool isUploading;
  final ValueChanged<String?> onStatusChanged;
  final VoidCallback onFieldBlur;
  final VoidCallback onPhotoUpload;

  @override
  Widget build(BuildContext context) {
    final requiresComment = item.isCritical && status == 'SKIPPED';
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item.label, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: status,
              items: const [
                DropdownMenuItem(value: 'DONE', child: Text('Done')),
                DropdownMenuItem(value: 'SKIPPED', child: Text('Skipped')),
              ],
              onChanged: onStatusChanged,
              decoration: const InputDecoration(labelText: 'Status'),
            ),
            if (item.requiresValue)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: TextField(
                  controller: valueController,
                  onEditingComplete: onFieldBlur,
                  decoration: const InputDecoration(labelText: 'Recorded value'),
                ),
              ),
            if (item.requiresPhoto)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: isUploading ? null : onPhotoUpload,
                          icon: isUploading
                              ? const SizedBox(
                                  height: 16,
                                  width: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.photo_camera),
                          label: const Text('Capture Photo'),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: photoController,
                            onEditingComplete: onFieldBlur,
                            decoration: const InputDecoration(labelText: 'Photo URL'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: TextField(
                controller: notesController,
                onEditingComplete: onFieldBlur,
                decoration: InputDecoration(
                  labelText: requiresComment ? 'Comment (required for critical skips)' : 'Comment',
                  suffixIcon: requiresComment ? const Icon(Icons.warning_amber) : null,
                ),
              ),
            ),
            if (requiresComment)
              const Padding(
                padding: EdgeInsets.only(top: 4),
                child: Text(
                  'Critical items skipped must include a comment before completion.',
                  style: TextStyle(color: Colors.redAccent),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
