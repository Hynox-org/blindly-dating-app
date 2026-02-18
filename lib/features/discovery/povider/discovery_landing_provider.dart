import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/models/discovery_user_model.dart';
import '../repository/discovery_landing_repository.dart';

final discoveryLandingProvider =
    StateNotifierProvider<
      DiscoveryLandingNotifier,
      AsyncValue<Map<String, List<DiscoveryUser>>>
    >((ref) {
      final repository = ref.watch(discoveryLandingRepositoryProvider);
      return DiscoveryLandingNotifier(repository);
    });

class DiscoveryLandingNotifier
    extends StateNotifier<AsyncValue<Map<String, List<DiscoveryUser>>>> {
  final DiscoveryLandingRepository _repository;

  DiscoveryLandingNotifier(this._repository)
    : super(const AsyncValue.loading()) {
    _init();
  }

  Future<void> _init() async {
    // Ideally get location from a provider, but for simplicity here or using a default
    // In real app, listen to location provider.
    // For now, let's assume valid location or fetch one.
    try {
      // Placeholder for location fetching or injection
      // final position = await Geolocator.getCurrentPosition();
      // fetchFeed(position.latitude, position.longitude);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> fetchFeed(double lat, double long, {String? mode}) async {
    state = const AsyncValue.loading();
    try {
      final data = await _repository.getDiscoveryLandingFeed(
        lat: lat,
        long: long,
        mode: mode,
      );
      state = AsyncValue.data(data);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  void removeUser(String userId) {
    state.whenData((data) {
      final newData = <String, List<DiscoveryUser>>{};
      bool changed = false;

      for (var key in data.keys) {
        final list = data[key] ?? [];
        final filtered = list.where((u) => u.profileId != userId).toList();
        newData[key] = filtered;
        if (list.length != filtered.length) changed = true;
      }

      if (changed) {
        state = AsyncValue.data(newData);
      }
    });
  }
}
