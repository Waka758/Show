import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../firebase/firebase_providers.dart';
import '../firebase/firestore_repositories.dart';
import 'repository_interfaces.dart';

final orgRepositoryProvider = Provider<OrgRepository>((ref) {
  return FirestoreOrgRepository(ref.read(firestoreProvider), FirebaseFunctions.instance);
});

final manualRepositoryProvider = Provider<ManualRepository>((ref) {
  return FirestoreManualRepository(ref.read(firestoreProvider));
});

final checklistRepositoryProvider = Provider<ChecklistRepository>((ref) {
  return FirestoreChecklistRepository(ref.read(firestoreProvider));
});

final incidentRepositoryProvider = Provider<IncidentRepository>((ref) {
  return FirestoreIncidentRepository(ref.read(firestoreProvider));
});

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return FirestoreTaskRepository(ref.read(firestoreProvider));
});

final gamificationRepositoryProvider = Provider<GamificationRepository>((ref) {
  return FirestoreGamificationRepository(ref.read(firestoreProvider));
});

final aiGenerationRepositoryProvider = Provider<AiGenerationRepository>((ref) {
  return FirestoreAiGenerationRepository(FirebaseFunctions.instance);
});
