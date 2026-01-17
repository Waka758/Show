class XpEvent {
  const XpEvent({
    required this.id,
    required this.userId,
    required this.siteId,
    required this.type,
    required this.points,
    required this.refId,
    required this.createdAt,
  });

  final String id;
  final String userId;
  final String siteId;
  final String type;
  final int points;
  final String refId;
  final DateTime createdAt;

  factory XpEvent.fromMap(String id, Map<String, dynamic> data) {
    return XpEvent(
      id: id,
      userId: data['userId'] as String? ?? '',
      siteId: data['siteId'] as String? ?? '',
      type: data['type'] as String? ?? '',
      points: data['points'] as int? ?? 0,
      refId: data['refId'] as String? ?? '',
      createdAt: DateTime.tryParse(data['createdAt']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'siteId': siteId,
      'type': type,
      'points': points,
      'refId': refId,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
