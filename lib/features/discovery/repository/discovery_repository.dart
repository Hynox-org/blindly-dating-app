import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../features/discovery/domain/models/discovery_user_model.dart';

// 1. Provider
final discoveryRepositoryProvider = Provider<DiscoveryRepository>((ref) {
  return DiscoveryRepository(Supabase.instance.client);
});

// 2. Repository
class DiscoveryRepository {
  final SupabaseClient _supabase;

  DiscoveryRepository(this._supabase);

  // ✅ CONSTANTS
  static const bool kDevMode =
      true; // Set to true to bypass checks (like OTP) for testing

  /// 🔥 MAIN DISCOVERY FEED
  Future<List<DiscoveryUser>> getDiscoveryFeed({
  int radius = 5000,
  int limit = 20,
  int offset = 0, // ✅ ADD THIS
}) async {
  try {
    final authUser = _supabase.auth.currentUser;
    if (authUser == null) {
      throw Exception('User not logged in');
    }

    debugPrint('🚀 RPC CALL PARAMS');
    debugPrint('FUNCTION: get_discovery_feed_final');
    debugPrint('RADIUS: $radius');
    debugPrint('LIMIT: $limit');
    debugPrint('OFFSET: $offset');

    final int effectiveRadius = kDevMode ? 20000000 : radius;

    final List<dynamic> response = await _supabase.rpc(
      'get_discovery_feed_final',
      params: {
        'p_radius_meters': effectiveRadius,
        'p_limit': limit,
        'p_offset': offset, // ✅ PASS TO SQL
      },
    );

    debugPrint('🧪 RAW RPC RESPONSE COUNT: ${response.length}');

    final List<DiscoveryUser> users = [];

    for (final raw in response) {
      final Map<String, dynamic> data = Map<String, dynamic>.from(raw);

      final String? imagePath = data['image_url'];

      if (imagePath != null && imagePath.isNotEmpty) {
        if (imagePath.startsWith('http')) {
          data['image_url'] = imagePath;
        } else {
          final signedUrl = await _supabase.storage
              .from('user_photos')
              .createSignedUrl(imagePath, 15 * 60);
          data['image_url'] = signedUrl;
        }
      } else {
        data['image_url'] = null;
      }

      users.add(DiscoveryUser.fromJson(data));
    }

    return users;
  } catch (e, st) {
    debugPrint('🛑 DISCOVERY RPC FAILED');
    debugPrint(e.toString());
    debugPrint(st.toString());
    rethrow;
  }
}

}
