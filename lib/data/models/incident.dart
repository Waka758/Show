class Incident {
  const Incident({
    required this.id,
    required this.siteId,
    required this.createdBy,
    required this.category,
    required this.severity,
    required this.title,
    required this.description,
    this.photoUrl,
    required this.containmentSteps,
    required this.status,
    required this.createdAt,
  });

  final String id;
  final String siteId;
  final String createdBy;
  final String category;
  final String severity;
  final String title;
  final String description;
  final String? photoUrl;
  final String containmentSteps;
  final String status;
  final DateTime createdAt;

  factory Incident.fromMap(String id, Map<String, dynamic> data) {
    return Incident(
      id: id,
      siteId: data['siteId'] as String? ?? '',
      createdBy: data['createdBy'] as String? ?? '',
      category: data['category'] as String? ?? '',
      severity: data['severity'] as String? ?? '',
      title: data['title'] as String? ?? '',
      description: data['description'] as String? ?? '',
      photoUrl: data['photoUrl'] as String?,
      containmentSteps: data['containmentSteps'] as String? ?? '',
      status: data['status'] as String? ?? 'OPEN',
      createdAt: DateTime.tryParse(data['createdAt']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'siteId': siteId,
      'createdBy': createdBy,
      'category': category,
      'severity': severity,
      'title': title,
      'description': description,
      'photoUrl': photoUrl,
      'containmentSteps': containmentSteps,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
