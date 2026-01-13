import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repository/swipe_repository.dart';

// ======================================================
// Swipe Provider
// ======================================================
final swipeProvider =
    StateNotifierProvider<SwipeNotifier, AsyncValue<void>>(
  (ref) {
    final repository = ref.read(swipeRepositoryProvider);
    return SwipeNotifier(repository);
  },
);

// ======================================================
// Swipe Notifier
// ======================================================
class SwipeNotifier extends StateNotifier<AsyncValue<void>> {
  final SwipeRepository _repository;

  SwipeNotifier(this._repository) : super(const AsyncData(null));

  // --------------------------------------------------
  // 👍 RECORD SWIPE (like / pass / super_like)
  // --------------------------------------------------
  Future<void> swipe({
    required String targetProfileId,
    required String action, // like | pass | super_like
  }) async {
    try {
      state = const AsyncLoading();

      await _repository.recordSwipe(
        targetProfileId: targetProfileId,
        action: action, // ✅ fixed param
      );

      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  // --------------------------------------------------
  // ↩️ UNDO LAST SWIPE
  // --------------------------------------------------
  Future<bool> undo() async {
    try {
      state = const AsyncLoading();

      final success = await _repository.undoLastSwipe();

      state = const AsyncData(null);
      return success;
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }
}
