import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Note the import path: we go up one level (..) to 'media', then down to 'data'
import '../data/repositories/photo_moderation_repository.dart';

// 1. REPOSITORY PROVIDER
final photoModerationRepositoryProvider = Provider<PhotoModerationRepository>((ref) {
  return PhotoModerationRepository();
});

// 2. SERVICE PROVIDER (Use this one in your UI/Onboarding)
final photoModerationProvider = Provider<PhotoModerationService>((ref) {
  return PhotoModerationService(ref);
});

class PhotoModerationService {
  final Ref _ref;

  PhotoModerationService(this._ref);

  /// Returns [true] if Safe, [false] if Blocked.
  Future<bool> checkImageSafety(File imageFile, {required String source}) async {
    final repo = _ref.read(photoModerationRepositoryProvider);
    
    final decision = await repo.moderateImage(
      imageFile: imageFile, 
      source: source
    );

    switch (decision) {
      case ModerationDecision.allow:
        return true; 
      case ModerationDecision.review:
        return true; // Allowing "Review" items for now
      case ModerationDecision.block:
        return false; 
      case ModerationDecision.error:
        return false; // Fail safe
    }
  }
}