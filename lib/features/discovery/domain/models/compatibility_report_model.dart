import 'package:flutter/material.dart';

/// The score is deliberately banded rather than shown as a percentage: the
/// underlying inputs are self-reported profile answers, and a precise-looking
/// number claims more certainty than they can support.
enum CompatibilityBand { strong, good, some, low, unknown }

CompatibilityBand _bandFrom(String? raw) {
  switch (raw) {
    case 'strong':
      return CompatibilityBand.strong;
    case 'good':
      return CompatibilityBand.good;
    case 'some':
      return CompatibilityBand.some;
    case 'low':
      return CompatibilityBand.low;
    default:
      return CompatibilityBand.unknown;
  }
}

extension CompatibilityBandDisplay on CompatibilityBand {
  String get label {
    switch (this) {
      case CompatibilityBand.strong:
        return 'Strong match';
      case CompatibilityBand.good:
        return 'Good match';
      case CompatibilityBand.some:
        return 'Some common ground';
      case CompatibilityBand.low:
        return 'Not much in common';
      case CompatibilityBand.unknown:
        return 'Not enough to go on yet';
    }
  }

  Color get color {
    switch (this) {
      case CompatibilityBand.strong:
        return const Color(0xFF2E7D32);
      case CompatibilityBand.good:
        return const Color(0xFF558B2F);
      case CompatibilityBand.some:
        return const Color(0xFFB58A1B);
      case CompatibilityBand.low:
        return const Color(0xFF8D6E63);
      case CompatibilityBand.unknown:
        return const Color(0xFF757575);
    }
  }

  /// How full to draw the band meter. Four discrete steps, so it reads as a
  /// band and never invites arithmetic.
  double get fill {
    switch (this) {
      case CompatibilityBand.strong:
        return 1.0;
      case CompatibilityBand.good:
        return 0.72;
      case CompatibilityBand.some:
        return 0.45;
      case CompatibilityBand.low:
        return 0.2;
      case CompatibilityBand.unknown:
        return 0.0;
    }
  }
}

class CompatibilityDimension {
  final String key;
  final String label;
  final CompatibilityBand band;

  /// Concrete things the two profiles have in common on this dimension, if
  /// any. Used to back the explanation with visible evidence.
  final List<String> shared;

  const CompatibilityDimension({
    required this.key,
    required this.label,
    required this.band,
    this.shared = const [],
  });

  factory CompatibilityDimension.fromJson(Map<String, dynamic> json) {
    final shared = <String>[];
    for (final key in const [
      'shared_interests',
      'shared_lifestyle',
      'shared_qualities',
      'shared_causes',
      'shared_languages',
    ]) {
      final value = json[key];
      if (value is List) shared.addAll(value.map((e) => e.toString()));
    }

    return CompatibilityDimension(
      key: json['key']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
      band: _bandFrom(json['band']?.toString()),
      shared: shared,
    );
  }
}

class CompatibilityReport {
  final String targetId;
  final CompatibilityBand band;

  /// Mutual fit: whether each side meets the other's stated filters. Scored
  /// separately because a one-sided score would flatter pairs who would never
  /// surface to each other.
  final CompatibilityBand reciprocityBand;

  final String headline;
  final List<String> points;
  final String caveat;
  final List<CompatibilityDimension> dimensions;
  final bool cached;

  const CompatibilityReport({
    required this.targetId,
    required this.band,
    required this.reciprocityBand,
    required this.headline,
    required this.points,
    required this.caveat,
    required this.dimensions,
    this.cached = false,
  });

  factory CompatibilityReport.fromJson(Map<String, dynamic> json) {
    final breakdown = Map<String, dynamic>.from(json['breakdown'] ?? const {});
    final explanation = Map<String, dynamic>.from(json['explanation'] ?? const {});
    final reciprocity = Map<String, dynamic>.from(
      breakdown['reciprocity'] ?? const {},
    );

    return CompatibilityReport(
      targetId: breakdown['target_id']?.toString() ?? '',
      band: _bandFrom(json['band']?.toString() ?? breakdown['band']?.toString()),
      reciprocityBand: _bandFrom(reciprocity['band']?.toString()),
      headline: explanation['headline']?.toString() ?? '',
      points:
          (explanation['points'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      caveat: explanation['caveat']?.toString() ?? '',
      dimensions:
          (breakdown['dimensions'] as List<dynamic>?)
              ?.map(
                (d) =>
                    CompatibilityDimension.fromJson(Map<String, dynamic>.from(d)),
              )
              .toList() ??
          const [],
      cached: json['cached'] == true,
    );
  }
}
