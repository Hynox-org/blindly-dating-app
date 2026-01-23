import 'package:hive/hive.dart';

@HiveType(typeId: 0) // Unique ID for this class
class DiscoveryUser {
  @HiveField(0)
  final String profileId;

  @HiveField(1)
  final String displayName;

  @HiveField(2)
  final int age;

  @HiveField(3)
  final String bio;

  @HiveField(4)
  final String gender;

  @HiveField(5)
  final String city;

  @HiveField(6)
  final double distanceMeters;

  @HiveField(7)
  final int matchScore;

  @HiveField(8)
  final int sharedInterestsCount;

  @HiveField(9)
  final int sharedLifestyleCount;

  @HiveField(10)
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
      profileId: json['profile_id']?.toString() ?? '',
      displayName: json['display_name'] as String? ?? 'User',
      age: json['age'] as int? ?? 0,
      bio: json['bio'] as String? ?? '',
      gender: json['gender'] as String? ?? 'Unknown',
      city: json['city'] as String? ?? '',
      distanceMeters: (json['distance_meters'] as num?)?.toDouble() ?? 0.0,
      sharedInterestsCount: json['interest_match_count'] as int? ?? 0,
      sharedLifestyleCount: json['lifestyle_match_count'] as int? ?? 0,
      matchScore: json['match_score'] as int? ?? 0,
      mediaUrl: json['media_url'] as String?,
    );
  }
}
