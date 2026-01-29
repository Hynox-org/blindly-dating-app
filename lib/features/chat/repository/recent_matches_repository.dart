import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../chat/domain/models/recent_matches_model.dart';


// ======================================================
// Provider
// ======================================================
final recentMatchesRepositoryProvider =
    Provider<RecentMatchesRepository>((ref) {
  return RecentMatchesRepository(Supabase.instance.client);
});


// ======================================================
// Repository
// ======================================================
class RecentMatchesRepository {
  final SupabaseClient _supabase;

  RecentMatchesRepository(this._supabase);

  // --------------------------------------------------
  // 🔥 GET RECENT MATCHES
  // --------------------------------------------------
  /// Uses RPC: get_recent_matches
  /// - Resolves opposite profile automatically
  /// - Returns profile_id, display_name, image_path, matched_at
  ///
  /// Flutter:
  /// - Converts storage image path → signed URL
  ///
  Future<List<RecentMatch>> getRecentMatches() async {
    try {
      debugPrint('💬 Fetching recent matches');

      final List<dynamic> response =
          await _supabase.rpc('get_recent_matches');

      if (response.isEmpty) {
        return [];
      }

      final List<RecentMatch> matches = [];

      for (final raw in response) {
        final data = Map<String, dynamic>.from(raw);

        String? imagePath = data['image_path'];

        if (imagePath != null && imagePath.isNotEmpty) {
          if (!imagePath.startsWith('http')) {
            try {
              final signedUrl = await _supabase.storage
                  .from('user_photos')
                  .createSignedUrl(imagePath, 60 * 15);

              data['image_path'] = signedUrl;
            } catch (_) {
              data['image_path'] = null;
            }
          }
        }

        matches.add(RecentMatch.fromJson(data));
      }

      debugPrint('✅ Recent matches fetched: ${matches.length}');
      return matches;
    } catch (e, st) {
      debugPrint('🛑 Failed to fetch recent matches');
      debugPrint(e.toString());
      debugPrint(st.toString());
      return [];
    }
  }
}
