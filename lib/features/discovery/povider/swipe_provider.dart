import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repository/swipe_repository.dart';

// ❌ DO NOT redefine swipeRepositoryProvider here
// It is already defined in swipe_repository.dart

// ======================================================
// Swipe State Provider
// ======================================================
final swipeProvider =
    StateNotifierProvider<SwipeNotifier, AsyncValue<void>>(
  (ref) {
    return SwipeNotifier(ref.read(swipeRepositoryProvider));
  },
);

// ======================================================
// Swipe Notifier
// ======================================================
class SwipeNotifier extends StateNotifier<AsyncValue<void>> {
  final SwipeRepository _repository;

  SwipeNotifier(this._repository) : super(const AsyncData(null));

  // --------------------------------------------------
  // RECORD SWIPE
  // --------------------------------------------------
  /// action must be:
  /// - like
  /// - pass
  /// - super_like
  Future<void> swipe({
    required String targetProfileId,
    required String action,
  }) async {
    try {
      state = const AsyncLoading();

      await _repository.recordSwipe(
        targetProfileId: targetProfileId,
        actionType: action,
      );

      // ✅ Success
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow; // 🔥 UI must receive the error
    }
  }

  // --------------------------------------------------
  // UNDO LAST SWIPE (PREMIUM ONLY)
  // --------------------------------------------------
  Future<void> undo() async {
    try {
      state = const AsyncLoading();

      await _repository.undoLastSwipe();

      // ✅ Success
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow; // 🔥 UI handles PREMIUM_REQUIRED, etc.
    }
  }
}
