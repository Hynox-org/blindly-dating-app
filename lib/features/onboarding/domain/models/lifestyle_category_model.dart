import 'lifestyle_chip_model.dart';

class LifestyleCategory {
  final int id;
  final String key;
  final bool isMultiselect;
  final List<LifestyleChip> chips;

  LifestyleCategory({
    required this.id,
    required this.key,
    required this.isMultiselect,
    this.chips = const [],
  });

  factory LifestyleCategory.fromJson(Map<String, dynamic> json) {
    return LifestyleCategory(
      id: json['id'] as int,
      key: json['key'] as String,
      isMultiselect: json['is_multiselect'] as bool? ?? false,
      chips: [], // Chips usually populated separately or via join
    );
  }

  LifestyleCategory copyWith({List<LifestyleChip>? chips}) {
    return LifestyleCategory(
      id: id,
      key: key,
      isMultiselect: isMultiselect,
      chips: chips ?? this.chips,
    );
  }
}
