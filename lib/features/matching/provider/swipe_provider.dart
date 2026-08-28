import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:blindly_dating_app/features/matching/repository/swipe_repository.dart';

// ======================================================
// Swipe Provider
// ======================================================
final swipeProvider = StateNotifierProvider<SwipeNotifier, AsyncValue<void>>((
  ref,
) {
  final repository = ref.read(swipeRepositoryProvider);
  return SwipeNotifier(repository);
});

// ======================================================
// Swipe Notifier
// ======================================================
class SwipeNotifier extends StateNotifier<AsyncValue<void>> {
  final SwipeRepository _repository;

  SwipeNotifier(this._repository) : super(const AsyncData(null));

  // --------------------------------------------------
  // 👍 RECORD SWIPE (like / pass / super_like)
  // --------------------------------------------------
  /// Returns true when this swipe produced a match, so the caller can
  /// celebrate it. Dropping this on the floor is why a match made from the
  /// Discover page used to go unannounced.
  Future<bool> swipe({
    required String targetProfileId,
    required String action, // like | pass | super_like
  }) async {
    try {
      state = const AsyncLoading();

      final matched = await _repository.recordSwipe(
        targetProfileId: targetProfileId,
        action: action,
      );

      state = const AsyncData(null);
      return matched;
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  // --------------------------------------------------
  // ↩️ UNDO LAST SWIPE
  // --------------------------------------------------
  /// [targetProfileId] names the card being undone. Callers must pass it:
  /// without it the backend falls back to the caller's most recent swipe
  /// *anywhere in the app*, which is not what any undo button means.
  Future<bool> undo({String? targetProfileId}) async {
    try {
      state = const AsyncLoading();

      final success = await _repository.undoLastSwipe(
        targetProfileId: targetProfileId,
      );

      state = const AsyncData(null);
      return success;
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }
}
