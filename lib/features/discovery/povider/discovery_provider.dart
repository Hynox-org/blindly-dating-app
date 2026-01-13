import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../features/discovery/repository/discovery_repository.dart';
import '../domain/models/discovery_user_model.dart';

// ======================================================
// Discovery Feed Notifier
// ======================================================
class DiscoveryFeedNotifier
    extends StateNotifier<AsyncValue<List<DiscoveryUser>>> {
  final DiscoveryRepository _repository;

  static const int _limit = 20;

  int _offset = 0;
  bool _hasMore = true;
  bool _isLoading = false;

  DiscoveryFeedNotifier(this._repository)
      : super(const AsyncLoading()) {
    // ✅ AUTO-LOAD DISCOVERY FEED ON PROVIDER CREATION
    _initialLoad();
  }

  // --------------------------------------------------
  // 🔥 FIRST LOAD (CALLED ONLY ONCE)
  // --------------------------------------------------
  Future<void> _initialLoad() async {
    try {
      _isLoading = true;

      final users = await _repository.getDiscoveryFeed(
        radius: 50000,
        limit: _limit,
        offset: 0,
      );

      _offset = 0;
      _hasMore = users.length == _limit;

      state = AsyncData(users);
    } catch (e, st) {
      state = AsyncError(e, st);
    } finally {
      _isLoading = false;
    }
  }

  void removeTopProfile() {
  final current = state.value ?? [];
  if (current.isEmpty) return;

  state = AsyncData(current.sublist(1));
}

  // --------------------------------------------------
  // 🔁 FORCE REFRESH (MODE CHANGE, MANUAL REFRESH)
  // --------------------------------------------------
  Future<List<DiscoveryUser>> refreshFeed() async {
    if (_isLoading) return state.value ?? [];

    try {
      _isLoading = true;
      _offset = 0;
      _hasMore = true;

      state = const AsyncLoading();

      final freshUsers = await _repository.getDiscoveryFeed(
        radius: 50000,
        limit: _limit,
        offset: 0,
      );

      _hasMore = freshUsers.length == _limit;
      state = AsyncData(freshUsers);

      return freshUsers;
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    } finally {
      _isLoading = false;
    }
  }

  // --------------------------------------------------
  // 🔁 LOAD NEXT BATCH (WHEN DECK IS EMPTY)
  // --------------------------------------------------
  Future<bool> loadNextBatch() async {
    if (!_hasMore || _isLoading) return false;

    try {
      _isLoading = true;

      final nextOffset = _offset + _limit;

      final newUsers = await _repository.getDiscoveryFeed(
        radius: 50000,
        limit: _limit,
        offset: nextOffset,
      );

      if (newUsers.isEmpty) {
        _hasMore = false;
        state = const AsyncData([]);
        return false;
      }

      _offset = nextOffset;
      _hasMore = newUsers.length == _limit;

      state = AsyncData(newUsers);
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    } finally {
      _isLoading = false;
    }
  }

  // --------------------------------------------------
  // ↩️ INSERT PROFILE BACK (UNDO)
  // --------------------------------------------------
  void insertAtTop(DiscoveryUser user) {
    final current = state.value ?? [];
    state = AsyncData([user, ...current]);
  }

  // --------------------------------------------------
  // 🔄 CHANGE DISCOVERY MODE
  // --------------------------------------------------
  Future<void> changeDiscoveryMode(String uiMode) async {
    final String dbMode;
    if (uiMode.toLowerCase() == 'date') {
      dbMode = 'dating';
    } else if (uiMode.toLowerCase() == 'bff') {
      dbMode = 'bff';
    } else {
      throw Exception('Unsupported discovery mode');
    }

    await _repository.updateDiscoveryMode(dbMode);
    await refreshFeed();
  }
}


// ======================================================
// Provider
// ======================================================
final discoveryFeedProvider =
    StateNotifierProvider<
      DiscoveryFeedNotifier,
      AsyncValue<List<DiscoveryUser>>
    >((ref) {
      final repository = ref.watch(discoveryRepositoryProvider);
      return DiscoveryFeedNotifier(repository);
    });
