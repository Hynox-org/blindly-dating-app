import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import '../../features/discovery/repository/discovery_cache_service.dart';
import '../../features/auth/providers/verification_provider.dart';
import '../../features/discovery/povider/discovery_provider.dart';
import '../../features/auth/providers/location_provider.dart';
import '../../features/discovery/domain/models/discovery_user_model.dart';

final bootstrapServiceProvider = Provider<BootstrapService>((ref) {
  return BootstrapService(ref);
});

class BootstrapService {
  final Ref _ref;
  final _cacheService = DiscoveryCacheService();

  BootstrapService(this._ref);

  /// 🚀 MAIN ENTRY POINT
  Future<void> initApp() async {
    print("🚀 BOOTSTRAP: Starting App Initialization...");

    await _cacheService.init();

    _loadCacheToUI();

    // fire & forget
    _refreshDataInBackground();
  }

  // --------------------------------------------------
  // 📦 LOAD CACHE
  // --------------------------------------------------
  void _loadCacheToUI() {
    final cachedUsers = _cacheService.getUsers();
    final cachedVerification = _cacheService.getVerificationStatus();

    print("📦 BOOTSTRAP: Loaded ${cachedUsers.length} users from Cache.");

    _ref.read(discoveryFeedProvider.notifier).loadFromCache(cachedUsers);
    _ref.read(verificationStatusProvider.notifier).state = cachedVerification;
  }

  // --------------------------------------------------
  // 🌐 BACKGROUND REFRESH
  // --------------------------------------------------
  Future<void> _refreshDataInBackground() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;

      print("🌐 BOOTSTRAP: Fetching fresh data...");

      // A️⃣ Verification
      final response = await Supabase.instance.client
          .from('profiles')
          .select('is_verified')
          .eq('user_id', user.id)
          .single();

      final isVerified = response['is_verified'] as bool? ?? false;

      _ref.read(verificationStatusProvider.notifier).state = isVerified;
      await _cacheService.saveVerificationStatus(isVerified);

      // B️⃣ Location update
      await _ref.read(locationServiceProvider).updateUserLocation();

      // C️⃣ Refresh discovery feed (FIRST PAGE ONLY)
      await _ref.read(discoveryFeedProvider.notifier).refreshFeed();

      // D️⃣ Read updated state from provider
      final discoveryState = _ref.read(discoveryFeedProvider);
      final freshUsers = discoveryState.value ?? <DiscoveryUser>[];

      // Cache users
      await _cacheService.saveUsers(freshUsers);

      // Pre-cache images
      _preCacheImages(freshUsers);

      print("✅ BOOTSTRAP: Data synced & cached successfully.");
    } catch (e) {
      print(
        "⚠️ BOOTSTRAP: Network refresh failed ($e). Offline cache will be used.",
      );
    }
  }

  // --------------------------------------------------
  // 🖼️ PRE-CACHE IMAGES
  // --------------------------------------------------
  Future<void> _preCacheImages(List<DiscoveryUser> users) async {
    print(
      "⬇️ PRE-CACHE: Starting background image download for ${users.length} profiles...",
    );

    int count = 0;
    for (final user in users) {
      if (user.mediaUrl != null && user.mediaUrl!.isNotEmpty) {
        try {
          await DefaultCacheManager().getSingleFile(user.mediaUrl!);
          count++;
        } catch (_) {}
      }
    }

    print(
      "✅ PRE-CACHE: Successfully downloaded $count images for offline use.",
    );
  }
}
