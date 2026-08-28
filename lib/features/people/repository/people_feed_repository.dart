import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:blindly_dating_app/features/matching/domain/models/match_profile.dart';
import 'package:blindly_dating_app/features/matching/repository/matching_repository.dart';

// ======================================================
// Provider
// ======================================================
final peopleFeedRepositoryProvider = Provider<PeopleFeedRepository>((ref) {
  return PeopleFeedRepository(
    Supabase.instance.client,
    ref.watch(matchingRepositoryProvider),
  );
});

// ======================================================
// Repository
// ======================================================
/// The flat card stack behind the People tab. One RPC per batch, already
/// hydrated — the categorised carousels on Discover are a different feed and
/// live in DiscoveryFeedRepository.
class PeopleFeedRepository {
  final SupabaseClient _supabase;
  final MatchingRepository _matching;

  PeopleFeedRepository(this._supabase, this._matching);

  // --------------------------------------------------
  // 🔥 DECK FEED (FLAT LIST FOR SWIPER CARD)
  // --------------------------------------------------
  Future<(List<MatchProfile>, bool)> getPeopleFeed({
    required String currentMode,
    int limit = 20,
  }) async {
    try {
      final authUser = _supabase.auth.currentUser;
      if (authUser == null) throw Exception('User not logged in');

      // Swiped/blocked profiles are excluded server-side, so every call returns
      // the next unseen batch — no offset needed.
      final List<dynamic>? response = await _supabase.rpc(
        'get_discovery_prospects',
        params: {'p_mode': currentMode, 'p_limit': limit},
      );

      if (response == null || response.isEmpty) {
        return (<MatchProfile>[], true);
      }

      final exhausted = response.length < limit;

      final futureUsers = response.map((raw) async {
        final Map<String, dynamic> data = Map<String, dynamic>.from(raw);

        // Sign media as it comes back raw from the RPC
        data['image_urls'] = await _matching.signImages(
          List<dynamic>.from(data['image_urls'] ?? []),
        );
        data['voice_intro_url'] = await _matching.signVoice(
          data['voice_intro_url']?.toString(),
        );

        return MatchProfile.fromJson(data);
      });

      final users = await Future.wait(futureUsers);
      return (users, exhausted);
    } catch (e, stackTrace) {
      debugPrint('🛑 PEOPLE FEED FAILED: $e');
      debugPrint(stackTrace.toString());
      rethrow;
    }
  }
}
