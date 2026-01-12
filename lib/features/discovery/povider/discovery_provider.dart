import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../features/discovery/repository/discovery_repository.dart';
import '../domain/models/discovery_user_model.dart';

// ======================================================
// Discovery Feed Notifier
// ======================================================
class DiscoveryFeedNotifier
    extends StateNotifier<AsyncValue<List<DiscoveryUser>>> {
  final DiscoveryRepository _repository;

  int _offset = 0;
  static const int _limit = 20;

  DiscoveryFeedNotifier(this._repository) : super(const AsyncLoading());

  // --------------------------------------------------
  // 📦 LOAD FROM CACHE (Bootstrap)
  // --------------------------------------------------
  void loadFromCache(List<DiscoveryUser> cachedUsers) {
    if (cachedUsers.isNotEmpty) {
      state = AsyncData(cachedUsers);
    }
  }

  // --------------------------------------------------
  // 🌐 INITIAL LOAD / REFRESH
  // --------------------------------------------------
  Future<void> refreshFeed() async {
    try {
      _offset = 0;
      state = const AsyncLoading();

      final freshUsers = await _repository.getDiscoveryFeed(
        radius: 5000,
        limit: _limit,
        offset: _offset,
      );

      state = AsyncData(freshUsers);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  // --------------------------------------------------
  // 🔁 LOAD NEXT BATCH (AFTER ALL CARDS SWIPED)
  // --------------------------------------------------
  /// Returns:
  /// true  → new profiles loaded
  /// false → no more profiles available
  Future<bool> loadNextBatch() async {
    try {
      _offset += _limit;

      final newUsers = await _repository.getDiscoveryFeed(
        radius: 5000,
        limit: _limit,
        offset: _offset,
      );

      if (newUsers.isEmpty) {
        // 🚫 No more profiles in DB
        state = const AsyncData([]);
        return false;
      }

      // Replace feed with NEW users
      state = AsyncData(newUsers);
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }
}

// ======================================================
// Provider
// ======================================================
final discoveryFeedProvider =
    StateNotifierProvider<
        DiscoveryFeedNotifier,
        AsyncValue<List<DiscoveryUser>>>((ref) {
  final repository = ref.watch(discoveryRepositoryProvider);
  return DiscoveryFeedNotifier(repository);
});
