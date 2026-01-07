class ProfilePrompt {
  final String? id;
  final String profileId;
  final String promptTemplateId;
  final String userResponse;
  final int promptDisplayOrder;
  // Optional: Include full template object for easier UI display if using joins,
  // but strict table mapping might just have IDs.
  // For UI convenience, we might want to store the question text too if joined,
  // but let's stick to the table structure first or allow optional fields.
  final String? promptQuestion;

  ProfilePrompt({
    this.id,
    required this.profileId,
    required this.promptTemplateId,
    required this.userResponse,
    required this.promptDisplayOrder,
    this.promptQuestion,
  });

  factory ProfilePrompt.fromJson(Map<String, dynamic> json) {
    return ProfilePrompt(
      id: json['id'],
      profileId: json['profile_id'],
      promptTemplateId: json['prompt_template_id'],
      userResponse: json['user_response'],
      promptDisplayOrder: json['prompt_display_order'],
      // If we join with prompt_templates, we might get the text.
      promptQuestion: json['prompt_templates'] != null
          ? json['prompt_templates']['prompt_text']
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'profile_id': profileId,
      'prompt_template_id': promptTemplateId,
      'user_response': userResponse,
      'prompt_display_order': promptDisplayOrder,
    };
  }

  // Create a copyWith for updates
  ProfilePrompt copyWith({
    String? id,
    String? profileId,
    String? promptTemplateId,
    String? userResponse,
    int? promptDisplayOrder,
    String? promptQuestion,
  }) {
    return ProfilePrompt(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      promptTemplateId: promptTemplateId ?? this.promptTemplateId,
      userResponse: userResponse ?? this.userResponse,
      promptDisplayOrder: promptDisplayOrder ?? this.promptDisplayOrder,
      promptQuestion: promptQuestion ?? this.promptQuestion,
    );
  }
}
