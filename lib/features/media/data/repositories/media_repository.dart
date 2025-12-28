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
  Future<File?> cropImage(File file) async {
    try {
      final CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: file.path,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Photo',
            toolbarColor: Colors.black,
            toolbarWidgetColor: Colors.white,
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

  /// Uploads an image to Supabase Storage and returns the public URL
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

      final String publicUrl = _supabase.storage
          .from('user_photos')
          .getPublicUrl(filePath);

      return publicUrl;
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  /// Uploads a voice intro to Supabase Storage and returns the public URL
  Future<String> uploadVoice(File file, String userId) async {
    try {
      final String extension = p.extension(file.path);
      // We use a UUID to ensure uniqueness and avoid caching issues if we were to overwrite
      final String fileName = '${const Uuid().v4()}$extension';
      final String filePath = '$userId/$fileName';

      await _supabase.storage
          .from('user_voices')
          .upload(
            filePath,
            file,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
          );

      final String publicUrl = _supabase.storage
          .from('user_voices')
          .getPublicUrl(filePath);

      return publicUrl;
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
  /// Does NOT delete the file from storage (best effort or manual cleanup required later).
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
}
