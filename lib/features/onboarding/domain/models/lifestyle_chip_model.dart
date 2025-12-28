class LifestyleChip {
  final String id;
  final int categoryId;
  final String label;
  final bool isActive;

  LifestyleChip({
    required this.id,
    required this.categoryId,
    required this.label,
    required this.isActive,
  });

  factory LifestyleChip.fromJson(Map<String, dynamic> json) {
    return LifestyleChip(
      id: json['id'] as String,
      categoryId: json['category_id'] as int,
      label: json['label'] as String,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category_id': categoryId,
      'label': label,
      'is_active': isActive,
    };
  }
}
