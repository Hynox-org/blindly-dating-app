class PromptCategory {
  final int id;
  final String key;
  final String displayName;
  final bool isActive;

  PromptCategory({
    required this.id,
    required this.key,
    required this.displayName,
    required this.isActive,
  });

  factory PromptCategory.fromJson(Map<String, dynamic> json) {
    return PromptCategory(
      id: json['id'],
      key: json['key'],
      displayName: json['display_name'],
      isActive: json['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'key': key,
      'display_name': displayName,
      'is_active': isActive,
    };
  }
}
