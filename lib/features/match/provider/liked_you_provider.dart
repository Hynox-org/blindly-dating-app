import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/models/liked_you_user_model.dart';
import '../repository/liked_you_repository.dart';

// ======================================================
// ❤️ Liked You Notifier
// ======================================================
class LikedYouNotifier extends StateNotifier<AsyncValue<List<LikedYouUser>>> {
  final LikedYouRepository _repository;

  LikedYouNotifier(this._repository) : super(const AsyncLoading());

  // --------------------------------------------------
  // 🔥 LOAD USERS WHO LIKED ME
  // --------------------------------------------------
  Future<void> _loadLikedYou() async {
    try {
      state = const AsyncLoading();

      final users = await _repository.getUsersWhoLikedMe();

      state = AsyncData(users);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  // --------------------------------------------------
  // 🔁 PUBLIC REFRESH
  // --------------------------------------------------
  Future<void> refresh() async {
    await _loadLikedYou();
  }
}

// ======================================================
// Provider
// ======================================================
final likedYouProvider =
    StateNotifierProvider<LikedYouNotifier, AsyncValue<List<LikedYouUser>>>((
      ref,
    ) {
      final repository = ref.watch(likedYouRepositoryProvider);
      return LikedYouNotifier(repository);
    });
