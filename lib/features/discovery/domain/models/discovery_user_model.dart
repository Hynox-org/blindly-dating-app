class DiscoveryUser {
  final String profileId;
  final String displayName;
  final int age;
  final String bio;
  final String gender;
  final String city;
  final double distanceMeters;
  final int matchScore;
  final int sharedInterestsCount;
  final int sharedLifestyleCount;
  final String? mediaUrl;

  DiscoveryUser({
    required this.profileId,
    required this.displayName,
    required this.age,
    required this.bio,
    required this.gender,
    required this.city,
    required this.distanceMeters,
    required this.matchScore,
    required this.sharedInterestsCount,
    required this.sharedLifestyleCount,
    this.mediaUrl,
  });

  factory DiscoveryUser.fromJson(Map<String, dynamic> json) {
    return DiscoveryUser(
      // ✅ UUID safe
      profileId: json['profile_id']?.toString() ?? '',

      displayName: json['display_name'] as String? ?? 'User',

      age: json['age'] as int? ?? 0,

      // ✅ FIX 1: Handles null bio (Prevents crash for Harini)
      bio: json['bio'] as String? ?? '',

      // ✅ FIX 2: Handles null gender (Prevents crash if API doesn't send it)
      gender: json['gender'] as String? ?? 'Unknown',

      city: json['city'] as String? ?? '',

      // ✅ NULL + TYPE SAFE
      distanceMeters: (json['distance_meters'] as num?)?.toDouble() ?? 0.0,

      sharedInterestsCount:
          json['interest_match_count'] as int? ?? 0,

      sharedLifestyleCount:
          json['lifestyle_match_count'] as int? ?? 0,

      matchScore: json['match_score'] as int? ?? 0,

      // ✅ FIX 3: Handles null image
      mediaUrl: json['image_url'] as String?,
    );
  }
}