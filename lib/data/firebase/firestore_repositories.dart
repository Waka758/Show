import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';

import '../models/checklist.dart';
import '../models/checklist_run.dart';
import '../models/incident.dart';
import '../models/manual.dart';
import '../models/org_user.dart';
import '../models/sop.dart';
import '../models/site.dart';
import '../models/subscription.dart';
import '../models/task.dart';
import '../repositories/repository_interfaces.dart';

class FirestoreOrgRepository implements OrgRepository {
  FirestoreOrgRepository(this.firestore, this.functions);

  final FirebaseFirestore firestore;
  final FirebaseFunctions functions;

  @override
  Stream<OrgUser?> watchCurrentUser(String orgId, String userId) {
    return firestore.collection('orgs').doc(orgId).collection('users').doc(userId).snapshots().map(
          (snapshot) =>
              snapshot.data() == null ? null : OrgUser.fromMap(snapshot.id, snapshot.data()!),
        );
  }

  @override
  Stream<Subscription?> watchSubscription(String orgId) {
    return firestore.collection('subscriptions').doc(orgId).snapshots().map(
          (snapshot) => snapshot.data() == null ? null : Subscription.fromMap(snapshot.data()!),
        );
  }

  @override
  Stream<List<OrgUser>> watchUsers(String orgId) {
    return firestore
        .collection('orgs')
        .doc(orgId)
        .collection('users')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => OrgUser.fromMap(doc.id, doc.data())).toList());
  }

  @override
  Stream<List<Site>> watchSites(String orgId) {
    return firestore
        .collection('orgs')
        .doc(orgId)
        .collection('sites')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Site.fromMap(doc.id, doc.data())).toList());
  }

  @override
  Future<void> createOrgSetup(String orgId, String industryKey, Map<String, dynamic> answers) {
    return firestore.collection('orgs').doc(orgId).collection('orgSetup').doc('default').set({
      'industryKey': industryKey,
      'answersMap': answers,
      'createdAt': DateTime.now().toIso8601String(),
    });
  }

  @override
  Future<void> ensureUserProfile({
    required String orgId,
    required String userId,
    required String fullName,
    required String role,
    String? siteId,
  }) async {
    final userRef = firestore.collection('orgs').doc(orgId).collection('users').doc(userId);
    final snapshot = await userRef.get();
    if (snapshot.exists) {
      return;
    }
    await userRef.set({
      'fullName': fullName,
      'role': role,
      'siteId': siteId,
      'createdAt': DateTime.now().toIso8601String(),
    });
  }

  @override
  Future<void> createUser({
    required String orgId,
    required String fullName,
    required String role,
    String? siteId,
  }) async {
    final userRef = firestore.collection('orgs').doc(orgId).collection('users').doc();
    await userRef.set({
      'fullName': fullName,
      'role': role,
      'siteId': siteId,
      'createdAt': DateTime.now().toIso8601String(),
    });
  }

  @override
  Future<void> createSite({
    required String orgId,
    required String name,
    required String timezone,
  }) async {
    final siteRef = firestore.collection('orgs').doc(orgId).collection('sites').doc();
    await siteRef.set({
      'name': name,
      'timezone': timezone,
    });
  }

  Future<void> triggerIndustryGeneration({
    required String orgId,
    required String industryKey,
    required Map<String, dynamic> answers,
  }) async {
    final callable = functions.httpsCallable('generateIndustryStarterPack');
    await callable.call({
      'orgId': orgId,
      'industryKey': industryKey,
      'answersMap': answers,
    });
  }
}

class FirestoreManualRepository implements ManualRepository {
  FirestoreManualRepository(this.firestore);

  final FirebaseFirestore firestore;

  @override
  Stream<List<Manual>> watchManuals(String orgId) {
    return firestore
        .collection('orgs')
        .doc(orgId)
        .collection('manuals')
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Manual.fromMap(doc.id, doc.data())).toList());
  }

  @override
  Stream<List<Sop>> watchSops(String orgId) {
    return firestore
        .collection('orgs')
        .doc(orgId)
        .collection('sops')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Sop.fromMap(doc.id, doc.data())).toList());
  }

  @override
  Stream<List<Sop>> searchSops(String orgId, String query) {
    return firestore
        .collection('orgs')
        .doc(orgId)
        .collection('sops')
        .where('title', isGreaterThanOrEqualTo: query)
        .where('title', isLessThanOrEqualTo: '$query\uf8ff')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Sop.fromMap(doc.id, doc.data())).toList());
  }

  @override
  Future<Sop?> fetchSop(String orgId, String sopId) async {
    final snapshot = await firestore.collection('orgs').doc(orgId).collection('sops').doc(sopId).get();
    if (!snapshot.exists) {
      return null;
    }
    return Sop.fromMap(snapshot.id, snapshot.data()!);
  }

  @override
  Future<void> updateManualStatus(String orgId, String manualId, String status) {
    return firestore.collection('orgs').doc(orgId).collection('manuals').doc(manualId).set({
      'status': status,
      'updatedAt': DateTime.now().toIso8601String(),
    }, SetOptions(merge: true));
  }

  @override
  Future<void> updateSopStatus(String orgId, String sopId, String status) {
    return firestore.collection('orgs').doc(orgId).collection('sops').doc(sopId).set({
      'status': status,
      'updatedAt': DateTime.now().toIso8601String(),
    }, SetOptions(merge: true));
  }
}

class FirestoreChecklistRepository implements ChecklistRepository {
  FirestoreChecklistRepository(this.firestore);

  final FirebaseFirestore firestore;

