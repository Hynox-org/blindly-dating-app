import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/models/discovery_user_model.dart';
import '../domain/models/discovery_landing_data.dart';
import '../repository/smart_discovery_repository.dart';

final discoveryLandingProvider =
    StateNotifierProvider<
      DiscoveryLandingNotifier,
      AsyncValue<DiscoveryLandingData>
    >((ref) {
      final repository = ref.watch(smartDiscoveryRepositoryProvider);
      return DiscoveryLandingNotifier(repository);
    });

class DiscoveryLandingNotifier
    extends StateNotifier<AsyncValue<DiscoveryLandingData>> {
  final SmartDiscoveryRepository _repository;
  String? _lastFetchedMode;
  DateTime? _lastFetchTime;

  DiscoveryLandingNotifier(this._repository)
    : super(const AsyncValue.loading()) {
    _init();
  }

  Future<void> _init() async {
    // Initialization without location context
  }

  Future<void> fetchFeed(
    double lat,
    double long, {
    String? mode,
    bool forceRefresh = false,
  }) async {
    // Cache Check: Don't refresh if it's the same mode, we already have data, and they didn't force it
    final hasData = state.valueOrNull != null;
    final isSameMode = _lastFetchedMode == mode;
    final fetchRecently =
        _lastFetchTime != null &&
        DateTime.now().difference(_lastFetchTime!).inMinutes <
            5; // prevent spams

    if (hasData && isSameMode && !forceRefresh && fetchRecently) {
      return; // Use Cache
    }

    if (!hasData || forceRefresh) {
      state = const AsyncValue.loading();
    }

    try {
      final data = await _repository.getSmartDiscoveryFeed(
        mode: mode ?? 'date',
      );
      _lastFetchedMode = mode;
      _lastFetchTime = DateTime.now();
      state = AsyncValue.data(data);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  void removeUser(String userId) {
    state.whenData((data) {
      final newData = <String, List<DiscoveryUser>>{};
      bool changed = false;

      for (var key in data.feeds.keys) {
        final list = data.feeds[key] ?? [];
        final filtered = list.where((u) => u.profileId != userId).toList();
        newData[key] = filtered;
        if (list.length != filtered.length) changed = true;
      }

      if (changed) {
        state = AsyncValue.data(
          DiscoveryLandingData(
            feeds: newData,
            lastRefreshedAt: data.lastRefreshedAt,
          ),
        );
      }
    });
  }
}
