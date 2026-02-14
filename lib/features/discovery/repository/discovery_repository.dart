import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Make sure this path points to your actual model file
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

  /// Huge radius when dev mode is ON (20,000 KM to cover the world)
  static const int _devRadiusKm = 20000;

  // --------------------------------------------------
  // 🔥 MAIN DISCOVERY FEED (OPTIMIZED FOR LISTS)
  // --------------------------------------------------
  Future<List<DiscoveryUser>> getDiscoveryFeed({
    required String currentMode,
    int radiusKm = 50,
    int limit = 20, // ✅ Production Grade: Batch size increased
    int offset = 0,
  }) async {
    try {
      final authUser = _supabase.auth.currentUser;
      if (authUser == null) {
        throw Exception('User not logged in');
      }

      final int effectiveRadius = kDevMode ? _devRadiusKm : radiusKm;

      debugPrint('🚀 DISCOVERY RPC CALL: get_discovery_prospects');
      debugPrint('MODE    : $currentMode');
      debugPrint('RADIUS  : $effectiveRadius KM');
      debugPrint('LIMIT   : $limit');
      debugPrint('OFFSET  : $offset');

      // 1. Call DB
      final List<dynamic>? response = await _supabase.rpc(
        'get_discovery_prospects',
        params: {
          'search_mode': currentMode,
          'radius_km': effectiveRadius,
          'limit_count': limit,
          'offset_count': offset,
        },
      );

      if (response == null || response.isEmpty) return [];

      debugPrint('🧪 DISCOVERY ROWS FOUND: ${response.length}');

      // 2. PARALLEL PROCESSING (Iterate Users)
      final futureUsers = response.map((raw) async {
        final Map<String, dynamic> data = Map<String, dynamic>.from(raw);

        // 🔍 EXTRACT LIST: Get the array of paths from DB (Column: image_urls)
        // Note: Postgres arrays often come as List<dynamic> in Supabase Flutter
        final List<dynamic> rawPaths = data['image_urls'] ?? [];
        final List<String> signedUrls = [];

        // 🔄 LOOP & SIGN: Process each image in the list
        for (var item in rawPaths) {
          String imagePath = item.toString();

          // Only sign if it looks like a path (not a full http URL)
          if (imagePath.isNotEmpty && !imagePath.startsWith('http')) {
            try {
              // 🛠️ Remove leading slash if present
              if (imagePath.startsWith('/')) {
                imagePath = imagePath.substring(1);
              }

              // ⚠️ CRITICAL: Ensure bucket name is correct ('user_photos')
              final signedUrl = await _supabase.storage
                  .from('user_photos')
                  .createSignedUrl(imagePath, 60 * 60); // 1 Hour Expiry

              signedUrls.add(signedUrl);
            } catch (e) {
              debugPrint('⚠️ Image sign failed for path: $imagePath');
              // Optional: Add original path or skip? We skip to keep UI clean.
            }
          } else if (imagePath.isNotEmpty) {
            // It's already a full URL (e.g. Google Auth photo), keep it.
            signedUrls.add(imagePath);
          }
        }

        // ✅ UPDATE DATA: Replace the raw paths with the signed URLs
        data['image_urls'] = signedUrls;

        // ✅ Ensure numeric types are handled safely
        if (data['age'] == null) data['age'] = 0;
        if (data['distance_km'] == null) data['distance_km'] = 0.0;

        return DiscoveryUser.fromJson(data);
      });

      // 3. Wait for all users to be processed
      final List<DiscoveryUser> users = await Future.wait(futureUsers);

      return users;
    } catch (e, stackTrace) {
      debugPrint('🛑 DISCOVERY FEED FAILED');
      debugPrint(e.toString());
      debugPrint(stackTrace.toString());
      rethrow;
    }
  }

  // --------------------------------------------------
  // ⏪ UNDO LAST SWIPE
  // --------------------------------------------------
  Future<bool> undoLastSwipe() async {
    try {
      final response = await _supabase.rpc('undo_last_swipe');
      return response as bool;
    } catch (e) {
      debugPrint('❌ Undo RPC failed: $e');
      return false;
    }
  }

  // --------------------------------------------------
  // 🛠 ENSURE PROFILE MODE EXISTS
  // --------------------------------------------------
  Future<void> ensureProfileMode(String mode) async {
    final dbMode = mode.toLowerCase();
    if (dbMode != 'date' && dbMode != 'bff') return;

    try {
      final authUserId = _supabase.auth.currentUser?.id;
      if (authUserId == null) return;

      final profileData = await _supabase
          .from('profiles')
          .select('id')
          .eq('user_id', authUserId)
          .maybeSingle();

      if (profileData == null) return;

      final String profileId = profileData['id'];

      final existing = await _supabase
          .from('profile_modes')
          .select('id')
          .eq('profile_id', profileId)
          .eq('mode', dbMode)
          .maybeSingle();

      if (existing == null) {
        await _supabase.from('profile_modes').insert({
          'profile_id': profileId,
          'mode': dbMode,
          'is_active': true,
        });
      }
    } catch (e) {
      debugPrint('❌ Failed to ensure profile mode: $e');
    }
  }

  // --------------------------------------------------
  // 🔄 SOURCE OF TRUTH: PROFILES TABLE
  // --------------------------------------------------
  Future<String> fetchCurrentMode() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return 'date';

      final response = await _supabase
          .from('profiles')
          .select('current_mode')
          .eq('user_id', userId)
          .maybeSingle();

      if (response != null && response['current_mode'] != null) {
        return response['current_mode'] as String;
      }
    } catch (e) {
      debugPrint('⚠️ Failed to fetch current mode from DB: $e');
    }
    return 'date';
  }

  Future<void> updateCurrentMode(String mode) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      await _supabase
          .from('profiles')
          .update({'current_mode': mode})
          .eq('user_id', userId);
    } catch (e) {
      debugPrint('❌ Failed to update current mode in DB: $e');
    }
  }
}
