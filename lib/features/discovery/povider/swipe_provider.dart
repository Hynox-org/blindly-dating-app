import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repository/swipe_repository.dart';

// ❌ DO NOT redefine swipeRepositoryProvider here
// It already exists in swipe_repository.dart

// -------------------------------
// Swipe State Provider
// -------------------------------
final swipeProvider =
    StateNotifierProvider<SwipeNotifier, AsyncValue<void>>((ref) {
  return SwipeNotifier(
    ref.read(swipeRepositoryProvider),
  );
});

// -------------------------------
// Swipe Notifier
// -------------------------------
class SwipeNotifier extends StateNotifier<AsyncValue<void>> {
  final SwipeRepository _repository;

  SwipeNotifier(this._repository)
      : super(const AsyncData(null));

  /// Records a swipe action
  ///
  /// action must be:
  /// like | pass | super_like | rewind
  Future<void> swipe({
    required String targetProfileId,
    required String action,
  }) async {
    try {
      state = const AsyncLoading();

      await _repository.recordSwipe(
        targetProfileId: targetProfileId, // ✅ FIXED
        actionType: action,               // ✅ FIXED
      );

      // Success
      state = const AsyncData(null);

    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow; // 🔥 IMPORTANT: UI must receive error
    }
  }
}
