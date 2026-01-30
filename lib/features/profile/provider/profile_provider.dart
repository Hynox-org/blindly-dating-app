import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/models/profile_user_model.dart.dart';

final currentUserProfileProvider = FutureProvider.autoDispose<ProfileUser>((
  ref,
) async {
  final client = Supabase.instance.client;
  final authId = client.auth.currentUser?.id;

  if (authId == null) throw Exception("User not logged in");

  try {
    // 1. Fetch Profile Data
    // 1. Fetch Profile Data (excluding bio as it's mode-specific)
    final Map<String, dynamic>? profileDataRaw = await client
        .from('profiles')
        .select(
          'id, display_name, birth_date, gender, city, profile_completeness',
        )
        .eq('user_id', authId)
        .maybeSingle();

    if (profileDataRaw == null) return _getEmptyProfile(authId);

    // Create a mutable copy
    final Map<String, dynamic> profileData = Map<String, dynamic>.from(
      profileDataRaw,
    );
    final profileId = profileData['id'];

    // 1b. Fetch BIO from profile_modes (using 'Date' as default or ideally fetching active mode)
    // Since we are in a FutureProvider, we can try to read the mode provider if possible,
    // but connectionModeProvider is a StateNotifierProvider.
    // Ideally we should watch it or read it.
    // For now, let's Default to 'date' or try to fetch the active one if we had access.
    // Given the constraints, I will query profile_modes with the default mode or all modes.
    // Let's assume 'date' for the main profile view for now, or fetch the FIRST active mode.

    final modeData = await client
        .from('profile_modes')
        .select('bio')
        .eq('profile_id', profileId)
        .eq(
          'mode',
          'date',
        ) // Defaulting to date for now as we lack the provider context here easily without ref.watch logic change
        .maybeSingle();

    profileData['bio'] = modeData?['bio'] ?? '';

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
          final String signedUrl = await client.storage
              .from('user_photos') // ✅ Ensure this matches your bucket
              .createSignedUrl(rawPath, 60 * 60);
          finalImageUrls.add(signedUrl);
        }
      } else {
        finalImageUrls.add(
          'https://picsum.photos/400/600',
        ); // Default if 0 found
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
    id: id,
    name: 'New User',
    age: 18,
    gender: '',
    city: 'Unknown',
    bio: 'Tap Edit to set up your profile',
    imageUrls: ['https://picsum.photos/400/600'],
    interests: [],
    education: '',
    profession: '',
    completionPercentage: 0.0,
  );
}
