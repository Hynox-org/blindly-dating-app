import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../core/widgets/app_layout.dart';
import '../../../home/screens/connection_type_screen.dart';
import '../../../../core/utils/navigation_utils.dart';
import '../../povider/discovery_landing_provider.dart';
import '../../../../core/providers/connection_mode_provider.dart';
import '../../domain/models/discovery_user_model.dart';
import 'discovery_profile_detail_screen.dart';

class DiscoverScreen extends ConsumerStatefulWidget {
  const DiscoverScreen({super.key});

  @override
  ConsumerState<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends ConsumerState<DiscoverScreen> {
  @override
  void initState() {
    super.initState();
    // Trigger initial fetch
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchData();
    });
  }

  Future<void> _fetchData() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
      );
      final activeMode = ref.read(connectionModeProvider); // Get current mode
      ref
          .read(discoveryLandingProvider.notifier)
          .fetchFeed(position.latitude, position.longitude, mode: activeMode);
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
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Error: $err'),
                ElevatedButton(
                  onPressed: _fetchData,
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(Map<String, List<DiscoveryUser>> data) {
    if (data.values.every((list) => list.isEmpty)) {
      return const Center(child: Text("No users found nearby."));
    }

    return RefreshIndicator(
      onRefresh: _fetchData,
      child: ListView(
        padding: const EdgeInsets.only(bottom: 20),
        children: [
          if (data['nearby']?.isNotEmpty == true)
            _buildSection('Nearby', data['nearby']!),
          if (data['new_faces']?.isNotEmpty == true)
            _buildSection('New Faces', data['new_faces']!),
          if (data['recently_active']?.isNotEmpty == true)
            _buildSection('Recently Active', data['recently_active']!),
          if (data['wanderlust']?.isNotEmpty == true)
            _buildSection('Wanderlust', data['wanderlust']!),
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
    return GestureDetector(
      onTap: () {
        NavigationUtils.navigateToWithSlide(
          context,
          DiscoveryProfileDetailScreen(user: user),
        );
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
