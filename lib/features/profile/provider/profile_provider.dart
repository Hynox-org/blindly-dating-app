import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/models/profile_user_model.dart.dart';

final currentUserProfileProvider = FutureProvider.autoDispose<ProfileUser>((ref) async {
  final client = Supabase.instance.client;
  final authId = client.auth.currentUser?.id;

  if (authId == null) throw Exception("User not logged in");

  try {
    // 1. Fetch Profile Data
    final profileData = await client
        .from('profiles')
        .select('id, display_name, birth_date, gender, city, bio, profile_completeness') 
        .eq('user_id', authId)
        .maybeSingle();

    if (profileData == null) return _getEmptyProfile(authId);

    final profileId = profileData['id'];

    // 2. Fetch Up to 3 Images (Primary first)
    List<String> finalImageUrls = [];
    
    try {
      final List<dynamic> mediaData = await client
          .from('user_media')
          .select('media_url') 
          .eq('profile_id', profileId)
          .eq('media_type', 'photo')      
          .order('is_primary', ascending: false) // Primary image is index 0
          .order('display_order', ascending: true)
          .limit(3); // ✅ FETCH UP TO 3 IMAGES

      if (mediaData.isNotEmpty) {
        for (var item in mediaData) {
          final String rawPath = item['media_url'];
          // Create signed URL for each image
          final String signedUrl = await client
              .storage
              .from('user_photos') // ✅ Ensure this matches your bucket
              .createSignedUrl(rawPath, 60 * 60);
          finalImageUrls.add(signedUrl);
        }
      } else {
        finalImageUrls.add('https://picsum.photos/400/600'); // Default if 0 found
      }
    } catch (e) {
      debugPrint('⚠️ Media Error: $e');
      finalImageUrls.add('https://picsum.photos/400/600');
    }

    return ProfileUser.fromJson(profileData, finalImageUrls);

  } catch (e) {
    debugPrint('❌ CRITICAL ERROR: $e');
    return _getEmptyProfile(authId);
  }
});

ProfileUser _getEmptyProfile(String id) {
  return ProfileUser(
    id: id, name: 'New User', age: 18, gender: '', city: 'Unknown', bio: 'Tap Edit to set up your profile', imageUrls: ['https://picsum.photos/400/600'], interests: [], education: '', profession: '', completionPercentage: 0.0,
  );
}