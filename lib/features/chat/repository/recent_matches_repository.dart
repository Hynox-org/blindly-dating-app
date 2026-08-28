import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:blindly_dating_app/features/chat/data/match_repository.dart';

// ======================================================
// PROVIDERS
// ======================================================

final matchRepositoryProvider = Provider<MatchRepository>((ref) {
  return MatchRepository(Supabase.instance.client);
});

final recentMatchesRepositoryProvider =
    Provider<RecentMatchesRepository>((ref) {
  final matchRepo = ref.read(matchRepositoryProvider);

  return RecentMatchesRepository(
    Supabase.instance.client,
    matchRepo,
  );
});

// ======================================================
// REPOSITORY
// ======================================================

class RecentMatchesRepository {
  final SupabaseClient _supabase;
  final MatchRepository _matchRepository;

  RecentMatchesRepository(
    this._supabase,
    this._matchRepository,
  );

  // --------------------------------------------------
  // 🔥 GET RECENT MATCHES
  // --------------------------------------------------

  Future<List<Map<String, dynamic>>> getRecentMatches(
    String profileId,
  ) async {
    try {
      debugPrint('🔍 === DEBUG getRecentMatches($profileId) ===');

      // -------------------------------------------
      // STEP 1 — RAW MATCHES
      // -------------------------------------------
      final rawMatches = await _supabase
          .from('matches')
          .select(
              'id, user_a_id, user_b_id, status, created_at,expires_at,chat_started')
          .eq('status', 'active')
          .eq('chat_started', false)  // ✅ FIXED: Only unstarted chats
          .or('user_a_id.eq.$profileId,user_b_id.eq.$profileId')
          .order('created_at', ascending: false);

      if (rawMatches.isEmpty) return [];
      print('✅ Raw matches loaded: ${rawMatches.length}');
      print('🔍 Raw matches data: $rawMatches');
      final List<Map<String, dynamic>> matches = [];
      final Set<String> processedMatchIds = {};  // ✅ DEDUPLICATION

      // -------------------------------------------
      // STEP 2 — PROCESS EACH MATCH
      // -------------------------------------------
      for (final rawMatch in rawMatches) {
        final data = Map<String, dynamic>.from(rawMatch);
        final matchId = data['id'].toString();

        // ✅ SKIP if already processed (defensive against query duplicates)
        if (processedMatchIds.contains(matchId)) {
          print('⏭️ Skipping duplicate match: $matchId');
          continue;
        }
        processedMatchIds.add(matchId);

        final otherProfileId =
            data['user_a_id'] == profileId
                ? data['user_b_id']
                : data['user_a_id'];
        
        print('🔍 Processing match $matchId - Other Profile ID: $otherProfileId');
        
        // -------------------------------------------
        // FETCH PROFILE
        // -------------------------------------------
        final profileRes = await _supabase
            .from('profiles')
            .select('id, display_name, user_id')
            .eq('id', otherProfileId)
            .maybeSingle();
        print('🔍 Profile query result for $otherProfileId: $profileRes');
        
        if (profileRes == null) continue;

        debugPrint('✅ Profile loaded: ${profileRes['display_name']}');

        final profile = Map<String, dynamic>.from(profileRes);

        // -------------------------------------------
        // FETCH PHOTO VIA MatchRepository
        // -------------------------------------------
        final photoUrl = await _matchRepository
            .getFirstPhotoUrl(profile['user_id']);

        // ✅ ENHANCED DATA
        data['display_name'] = profile['display_name'];
        data['photo_url'] = photoUrl;
        data['other_profile_id'] = otherProfileId;
        data['expiry_at'] = data['expires_at'];
        
        print('✅ Enriched match data for $matchId: ${data['display_name']}, photoUrl: $photoUrl, expiryAt: ${data['expiry_at']}, otherProfileId: ${data['other_profile_id']}, chatStarted: ${data['chat_started']}, status: ${data['status']}, created_at: ${data['created_at']}');
        print('✅ photo URLs loaded for matches: $photoUrl');

        matches.add(data);  // ✅ SINGLE ADD (removed duplicate)
      }

      debugPrint('✅ FINAL matches: ${matches.length}');
      return matches;
    } catch (e, st) {
      debugPrint('🛑 CRASH: $e');
      debugPrint(st.toString());
      return [];
    }
  }
}
