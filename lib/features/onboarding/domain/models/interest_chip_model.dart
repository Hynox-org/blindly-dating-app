class InterestChip {
  final String id;
  final String section;
  final String label;
  final bool isActive;

  InterestChip({
    required this.id,
    required this.section,
    required this.label,
    required this.isActive,
  });

  factory InterestChip.fromJson(Map<String, dynamic> json) {
    return InterestChip(
      id: json['id'] as String,
      section: json['section'] as String,
      label: json['label'] as String,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'section': section,
      'label': label,
      'is_active': isActive,
    };
  }
}
