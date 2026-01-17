class Sop {
  const Sop({
    required this.id,
    required this.manualId,
    required this.sectionId,
    required this.title,
    required this.purpose,
    required this.scope,
    required this.steps,
    required this.standards,
    required this.commonFailures,
    required this.escalationTriggers,
    required this.status,
    required this.version,
    required this.updatedAt,
  });

  final String id;
  final String manualId;
  final String sectionId;
  final String title;
  final String purpose;
  final String scope;
  final List<String> steps;
  final String standards;
  final List<String> commonFailures;
  final List<String> escalationTriggers;
  final String status;
  final int version;
  final DateTime updatedAt;

  factory Sop.fromMap(String id, Map<String, dynamic> data) {
    return Sop(
      id: id,
      manualId: data['manualId'] as String? ?? '',
      sectionId: data['sectionId'] as String? ?? '',
      title: data['title'] as String? ?? '',
      purpose: data['purpose'] as String? ?? '',
      scope: data['scope'] as String? ?? '',
      steps: List<String>.from(data['steps'] as List? ?? const []),
      standards: data['standards'] as String? ?? '',
      commonFailures: List<String>.from(data['commonFailures'] as List? ?? const []),
      escalationTriggers: List<String>.from(data['escalationTriggers'] as List? ?? const []),
      status: data['status'] as String? ?? 'DRAFT',
      version: data['version'] as int? ?? 1,
      updatedAt: DateTime.tryParse(data['updatedAt']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'manualId': manualId,
      'sectionId': sectionId,
      'title': title,
      'purpose': purpose,
      'scope': scope,
      'steps': steps,
      'standards': standards,
      'commonFailures': commonFailures,
      'escalationTriggers': escalationTriggers,
      'status': status,
      'version': version,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
