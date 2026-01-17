class ChecklistRunItem {
  const ChecklistRunItem({
    required this.id,
    required this.status,
    this.valueText,
    this.photoUrl,
    this.comment,
    required this.updatedAt,
  });

  final String id;
  final String status;
  final String? valueText;
  final String? photoUrl;
  final String? comment;
  final DateTime updatedAt;

  factory ChecklistRunItem.fromMap(String id, Map<String, dynamic> data) {
    return ChecklistRunItem(
      id: id,
      status: data['status'] as String? ?? 'DONE',
      valueText: data['valueText'] as String?,
      photoUrl: data['photoUrl'] as String?,
      comment: data['comment'] as String?,
      updatedAt: DateTime.tryParse(data['updatedAt']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'status': status,
      'valueText': valueText,
      'photoUrl': photoUrl,
      'comment': comment,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class ChecklistRun {
  const ChecklistRun({
    required this.id,
    required this.checklistId,
    required this.siteId,
    required this.runDate,
    required this.startedBy,
    this.completedAt,
    required this.completionPercent,
  });

  final String id;
  final String checklistId;
  final String siteId;
  final DateTime runDate;
  final String startedBy;
  final DateTime? completedAt;
  final double completionPercent;

  factory ChecklistRun.fromMap(String id, Map<String, dynamic> data) {
    return ChecklistRun(
      id: id,
      checklistId: data['checklistId'] as String? ?? '',
      siteId: data['siteId'] as String? ?? '',
      runDate: DateTime.tryParse(data['runDate']?.toString() ?? '') ?? DateTime.now(),
      startedBy: data['startedBy'] as String? ?? '',
      completedAt: data['completedAt'] == null
          ? null
          : DateTime.tryParse(data['completedAt'].toString()),
      completionPercent: (data['completionPercent'] as num? ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'checklistId': checklistId,
      'siteId': siteId,
      'runDate': runDate.toIso8601String(),
      'startedBy': startedBy,
      'completedAt': completedAt?.toIso8601String(),
      'completionPercent': completionPercent,
    };
  }
}
