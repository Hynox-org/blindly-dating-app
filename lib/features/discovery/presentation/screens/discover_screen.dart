import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import '../../../../core/widgets/app_layout.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../../home/screens/connection_type_screen.dart';
import '../../../../core/utils/navigation_utils.dart';
import '../../povider/discovery_landing_provider.dart';
import '../../../../core/providers/connection_mode_provider.dart';
import '../../domain/models/discovery_user_model.dart';
import '../../domain/models/discovery_landing_data.dart';
import 'discovery_profile_detail_screen.dart';
import '../../povider/swipe_provider.dart';

class DiscoverScreen extends ConsumerStatefulWidget {
  const DiscoverScreen({super.key});

  @override
  ConsumerState<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends ConsumerState<DiscoverScreen> {
  Timer? _countdownTimer;
  final Map<String, String> _userInteractions =
      {}; // Track grid actions locally

  @override
  void initState() {
    super.initState();
    // Trigger initial fetch
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchData();
    });

    // Start countdown timer for UI updates
    _countdownTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchData({bool forceRefresh = false}) async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
      );
      final activeMode = ref.read(connectionModeProvider); // Get current mode
      ref
          .read(discoveryLandingProvider.notifier)
          .fetchFeed(
            position.latitude,
            position.longitude,
            mode: activeMode,
            forceRefresh: forceRefresh,
          );
    } catch (e) {
      debugPrint('Location error in DiscoverScreen: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Listen for mode changes to auto-refetch
    ref.listen(connectionModeProvider, (previous, next) {
      if (previous != next) {
        _fetchData();
      }
    });

    final state = ref.watch(discoveryLandingProvider);

    return AppLayout(
      showFooter: true,
      selectedIndex: 1,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.more_vert,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          onPressed: () {
            NavigationUtils.navigateToWithSlide(
              context,
              const ConnectionTypeScreen(),
            );
          },
        ),
        title: Text(
          'Discover',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      child: Container(
        color: Colors.white,
        child: state.when(
          data: (data) => _buildContent(data),
          loading: () => const Center(child: AppLoader()),
          error: (err, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Error: $err'),
                ElevatedButton(
                  onPressed: () => _fetchData(forceRefresh: true),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(DiscoveryLandingData data) {
    if (data.feeds.values.every((list) => list.isEmpty)) {
      return RefreshIndicator(
        onRefresh: () => _fetchData(forceRefresh: true),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.05),
            Image.asset(
              'assets/static/discover_empty_state.png',
              width: double.infinity,
              height: 250,
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Text(
                "You've reached the end\nof the line!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  height: 1.2,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Text(
                "Check back soon for more people or try adjusting your filters to see more profiles.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.4,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.8),
                ),
              ),
            ),
            const SizedBox(height: 48),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: FilledButton(
                onPressed: () => _fetchData(forceRefresh: true),
                style: FilledButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  "See More Peoples",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _fetchData(forceRefresh: true),
      child: ListView(
        padding: const EdgeInsets.only(bottom: 20),
        children: [
          if (data.feeds['top_picks']?.isNotEmpty == true)
            _buildSection('🔥 Top Picks For You', data.feeds['top_picks']!),
          if (data.feeds['nearby']?.isNotEmpty == true)
            _buildSection('📍 Nearby', data.feeds['nearby']!),
          if (data.feeds['shared_interests']?.isNotEmpty == true)
            _buildSection(
              '🤝 Shared Interests',
              data.feeds['shared_interests']!,
            ),
          if (data.feeds['new_faces']?.isNotEmpty == true)
            _buildSection('👋 New Faces', data.feeds['new_faces']!),
          if (data.feeds['recently_active']?.isNotEmpty == true)
            _buildSection('⏱️ Recently Active', data.feeds['recently_active']!),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<DiscoveryUser> users) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              if (users.length > 5)
                GestureDetector(
                  onTap: () {
                    // Navigate to see all
                  },
                  child: Text(
                    'See all',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ),
        SizedBox(
          height: 220, // Adjust based on card height
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: users.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final user = users[index];
              return _buildUserCard(user);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildUserCard(DiscoveryUser user) {
    final interactionState =
        _userInteractions[user.profileId] ?? user.swipeAction ?? 'none';

    return GestureDetector(
      onTap: () async {
        final result = await NavigationUtils.navigateToWithSlide<String>(
          context,
          DiscoveryProfileDetailScreen(
            user: user,
            initialState: interactionState,
          ),
        );
        if (result != null) {
          setState(() {
            _userInteractions[user.profileId] = result;
          });
        }
      },
      child: Container(
        width: 140,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  user.imageUrls.isNotEmpty
                      ? Image.network(
                          user.imageUrls.first,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              Container(color: Colors.grey[300]),
                        )
                      : Container(
                          color: Colors.grey[300],
                          child: const Icon(Icons.person, color: Colors.white),
                        ),
                  Positioned(
                    bottom: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${user.age}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  if (interactionState == 'liked')
                    const Positioned(
                      top: 8,
                      right: 8,
                      child: Text('❤️', style: TextStyle(fontSize: 20)),
                    ),
                  if (interactionState == 'passed')
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: () async {
                          try {
                            final success = await ref
                                .read(swipeProvider.notifier)
                                .undo();
                            if (success) {
                              setState(() {
                                _userInteractions[user.profileId] = 'none';
                              });
                            }
                          } catch (e) {
                            debugPrint('Undo error: $e');
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.undo,
                            size: 16,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.displayName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${user.distanceKm.toStringAsFixed(1)} km away',
                    style: TextStyle(color: Colors.grey[600], fontSize: 11),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
