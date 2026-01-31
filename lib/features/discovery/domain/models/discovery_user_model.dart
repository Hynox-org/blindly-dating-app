class DiscoveryUser {
  final String profileId;
  final String displayName;
  final int age;
  final double distanceKm;
  final String bio;
  final String modeId;
  final String? primaryImageUrl;

  DiscoveryUser({
    required this.profileId,
    required this.displayName,
    required this.age,
    required this.distanceKm,
    required this.bio,
    required this.modeId,
    this.primaryImageUrl,
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
      primaryImageUrl: json['primary_image_url'],
    );
  }
}
