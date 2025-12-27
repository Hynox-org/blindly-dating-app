import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repositories/media_repository.dart';
// 1. IMPORT YOUR MODERATION PROVIDER
import 'photo_moderation_provider.dart'; 

class MediaState {
  final List<File?> selectedPhotos;
  final bool isLoading;
  final String? error;

  const MediaState({
    required this.selectedPhotos,
    this.isLoading = false,
    this.error,
  });

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

  int get validPhotoCount => selectedPhotos.where((e) => e != null).length;
}

final mediaRepositoryProvider = Provider<MediaRepository>((ref) {
  return MediaRepository();
});

// 2. UPDATE PROVIDER TO PASS 'REF'
final mediaProvider = StateNotifierProvider<MediaNotifier, MediaState>((ref) {
  final repository = ref.watch(mediaRepositoryProvider);
  return MediaNotifier(ref, repository); // Pass ref here
});

class MediaNotifier extends StateNotifier<MediaState> {
  final Ref _ref; // Store Ref
  final MediaRepository _repository;

  // 3. UPDATE CONSTRUCTOR
  MediaNotifier(this._ref, this._repository) : super(MediaState.initial());

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

      final List<File?> currentPhotos = List<File?>.from(state.selectedPhotos);
      bool blockedAny = false; // Track if any photos were blocked

      for (int i = 0; i < images.length; i++) {
        File file = File(images[i].path);

        // Crop
        final cropped = await _repository.cropImage(file);
        if (cropped != null) {
          file = cropped;
        }

        // Compress
        final compressed = await _repository.compressImage(file);

        // -----------------------------------------------------------
        // 🛑 4. MODERATION CHECK (The Guard Dog)
        // -----------------------------------------------------------
        final isSafe = await _ref.read(photoModerationProvider).checkImageSafety(
          compressed, 
          source: 'profile'
        );

        if (!isSafe) {
          blockedAny = true;
          continue; // SKIP this photo, do not add it to the list
        }
        // -----------------------------------------------------------

        if (i == 0) {
          currentPhotos[targetIndex] = compressed;
        } else {
          final firstNull = currentPhotos.indexWhere(
            (element) => element == null,
          );
          if (firstNull != -1) {
            currentPhotos[firstNull] = compressed;
          }
        }
      }

      // Show error if something was blocked
      if (blockedAny) {
         state = state.copyWith(
           selectedPhotos: currentPhotos, 
           isLoading: false,
           error: "Some photos were blocked due to policy violations."
         );
      } else {
         state = state.copyWith(selectedPhotos: currentPhotos, isLoading: false);
      }

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

        // Crop
        final cropped = await _repository.cropImage(file);
        if (cropped != null) {
          file = cropped;
        }

        // Compress
        final compressed = await _repository.compressImage(file);

        // -----------------------------------------------------------
        // 🛑 5. MODERATION CHECK (Camera)
        // -----------------------------------------------------------
        final isSafe = await _ref.read(photoModerationProvider).checkImageSafety(
          compressed, 
          source: 'profile'
        );

        if (!isSafe) {
          state = state.copyWith(
            isLoading: false,
            error: "Photo blocked: Policy violation detected."
          );
          return; // Stop here
        }
        // -----------------------------------------------------------

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
      currentPhotos[index] = null;
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

  void reorderImages(int oldIndex, int newIndex) {
    final validPhotos = state.selectedPhotos.whereType<File>().toList();

    if (oldIndex < validPhotos.length && newIndex <= validPhotos.length) {
      final File item = validPhotos.removeAt(oldIndex);
      if (newIndex > validPhotos.length) newIndex = validPhotos.length;
      validPhotos.insert(newIndex, item);

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

      print('[MediaProvider] Fetching Profile ID...');
      final profileId = await _repository.getProfileId(userId);
      print('[MediaProvider] Profile ID fetched: $profileId');

      if (profileId == null) {
        print('[MediaProvider] Profile ID is null. Aborting.');
        state = state.copyWith(isLoading: false, error: 'Profile not found');
        return;
      }

      final List<Map<String, dynamic>> mediaData = [];

      print('[MediaProvider] Starting upload for ${validPhotos.length} photos...');
      for (int i = 0; i < validPhotos.length; i++) {
        final file = validPhotos[i];
        print('[MediaProvider] Uploading photo ${i + 1}/${validPhotos.length}...');

        final url = await _repository.uploadImage(file, userId);
        print('[MediaProvider] Photo ${i + 1} uploaded successfully. URL: $url');

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