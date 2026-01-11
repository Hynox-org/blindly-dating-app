import 'package:flutter_riverpod/flutter_riverpod.dart';
// ✅ Keep your existing repository import
import '../../../features/discovery/repository/discovery_repository.dart';
import '../domain/models/discovery_user_model.dart';

// ✅ 1. The Notifier (Manages the Data State)
class DiscoveryFeedNotifier
    extends StateNotifier<AsyncValue<List<DiscoveryUser>>> {
  final DiscoveryRepository _repository;

  DiscoveryFeedNotifier(this._repository) : super(const AsyncLoading());

  /// 📦 LOAD FROM CACHE (Called by BootstrapService)
  /// Instantly shows data from the phone's storage
  void loadFromCache(List<DiscoveryUser> cachedUsers) {
    if (cachedUsers.isNotEmpty) {
      state = AsyncData(cachedUsers);
    }
  }

  /// 🌐 REFRESH FROM NETWORK (Called by BootstrapService or Pull-to-Refresh)
  Future<List<DiscoveryUser>> refreshFeed() async {
    try {
      // Only show loading spinner if we have NO data at all
      if (state.value == null || state.value!.isEmpty) {
        state = const AsyncLoading();
      }

      // ✅ CALLING YOUR EXISTING REPOSITORY METHOD
      final freshUsers = await _repository.getDiscoveryFeed(
        radius: 50000, // 50km
      );

      // Update the UI
      state = AsyncData(freshUsers);
      return freshUsers;
    } catch (e, st) {
      // If network fails but we have cache, keep showing cache!
      if (state.value == null) {
        state = AsyncError(e, st);
      }
      rethrow;
    }
  }
}

// ✅ 2. The Provider Definition
final discoveryFeedProvider =
    StateNotifierProvider<
      DiscoveryFeedNotifier,
      AsyncValue<List<DiscoveryUser>>
    >((ref) {
      final repository = ref.watch(discoveryRepositoryProvider);
      return DiscoveryFeedNotifier(repository);
    });
