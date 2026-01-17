import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../../data/models/incident.dart';
import '../../data/repositories/providers.dart';
import '../../data/firebase/firebase_providers.dart';
import '../shared/app_state.dart';
import '../shared/auth_providers.dart';

class NewIncidentPage extends ConsumerStatefulWidget {
  const NewIncidentPage({super.key});

  @override
  ConsumerState<NewIncidentPage> createState() => _NewIncidentPageState();
}

class _NewIncidentPageState extends ConsumerState<NewIncidentPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _containmentController = TextEditingController();
  String _category = 'Safety';
  String _severity = 'Medium';
  final _imagePicker = ImagePicker();
  String? _photoUrl;
  bool _uploading = false;
  String? _draftIncidentId;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _containmentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final incidentId = _draftIncidentId ?? const Uuid().v4();
    final orgId = ref.read(activeOrgIdProvider);
    final siteId = ref.read(currentSiteIdProvider) ?? '';
    final userId = ref.read(currentUserIdProvider) ?? '';
    final incident = Incident(
      id: incidentId,
      siteId: siteId,
      createdBy: userId,
      category: _category,
      severity: _severity,
      title: _titleController.text,
      description: _descriptionController.text,
      photoUrl: _photoUrl,
      containmentSteps: _containmentController.text,
      status: 'OPEN',
      createdAt: DateTime.now(),
    );
    await ref.read(incidentRepositoryProvider).createIncident(orgId, incident);
    if (mounted) {
      context.go('/incidents');
    }
  }

  Future<void> _pickAndUploadPhoto() async {
    setState(() => _uploading = true);
    final picked = await _imagePicker.pickImage(source: ImageSource.camera);
    if (picked == null) {
      setState(() => _uploading = false);
      return;
    }
    _draftIncidentId ??= const Uuid().v4();
    final bytes = await picked.readAsBytes();
    final orgId = ref.read(activeOrgIdProvider);
    final storage = ref.read(firebaseStorageProvider);
    final refPath = storage.ref('orgs/$orgId/incidents/${_draftIncidentId!}/photo.jpg');
    await refPath.putData(bytes, SettableMetadata(contentType: 'image/jpeg'));
    final url = await refPath.getDownloadURL();
    setState(() {
      _photoUrl = url;
      _uploading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Incident')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (value) => value == null || value.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _category,
                items: const [
                  DropdownMenuItem(value: 'Safety', child: Text('Safety')),
                  DropdownMenuItem(value: 'Quality', child: Text('Quality')),
                  DropdownMenuItem(value: 'Operational', child: Text('Operational')),
                ],
                onChanged: (value) => setState(() => _category = value ?? 'Safety'),
                decoration: const InputDecoration(labelText: 'Category'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _severity,
                items: const [
                  DropdownMenuItem(value: 'Low', child: Text('Low')),
                  DropdownMenuItem(value: 'Medium', child: Text('Medium')),
                  DropdownMenuItem(value: 'High', child: Text('High')),
                ],
                onChanged: (value) => setState(() => _severity = value ?? 'Medium'),
                decoration: const InputDecoration(labelText: 'Severity'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 4,
                validator: (value) => value == null || value.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: _uploading ? null : _pickAndUploadPhoto,
                    icon: _uploading
                        ? const SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.photo_camera),
                    label: const Text('Add Photo'),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(_photoUrl == null ? 'No photo uploaded yet.' : 'Photo ready'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _containmentController,
                decoration: const InputDecoration(labelText: 'Containment Steps'),
                maxLines: 3,
                validator: (value) => value == null || value.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _submit,
                icon: const Icon(Icons.save),
                label: const Text('Save Incident'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
