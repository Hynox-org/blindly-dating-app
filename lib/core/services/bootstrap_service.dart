import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart'; // ✅ NEW: For Offline Images

// ✅ Your Correct Imports (Preserved)
import '../../features/discovery/repository/discovery_cache_service.dart';
import '../../features/auth/providers/verification_provider.dart';
import '../../features/discovery/povider/discovery_provider.dart'; // Typo 'povider' maintained
import '../../features/auth/providers/location_provider.dart';

// ✅ Model Import (Required to read the User list)
import '../../features/discovery/domain/models/discovery_user_model.dart';

final bootstrapServiceProvider = Provider<BootstrapService>((ref) {
  return BootstrapService(ref);
});

class BootstrapService {
  final Ref _ref;
  final _cacheService = DiscoveryCacheService();

  BootstrapService(this._ref);

  /// 🚀 MAIN ENTRY POINT: Call this when App Starts (Splash Screen or Onboarding Complete)
  Future<void> initApp() async {
    print("🚀 BOOTSTRAP: Starting App Initialization...");

    // 1. Initialize Local DB (Hive)
    await _cacheService.init();

    // 2. LOAD LOCAL DATA (Instant UI)
    // This makes the app feel "Instant" by showing yesterday's data immediately
    _loadCacheToUI();

    // 3. BACKGROUND REFRESH (Network Sync)
    // We don't await this, so the UI opens immediately while this runs in the background!
    _refreshDataInBackground();
  }

  // Helper: Pushes cached data into Riverpod Providers
  void _loadCacheToUI() {
    final cachedUsers = _cacheService.getUsers();
    final cachedVerification = _cacheService.getVerificationStatus();

    print("📦 BOOTSTRAP: Loaded ${cachedUsers.length} users from Cache.");

    // Inject users into the Feed Provider
    _ref.read(discoveryFeedProvider.notifier).loadFromCache(cachedUsers);

    // Inject verification status
    _ref.read(verificationStatusProvider.notifier).state = cachedVerification;
  }

  // Helper: Fetches fresh data from Supabase
  Future<void> _refreshDataInBackground() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;

      print("🌐 BOOTSTRAP: Fetching fresh data...");

      // A. Check Verification Status (Fresh from DB)
      final response = await Supabase.instance.client
          .from('profiles')
          .select('is_verified')
          .eq('user_id', user.id)
          .single();

      final isVerified = response['is_verified'] as bool? ?? false;

      // Update Provider & Save to Cache
      _ref.read(verificationStatusProvider.notifier).state = isVerified;
      await _cacheService.saveVerificationStatus(isVerified);

      // B. Update Location (Passport)
      // This runs your existing logic to update the DB with current GPS
      await _ref.read(locationServiceProvider).updateUserLocation();

      // C. Fetch Fresh Users
      // We call refreshFeed() which fetches from API and updates state
      final freshUsers = await _ref
          .read(discoveryFeedProvider.notifier)
          .refreshFeed();

      // Update Cache for next time
      await _cacheService.saveUsers(freshUsers);

      // D. 🚀 NEW: Pre-Cache Images Silently
      // Downloads images to disk so they work offline later
      _preCacheImages(freshUsers);

      print("✅ BOOTSTRAP: Data synced & cached successfully.");
    } catch (e) {
      print(
        "⚠️ BOOTSTRAP: Network refresh failed ($e). App will continue in Offline Mode.",
      );
      // No action needed; UI is already showing cached data.
    }
  }

  // ✅ NEW FUNCTION: Downloads images for offline use
  Future<void> _preCacheImages(List<DiscoveryUser> users) async {
    print(
      "⬇️ PRE-CACHE: Starting background image download for ${users.length} profiles...",
    );

    int count = 0;
    for (var user in users) {
      // Check if user has an image (mediaUrl)
      if (user.mediaUrl != null && user.mediaUrl!.isNotEmpty) {
        try {
          // This downloads the file to the cache manager used by CachedNetworkImage
          await DefaultCacheManager().getSingleFile(user.mediaUrl!);
          count++;
        } catch (e) {
          // Ignore failures (e.g., bad URL), we just try our best
          // print("Failed to pre-cache image for ${user.displayName}");
        }
      }
    }
    print(
      "✅ PRE-CACHE: Successfully downloaded $count images for offline use.",
    );
  }
}
