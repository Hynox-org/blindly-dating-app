import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:blindly_dating_app/features/discovery/domain/models/discovery_landing_data.dart';
import 'package:blindly_dating_app/features/discovery/repository/discovery_feed_repository.dart';

final discoveryLandingProvider =
    StateNotifierProvider<
      DiscoveryLandingNotifier,
      AsyncValue<DiscoveryLandingData>
    >((ref) {
      final repository = ref.watch(discoveryFeedRepositoryProvider);
      return DiscoveryLandingNotifier(repository);
    });

class DiscoveryLandingNotifier
    extends StateNotifier<AsyncValue<DiscoveryLandingData>> {
  final DiscoveryFeedRepository _repository;
  String? _lastFetchedMode;
  DateTime? _lastFetchTime;

  DiscoveryLandingNotifier(this._repository)
    : super(const AsyncValue.loading());

  /// The server reads the caller's location from `profiles.location_geom`, so
  /// there is deliberately no lat/long here — this used to take a pair of
  /// coordinates it never passed on, at the cost of a GPS fix per visit.
  Future<void> fetchFeed({String? mode, bool forceRefresh = false}) async {
    // The mode arrives as 'Date' from the provider and 'date' from the
    // database. Comparing raw strings counted that as a mode change and
    // threw away the cache on every cold start.
    final normalised = (mode ?? 'date').toLowerCase();

    final hasData = state.valueOrNull != null;
    final isSameMode = _lastFetchedMode == normalised;
    final fetchRecently =
        _lastFetchTime != null &&
        DateTime.now().difference(_lastFetchTime!).inMinutes < 5;

    if (hasData && isSameMode && !forceRefresh && fetchRecently) {
      return; // Use cache
    }

    if (!hasData || forceRefresh) {
      state = const AsyncValue.loading();
    }

    try {
      final data = await _repository.getDiscoveryFeed(mode: normalised);
      _lastFetchedMode = normalised;
      _lastFetchTime = DateTime.now();
      if (mounted) state = AsyncValue.data(data);
    } catch (e, st) {
      if (mounted) state = AsyncValue.error(e, st);
    }
  }
}
