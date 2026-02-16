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
      final List<dynamic> response = await _supabase.rpc('get_likes_received');

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
        final Map<String, dynamic> data = Map<String, dynamic>.from(raw);
        final String profileId = data['profile_id'];
        String? imagePath = data['image_path'];

        if (imagePath == null || imagePath.isEmpty) {
          debugPrint(
            '🔍 Fallback: Fetching photo for user $profileId (${data['display_name']})',
          );
          try {
            // 1. Try user_media (Primary)
            final primaryMedia = await _supabase
                .from('user_media')
                .select('media_url')
                .eq('profile_id', profileId)
                .eq('media_type', 'photo')
                .eq('is_primary', true)
                .maybeSingle();

            if (primaryMedia != null) {
              imagePath = primaryMedia['media_url'];
              debugPrint('✅ Found PRIMARY in user_media: $imagePath');
            } else {
              // 2. Try user_media (Any photo)
              debugPrint('ℹ️ No primary in user_media, trying ANY photo...');
              final anyMedia = await _supabase
                  .from('user_media')
                  .select('media_url')
                  .eq('profile_id', profileId)
                  .eq('media_type', 'photo')
                  .limit(1)
                  .maybeSingle();

              if (anyMedia != null) {
                imagePath = anyMedia['media_url'];
                debugPrint('✅ Found ANY photo in user_media: $imagePath');
              } else {
                debugPrint(
                  'ℹ️ No photos in user_media, trying profile_mode_media...',
                );
                // 3. Try profile_mode_media (via profile_modes)
                final modeMedia = await _supabase
                    .from('profile_mode_media')
                    .select('media_url, profile_modes!inner(profile_id)')
                    .eq('profile_modes.profile_id', profileId)
                    .eq('media_type', 'photo')
                    .order('is_primary', ascending: false)
                    .limit(1)
                    .maybeSingle();

                if (modeMedia != null) {
                  imagePath = modeMedia['media_url'];
                  debugPrint('✅ Found photo in profile_mode_media: $imagePath');
                } else {
                  debugPrint(
                    '❌ Total failure: No photos found for $profileId in ANY table',
                  );
                }
              }
            }
          } catch (e) {
            debugPrint('⚠️ Fallback failed for $profileId: $e');
          }
        }

        // --------------------------------------------------
        // CONVERT STORAGE PATH -> SIGNED URL
        // --------------------------------------------------
        if (imagePath != null && imagePath.isNotEmpty) {
          try {
            if (!imagePath.startsWith('http')) {
              final signedUrl = await _supabase.storage
                  .from('user_photos')
                  .createSignedUrl(
                    imagePath,
                    60 * 60, // 1 hour for better UX
                  );

              debugPrint('🔗 Signed URL generated: $signedUrl');
              data['image_path'] = signedUrl;
            } else {
              data['image_path'] = imagePath;
            }
          } catch (e) {
            debugPrint('⚠️ Image signing failed for $imagePath: $e');
            data['image_path'] = null;
          }
        } else {
          debugPrint('ℹ️ No imagePath for user ${data['display_name']}');
          data['image_path'] = null;
        }

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
        params: {'p_from_profile_id': fromProfileId},
      );
    } catch (e) {
      debugPrint('❌ Failed to ignore like: $e');
      rethrow;
    }
  }

  Future<void> matchUser({required String otherProfileId}) async {
    try {
      await _supabase.rpc(
        'create_match',
        params: {'p_other_profile_id': otherProfileId},
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
