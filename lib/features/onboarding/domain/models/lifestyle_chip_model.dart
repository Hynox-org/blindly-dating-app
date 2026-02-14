class LifestyleChip {
  final String id;
  final int categoryId;
  final String label;
  final bool isActive;
  final String? categoryName;
  final String? categoryKey;

  LifestyleChip({
    required this.id,
    required this.categoryId,
    required this.label,
    required this.isActive,
    this.categoryName,
    this.categoryKey,
  });

  factory LifestyleChip.fromJson(Map<String, dynamic> json) {
    String? catName;
    String? catKey;
    if (json['lifestyle_categories'] != null) {
      final key = json['lifestyle_categories']['key'] as String?;
      if (key != null && key.isNotEmpty) {
        catKey = key;
        final text = key.replaceAll('_', ' ');
        catName = text[0].toUpperCase() + text.substring(1).toLowerCase();
      }
    }

    return LifestyleChip(
      id: json['id'] as String,
      categoryId: json['category_id'] as int,
      label: json['label'] as String,
      isActive: json['is_active'] as bool? ?? true,
      categoryName: catName,
      categoryKey: catKey,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category_id': categoryId,
      'label': label,
      'is_active': isActive,
      'category_name': categoryName,
      'category_key': categoryKey,
    };
  }

  LifestyleChip copyWith({
    String? id,
    int? categoryId,
    String? label,
    bool? isActive,
    String? categoryName,
    String? categoryKey,
  }) {
    return LifestyleChip(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      label: label ?? this.label,
      isActive: isActive ?? this.isActive,
      categoryName: categoryName ?? this.categoryName,
      categoryKey: categoryKey ?? this.categoryKey,
    );
  }
}
