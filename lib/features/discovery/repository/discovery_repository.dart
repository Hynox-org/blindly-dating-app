import 'package:flutter/foundation.dart'; // 👈 Needed for debugPrint
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

  Future<List<DiscoveryUser>> getDiscoveryFeed({
    int radius = 50000, // 5 km
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not logged in');
      }

      // 🔍 STEP 1: VERIFY PARAMETERS BEFORE CALLING
      debugPrint('🚀 RPC CALL PARAMS');
      debugPrint('FUNCTION: get_discovery_feed_final');
      debugPrint('USER ID: $userId');
      debugPrint('RADIUS: $radius');
      debugPrint('LIMIT: $limit');
      debugPrint('OFFSET: $offset');

      // 1️⃣ Call Supabase SQL function
      // We use the name 'get_discovery_feed_final' which maps to 'public.get_discovery_feed_final'
      final List<dynamic> response = await _supabase.rpc(
        'get_discovery_feed_final', 
        params: {
          'p_user_id': userId,
          'p_radius_meters': radius,
          'p_limit': limit,
          'p_offset': offset,
        },
      );

      // 🔍 STEP 2: VERIFY RAW RESPONSE
      debugPrint('🧪 RAW RPC RESPONSE: $response');

      // 2️⃣ Convert to model + sign image URLs
      final List<DiscoveryUser> users = [];

      for (final raw in response) {
        final Map<String, dynamic> data = Map<String, dynamic>.from(raw);

        // SQL returns 'image_url', which might be a path or a full URL depending on previous saves
        final String? imagePath = data['image_url'];

        // 3️⃣ Ensure we have a valid, signed URL
        if (imagePath != null && imagePath.isNotEmpty) {
           // If it's already a full link (starts with http), use it as is
           if (imagePath.startsWith('http')) {
             data['image_url'] = imagePath;
           } else {
             // If it's just a path, sign it
             final signedUrl = await _supabase.storage
                .from('user_photos')
                .createSignedUrl(
                  imagePath,
                  15 * 60, // 15 minutes
                );
             data['image_url'] = signedUrl;
           }
        } else {
          data['image_url'] = null;
        }

        users.add(DiscoveryUser.fromJson(data));
      }

      return users;
    } catch (e, stackTrace) {
  debugPrint('🛑 DISCOVERY RPC FAILED');
  debugPrint(e.toString());
  debugPrint(stackTrace.toString());
  rethrow; // 🔥 LET UI SEE THE ERROR
}

  }
}