class Manual {
  const Manual({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.version,
    required this.updatedAt,
  });

  final String id;
  final String title;
  final String description;
  final String status;
  final int version;
  final DateTime updatedAt;

  bool get isDraft => status == 'DRAFT';

  factory Manual.fromMap(String id, Map<String, dynamic> data) {
    return Manual(
      id: id,
      title: data['title'] as String? ?? '',
      description: data['description'] as String? ?? '',
      status: data['status'] as String? ?? 'DRAFT',
      version: data['version'] as int? ?? 1,
      updatedAt: DateTime.tryParse(data['updatedAt']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'status': status,
      'version': version,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
