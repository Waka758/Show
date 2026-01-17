class IndustryPack {
  const IndustryPack({
    required this.id,
    required this.industryKey,
    required this.title,
    required this.description,
    required this.version,
    required this.promptTemplate,
    required this.schemaJson,
  });

  final String id;
  final String industryKey;
  final String title;
  final String description;
  final int version;
  final String promptTemplate;
  final Map<String, dynamic> schemaJson;

  factory IndustryPack.fromMap(String id, Map<String, dynamic> data) {
    return IndustryPack(
      id: id,
      industryKey: data['industryKey'] as String? ?? '',
      title: data['title'] as String? ?? '',
      description: data['description'] as String? ?? '',
      version: data['version'] as int? ?? 1,
      promptTemplate: data['promptTemplate'] as String? ?? '',
      schemaJson: Map<String, dynamic>.from(data['schemaJson'] as Map? ?? const {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'industryKey': industryKey,
      'title': title,
      'description': description,
      'version': version,
      'promptTemplate': promptTemplate,
      'schemaJson': schemaJson,
    };
  }
}
