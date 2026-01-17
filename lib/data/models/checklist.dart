class ChecklistItem {
  const ChecklistItem({
    required this.label,
    required this.requiresPhoto,
    required this.requiresValue,
    required this.isCritical,
  });

  final String label;
  final bool requiresPhoto;
  final bool requiresValue;
  final bool isCritical;

  factory ChecklistItem.fromMap(Map<String, dynamic> data) {
    return ChecklistItem(
      label: data['label'] as String? ?? '',
      requiresPhoto: data['requiresPhoto'] as bool? ?? false,
      requiresValue: data['requiresValue'] as bool? ?? false,
      isCritical: data['isCritical'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'label': label,
      'requiresPhoto': requiresPhoto,
      'requiresValue': requiresValue,
      'isCritical': isCritical,
    };
  }
}

class Checklist {
  const Checklist({
    required this.id,
    required this.title,
    required this.frequency,
    required this.roleTarget,
    required this.items,
    required this.active,
    required this.status,
    required this.version,
    this.siteId,
  });

  final String id;
  final String title;
  final String frequency;
  final String roleTarget;
  final List<ChecklistItem> items;
  final bool active;
  final String status;
  final int version;
  final String? siteId;

  factory Checklist.fromMap(String id, Map<String, dynamic> data) {
    return Checklist(
      id: id,
      title: data['title'] as String? ?? '',
      frequency: data['frequency'] as String? ?? 'Daily',
      roleTarget: data['roleTarget'] as String? ?? 'STAFF',
      items: (data['items'] as List? ?? const [])
          .map((item) => ChecklistItem.fromMap(Map<String, dynamic>.from(item as Map)))
          .toList(),
      active: data['active'] as bool? ?? true,
      status: data['status'] as String? ?? 'DRAFT',
      version: data['version'] as int? ?? 1,
      siteId: data['siteId'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'frequency': frequency,
      'roleTarget': roleTarget,
      'items': items.map((item) => item.toMap()).toList(),
      'active': active,
      'status': status,
      'version': version,
      'siteId': siteId,
    };
  }
}
