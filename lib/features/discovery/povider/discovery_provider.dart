import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../features/discovery/repository/discovery_repository.dart';
import '../domain/models/discovery_user_model.dart';

// This provider fetches the list automatically when watched
final discoveryFeedProvider = FutureProvider.autoDispose<List<DiscoveryUser>>((
  ref,
) async {
  // 1. Get the repository
  final repository = ref.watch(discoveryRepositoryProvider);

  // 2. Fetch the data
  // Check kDevMode directly from the class
  if (DiscoveryRepository.kDevMode) {
    return await repository.getAllProfilesDev();
  }

  // Production/Standard Mode
  // You can parameterize this later (e.g., if you add a distance slider)
  return await repository.getDiscoveryFeed(
    radius: 50000, // 5km
  );
});
