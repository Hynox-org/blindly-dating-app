import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

class MediaRepository {
  final ImagePicker _picker = ImagePicker();
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Get Profile ID from Auth User ID
  Future<String?> getProfileId(String userId) async {
    try {
      final response = await _supabase
          .from('profiles')
          .select('id')
          .eq('user_id', userId)
          .maybeSingle();

      return response?['id'] as String?;
    } catch (e) {
      throw Exception('Failed to get profile ID: $e');
    }
  }

  /// Picks multiple images from the gallery
  Future<List<XFile>> pickImagesFromGallery({int maxImages = 6}) async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(
        limit: maxImages,
        imageQuality: 80, // Initial quality reduction
      );
      return images;
    } catch (e) {
      throw Exception('Failed to pick images: $e');
    }
  }

  /// Picks a single image from the camera
  Future<XFile?> pickImageFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.front,
        imageQuality: 80,
      );
      return image;
    } catch (e) {
      throw Exception('Failed to capture image: $e');
    }
  }

  /// Compresses an image file to be under 1MB and max 1080p width/height
  Future<File> compressImage(File file) async {
    final String targetPath = '${file.parent.path}/${const Uuid().v4()}.jpg';

    XFile? result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      minWidth: 1080,
      minHeight: 1080,
      quality: 85,
    );

    if (result == null) return file;

    // If still > 1MB, compress further
    int quality = 85;
    while ((await result!.length()) > 1 * 1024 * 1024 && quality > 10) {
      quality -= 10;
      final nextResult = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        targetPath,
        minWidth: 1080,
        minHeight: 1080,
        quality: quality,
      );
      if (nextResult == null) break;
      result = nextResult;
    }

    return File(result.path);
  }

  /// Crops an image with custom UI settings
  Future<File?> cropImage(
    File file, {
    Color? toolbarColor,
    Color? toolbarWidgetColor,
    Color? activeControlsWidgetColor,
  }) async {
    try {
      final CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: file.path,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Photo',
            toolbarColor: toolbarColor ?? Colors.black,
            toolbarWidgetColor: toolbarWidgetColor ?? Colors.white,
            activeControlsWidgetColor: activeControlsWidgetColor,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false,
            aspectRatioPresets: [
              CropAspectRatioPreset.original,
              CropAspectRatioPreset.square,
              CropAspectRatioPreset.ratio3x2,
              CropAspectRatioPreset.ratio4x3,
              CropAspectRatioPreset.ratio16x9,
            ],
          ),
          IOSUiSettings(
            title: 'Crop Photo',
            aspectRatioPresets: [
              CropAspectRatioPreset.original,
              CropAspectRatioPreset.square,
              CropAspectRatioPreset.ratio3x2,
              CropAspectRatioPreset.ratio4x3,
              CropAspectRatioPreset.ratio16x9,
            ],
          ),
        ],
      );
      if (croppedFile != null) {
        return File(croppedFile.path);
      }
      return null;
    } catch (e) {
      // If cropping fails or cancelled, return null or original?
      // Better to log and return null to indicate cancel/fail
      return null;
    }
  }

  /// Uploads an image to Supabase Storage and returns the storage path (userId/filename.jpg)
  Future<String> uploadImage(File file, String userId) async {
    try {
      final String extension = p.extension(file.path);
      final String fileName = '${const Uuid().v4()}$extension';
      final String filePath = '$userId/$fileName';

      await _supabase.storage
          .from('user_photos')
          .upload(
            filePath,
            file,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
          );

      // Return path instead of public URL
      return filePath;
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  /// Uploads a voice intro and returns the storage path
  Future<String> uploadVoice(File file, String userId) async {
    try {
      final String extension = p.extension(file.path);
      final String fileName = '${const Uuid().v4()}$extension';
      final String filePath = '$userId/$fileName';

      await _supabase.storage
          .from('user_voices')
          .upload(
            filePath,
            file,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
          );

      return filePath;
    } catch (e) {
      throw Exception('Failed to upload voice: $e');
    }
  }

  /// Saves media metadata to the user_media table
  Future<void> saveMedia(List<Map<String, dynamic>> mediaData) async {
    try {
      if (mediaData.isEmpty) return;
      await _supabase.from('user_media').insert(mediaData);
    } catch (e) {
      throw Exception('Failed to save media metadata: $e');
    }
  }

  /// Deletes existing voice intro entries for a user from DB.
  Future<void> deleteUserVoiceIntro(String profileId) async {
    try {
      await _supabase
          .from('user_media')
          .delete()
          .eq('profile_id', profileId)
          .eq('media_type', 'voice_intro');
    } catch (e) {
      throw Exception('Failed to delete old voice intro: $e');
    }
  }

  /// Deletes an image from Supabase Storage
  Future<void> deleteImage(String path) async {
    try {
      await _supabase.storage.from('user_photos').remove([path]);
    } catch (e) {
      throw Exception('Failed to delete image: $e');
    }
  }

  /// Fetch user photos metadata and convert paths to Signed URLs
  Future<List<Map<String, dynamic>>> getUserMedia(String userId) async {
    try {
      final profileId = await getProfileId(userId);
      if (profileId == null) return [];

      final response = await _supabase
          .from('user_media')
          .select()
          .eq('profile_id', profileId)
          .eq('media_type', 'photo')
          .order('display_order');

      final List<Map<String, dynamic>> data = List<Map<String, dynamic>>.from(
        response,
      );

      final List<Map<String, dynamic>> validData = [];

      // Transform "media_url" (which might be a path or old URL) to a fresh Signed URL
      for (var item in data) {
        try {
          final rawUrl = item['media_url'] as String;
          final path = extractPathFromUrl(rawUrl, 'user_photos');
          // Generate signed URL (valid for 1 hour)
          final signedUrl = await _supabase.storage
              .from('user_photos')
              .createSignedUrl(path, 60 * 60);

          item['media_url'] = signedUrl;
          validData.add(item);
        } catch (e) {
          debugPrint('Failed to sign URL for item ${item['id']}: $e');
          // Skip this item if signing fails (e.g. object not found)
        }
      }

      return validData;
    } catch (e) {
      throw Exception('Failed to fetch user media: $e');
    }
  }

  /// Fetch user voice intro metadata and convert path to Signed URL
  Future<Map<String, dynamic>?> getUserVoiceIntro(String userId) async {
    try {
      final profileId = await getProfileId(userId);
      if (profileId == null) return null;

      final response = await _supabase
          .from('user_media')
          .select()
          .eq('profile_id', profileId)
          .eq('media_type', 'voice_intro')
          .maybeSingle();

      if (response != null) {
        final Map<String, dynamic> data = Map<String, dynamic>.from(response);
        final rawUrl = data['media_url'] as String;
        final path = extractPathFromUrl(rawUrl, 'user_voices');
        final signedUrl = await _supabase.storage
            .from('user_voices')
            .createSignedUrl(path, 60 * 60);
        data['media_url'] = signedUrl;
        return data;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Helper to extract storage path from a full URL or return the path itself if it's already a path.
  /// Identifies the segment after [bucketName]/.
  String extractPathFromUrl(String url, String bucketName) {
    // If it contains the bucket name in URL path
    // e.g. .../user_photos/userId/abc.jpg
    // or .../object/public/user_photos/userId/abc.jpg
    if (url.contains('/$bucketName/')) {
      final parts = url.split('/$bucketName/');
      if (parts.length > 1) {
        // Take the last part, but also remove query parameters if any (e.g. signed url token)
        String path = parts.last;
        if (path.contains('?')) {
          path = path.split('?').first;
        }
        return AsyncUri.decodeComponent(path); // Ensure decoded
      }
    }
    // If it doesn't look like a URL (no http), assume it is the path
    if (!url.startsWith('http')) {
      return url;
    }
    // Fallback: return as is, though likely won't work for signing
    return url;
  }
}

class AsyncUri {
  static String decodeComponent(String encodedComponent) {
    return Uri.decodeComponent(encodedComponent);
  }
}
