class UserProfile {
  final String id;
  final String? displayName;
  final String? bio;
  final DateTime? birthDate;
  final String? gender;
  final String onboardingStep;
  final String onboardingStatus;
  final int profileCompleteness;

  UserProfile({
    required this.id,
    this.displayName,
    this.bio,
    this.birthDate,
    this.gender,
    required this.onboardingStep,
    required this.onboardingStatus,
    required this.profileCompleteness,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      displayName: json['display_name'] as String?,
      bio: json['bio'] as String?,
      birthDate: json['birth_date'] != null
          ? DateTime.tryParse(json['birth_date'])
          : null,
      gender: json['gender'] as String?,
      onboardingStep: json['onboarding_step'] as String? ?? 'name_entry',
      onboardingStatus: json['onboarding_status'] as String? ?? 'in_progress',
      profileCompleteness: json['profile_completeness'] as int? ?? 0,
    );
  }

  bool get isComplete => onboardingStatus == 'complete';
}
