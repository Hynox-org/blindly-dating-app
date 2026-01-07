import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Note: Ensure this import points to your updated repository file
import '../data/repositories/photo_moderation_repository.dart';

// 1. REPOSITORY PROVIDER
final photoModerationRepositoryProvider = Provider<PhotoModerationRepository>((ref) {
  return PhotoModerationRepository();
});

// 2. SERVICE PROVIDER
final photoModerationProvider = Provider<PhotoModerationService>((ref) {
  return PhotoModerationService(ref);
});

class PhotoModerationService {
  final Ref _ref;

  PhotoModerationService(this._ref);

  /// Returns the full [ModerationResult] containing the decision and the reason.
  Future<ModerationResult> checkImageSafety(
    File imageFile, {
    required String source,
  }) async {
    final repo = _ref.read(photoModerationRepositoryProvider);

    // Call repository and return the full result object directly
    return await repo.moderateImage(
      imageFile: imageFile,
      source: source,
    );
  }
}