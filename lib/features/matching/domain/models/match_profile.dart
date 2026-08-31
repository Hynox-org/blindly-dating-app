import 'package:blindly_dating_app/features/onboarding/domain/models/profile_prompt_model.dart';

enum RelationshipState {
  none,
  likedByMe,
  likedMe, // They liked me, but I haven't liked back (potential match)
  matched,
  chatStarted,
  skippedByMe,
  blocked,
}

class MatchProfile {
  final String profileId;
  final String displayName;
  final int age;
  final double distanceKm;
  final String bio;
  final String modeId;
  final List<String> imageUrls; // ✅ CHANGED: From String? to List<String>
  final String gender;
  final String? workTitle;
  final String? workCompany;
  final String? education;
  final String? school;
  final int? height;
  final String? hometown;
  final List<String> languages;
  final String? drinking;
  final String? smoking;
  final String? exercise;
  final String? religion;
  final String? zodiac;
  final String? politics;
  final String? kids;
  final List<String> interests;
  final List<String> lifestyle;
  final String? relationshipType;
  final List<String> qualities;
  final List<String> causes;
  final List<String>
  spotifyArtists; // Assuming strings for now, or just placeholders
  final String? swipeAction; // ✅ New: Track initial hit from backend
  final List<ProfilePrompt> prompts; // ✅ New: Store dynamically fetched prompts
  final List<String>
  lookingForModes; // ✅ New: Fetch active mode looking_for preferences
  final String? voiceIntroUrl; // ✅ New: Shared voice intro
  final int? voiceIntroDuration;
  final bool isVerified;
  final String verificationLevel;
  final int trustScore; // ✅ Added Trust Score

  /// True while this profile holds a paid spotlight in the viewer's district.
  /// Set by get_discovery_prospects; the deck pins these to the front.
  final bool isSpotlight;
  final RelationshipState relationship; // ✅ New field

  MatchProfile({
    required this.profileId,
    required this.displayName,
    required this.age,
    required this.distanceKm,
    required this.bio,
    required this.modeId,
    required this.imageUrls,
    required this.gender,
    this.workTitle,
    this.workCompany,
    this.education,
    this.school,
    this.height,
    this.hometown,
    this.languages = const [],
    this.drinking,
    this.smoking,
    this.exercise,
    this.religion,
    this.zodiac,
    this.politics,
    this.kids,
    this.interests = const [],
    this.lifestyle = const [],
    this.relationshipType,
    this.qualities = const [],
    this.causes = const [],
    this.spotifyArtists = const [],
    this.prompts = const [],
    this.swipeAction,
    this.lookingForModes = const [],
    this.voiceIntroUrl,
    this.voiceIntroDuration,
    this.isVerified = false,
    this.verificationLevel = 'unverified',
    this.trustScore = 0, // ✅ Default to 0
    this.isSpotlight = false,
    this.relationship = RelationshipState.none,
  });

