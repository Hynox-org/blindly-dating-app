import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/models/liked_you_user_model.dart';

// ======================================================
// Provider
// ======================================================
final likedYouRepositoryProvider = Provider<LikedYouRepository>((ref) {
  return LikedYouRepository(Supabase.instance.client);
});

// ======================================================
// Repository
// ======================================================
class LikedYouRepository {
  final SupabaseClient _supabase;

  LikedYouRepository(this._supabase);

// --------------------------------------------------
// ❤️ GET USERS WHO LIKED ME
// --------------------------------------------------
/// Source of truth:
 /// - Auth user → profile_id (inside RPC)
 /// - Swipes → who liked me
 /// - Profiles → name, birth_date → age
 /// - User media → primary photo
 /// - RPC also returns total_likes
 ///
 /// Flutter responsibility:
 /// - Convert media_url → signed URL
 ///
Future<List<LikedYouUser>> getUsersWhoLikedMe() async {
  try {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      debugPrint('⚠️ getUsersWhoLikedMe: user not logged in');
      return [];  
    }

    debugPrint('❤️ Fetching users who liked me');

  // --------------------------------------------------
  // 📡 RPC CALL (DO NOT CHANGE)
  // --------------------------------------------------
    final List<dynamic> response =
      await _supabase.rpc('get_likes_received');
    print('response: $response');

    debugPrint('📡 RPC response length: ${response.length}');
    if (response.isEmpty) {
      debugPrint('ℹ️ No likes found');
      return [];
    }
    // ✅ SAFE: Now response is guaranteed non-empty
    debugPrint('📡 RPC result sample: ${response.first}');

    final List<LikedYouUser> result = [];

  // --------------------------------------------------
  // 🔁 MAP ROWS + SIGN IMAGE URLS
  // --------------------------------------------------
    for (final raw in response) {
      final Map<String, dynamic> data =
        Map<String, dynamic>.from(raw);

      String? imagePath = data['image_path'];

      print(imagePath);
      // Convert storage path → signed URL
      if (imagePath != null && imagePath.isNotEmpty) {
        try {
          if (!imagePath.startsWith('http')) {
            final signedUrl = await _supabase.storage
              .from('user_photos')
              .createSignedUrl(
                imagePath,
                60 * 15, // 15 minutes
            );

              print('signedUrl: $signedUrl');
              // ✅ FIXED: Use 'image_url' to match model
              data['image_url'] = signedUrl;
              print('Signed URL created for $data[image_url]');
          } else {
            // Already a URL, pass through
            data['image_url'] = imagePath;
          }
        } catch (e) {
          debugPrint('⚠️ Image signing failed: $e');
          data['image_url'] = null;
        }
      } else {
        data['image_url'] = null;   
        print('No image path for profile ${data['profile_id']}');
      }

      // 👇 total_likes flows directly into model
      result.add(LikedYouUser.fromJson(data));
    }

    debugPrint('imafgeUrl: ${result.first.imageUrl}');
    debugPrint(
      '✅ LikedYou fetched: ${result.length} | Total Likes: ${result.first.totalLikes}',
    );

   
    return result;
  } catch (e, stack) {
    debugPrint('🛑 Failed to fetch liked users');
    debugPrint(e.toString());
    debugPrint(stack.toString()); 
    return [];
  }
}
Future<void> ignoreLike(String fromProfileId) async {
  try {
    await _supabase.rpc(
      'ignore_like',
      params: {
        'p_from_profile_id': fromProfileId,
      },
    );
  } catch (e) {
    debugPrint('❌ Failed to ignore like: $e');
    rethrow;
  }
}

Future<void> matchUser({
  required String otherProfileId,
  }) async {
    try {
      await _supabase.rpc(
        'create_match',
        params: {
          'p_other_profile_id': otherProfileId,
        },
      );

      debugPrint('✅ Match created for $otherProfileId');
    } catch (e, st) {
      debugPrint('🛑 Match failed');
      debugPrint(e.toString());
      debugPrint(st.toString());
      rethrow;
    }
  }

}