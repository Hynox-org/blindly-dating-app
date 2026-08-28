import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:blindly_dating_app/features/media/data/repositories/media_repository.dart';
import 'package:blindly_dating_app/features/media/data/repositories/photo_moderation_repository.dart';

const int maxPhotos = PhotoModerationRepository.maxPhotos;

/// A photo slot: either one the user just added (already moderated and stored,
/// so it carries its [path]) or one loaded from the database.
class MediaContent {
  /// Local file, kept only so the grid can show the photo without a round trip.
  final File? file;

  /// Signed URL, for photos loaded from the database.
  final String? url;

  /// Storage path in `user_photos`. Set for every photo that will be saved.
  final String? path;

  final String? id;

  const MediaContent({this.file, this.url, this.path, this.id});

  bool get isLocal => file != null;
}

/// Why a photo the user just picked was turned away. The screen owns the
/// wording; this is only the reason code from moderation.
class PhotoRejection {
  final String code;

  /// True when the photo failed on our side rather than on its merits, which
  /// makes "try again" the right thing to offer instead of "pick another".
  final bool retryable;

  const PhotoRejection(this.code, {this.retryable = false});
}

class MediaState {
  final List<MediaContent?> selectedPhotos;
  final bool isLoading;

  /// Photos the last batch turned away. Cleared once the screen has shown them.
  final List<PhotoRejection> rejections;

  /// Something went wrong loading or saving -- not a verdict on a photo.
  final String? error;

  const MediaState({
    required this.selectedPhotos,
    this.isLoading = false,
    this.rejections = const [],
    this.error,
  });

  factory MediaState.initial() =>
      MediaState(selectedPhotos: List<MediaContent?>.filled(maxPhotos, null));

  MediaState copyWith({
    List<MediaContent?>? selectedPhotos,
    bool? isLoading,
    List<PhotoRejection>? rejections,
    String? error,
  }) {
    return MediaState(
      selectedPhotos: selectedPhotos ?? this.selectedPhotos,
      isLoading: isLoading ?? this.isLoading,
      rejections: rejections ?? const [],
      error: error,
    );
  }

  int get validPhotoCount => selectedPhotos.where((e) => e != null).length;

  /// How many more photos can be added when [targetIndex] is the slot tapped.
  int freeSlots(int targetIndex) =>
      maxPhotos -
      validPhotoCount +
      (selectedPhotos[targetIndex] != null ? 1 : 0);
}

final mediaRepositoryProvider = Provider<MediaRepository>(
  (ref) => MediaRepository(),
);

final photoModerationRepositoryProvider = Provider<PhotoModerationRepository>(
  (ref) => PhotoModerationRepository(),
);

final mediaProvider = StateNotifierProvider<MediaNotifier, MediaState>((ref) {
  return MediaNotifier(
    ref.watch(mediaRepositoryProvider),
    ref.watch(photoModerationRepositoryProvider),
  );
});

class MediaNotifier extends StateNotifier<MediaState> {
  final MediaRepository _repository;
  final PhotoModerationRepository _moderation;

  /// Photos that reached storage but the user then dropped. Cleaned up on save,
  /// not on removal -- the user may still back out of the whole edit.
  final Set<String> _discarded = {};

  /// Set by [loadUserMedia], which the photo screen always calls on open.
  /// Draft tracking is skipped while it is null.
  String? _userId;

  MediaNotifier(this._repository, this._moderation) : super(MediaState.initial());

