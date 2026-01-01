import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:path/path.dart' as p;

class VerificationRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Uploads the selfie image to the 'user_selfies' bucket.
  /// Returns the full public URL or storage path.
  Future<String> uploadSelfie(File file, String userId) async {
    try {
      final String extension = p.extension(file.path);
      final String fileName = '${const Uuid().v4()}$extension';
      final String filePath = '$userId/$fileName';

      await _supabase.storage
          .from('user_selfies')
          .upload(
            filePath,
            file,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
          );

      // We return the filePath (storage path) similar to MediaRepository
      // But for verification, we might need a signed URL later or the system processes it by path.
      // The prompt asked for "selfie_video_url text null" in verifications table and "media_url" in user_media.
      // Usually storing the path is safer if we use signed URLs for display.
      return filePath;
    } catch (e) {
      throw Exception('Failed to upload verification selfie: $e');
    }
  }

  /// Creates a verification request in the database and adds to user media.
  Future<void> createVerificationRequest({
    required String userId,
    required String selfieStoragePath,
    required String
    poseName, // e.g., "palm_open" to store in review_notes or similar if needed
  }) async {
    try {
      // 1. Get Profile ID
      final profileResponse = await _supabase
          .from('profiles')
          .select('id')
          .eq('user_id', userId)
          .maybeSingle();

      if (profileResponse == null) {
        throw Exception('Profile not found for user: $userId');
      }
      final String profileId = profileResponse['id'];

      // 2. Insert into 'verifications' table
      // We store the storage path in selfie_video_url (reusing column for image/video) based on schema
      await _supabase.from('verifications').insert({
        'profile_id': profileId,
        'verification_type': 'liveness', // Valid values: {liveness, gov_id}
        'provider': 'aws_rekognition', // Default as per schema, or 'internal'
        'attempt_number': 1, // Logic to increment? For now 1.
        'status': 'pending',
        'selfie_video_url':
            selfieStoragePath, // Using this column for the visual proof
        'review_notes': 'Target Pose: $poseName',
      });

      // 3. Calculate next display_order for user_media
      final countResponse = await _supabase
          .from('user_media')
          .select('display_order')
          .eq('profile_id', profileId)
          .order('display_order', ascending: false)
          .limit(1)
          .maybeSingle();

      int nextOrder = 0;
      if (countResponse != null) {
        nextOrder = (countResponse['display_order'] as int) + 1;
      }

      // 4. Insert into 'user_media' table
      await _supabase.from('user_media').insert({
        'profile_id': profileId,
        'media_url': selfieStoragePath,
        'media_type': 'photo',
        'display_order': nextOrder,
        'is_primary': false,
        'moderation_status': 'pending',
        'file_size_bytes': 0, // We could get this from File object if passed
      });
    } catch (e) {
      throw Exception('Failed to create verification request: $e');
    }
  }
}
