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
      debugPrint(
        'RADIUS  : ${kDevMode ? _devRadiusMeters : radius}',
      );
      

      final int effectiveRadius =
          kDevMode ? _devRadiusMeters : radius;

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
      // 🔁 MAP RESPONSE
      // --------------------------------------------------
      final List<DiscoveryUser> users = [];

      for (final raw in response) {
        final Map<String, dynamic> data =
            Map<String, dynamic>.from(raw);

        final String? imagePath = data['media_url'];

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
