class Site {
  const Site({
    required this.id,
    required this.name,
    required this.timezone,
  });

  final String id;
  final String name;
  final String timezone;

  factory Site.fromMap(String id, Map<String, dynamic> data) {
    return Site(
      id: id,
      name: data['name'] as String? ?? '',
      timezone: data['timezone'] as String? ?? 'UTC',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'timezone': timezone,
    };
  }
}
