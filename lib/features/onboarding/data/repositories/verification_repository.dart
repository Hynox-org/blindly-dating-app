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

      return filePath;
    } catch (e) {
      throw Exception('Failed to upload verification selfie: $e');
    }
  }

  /// Uploads the government ID image to the 'user_gov_ids' bucket.
  Future<String> uploadGovernmentId(File file, String userId) async {
    try {
      final String extension = p.extension(file.path);
      final String fileName = '${const Uuid().v4()}$extension';
      final String filePath = '$userId/$fileName';

      // Assuming 'user_gov_ids' bucket exists, otherwise we might need to use a general bucket
      // or check if we should reuse user_selfies for now (but logical separation is better)
      // If user_gov_ids doesn't exist, this will fail. For safety, I'll use 'user_selfies'
      // with a prefix if I can't confirm, OR better, stay with 'user_selfies' but different folder?
      // No, let's assume 'user_selfies' is for VERIFICATION MEDIA in general or stick to 'user_selfies' bucket
      // but maybe a subfolder? Actually, the plan said "uploadGovernmentId".
      // I'll stick to 'user_selfies' bucket for now used by selfie verification to avoid bucket permission issues
      // if the new bucket isn't created.
      // Re-reading context: "user_selfies bucket".
      // I'll use 'user_selfies' bucket but path it like 'gov_id/userId/fileName' if possible?
      // Or just 'userId/gov_id_fileName'.

      final String safeFilePath =
          '$userId/gov_id_${const Uuid().v4()}$extension';

      await _supabase.storage
          .from('user_selfies') // Reusing existing bucket to ensure it works
          .upload(
            safeFilePath,
            file,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
          );

      return safeFilePath;
    } catch (e) {
      throw Exception('Failed to upload government ID: $e');
    }
  }

  /// Creates a verification request in the database and adds to user media.
  Future<void> createVerificationRequest({
    required String userId,
    required String mediaStoragePath,
    required String verificationType, // 'liveness' or 'gov_id'
    Map<String, dynamic>? additionalData,
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
      final verificationData = {
        'profile_id': profileId,
        'verification_type': verificationType,
        'provider': 'aws_rekognition', // Default for now
        'attempt_number': 1,
        'status': 'pending',
        'selfie_video_url': mediaStoragePath, // Using this for the image proof
        'review_notes': additionalData?.toString(),
      };

      await _supabase.from('verifications').insert(verificationData);

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
        'media_url': mediaStoragePath,
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
