class DiscoveryUser {
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
  final String? relationshipType;
  final List<String> qualities;
  final List<String> causes;
  final List<String>
  spotifyArtists; // Assuming strings for now, or just placeholders
  final String? swipeAction; // ✅ New: Track initial hit from backend

  DiscoveryUser({
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
    this.relationshipType,
    this.qualities = const [],
    this.causes = const [],
    this.spotifyArtists = const [],
    this.swipeAction,
  });

  factory DiscoveryUser.fromJson(Map<String, dynamic> json) {
    return DiscoveryUser(
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
      height: json['height'] as int?,
      hometown: json['hometown'],
      languages:
          (json['languages'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      drinking: json['drinking'],
      smoking: json['smoking'],
      exercise: json['exercise'],
      religion: json['religion'],
      zodiac: json['zodiac'],
      politics: json['politics'],
      kids: json['kids'],
      interests:
          (json['interests'] as List<dynamic>?)
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
    );
  }
}
