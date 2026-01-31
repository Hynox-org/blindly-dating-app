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
}