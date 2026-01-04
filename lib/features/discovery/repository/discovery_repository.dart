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

  // ⚡ DEV MODE FLAG
  static const bool kDevMode = true;

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
        await _signProfileImage(data);
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

  /// 🛠️ DEV MODE: Fetch ALL profiles directly from tables
  Future<List<DiscoveryUser>> getAllProfilesDev({int limit = 50}) async {
    try {
      debugPrint('🚧 DEV MODE: Fetching ALL profiles directly...');

      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not logged in');

      // 1. Fetch raw profiles
      final List<dynamic> profiles = await _supabase
          .from('profiles')
          .select()
          .neq('id', userId) // Don't show self
          .limit(limit);

      debugPrint('🚧 DEV MODE: Found ${profiles.length} profiles');

      final List<DiscoveryUser> users = [];

      for (final raw in profiles) {
        final Map<String, dynamic> data = Map<String, dynamic>.from(raw);
        final profileId = data['id'];

        // 2. Fetch one photo for this user
        final mediaResponse = await _supabase
            .from('user_media')
            .select('media_url')
            .eq('profile_id', profileId)
            .eq('media_type', 'photo')
            .limit(1)
            .maybeSingle();

        if (mediaResponse != null) {
          data['image_url'] = mediaResponse['media_url'];
        }

        // 3. Map Fields for DiscoveryUser model
        data['profile_id'] = profileId;
        data['distance_meters'] = 0; // Dummy
        data['match_score'] = 100; // Dummy
        data['interest_match_count'] = 0;
        data['lifestyle_match_count'] = 0;

        // Calculate Age if birth_date exists
        if (data['birth_date'] != null) {
          try {
            final dob = DateTime.parse(data['birth_date']);
            final now = DateTime.now();
            int age = now.year - dob.year;
            if (now.month < dob.month ||
                (now.month == dob.month && now.day < dob.day)) {
              age--;
            }
            data['age'] = age;
          } catch (_) {
            data['age'] = 25; // Default fallback
          }
        } else {
          data['age'] = 25; // Default fallback
        }

        // Sign the image URL
        await _signProfileImage(data);

        users.add(DiscoveryUser.fromJson(data));
      }

      return users;
    } catch (e, stack) {
      debugPrint('🛑 DEV MODE FETCH FAILED: $e');
      debugPrint(stack.toString());
      rethrow;
    }
  }

  /// Helper to sign image URLs
  Future<void> _signProfileImage(Map<String, dynamic> data) async {
    // SQL returns 'image_url', which might be a path or a full URL depending on previous saves
    final String? imagePath = data['image_url'];

    // Ensure we have a valid, signed URL
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
  }
}
