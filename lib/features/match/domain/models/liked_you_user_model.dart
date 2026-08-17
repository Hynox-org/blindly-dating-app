import 'package:flutter/foundation.dart';

@immutable
class LikedYouUser {
  final String profileId;
  final String displayName;
  final int age;

  /// Signed URL, or null if the user has no showable photo.
  final String? imageUrl;

  final DateTime likedAt;
  final String actionType; // 'like' | 'super_like'

  const LikedYouUser({
    required this.profileId,
    required this.displayName,
    required this.age,
    required this.imageUrl,
    required this.likedAt,
    this.actionType = 'like',
  });

  factory LikedYouUser.fromJson(Map<String, dynamic> json) {
    return LikedYouUser(
      profileId: json['profile_id'] as String,
      displayName: (json['display_name'] as String?) ?? '',
      age: (json['age'] as int?) ?? 0,
      imageUrl: json['image_url'] as String?,
      likedAt: DateTime.parse(json['liked_at'] as String),
      actionType: (json['action_type'] as String?) ?? 'like',
    );
  }

  bool get isSuperLike => actionType == 'super_like';
  bool get hasImage => imageUrl != null && imageUrl!.isNotEmpty;
}
