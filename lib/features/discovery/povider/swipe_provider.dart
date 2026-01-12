import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repository/swipe_repository.dart';
import '../../matches/provider/match_provider.dart';

// ======================================================
// Swipe State Provider
// ======================================================
final swipeProvider =
    StateNotifierProvider<SwipeNotifier, AsyncValue<void>>(
  (ref) {
    return SwipeNotifier(
      ref.read(swipeRepositoryProvider),
      ref, // 🔥 PASS REF
    );
  },
);

// ======================================================
// Swipe Notifier
// ======================================================
class SwipeNotifier extends StateNotifier<AsyncValue<void>> {
  final SwipeRepository _repository;
  final Ref _ref;

  SwipeNotifier(this._repository, this._ref)
      : super(const AsyncData(null));

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

      // 🔥🔥🔥 CRITICAL FIX
      // Force refresh matches immediately
      _ref.read(myMatchesProvider.notifier).loadMatches();

      // ✅ Success
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow; // UI must receive the error
    }
  }

  // --------------------------------------------------
  // UNDO LAST SWIPE (PREMIUM ONLY)
  // --------------------------------------------------
  Future<void> undo() async {
    try {
      state = const AsyncLoading();

      await _repository.undoLastSwipe();

      // 🔥 Refresh matches after undo as well
      _ref.read(myMatchesProvider.notifier).loadMatches();

      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }
}
