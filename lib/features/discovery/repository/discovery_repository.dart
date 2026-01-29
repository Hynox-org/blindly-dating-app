import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../features/discovery/domain/models/discovery_user_model.dart';

// ======================================================
// Provider
// ======================================================
final discoveryRepositoryProvider = Provider<DiscoveryRepository>((ref) {
  return DiscoveryRepository(Supabase.instance.client);
});

// ======================================================
// Repository
// ======================================================
class DiscoveryRepository {
  final SupabaseClient _supabase;

  DiscoveryRepository(this._supabase);

  // --------------------------------------------------
  // 🔧 CONFIG
  // --------------------------------------------------

  /// Dev mode ignores distance limits
  static const bool kDevMode = true;

  /// Huge radius when dev mode is ON (≈ entire world)
  static const int _devRadiusMeters = 20000000;

  // --------------------------------------------------
  // 🔁 UPDATE DISCOVERY MODE (dating / bff)
  // --------------------------------------------------
  Future<void> updateDiscoveryMode(String mode) async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      throw Exception('User not logged in');
    }

    final response = await _supabase
        .from('profiles')
        .update({'discovery_mode': mode})
        .eq('user_id', user.id)
        .select(); // 👈 FORCE RESPONSE

    debugPrint('✅ discovery_mode update response: $response');
  }

  // --------------------------------------------------
  // 🔥 MAIN DISCOVERY FEED
  // --------------------------------------------------
  ///
  /// Supabase is the source of truth.
  /// - discovery_mode is read from profiles table
  /// - gender logic is handled inside SQL
  /// - swipe filtering is handled inside SQL
  ///
  Future<List<DiscoveryUser>> getDiscoveryFeed({
    int radius = 5000, // meters
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final authUser = _supabase.auth.currentUser;
      if (authUser == null) {
        throw Exception('User not logged in');
      }

      // --------------------------------------------------
      // 🧪 DEBUG LOGS
      // --------------------------------------------------
      debugPrint('🚀 DISCOVERY RPC CALL');
      debugPrint('USER ID : ${authUser.id}');
      debugPrint('LIMIT   : $limit');
      debugPrint('OFFSET  : $offset');
      debugPrint('RADIUS  : ${kDevMode ? _devRadiusMeters : radius}');

      final int effectiveRadius = kDevMode ? _devRadiusMeters : radius;

      // --------------------------------------------------
      // 📡 RPC CALL
      // --------------------------------------------------
      final List<dynamic> response =
          (await _supabase.rpc(
            'get_discovery_feed_final',
            params: {
              'p_radius_meters': effectiveRadius,
              'p_limit': limit,
              'p_offset': offset,
            },
          )) ??
          [];

      debugPrint('🧪 DISCOVERY ROWS: ${response.length}');

      // --------------------------------------------------
      // 🛠️ FALLBACK: MANUALLY FETCH IMAGES
      // --------------------------------------------------
      // If RPC fails to join images, we fetch them manually here.
      Map<String, String> manualMediaMap = {};

      if (response.isNotEmpty) {
        try {
          final List<dynamic> profileIds = response
              .map((r) => r['profile_id'])
              .toList();

          // Workaround for undefined 'in_' method: Fetch in parallel
          final futures = profileIds.map(
            (pid) => _supabase
                .from('user_media')
                .select('profile_id, media_url')
                .eq('profile_id', pid)
                .eq('is_primary', true)
                .maybeSingle(),
          );

          final List<dynamic> results = await Future.wait(futures);

          for (final item in results) {
            if (item != null) {
              final pid = item['profile_id'] as String;
              final url = item['media_url'] as String?;
              if (url != null && url.isNotEmpty) {
                manualMediaMap[pid] = url;
              }
            }
          }
          debugPrint(
            '📸 Manually fetched ${manualMediaMap.length} images from user_media',
          );
        } catch (e) {
          debugPrint('⚠️ Failed to fetch manual images: $e');
        }
      }

      // --------------------------------------------------
      // 🔁 MAP RESPONSE
      // --------------------------------------------------
      final List<DiscoveryUser> users = [];

      for (final raw in response) {
        final Map<String, dynamic> data = Map<String, dynamic>.from(raw);

        final String pid = data['profile_id'];

        // Check potential keys for the image (RPC keys OR Manual Fetch)
        final String? imagePath =
            data['media_url'] ??
            data['avatar_url'] ??
            data['photo_url'] ??
            data['image_url'] ??
            manualMediaMap[pid];

        // --------------------------------------------------
        // 🖼️ HANDLE MEDIA URLS (FIXED)
        // --------------------------------------------------
        if (imagePath != null && imagePath.isNotEmpty) {
          if (!imagePath.startsWith('http')) {
            final signedUrl = await _supabase.storage
                .from('user_photos')
                .createSignedUrl(imagePath, 15 * 60);

            // ✅ IMPORTANT: write back to SAME key model reads
            data['media_url'] = signedUrl;
          } else {
            // ✅ Ensure media_url is populated even if from avatar_url/photo_url
            data['media_url'] = imagePath;
          }
        } else {
          data['media_url'] = null;
        }

        users.add(DiscoveryUser.fromJson(data));
      }

      return users;
    } catch (e, stackTrace) {
      debugPrint('🛑 DISCOVERY FEED FAILED');
      debugPrint(e.toString());
      debugPrint(stackTrace.toString());
      rethrow;
    }
  }
}
