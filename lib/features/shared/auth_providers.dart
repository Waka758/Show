import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/org_user.dart';
import '../../data/repositories/providers.dart';
import '../../data/firebase/firebase_providers.dart';
import 'app_state.dart';

final authStateProvider = StreamProvider<User?>((ref) {
  final auth = ref.read(firebaseAuthProvider);
  return auth.authStateChanges();
});

final currentUserIdProvider = Provider<String?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.value?.uid;
});

final currentOrgUserProvider = StreamProvider<OrgUser?>((ref) {
  final orgId = ref.read(activeOrgIdProvider);
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) {
    return const Stream.empty();
  }
  return ref.read(orgRepositoryProvider).watchCurrentUser(orgId, userId);
});

final currentUserRoleProvider = Provider<String>((ref) {
  final user = ref.watch(currentOrgUserProvider).value;
  return user?.role ?? 'STAFF';
});

final currentSiteIdProvider = Provider<String?>((ref) {
  final user = ref.watch(currentOrgUserProvider).value;
  return user?.siteId;
});

final isSuperAdminProvider = StreamProvider<bool>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) {
    return Stream.value(false);
  }
  final firestore = ref.read(firestoreProvider);
  return firestore.collection('platformAdmins').doc(userId).snapshots().map((snapshot) {
    final data = snapshot.data();
    return snapshot.exists && (data?['active'] == true);
  });
});
