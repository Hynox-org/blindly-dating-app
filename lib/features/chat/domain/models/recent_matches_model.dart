import 'package:flutter/foundation.dart';

@immutable
class RecentMatch {
  final String matchId;
  final String profileId;
  final String displayName;
  final String? imageUrl;
  final DateTime matchedAt;
  final DateTime? expiryAt;
  final String? photoUrl;

  const RecentMatch({
    required this.matchId,
    required this.profileId,
    required this.displayName,
    required this.imageUrl,
    required this.matchedAt,
    this.expiryAt,
    this.photoUrl,
  });

  factory RecentMatch.fromJson(Map<String, dynamic> json) {
    final rawMatchedAt = json['matched_at'];

    return RecentMatch(
      matchId: json['id']?.toString() ?? '',
      profileId: json['other_profile_id']?.toString() ?? '',
      displayName: json['display_name']?.toString() ?? '',
      imageUrl: json['photo_url']?.toString(), // ✅ FIXED
      matchedAt: rawMatchedAt != null
          ? DateTime.parse(rawMatchedAt.toString())
          : DateTime.fromMillisecondsSinceEpoch(0),
      expiryAt: json['expiry_at'] != null
          ? DateTime.parse(json['expiry_at'].toString())
          : null,
    );
  }

  bool get hasImage => imageUrl != null && imageUrl!.trim().isNotEmpty;
}