  factory MatchProfile.fromJson(Map<String, dynamic> json) {
    return MatchProfile(
      profileId: json['profile_id'],
      displayName: json['display_name'] ?? 'Unknown',
      age: json['age'] ?? 0,
      // Ensure we handle both int and double from JSON safely
      distanceKm: (json['distance_km'] as num?)?.toDouble() ?? 0.0,
      bio: json['bio'] ?? '',
      modeId: json['mode_id'] ?? 'date',

      // ✅ Parse the list of strings from SQL
      imageUrls:
          (json['image_urls'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],

      gender: json['gender'] ?? 'Male',
      workTitle: json['work_title'],
      workCompany: json['work_company'],
      education:
          json['education_level'], // Mapping education_level to education
      school: json['educated_at'], // Mapping educated_at to school
      height: json['height_cm'] as int?,
      hometown: json['hometown_city'] ?? json['hometown'],
      languages:
          (json['languages'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      drinking: json['drinking'],
      smoking: json['smoking'],
      exercise: json['exercise'],
      religion: json['religion'],
      zodiac: json['star_sign'],
      politics: json['politics'],
      kids: json['kids'],
      interests:
          (json['interests'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      lifestyle:
          (json['lifestyle'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      relationshipType: json['relationship_type'],
      qualities:
          (json['qualities'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      causes:
          (json['causes_communities'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      // If spotify artists are stored in JSON (or skipped for now), we parse them
      // Assuming table has 'spotify_artists' or similar if implemented
      spotifyArtists: [],
      swipeAction: json['swipe_action'], // ✅ Map from SQL
      prompts:
          (json['prompts'] as List<dynamic>?)
              ?.map((p) => ProfilePrompt.fromJson(p as Map<String, dynamic>))
              .toList() ??
          [],
      lookingForModes:
          (json['looking_for'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      voiceIntroUrl: json['voice_into_url'] ?? json['voice_intro_url'],
      voiceIntroDuration:
          json['voice_intro_duration'] ?? json['duration_seconds'],
      isVerified: json['is_verified'] ?? false,
      verificationLevel: json['verification_level'] ?? 'unverified',
      trustScore: json['trust_score'] ?? 0, // ✅ Map Trust Score
      isSpotlight: json['is_spotlight'] ?? false,
      relationship: json['relationship'] != null
          ? RelationshipState.values.firstWhere(
              (e) => e.name == json['relationship'],
              orElse: () => RelationshipState.none,
            )
          : RelationshipState.none,
    );
  }

  MatchProfile copyWith({
    String? profileId,
    String? displayName,
    int? age,
    double? distanceKm,
    String? bio,
    String? modeId,
    List<String>? imageUrls,
    String? gender,
    String? workTitle,
    String? workCompany,
    String? education,
    String? school,
    int? height,
    String? hometown,
    List<String>? languages,
    String? drinking,
    String? smoking,
    String? exercise,
    String? religion,
    String? zodiac,
    String? politics,
    String? kids,
    List<String>? interests,
    List<String>? lifestyle,
    String? relationshipType,
    List<String>? qualities,
    List<String>? causes,
    List<String>? spotifyArtists,
    String? swipeAction,
    List<ProfilePrompt>? prompts,
    List<String>? lookingForModes,
    String? voiceIntroUrl,
    int? voiceIntroDuration,
    bool? isVerified,
    String? verificationLevel,
    int? trustScore,
    bool? isSpotlight,
    RelationshipState? relationship,
  }) {
    return MatchProfile(
      profileId: profileId ?? this.profileId,
      displayName: displayName ?? this.displayName,
      age: age ?? this.age,
      distanceKm: distanceKm ?? this.distanceKm,
      bio: bio ?? this.bio,
      modeId: modeId ?? this.modeId,
      imageUrls: imageUrls ?? this.imageUrls,
      gender: gender ?? this.gender,
      workTitle: workTitle ?? this.workTitle,
      workCompany: workCompany ?? this.workCompany,
      education: education ?? this.education,
      school: school ?? this.school,
      height: height ?? this.height,
      hometown: hometown ?? this.hometown,
      languages: languages ?? this.languages,
      drinking: drinking ?? this.drinking,
      smoking: smoking ?? this.smoking,
      exercise: exercise ?? this.exercise,
      religion: religion ?? this.religion,
      zodiac: zodiac ?? this.zodiac,
      politics: politics ?? this.politics,
      kids: kids ?? this.kids,
      interests: interests ?? this.interests,
      lifestyle: lifestyle ?? this.lifestyle,
      relationshipType: relationshipType ?? this.relationshipType,
      qualities: qualities ?? this.qualities,
      causes: causes ?? this.causes,
      spotifyArtists: spotifyArtists ?? this.spotifyArtists,
      swipeAction: swipeAction ?? this.swipeAction,
      prompts: prompts ?? this.prompts,
      lookingForModes: lookingForModes ?? this.lookingForModes,
      voiceIntroUrl: voiceIntroUrl ?? this.voiceIntroUrl,
      voiceIntroDuration: voiceIntroDuration ?? this.voiceIntroDuration,
      isVerified: isVerified ?? this.isVerified,
      verificationLevel: verificationLevel ?? this.verificationLevel,
      trustScore: trustScore ?? this.trustScore,
      isSpotlight: isSpotlight ?? this.isSpotlight,
      relationship: relationship ?? this.relationship,
    );
  }
}
