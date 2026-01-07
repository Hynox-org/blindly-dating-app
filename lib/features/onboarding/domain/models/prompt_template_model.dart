class PromptTemplate {
  final String id;
  final String promptText;
  final String language;
  final bool isActive;
  final int categoryId;

  PromptTemplate({
    required this.id,
    required this.promptText,
    required this.language,
    required this.isActive,
    required this.categoryId,
  });

  factory PromptTemplate.fromJson(Map<String, dynamic> json) {
    return PromptTemplate(
      id: json['id'],
      promptText: json['prompt_text'],
      language: json['language'],
      isActive: json['is_active'] ?? true,
      categoryId: json['category_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'prompt_text': promptText,
      'language': language,
      'is_active': isActive,
      'category_id': categoryId,
    };
  }
}