  @override
  Stream<List<Checklist>> watchChecklists(String orgId, String? siteId, String role) {
    var query = firestore.collection('orgs').doc(orgId).collection('checklists').where('active', isEqualTo: true);
    if (siteId != null) {
      query = query.where('siteId', isEqualTo: siteId);
    }
    if (role != 'OWNER' && role != 'ADMIN') {
      query = query.where('roleTarget', isEqualTo: role);
    }
    return query.snapshots().map(
          (snapshot) => snapshot.docs.map((doc) => Checklist.fromMap(doc.id, doc.data())).toList(),
        );
  }

  @override
  Stream<List<Checklist>> watchAllChecklists(String orgId) {
    return firestore
        .collection('orgs')
        .doc(orgId)
        .collection('checklists')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Checklist.fromMap(doc.id, doc.data())).toList());
  }

  @override
  Future<void> updateChecklistStatus(String orgId, String checklistId, String status) {
    return firestore.collection('orgs').doc(orgId).collection('checklists').doc(checklistId).set({
      'status': status,
      'version': FieldValue.increment(1),
    }, SetOptions(merge: true));
  }

  @override
  Future<ChecklistRun> startRun(String orgId, Checklist checklist, String userId, String siteId) async {
    final doc = firestore.collection('orgs').doc(orgId).collection('checklistRuns').doc();
    final run = ChecklistRun(
      id: doc.id,
      checklistId: checklist.id,
      siteId: siteId,
      runDate: DateTime.now(),
      startedBy: userId,
      completionPercent: 0,
    );
    await doc.set(run.toMap());
    return run;
  }

  @override
  Future<void> updateRunItem(String orgId, String runId, ChecklistRunItem item) {
    return firestore
        .collection('orgs')
        .doc(orgId)
        .collection('checklistRuns')
        .doc(runId)
        .collection('items')
        .doc(item.id)
        .set(item.toMap(), SetOptions(merge: true));
  }

  @override
  Future<void> completeRun(String orgId, String runId, double completionPercent) {
    return firestore.collection('orgs').doc(orgId).collection('checklistRuns').doc(runId).set({
      'completedAt': DateTime.now().toIso8601String(),
      'completionPercent': completionPercent,
    }, SetOptions(merge: true));
  }
}

class FirestoreIncidentRepository implements IncidentRepository {
  FirestoreIncidentRepository(this.firestore);

  final FirebaseFirestore firestore;

  @override
  Stream<List<Incident>> watchIncidents(String orgId, String? siteId) {
    var query = firestore.collection('orgs').doc(orgId).collection('incidents');
    if (siteId != null) {
      query = query.where('siteId', isEqualTo: siteId);
    }
    return query.orderBy('createdAt', descending: true).snapshots().map(
          (snapshot) => snapshot.docs.map((doc) => Incident.fromMap(doc.id, doc.data())).toList(),
        );
  }

  @override
  Future<void> createIncident(String orgId, Incident incident) {
    return firestore.collection('orgs').doc(orgId).collection('incidents').doc(incident.id).set(incident.toMap());
  }
}

class FirestoreTaskRepository implements TaskRepository {
  FirestoreTaskRepository(this.firestore);

  final FirebaseFirestore firestore;

  @override
  Stream<List<OpsTask>> watchTasks(String orgId, String? siteId) {
    var query = firestore.collection('orgs').doc(orgId).collection('tasks');
    if (siteId != null) {
      query = query.where('siteId', isEqualTo: siteId);
    }
    return query.orderBy('createdAt', descending: true).snapshots().map(
          (snapshot) => snapshot.docs.map((doc) => OpsTask.fromMap(doc.id, doc.data())).toList(),
        );
  }

  @override
  Future<void> createTask(String orgId, OpsTask task) {
    return firestore.collection('orgs').doc(orgId).collection('tasks').doc(task.id).set(task.toMap());
  }
}

class FirestoreGamificationRepository implements GamificationRepository {
  FirestoreGamificationRepository(this.firestore);

  final FirebaseFirestore firestore;

  @override
  Future<void> recordChecklistCompletion({
    required String orgId,
    required String userId,
    required String siteId,
    required String checklistRunId,
    required int points,
  }) async {
    final xpRef = firestore.collection('orgs').doc(orgId).collection('xpEvents').doc();
    await xpRef.set({
      'userId': userId,
      'siteId': siteId,
      'type': 'CHECKLIST_COMPLETE',
      'points': points,
      'refId': checklistRunId,
      'createdAt': DateTime.now().toIso8601String(),
    });

    final statsRef = firestore.collection('orgs').doc(orgId).collection('userStats').doc(userId);
    await firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(statsRef);
      final currentXp = (snapshot.data()?['xpTotal'] as int?) ?? 0;
      final streakDays = (snapshot.data()?['streakDays'] as int?) ?? 0;
      transaction.set(statsRef, {
        'xpTotal': currentXp + points,
        'streakDays': streakDays + 1,
        'badges': snapshot.data()?['badges'] ?? [],
      }, SetOptions(merge: true));
    });
  }
}

class FirestoreAiGenerationRepository implements AiGenerationRepository {
  FirestoreAiGenerationRepository(this.functions);

  final FirebaseFunctions functions;

  @override
  Future<void> generateStarterPack({
    required String orgId,
    required String industryKey,
    required Map<String, dynamic> answers,
  }) async {
    final callable = functions.httpsCallable('generateIndustryStarterPack');
    await callable.call({
      'orgId': orgId,
      'industryKey': industryKey,
      'answersMap': answers,
    });
  }
}
