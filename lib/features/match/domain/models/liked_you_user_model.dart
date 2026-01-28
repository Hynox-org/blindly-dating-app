import 'package:flutter/foundation.dart';

@immutable
class LikedYouUser {
  // --------------------------------------------------
  // 🔑 CORE IDENTIFIERS
  // --------------------------------------------------
  final String profileId;

  // --------------------------------------------------
  // 👤 PROFILE INFO
  // --------------------------------------------------
  final String displayName;
  final int age;

  // --------------------------------------------------
  // 🖼️ MEDIA
  // --------------------------------------------------
  /// Signed URL or null if user has no photo
  final String? imageUrl;

  // --------------------------------------------------
  // ❤️ LIKE METADATA
  // --------------------------------------------------
  final DateTime likedAt;

  /// 🔥 TOTAL LIKES COUNT (same for all rows)
  final int totalLikes;

  const LikedYouUser({
    required this.profileId,
    required this.displayName,
    required this.age,
    required this.imageUrl,
    required this.likedAt,
    required this.totalLikes,
  });

  // --------------------------------------------------
  // 🧩 FROM SUPABASE (RPC)
  // --------------------------------------------------
  factory LikedYouUser.fromJson(Map<String, dynamic> json) {
    return LikedYouUser(
      profileId: json['profile_id'] as String,
      displayName: (json['display_name'] as String?) ?? '',
      age: (json['age'] as int?) ?? 0,
      imageUrl: json['image_path'] as String?,
      likedAt: DateTime.parse(json['liked_at'] as String),

      // ✅ SAFE DEFAULT (important)
      totalLikes: (json['total_likes'] as int?) ?? 0,
    );
  }

  // --------------------------------------------------
  // 🔄 TO JSON (OPTIONAL / FUTURE USE)
  // --------------------------------------------------
  Map<String, dynamic> toJson() {
    return {
      'profile_id': profileId,
      'display_name': displayName,
      'age': age,
      'image_path': imageUrl,
      'liked_at': likedAt.toIso8601String(),
      'total_likes': totalLikes,
    };
  }

  // --------------------------------------------------
  // 🧠 UI HELPERS
  // --------------------------------------------------

  /// First name only (nice for UI)
  String get firstName {
    if (displayName.isEmpty) return '';
    return displayName.split(' ').first;
  }

  /// Safe age display
  String get ageLabel => age > 0 ? age.toString() : '';

  /// Whether profile has a usable photo
  bool get hasImage => imageUrl != null && imageUrl!.isNotEmpty;
}