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

  /// Get Mode ID from Profile ID and Mode
  Future<String?> getProfileModeId(String profileId, String mode) async {
    try {
      final response = await _supabase
          .from('profile_modes')
          .select('id')
          .eq('profile_id', profileId)
          .eq('mode', mode)
          .maybeSingle();

      return response?['id'] as String?;
    } catch (e) {
      throw Exception('Failed to get profile mode ID: $e');
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

  /// Saves media metadata to the profile_mode_media table
  Future<void> saveMedia(List<Map<String, dynamic>> mediaData) async {
    try {
      if (mediaData.isEmpty) return;
      await _supabase.from('profile_mode_media').insert(mediaData);
    } catch (e) {
      throw Exception('Failed to save media metadata: $e');
    }
  }

  /// Swaps this mode's photo rows for [rows]. Voice intro rows are untouched.
  ///
  /// ponytail: delete-then-insert, so a failure between the two leaves the user
  /// with no photo rows until they submit again. A Postgres function would make
  /// it atomic -- worth doing if this ever fails in the wild.
  Future<void> replacePhotos(
    String profileModeId,
    List<Map<String, dynamic>> rows,
  ) async {
    try {
      await _supabase
          .from('profile_mode_media')
          .delete()
          .eq('profile_mode_id', profileModeId)
          .eq('media_type', 'photo');
      await saveMedia(rows);
    } catch (e) {
      throw Exception('Failed to save photos: $e');
    }
  }

  /// Removes photos the user dropped, so storage does not accumulate files no
  /// row points at. Best effort: a leftover file costs pennies, and failing the
  /// save over one would cost the user their edit.
  Future<void> deletePhotos(Iterable<String> paths) async {
    if (paths.isEmpty) return;
    try {
      await _supabase.storage.from('user_photos').remove(paths.toList());
    } catch (e) {
      debugPrint('Failed to remove discarded photos: $e');
    }
  }

  /// Deletes existing voice intro entries for a user from DB.
  Future<void> deleteUserVoiceIntro(String profileModeId) async {
    try {
      await _supabase
          .from('profile_mode_media')
          .delete()
          .eq('profile_mode_id', profileModeId)
          .eq('media_type', 'voice_intro');
    } catch (e) {
      throw Exception('Failed to delete old voice intro: $e');
    }
  }

  /// Signs [paths] in one call and returns path -> URL. Paths storage cannot
  /// sign are simply absent: the file is gone, which is a normal outcome once
  /// the orphan sweep has run.
  Future<Map<String, String>> signPhotoPaths(List<String> paths) async {
    if (paths.isEmpty) return {};
    try {
      final signed = await _supabase.storage
          .from('user_photos')
          .createSignedUrls(paths, 60 * 60);
      return {
        for (final s in signed)
          if (s.signedUrl.isNotEmpty) s.path: s.signedUrl,
      };
    } catch (e) {
      debugPrint('Failed to sign photo paths: $e');
      return {};
    }
  }

  /// Fetch user photos metadata and convert paths to Signed URLs
  Future<List<Map<String, dynamic>>> getUserMedia(
    String userId, {
    String mode = 'date',
  }) async {
    try {
      final profileId = await getProfileId(userId);
      if (profileId == null) return [];

      final profileModeId = await getProfileModeId(profileId, mode);
      if (profileModeId == null) return [];

      final response = await _supabase
          .from('profile_mode_media')
          .select()
          .eq('profile_mode_id', profileModeId)
          .eq('media_type', 'photo')
          .order('display_order');

      final data = List<Map<String, dynamic>>.from(response);
      if (data.isEmpty) return [];

      // `media_url` holds the storage path (older rows may hold a full URL).
      // Keep it as `storage_path` -- that is what gets written back on save --
      // and sign the whole set in one call rather than one round trip each.
      for (final item in data) {
        item['storage_path'] = extractPathFromUrl(
          item['media_url'] as String,
          'user_photos',
        );
      }

      final byPath = await signPhotoPaths(
        data.map((i) => i['storage_path'] as String).toList(),
      );
      final validData = <Map<String, dynamic>>[];
      for (final item in data) {
        final url = byPath[item['storage_path']];
        // Skip anything storage could not sign -- the file is gone.
        if (url == null) {
          debugPrint('No signed URL for ${item['storage_path']}');
          continue;
        }
        item['media_url'] = url;
        validData.add(item);
      }

      return validData;
    } catch (e) {
      throw Exception('Failed to fetch user media: $e');
    }
  }

  /// Fetch user voice intro metadata and convert path to Signed URL
  Future<Map<String, dynamic>?> getUserVoiceIntro(
    String userId, {
    String mode = 'date',
  }) async {
    try {
      final profileId = await getProfileId(userId);
      if (profileId == null) return null;

      final profileModeId = await getProfileModeId(profileId, mode);
      if (profileModeId == null) return null;

      final response = await _supabase
          .from('profile_mode_media')
          .select()
          .eq('profile_mode_id', profileModeId)
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
        return Uri.decodeComponent(path);
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
