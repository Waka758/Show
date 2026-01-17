class OrgUser {
  const OrgUser({
    required this.id,
    required this.fullName,
    required this.role,
    this.siteId,
    required this.createdAt,
  });

  final String id;
  final String fullName;
  final String role;
  final String? siteId;
  final DateTime createdAt;

  bool get isOwner => role == 'OWNER';
  bool get isStaff => role == 'STAFF';

  factory OrgUser.fromMap(String id, Map<String, dynamic> data) {
    return OrgUser(
      id: id,
      fullName: data['fullName'] as String? ?? '',
      role: data['role'] as String? ?? 'STAFF',
      siteId: data['siteId'] as String?,
      createdAt: DateTime.tryParse(data['createdAt']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fullName': fullName,
      'role': role,
      'siteId': siteId,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
