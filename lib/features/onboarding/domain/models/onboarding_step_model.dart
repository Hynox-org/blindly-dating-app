class OnboardingStep {
  final String id;
  final String stepKey;
  final String stepName;
  final int stepPosition;
  final bool isMandatory;
  final String stepType;
  final int estimatedTimeSeconds;
  final int maxSkipsAllowed;
  final bool isParallel;

  OnboardingStep({
    required this.id,
    required this.stepKey,
    required this.stepName,
    required this.stepPosition,
    required this.isMandatory,
    required this.stepType,
    required this.estimatedTimeSeconds,
    required this.maxSkipsAllowed,
    required this.isParallel,
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
    );
  }

  bool get isSkippable => !isMandatory && maxSkipsAllowed > 0;
}
