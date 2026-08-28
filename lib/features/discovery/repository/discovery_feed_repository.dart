import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:blindly_dating_app/features/matching/domain/models/match_profile.dart';
import 'package:blindly_dating_app/features/matching/repository/matching_repository.dart';
import 'package:blindly_dating_app/features/discovery/domain/models/discovery_landing_data.dart';

// ======================================================
// Provider
// ======================================================
final discoveryFeedRepositoryProvider = Provider<DiscoveryFeedRepository>((ref) {
  return DiscoveryFeedRepository(
    Supabase.instance.client,
    ref.watch(matchingRepositoryProvider),
  );
});

// ======================================================
// Repository
// ======================================================
/// The categorised carousels behind the Discover tab. Two RPCs: the ids for
/// today's categories, then one batched hydration. The flat swipe deck is a
/// different feed and lives in PeopleFeedRepository.
class DiscoveryFeedRepository {
  final SupabaseClient _supabase;
  final MatchingRepository _matching;

  DiscoveryFeedRepository(this._supabase, this._matching);

  // --------------------------------------------------
  // 🌟 CATEGORISED FEED (DISCOVER LANDING)
  // --------------------------------------------------
  Future<DiscoveryLandingData> getDiscoveryFeed({required String mode}) async {
    try {
      final searchMode = mode.toLowerCase();

      // 1. Today's categorised ids. The set is seeded on the date server-side,
      //    so it stays put for 24h and rotates at midnight.
      final List<dynamic>? rows = await _supabase.rpc(
        'get_discovery_categories',
        params: {'p_mode': searchMode},
      );

      final Map<String, List<dynamic>> categories = {};
      final Set<String> allUuids = {};
      for (final row in rows ?? const []) {
        final category = row['category'] as String;
        final id = row['profile_id'] as String;
        categories.putIfAbsent(category, () => <dynamic>[]).add(id);
        allUuids.add(id);
      }

      if (allUuids.isEmpty) {
        return DiscoveryLandingData(feeds: {}, lastRefreshedAt: DateTime.now());
      }

      // 2. Fetch the hydrated profiles
      final List<dynamic>? profilesResponse = await _supabase.rpc(
        'hydrate_discovery_profiles',
        params: {
          'payload': {'p_ids': allUuids.toList(), 'p_mode': searchMode},
        },
      );

      final Map<String, MatchProfile> profileLookup = {};

      if (profilesResponse != null) {
        for (var row in profilesResponse) {
          final profileData = Map<String, dynamic>.from(row);

          profileData['image_urls'] = await _matching.signImages(
            List<dynamic>.from(profileData['image_urls'] ?? []),
          );
          profileData['voice_intro_url'] = await _matching.signVoice(
            profileData['voice_intro_url']?.toString(),
          );

          final pId = profileData['profile_id'] as String;
          profileLookup[pId] = MatchProfile.fromJson(profileData);
        }
      }

      // 3. Re-map into categories
      final Map<String, List<MatchProfile>> finalFeeds = {};
      categories.forEach((categoryName, uuidsList) {
        final List<MatchProfile> usersForCategory = [];
        for (var uuid in uuidsList) {
          if (profileLookup.containsKey(uuid)) {
            usersForCategory.add(profileLookup[uuid]!);
          }
        }
        if (usersForCategory.isNotEmpty) {
          finalFeeds[categoryName] = usersForCategory;
        }
      });

      return DiscoveryLandingData(
        feeds: finalFeeds,
        lastRefreshedAt: DateTime.now(),
      );
    } catch (e) {
      debugPrint('Error fetching discovery feed: $e');
      rethrow;
    }
  }
}