  Future<void> loadUserMedia(String userId) async {
    try {
      _userId = userId;
      _discarded.clear();
      state = state.copyWith(isLoading: true);

      final photos = List<MediaContent?>.filled(maxPhotos, null);
      final committed = <String>{};

      for (final row in await _repository.getUserMedia(userId)) {
        final order = row['display_order'] as int;
        final path = row['storage_path'] as String?;
        if (order < 0 || order >= maxPhotos) continue;
        photos[order] = MediaContent(
          url: row['media_url'] as String,
          path: path,
          id: row['id'] as String?,
        );
        if (path != null) committed.add(path);
      }

      await _restoreDrafts(userId, photos, committed);

      state = state.copyWith(selectedPhotos: photos, isLoading: false);
      // Drop any draft the sweep has already collected.
      await _saveDrafts();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'load_failed');
    }
  }

  /// Puts back photos that passed moderation but were never submitted, so
  /// closing the app mid-upload does not lose them. They are still waiting on
  /// Continue -- nothing here writes a row.
  ///
  /// A draft older than the server's three hour sweep window is gone from
  /// storage; it simply fails to sign and is dropped.
  Future<void> _restoreDrafts(
    String userId,
    List<MediaContent?> photos,
    Set<String> committed,
  ) async {
    final saved = await _readDraftPaths(userId);
    final pending = <int, String>{};
    for (var slot = 0; slot < maxPhotos; slot++) {
      final path = saved[slot];
      if (path != null && !committed.contains(path)) pending[slot] = path;
    }
    if (pending.isEmpty) return;

    final urls = await _repository.signPhotoPaths(pending.values.toList());
    for (final entry in pending.entries) {
      final url = urls[entry.value];
      if (url == null) continue;
      // Prefer the slot it was in; fall back if a saved photo now holds it.
      final slot = photos[entry.key] == null
          ? entry.key
          : photos.indexWhere((p) => p == null);
      if (slot == -1) continue;
      photos[slot] = MediaContent(url: url, path: entry.value);
    }
  }

  String _draftKey(String userId) => 'photo_drafts_$userId';

  Future<List<String?>> _readDraftPaths(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_draftKey(userId));
    if (raw == null) return List.filled(maxPhotos, null);
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return List.generate(
        maxPhotos,
        (i) => i < decoded.length ? decoded[i] as String? : null,
      );
    } catch (_) {
      return List.filled(maxPhotos, null);
    }
  }

  /// Records the uncommitted photos, slot by slot. A photo with an `id` came
  /// from the database and is not a draft.
  Future<void> _saveDrafts() async {
    final userId = _userId;
    if (userId == null) return;

    final paths = state.selectedPhotos
        .map((m) => m?.id == null ? m?.path : null)
        .toList();
    final prefs = await SharedPreferences.getInstance();
    if (paths.every((p) => p == null)) {
      await prefs.remove(_draftKey(userId));
    } else {
      await prefs.setString(_draftKey(userId), jsonEncode(paths));
    }
  }

  /// Compresses, moderates and -- for whatever passes -- stores [files] in one
  /// round trip. Only accepted photos take a slot; the rest come back as
  /// [MediaState.rejections] for the screen to explain.
  Future<void> processAndAddFiles(List<File> files, int targetIndex) async {
    if (files.isEmpty) return;

    final room = state.freeSlots(targetIndex);
    if (room <= 0) return;
    final batch = files.take(room).toList();

    state = state.copyWith(isLoading: true);

    try {
      final compressed = <File>[];
      for (final file in batch) {
        compressed.add(await _repository.compressImage(file));
      }

      final results = await _moderation.moderate(compressed);

      final photos = List<MediaContent?>.from(state.selectedPhotos);
      final rejections = <PhotoRejection>[];
      var placedFirst = false;

      for (var i = 0; i < results.length; i++) {
        final result = results[i];
        if (result.decision != PhotoDecision.allow) {
          rejections.add(
            PhotoRejection(
              result.code,
              retryable: result.decision == PhotoDecision.failure,
            ),
          );
          continue;
        }

        final content = MediaContent(file: compressed[i], path: result.path);
        // The first photo that passes takes the slot the user actually tapped;
        // the rest fill in from the front.
        if (!placedFirst) {
          final replaced = photos[targetIndex]?.path;
          if (replaced != null) _discarded.add(replaced);
          photos[targetIndex] = content;
          placedFirst = true;
        } else {
          final free = photos.indexWhere((e) => e == null);
          if (free == -1) break;
          photos[free] = content;
        }
      }

      state = state.copyWith(
        selectedPhotos: photos,
        isLoading: false,
        rejections: rejections,
      );
      await _saveDrafts();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'upload_failed');
    }
  }

  void removeImage(int index) {
    if (index < 0 || index >= state.selectedPhotos.length) return;
    final photos = List<MediaContent?>.from(state.selectedPhotos);
    final path = photos[index]?.path;
    if (path != null) _discarded.add(path);
    photos[index] = null;
    state = state.copyWith(selectedPhotos: photos);
    unawaited(_saveDrafts());
  }

  /// A re-cropped photo is a different photo, so it goes back through
  /// moderation rather than inheriting the original's verdict.
  Future<void> replaceImage(int index, File file) =>
      processAndAddFiles([file], index);

  /// Writes the photo rows. Every photo already lives in storage by this point
  /// -- moderation put it there -- so this only records order and ownership.
  Future<void> submitMedia(String userId) async {
    final photos = state.selectedPhotos.whereType<MediaContent>().toList();
    if (photos.length < 2) {
      state = state.copyWith(error: 'need_two_photos');
      return;
    }

    state = state.copyWith(isLoading: true);

    try {
      final profileId = await _repository.getProfileId(userId);
      if (profileId == null) {
        state = state.copyWith(isLoading: false, error: 'profile_not_found');
        return;
      }
      final profileModeId = await _repository.getProfileModeId(
        profileId,
        'date',
      );
      if (profileModeId == null) {
        state = state.copyWith(isLoading: false, error: 'profile_not_found');
        return;
      }

      // A draft left sitting past the sweep window is gone from storage. Catch
      // it here rather than writing a row that points at nothing.
      final paths = photos.map((p) => p.path).nonNulls.toList();
      final live = await _repository.signPhotoPaths(paths);
      if (live.length != paths.length) {
        final surviving = List<MediaContent?>.filled(maxPhotos, null);
        var slot = 0;
        for (final photo in photos) {
          if (live.containsKey(photo.path)) surviving[slot++] = photo;
        }
        state = state.copyWith(
          selectedPhotos: surviving,
          isLoading: false,
          error: 'photos_expired',
        );
        return;
      }

      final rows = <Map<String, dynamic>>[];
      for (var i = 0; i < photos.length; i++) {
        final path = photos[i].path;
        if (path == null) continue;
        rows.add({
          'profile_mode_id': profileModeId,
          'media_url': path,
          'media_type': 'photo',
          'display_order': i,
          'is_primary': i == 0,
          // Nothing without a verdict gets this far.
          'moderation_status': 'approved',
        });
      }

      await _repository.replacePhotos(profileModeId, rows);

      // Whatever the user dropped along the way is now unreferenced.
      final kept = rows.map((r) => r['media_url'] as String).toSet();
      await _repository.deletePhotos(_discarded.difference(kept));
      _discarded.clear();

      // Everything is committed now, so there is no draft left to restore.
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_draftKey(userId));

      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'save_failed');
    }
  }
}
