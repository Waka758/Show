class OpsTask {
  const OpsTask({
    required this.id,
    required this.siteId,
    required this.createdBy,
    required this.title,
    required this.description,
    this.incidentId,
    this.assignedTo,
    this.dueDate,
    required this.status,
    required this.createdAt,
  });

  final String id;
  final String siteId;
  final String createdBy;
  final String title;
  final String description;
  final String? incidentId;
  final String? assignedTo;
  final DateTime? dueDate;
  final String status;
  final DateTime createdAt;

  factory OpsTask.fromMap(String id, Map<String, dynamic> data) {
    return OpsTask(
      id: id,
      siteId: data['siteId'] as String? ?? '',
      createdBy: data['createdBy'] as String? ?? '',
      title: data['title'] as String? ?? '',
      description: data['description'] as String? ?? '',
      incidentId: data['incidentId'] as String?,
      assignedTo: data['assignedTo'] as String?,
      dueDate: data['dueDate'] == null ? null : DateTime.tryParse(data['dueDate'].toString()),
      status: data['status'] as String? ?? 'OPEN',
      createdAt: DateTime.tryParse(data['createdAt']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'siteId': siteId,
      'createdBy': createdBy,
      'title': title,
      'description': description,
      'incidentId': incidentId,
      'assignedTo': assignedTo,
      'dueDate': dueDate?.toIso8601String(),
      'status': status,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
