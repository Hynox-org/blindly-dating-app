import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:blindly_dating_app/features/matching/domain/models/match_profile.dart';
import 'package:blindly_dating_app/features/matching/repository/matching_repository.dart';
import 'package:blindly_dating_app/features/discovery/domain/models/discovery_landing_data.dart';

// ======================================================
// Provider
// ======================================================
final discoveryFeedRepositoryProvider = Provider<DiscoveryFeedRepository>((
  ref,
) {
  return DiscoveryFeedRepository(
    Supabase.instance.client,
    ref.watch(matchingRepositoryProvider),
  );
});

// ======================================================
// Pure mapping (no Supabase — this is what the tests drive)
// ======================================================
/// Groups `get_discovery_categories` rows into `category -> [profile_id]`,
/// preserving the server's order. Rows missing either field are dropped
/// rather than thrown on: one bad row should not empty the whole page.
Map<String, List<String>> parseCategoryRows(List<dynamic>? rows) {
  final categories = <String, List<String>>{};
  for (final row in rows ?? const []) {
    if (row is! Map) continue;
    final category = row['category'];
    final id = row['profile_id'];
    if (category is! String || id is! String) continue;
    if (category.isEmpty || id.isEmpty) continue;
    categories.putIfAbsent(category, () => <String>[]).add(id);
  }
  return categories;
}

/// Re-hangs the hydrated profiles off the category ids. Ids with no hydrated
/// profile (filtered out server-side between the two calls) are skipped, and
/// a category left with nothing is dropped so the UI never renders an empty
/// carousel.
Map<String, List<MatchProfile>> assembleFeeds(
  Map<String, List<String>> categories,
  Map<String, MatchProfile> profileLookup,
) {
  final feeds = <String, List<MatchProfile>>{};
  categories.forEach((category, ids) {
    final users = <MatchProfile>[];
    final seen = <String>{};
    for (final id in ids) {
      final profile = profileLookup[id];
      // The same profile can be listed twice in one category by the server
      // seed; a duplicate key in a ListView is a crash, not a cosmetic bug.
      if (profile != null && seen.add(id)) users.add(profile);
    }
    if (users.isNotEmpty) feeds[category] = users;
  });
  return feeds;
}

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

      final categories = parseCategoryRows(rows);
      final allUuids = {for (final ids in categories.values) ...ids};

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

      // Signing is a round-trip per profile; in a loop that was ~50 of them
      // back to back. They don't depend on each other, so fire them together.
      final profileLookup = Map.fromEntries(
        await Future.wait([
          for (final row in profilesResponse ?? const [])
            if (row is Map) _hydrate(Map<String, dynamic>.from(row)),
        ]),
      )..remove(null);

      return DiscoveryLandingData(
        feeds: assembleFeeds(categories, profileLookup.cast()),
        lastRefreshedAt: DateTime.now(),
      );
    } catch (e) {
      debugPrint('Error fetching discovery feed: $e');
      rethrow;
    }
  }

  Future<MapEntry<String?, MatchProfile?>> _hydrate(
    Map<String, dynamic> data,
  ) async {
    final id = data['profile_id'];
    if (id is! String) return const MapEntry(null, null);

    final signed = await Future.wait([
      _matching.signImages(List<dynamic>.from(data['image_urls'] ?? [])),
      _matching.signVoice(data['voice_intro_url']?.toString()),
    ]);
    data['image_urls'] = signed[0];
    data['voice_intro_url'] = signed[1];

    return MapEntry(id, MatchProfile.fromJson(data));
  }
}
