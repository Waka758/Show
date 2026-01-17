import '../models/checklist.dart';
import '../models/checklist_run.dart';
import '../models/incident.dart';
import '../models/manual.dart';
import '../models/org_user.dart';
import '../models/sop.dart';
import '../models/subscription.dart';
import '../models/task.dart';

abstract class OrgRepository {
  Stream<OrgUser?> watchCurrentUser(String orgId, String userId);
  Stream<Subscription?> watchSubscription(String orgId);
  Stream<List<OrgUser>> watchUsers(String orgId);
  Stream<List<Site>> watchSites(String orgId);
  Future<void> ensureUserProfile({
    required String orgId,
    required String userId,
    required String fullName,
    required String role,
    String? siteId,
  });
  Future<void> createUser({
    required String orgId,
    required String fullName,
    required String role,
    String? siteId,
  });
  Future<void> createSite({
    required String orgId,
    required String name,
    required String timezone,
  });
  Future<void> createOrgSetup(String orgId, String industryKey, Map<String, dynamic> answers);
}

abstract class ManualRepository {
  Stream<List<Manual>> watchManuals(String orgId);
  Stream<List<Sop>> watchSops(String orgId);
  Stream<List<Sop>> searchSops(String orgId, String query);
  Future<Sop?> fetchSop(String orgId, String sopId);
  Future<void> updateManualStatus(String orgId, String manualId, String status);
  Future<void> updateSopStatus(String orgId, String sopId, String status);
}

abstract class ChecklistRepository {
  Stream<List<Checklist>> watchChecklists(String orgId, String? siteId, String role);
  Stream<List<Checklist>> watchAllChecklists(String orgId);
  Future<void> updateChecklistStatus(String orgId, String checklistId, String status);
  Future<ChecklistRun> startRun(String orgId, Checklist checklist, String userId, String siteId);
  Future<void> updateRunItem(
    String orgId,
    String runId,
    ChecklistRunItem item,
  );
  Future<void> completeRun(String orgId, String runId, double completionPercent);
}

abstract class IncidentRepository {
  Stream<List<Incident>> watchIncidents(String orgId, String? siteId);
  Future<void> createIncident(String orgId, Incident incident);
}

abstract class TaskRepository {
  Stream<List<OpsTask>> watchTasks(String orgId, String? siteId);
  Future<void> createTask(String orgId, OpsTask task);
}

abstract class GamificationRepository {
  Future<void> recordChecklistCompletion({
    required String orgId,
    required String userId,
    required String siteId,
    required String checklistRunId,
    required int points,
  });
}

abstract class AiGenerationRepository {
  Future<void> generateStarterPack({
    required String orgId,
    required String industryKey,
    required Map<String, dynamic> answers,
  });
}
