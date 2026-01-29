import 'package:flutter/foundation.dart';

@immutable
class RecentMatch {
  final String matchId;
  final String profileId;
  final String displayName;
  final String? imageUrl;
  final DateTime matchedAt;

  const RecentMatch({
    required this.matchId,
    required this.profileId,
    required this.displayName,
    required this.imageUrl,
    required this.matchedAt,
  });

  factory RecentMatch.fromJson(Map<String, dynamic> json) {
    return RecentMatch(
      matchId: json['match_id'] as String,
      profileId: json['other_profile_id'] as String,
      displayName: (json['display_name'] as String?) ?? '',
      imageUrl: json['image_path'] as String?,
      matchedAt: DateTime.parse(json['matched_at']),
    );
  }

  bool get hasImage => imageUrl != null && imageUrl!.isNotEmpty;
}
