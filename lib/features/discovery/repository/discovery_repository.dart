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
    required String mode,
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
      debugPrint('MODE    : $mode');
      debugPrint('LIMIT   : $limit');
      debugPrint('OFFSET  : $offset');
      debugPrint('RADIUS  : ${kDevMode ? _devRadiusMeters : radius}');

      final int effectiveRadius = kDevMode ? _devRadiusMeters : radius;

      // --------------------------------------------------
      // 🧩 DYNAMIC PREFERENCE LOGIC (CLIENT SIDE)
      // --------------------------------------------------
      final profileData = await _supabase
          .from('profiles')
          .select('gender')
          .eq('user_id', authUser.id)
          .maybeSingle();

      final String? gender = profileData?['gender'];
      List<String> lookingFor = [];

      if (gender != null) {
        if (mode.toLowerCase() == 'date') {
          // Date Mode: Opposite Gender
          if (gender == 'M')
            lookingFor = ['F'];
          else if (gender == 'F')
            lookingFor = ['M'];
          else
            lookingFor = ['M', 'F', 'NB']; // NB sees everyone
        } else if (mode.toLowerCase() == 'bff') {
          // BFF Mode: Same Gender + NB?
          // Simplification: Same gender + NB
          lookingFor = [gender];
          if (gender != 'NB') lookingFor.add('NB');
        }
      }

      // If still empty (gender unknown), default to Everyone
      if (lookingFor.isEmpty) {
        lookingFor = ['M', 'F', 'NB'];
      }

      debugPrint(
        '🎯 DYNAMIC LOOKING FOR: $lookingFor (Gender: $gender, Mode: $mode)',
      );

      // --------------------------------------------------
      // 📡 RPC CALL (V3)
      // --------------------------------------------------
      final List<dynamic> response =
          (await _supabase.rpc(
            'get_discovery_feed_v3', // calling new V3
            params: {
              'p_mode': mode.toLowerCase(),
              'p_radius_meters': effectiveRadius,
              'p_limit': limit,
              'p_offset': offset,
              'p_looking_for': lookingFor, // Passing dynamic param
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

  // --------------------------------------------------
  // 👆 ACTION: SWIPE
  // --------------------------------------------------
  Future<void> swipeUser({
    required String targetUserId,
    required bool isLike,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    try {
      await _supabase.from('swipes').upsert({
        'actor_id': user.id,
        'target_id': targetUserId,
        'is_like': isLike,
        'swiped_at': DateTime.now().toIso8601String(),
      });
      debugPrint('✅ Swipe Recorded: $targetUserId (Like: $isLike)');
    } catch (e) {
      debugPrint('❌ Failed to record swipe: $e');
      throw e;
    }
  }
}
