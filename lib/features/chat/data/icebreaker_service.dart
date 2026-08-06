import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class IcebreakerResponse {
  final Map<String, String> bothProfiles;
  final Map<String, String> recipientOnly;

  IcebreakerResponse({
    required this.bothProfiles,
    required this.recipientOnly,
  });

  factory IcebreakerResponse.fromJson(Map<String, dynamic> json) {
    final icebreakers = json['icebreakers'] as Map<String, dynamic>;

    return IcebreakerResponse(
      bothProfiles: Map<String, String>.from(icebreakers['both_profiles']),
      recipientOnly: Map<String, String>.from(icebreakers['recipient_only']),
    );
  }
}

class IcebreakerService {
  /// Both sides are derived server-side from [matchId]; only the match is
  /// passed so a client can't ask for icebreakers about arbitrary profiles.
  static Future<IcebreakerResponse?> fetchAiIcebreakers({
    required String matchId,
    bool refresh = false,
  }) async {
    try {
      final res = await Supabase.instance.client.functions.invoke(
        'ai-icebreakers',
        body: {'match_id': matchId, 'refresh': refresh},
      );

      final data = res.data;
      if (data is Map && data['success'] == true) {
        return IcebreakerResponse.fromJson(Map<String, dynamic>.from(data));
      }

      debugPrint('❌ Icebreaker API error: ${res.status} - $data');
      return null;
    } catch (e) {
      debugPrint('❌ Icebreaker Service error: $e');
      return null;
    }
  }
}
