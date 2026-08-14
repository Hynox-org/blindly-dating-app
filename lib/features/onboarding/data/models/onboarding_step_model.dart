/// A step is behind the user once it is finished or deliberately skipped.
bool isStepDone(Object? status) => status == 'completed' || status == 'skipped';

/// Reads the `steps_progress` column, which is null for a user who has not
/// started and a JSON object after that.
Map<String, dynamic> parseStepProgress(Object? raw) =>
    raw == null ? {} : Map<String, dynamic>.from(raw as Map);

/// The first step the user still has to face, or null when none are left.
///
/// The shell asks this to decide where to send the user, and the completion
/// check asks it to decide whether a 'complete' flag is telling the truth.
/// Same question, so it lives in one place.
OnboardingStep? nextIncompleteStep(
  List<OnboardingStep> steps,
  Map<String, dynamic> progress,
) {
  final ordered = [...steps]
    ..sort((a, b) => a.stepPosition.compareTo(b.stepPosition));
  for (final step in ordered) {
    if (!isStepDone(progress[step.stepKey])) return step;
  }
  return null;
}

class OnboardingStep {
  final String id;
  final String stepKey;
  final String stepName;
  final int stepPosition;
  final bool isMandatory;
  final String
  stepType; // auth, basic_profile, photos, verification, enrichment
  final int estimatedTimeSeconds;
  final int maxSkipsAllowed;
  final bool isParallel;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const OnboardingStep({
    required this.id,
    required this.stepKey,
    required this.stepName,
    required this.stepPosition,
    this.isMandatory = false,
    required this.stepType,
    this.estimatedTimeSeconds = 30,
    this.maxSkipsAllowed = 0,
    this.isParallel = false,
    this.createdAt,
    this.updatedAt,
  });

  factory OnboardingStep.fromJson(Map<String, dynamic> json) {
    return OnboardingStep(
      id: json['id'] as String,
      stepKey: json['step_key'] as String,
      stepName: json['step_name'] as String,
      stepPosition: json['step_position'] as int,
      isMandatory: json['is_mandatory'] as bool? ?? false,
      stepType: json['step_type'] as String,
      estimatedTimeSeconds: json['estimated_time_seconds'] as int? ?? 30,
      maxSkipsAllowed: json['max_skips_allowed'] as int? ?? 0,
      isParallel: json['is_parallel'] as bool? ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'step_key': stepKey,
      'step_name': stepName,
      'step_position': stepPosition,
      'is_mandatory': isMandatory,
      'step_type': stepType,
      'estimated_time_seconds': estimatedTimeSeconds,
      'max_skips_allowed': maxSkipsAllowed,
      'is_parallel': isParallel,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
