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
  // 🔥 MAIN DISCOVERY FEED (OPTIMIZED)
  // --------------------------------------------------
  Future<List<DiscoveryUser>> getDiscoveryFeed({
    required String currentMode,
    int radiusKm = 50,
    int limit = 10,
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

      // 2. PARALLEL PROCESSING (Production Speed ⚡)
      final futureUsers = response.map((raw) async {
        final Map<String, dynamic> data = Map<String, dynamic>.from(raw);
        final String? imagePath = data['primary_image_url'];

        // Handle Signing
        if (imagePath != null &&
            imagePath.isNotEmpty &&
            !imagePath.startsWith('http')) {
          try {
            // ⚠️ VERIFY BUCKET NAME: 'user_photos'
            final signedUrl = await _supabase.storage
                .from('user_photos')
                .createSignedUrl(imagePath, 60 * 60);

            data['primary_image_url'] = signedUrl;
          } catch (e) {
            debugPrint('⚠️ Image sign failed for ${data['profile_id']}: $e');
          }
        }

        return DiscoveryUser.fromJson(data);
      });

      // 3. Wait for all to finish instantly
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
  // ⏪ UNDO LAST SWIPE (✅ ADDED THIS MISSING PART)
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
    // 1. Validate Mode (Only Date/BFF supported in DB for now)
    final dbMode = mode.toLowerCase();
    if (dbMode != 'date' && dbMode != 'bff') return;

    try {
      final authUserId = _supabase.auth.currentUser?.id;
      if (authUserId == null) return;

      // 2. Resolve Profile ID from Auth ID
      // The 'profiles' table usually maps 1:1 with auth.users but has its own UUID PK or uses the same UUID.
      // The FK error suggests we must be careful. Let's look it up.
      final profileData = await _supabase
          .from('profiles')
          .select('id')
          .eq('user_id', authUserId)
          .maybeSingle();

      if (profileData == null) {
        debugPrint(
          '⚠️ ensureProfileMode: No profile found for auth user $authUserId',
        );
        return;
      }

      final String profileId = profileData['id'];

      // 3. Check if mode exists
      final existing = await _supabase
          .from('profile_modes')
          .select('id')
          .eq('profile_id', profileId)
          .eq('mode', dbMode)
          .maybeSingle();

      if (existing == null) {
        debugPrint('🆕 Creating new profile mode: $dbMode');
        // 4. Create if missing
        await _supabase.from('profile_modes').insert({
          'profile_id': profileId,
          'mode': dbMode,
          'is_active': true, // Default to active
        });
      } else {
        debugPrint('✅ Profile mode exists: $dbMode');
      }
    } catch (e) {
      debugPrint('❌ Failed to ensure profile mode: $e');
      // Don't rethrow, strictly background task
    }
  }
}
