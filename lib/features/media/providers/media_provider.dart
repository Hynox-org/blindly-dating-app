import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repositories/media_repository.dart';

class MediaState {
  final List<File?> selectedPhotos;
  final bool isLoading;
  final String? error;

  const MediaState({
    required this.selectedPhotos, // Making it required to ensure we always init correctly
    this.isLoading = false,
    this.error,
  });

  // Factory to create initial state with 6 nulls
  factory MediaState.initial() {
    return MediaState(selectedPhotos: List<File?>.filled(6, null));
  }

  MediaState copyWith({
    List<File?>? selectedPhotos,
    bool? isLoading,
    String? error,
  }) {
    return MediaState(
      selectedPhotos: selectedPhotos ?? this.selectedPhotos,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  // Helper to get actual files count
  int get validPhotoCount => selectedPhotos.where((e) => e != null).length;
}

final mediaRepositoryProvider = Provider<MediaRepository>((ref) {
  return MediaRepository();
});

final mediaProvider = StateNotifierProvider<MediaNotifier, MediaState>((ref) {
  final repository = ref.watch(mediaRepositoryProvider);
  return MediaNotifier(repository);
});

class MediaNotifier extends StateNotifier<MediaState> {
  final MediaRepository _repository;

  MediaNotifier(this._repository) : super(MediaState.initial());

  Future<void> pickImages(int targetIndex) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      // Calculate remaining capacity
      // We allow picking as many as there are empty slots
      // If targetIndex is currently occupied, we are overwriting it, so it counts as available for the new batch.

      final currentValidCount = state.validPhotoCount;
      // If target is null, we have free slots = 6 - valid.
      // If target is not null, we effectively have (6 - valid) + 1 (the one being replaced).
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

      final List<File?> currentPhotos = List<File?>.from(state.selectedPhotos);

      for (int i = 0; i < images.length; i++) {
        File file = File(images[i].path);

        // Crop
        final cropped = await _repository.cropImage(file);
        if (cropped != null) {
          file = cropped;
        }

        // Compress
        final compressed = await _repository.compressImage(file);

        if (i == 0) {
          // First image goes to target index
          currentPhotos[targetIndex] = compressed;
        } else {
          // Subsequent images go to next available null slots
          // (We shouldn't overwrite other existing photos, only fill gaps)
          final firstNull = currentPhotos.indexWhere(
            (element) => element == null,
          );
          if (firstNull != -1) {
            currentPhotos[firstNull] = compressed;
          }
        }
      }

      state = state.copyWith(selectedPhotos: currentPhotos, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> captureImage(int targetIndex) async {
    try {
      // Check if full (unless we are replacing the target)
      if (state.validPhotoCount >= 6 &&
          state.selectedPhotos[targetIndex] == null) {
        state = state.copyWith(error: 'Maximum 6 photos allowed');
        return;
      }

      state = state.copyWith(isLoading: true, error: null);
      final xFile = await _repository.pickImageFromCamera();

      if (xFile != null) {
        File file = File(xFile.path);

        // Crop
        final cropped = await _repository.cropImage(file);
        if (cropped != null) {
          file = cropped;
        }

        // Compress
        final compressed = await _repository.compressImage(file);

        final List<File?> currentPhotos = List.from(state.selectedPhotos);
        currentPhotos[targetIndex] = compressed;

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
      final List<File?> currentPhotos = List.from(state.selectedPhotos);
      currentPhotos[index] = null; // Just nullify that slot
      state = state.copyWith(selectedPhotos: currentPhotos);
    }
  }

  void updateImage(int index, File file) {
    if (index >= 0 && index < state.selectedPhotos.length) {
      final List<File?> currentPhotos = List.from(state.selectedPhotos);
      currentPhotos[index] = file;
      state = state.copyWith(selectedPhotos: currentPhotos);
    }
  }

  // Reordering implies bringing them together.
  // We extract all non-nulls, reorder them, and then place them back into the filtered list.
  // This will "compact" the list (remove gaps) which is expected behavior when sorting.
  void reorderImages(int oldIndex, int newIndex) {
    // 1. Extract valid photos
    final validPhotos = state.selectedPhotos.whereType<File>().toList();

    // Check bounds against valid list
    if (oldIndex < validPhotos.length && newIndex <= validPhotos.length) {
      final File item = validPhotos.removeAt(oldIndex);

      // With ReorderableGridView (and some ListView versions),
      // the newIndex is the target insertion index in the *modified* list context
      // OR we just treat it as a direct insert.
      // Based on user feedback, removing the -1 logic is required.
      if (newIndex > validPhotos.length) newIndex = validPhotos.length;

      validPhotos.insert(newIndex, item);

      // 2. Re-construct sparse list (compacted)
      final List<File?> newSparse = List.filled(6, null);
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
      print('[MediaProvider] submitMedia called for userId: $userId');
      final validPhotos = state.selectedPhotos.whereType<File>().toList();

      if (validPhotos.length < 2) {
        print('[MediaProvider] Validation failed: Less than 2 photos');
        state = state.copyWith(error: 'Please add at least 2 photos');
        return;
      }

      state = state.copyWith(isLoading: true, error: null);

      // Fetch Profile ID
      print('[MediaProvider] Fetching Profile ID...');
      final profileId = await _repository.getProfileId(userId);
      print('[MediaProvider] Profile ID fetched: $profileId');

      if (profileId == null) {
        print('[MediaProvider] Profile ID is null. Aborting.');
        state = state.copyWith(isLoading: false, error: 'Profile not found');
        return;
      }

      final List<Map<String, dynamic>> mediaData = [];

      print(
        '[MediaProvider] Starting upload for ${validPhotos.length} photos...',
      );
      for (int i = 0; i < validPhotos.length; i++) {
        final file = validPhotos[i];
        print(
          '[MediaProvider] Uploading photo ${i + 1}/${validPhotos.length}...',
        );

        // Upload
        final url = await _repository.uploadImage(file, userId);
        print(
          '[MediaProvider] Photo ${i + 1} uploaded successfully. URL: $url',
        );

        mediaData.add({
          'profile_id': profileId,
          'media_url': url,
          'media_type': 'photo',
          'display_order': i,
          'is_primary': i == 0,
          'file_size_bytes': await file.length(),
          'moderation_status': 'pending',
        });
      }

      print('[MediaProvider] Saving media metadata to user_media table...');
      await _repository.saveMedia(mediaData);
      print('[MediaProvider] Metadata saved successfully.');

      state = state.copyWith(isLoading: false);
      print('[MediaProvider] submitMedia completed successfully.');
    } catch (e) {
      print('[MediaProvider] Error in submitMedia: $e');
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}
