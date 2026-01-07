import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repositories/media_repository.dart';
import 'photo_moderation_provider.dart';
// 1. ADD THIS IMPORT (Needed for ModerationDecision enum)
import '../data/repositories/photo_moderation_repository.dart';

/// Wrapper to hold either a local File (newly picked) or a remote URL (existing).
class MediaContent {
  final File? file;
  final String? url;
  final String? id; // Optional: ID from database if editing existing

  const MediaContent({this.file, this.url, this.id});

  bool get isLocal => file != null;
  bool get isRemote => url != null;
}

class MediaState {
  final List<MediaContent?> selectedPhotos;
  final bool isLoading;
  final String? error;

  const MediaState({
    required this.selectedPhotos,
    this.isLoading = false,
    this.error,
  });

  factory MediaState.initial() {
    return MediaState(selectedPhotos: List<MediaContent?>.filled(6, null));
  }

  MediaState copyWith({
    List<MediaContent?>? selectedPhotos,
    bool? isLoading,
    String? error,
  }) {
    return MediaState(
      selectedPhotos: selectedPhotos ?? this.selectedPhotos,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  int get validPhotoCount => selectedPhotos.where((e) => e != null).length;
}

final mediaRepositoryProvider = Provider<MediaRepository>((ref) {
  return MediaRepository();
});

final mediaProvider = StateNotifierProvider<MediaNotifier, MediaState>((ref) {
  final repository = ref.watch(mediaRepositoryProvider);
  return MediaNotifier(ref, repository);
});

class MediaNotifier extends StateNotifier<MediaState> {
  final Ref _ref;
  final MediaRepository _repository;

  MediaNotifier(this._ref, this._repository) : super(MediaState.initial());

  Future<void> loadUserMedia(String userId) async {
    try {
      state = state.copyWith(isLoading: true);
      final mediaList = await _repository.getUserMedia(userId);

      final List<MediaContent?> loaded = List.filled(6, null);

      // Populate slots based on display_order
      for (var existing in mediaList) {
        final order = existing['display_order'] as int;
        final url = existing['media_url'] as String;
        final id = existing['id'] as String?;

        if (order >= 0 && order < 6) {
          loaded[order] = MediaContent(url: url, id: id);
        }
      }

      state = state.copyWith(selectedPhotos: loaded, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load photos: $e',
      );
    }
  }

  Future<void> pickImages(int targetIndex) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final currentValidCount = state.validPhotoCount;
      final isTargetOccupied = state.selectedPhotos[targetIndex] != null;
      final maxToPick = 6 - currentValidCount + (isTargetOccupied ? 1 : 0);

      if (maxToPick <= 0) {
        state = state.copyWith(
          isLoading: false,
          error: 'Maximum 6 photos allowed',
        );
        return;
      }

      final images = await _repository.pickImagesFromGallery(
        maxImages: maxToPick,
      );

      final List<MediaContent?> currentPhotos = List.from(state.selectedPhotos);
      bool blockedAny = false;
      String? lastBlockReason;

      for (int i = 0; i < images.length; i++) {
        File file = File(images[i].path);

        // Auto-crop removed
        final compressed = await _repository.compressImage(file);

        // 2. MODERATION FIX
        final result = await _ref
            .read(photoModerationProvider)
            .checkImageSafety(compressed, source: 'profile');

        // Check Decision (Allow or Review are okay)
        if (result.decision == ModerationDecision.block ||
            result.decision == ModerationDecision.error) {
          blockedAny = true;
          lastBlockReason = result.reason;
          continue; // Skip adding this photo
        }

        final content = MediaContent(file: compressed);

        if (i == 0) {
          currentPhotos[targetIndex] = content;
        } else {
          final firstNull = currentPhotos.indexWhere((e) => e == null);
          if (firstNull != -1) {
            currentPhotos[firstNull] = content;
          }
        }
      }

      state = state.copyWith(
        selectedPhotos: currentPhotos,
        isLoading: false,
        // Show the specific reason if blocked
        error: blockedAny
            ? (lastBlockReason ?? "Some photos were blocked.")
            : null,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> captureImage(int targetIndex) async {
    try {
      if (state.validPhotoCount >= 6 &&
          state.selectedPhotos[targetIndex] == null) {
        state = state.copyWith(error: 'Maximum 6 photos allowed');
        return;
      }

      state = state.copyWith(isLoading: true, error: null);
      final xFile = await _repository.pickImageFromCamera();

      if (xFile != null) {
        File file = File(xFile.path);

        // Auto-crop removed
        final compressed = await _repository.compressImage(file);

        // 3. MODERATION FIX
        final result = await _ref
            .read(photoModerationProvider)
            .checkImageSafety(compressed, source: 'profile');

        if (result.decision == ModerationDecision.block ||
            result.decision == ModerationDecision.error) {
          state = state.copyWith(
            isLoading: false,
            // Show the actual reason from Lambda
            error: result.reason ?? "Photo blocked: Policy violation detected.",
          );
          return;
        }

        final List<MediaContent?> currentPhotos = List.from(
          state.selectedPhotos,
        );
        currentPhotos[targetIndex] = MediaContent(file: compressed);

        state = state.copyWith(selectedPhotos: currentPhotos, isLoading: false);
      } else {
        state = state.copyWith(isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void removeImage(int index) {
    if (index >= 0 && index < state.selectedPhotos.length) {
      final List<MediaContent?> currentPhotos = List.from(state.selectedPhotos);
      currentPhotos[index] = null;
      state = state.copyWith(selectedPhotos: currentPhotos);
    }
  }

  void updateImage(int index, File file) {
    if (index >= 0 && index < state.selectedPhotos.length) {
      final List<MediaContent?> currentPhotos = List.from(state.selectedPhotos);
      // We assume update uses a new file
      currentPhotos[index] = MediaContent(file: file);
      state = state.copyWith(selectedPhotos: currentPhotos);
    }
  }

  void reorderImages(int oldIndex, int newIndex) {
    final validPhotos = state.selectedPhotos.whereType<MediaContent>().toList();
    if (oldIndex < validPhotos.length && newIndex <= validPhotos.length) {
      final item = validPhotos.removeAt(oldIndex);
      if (newIndex > validPhotos.length) newIndex = validPhotos.length;
      validPhotos.insert(newIndex, item);

      final List<MediaContent?> newSparse = List.filled(6, null);
      for (int i = 0; i < validPhotos.length; i++) {
        newSparse[i] = validPhotos[i];
      }
      state = state.copyWith(selectedPhotos: newSparse);
    }
  }

  void clear() {
    state = MediaState.initial();
  }

  Future<void> submitMedia(String userId) async {
    try {
      final validPhotos = state.selectedPhotos
          .whereType<MediaContent>()
          .toList();

      if (validPhotos.length < 2) {
        state = state.copyWith(error: 'Please add at least 2 photos');
        return;
      }

      state = state.copyWith(isLoading: true, error: null);

      final profileId = await _repository.getProfileId(userId);
      if (profileId == null) {
        state = state.copyWith(isLoading: false, error: 'Profile not found');
        return;
      }

      await _supabaseDeletePhotosMetadata(profileId);

      final List<Map<String, dynamic>> mediaDataToSave = [];

      for (int i = 0; i < validPhotos.length; i++) {
        final content = validPhotos[i];
        String url;
        int size = 0;

        if (content.isLocal) {
          url = await _repository.uploadImage(content.file!, userId);
          size = await content.file!.length();
        } else {
          url = _repository.extractPathFromUrl(content.url!, 'user_photos');
        }

        mediaDataToSave.add({
          'profile_id': profileId,
          'media_url': url,
          'media_type': 'photo',
          'display_order': i,
          'is_primary': i == 0,
          'file_size_bytes': size,
          'moderation_status': 'pending',
        });
      }

      await _repository.saveMedia(mediaDataToSave);

      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> _supabaseDeletePhotosMetadata(String profileId) async {
    // Logic to clear old photos should be implemented here or in repo
  }
}
