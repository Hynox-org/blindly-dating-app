import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';

// ✅ 1. Providers
import '../../auth/providers/auth_providers.dart';
import '../../../features/discovery/povider/discovery_provider.dart';
import '../../auth/providers/location_provider.dart';

// ✅ 2. Models
import '../../discovery/domain/models/discovery_user_model.dart';

// ✅ 3. Components
import '../component/ProfileSwipeCard.dart';
import '../../../../core/utils/gender_utils.dart';
import '../../../../core/utils/custom_popups.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final CardSwiperController _controller = CardSwiperController();

  // State Variables
  int _swipeCount = 10;
  final int _maxSwipes = 10;
  final bool _isPremium = false;
  int _selectedIndex = 2;
  double _swipeProgress = 0.0;

  // ✅ NEW: Controls the initialization flow
  bool _isLocationReady = false;

  @override
  void initState() {
    super.initState();
    // Start the initialization sequence immediately
    _initLocationAndFeed();
  }

  /// ✅ SEQUENTIAL INITIALIZATION
  /// 1. Updates Passport Location first
  /// 2. Then enables the Discovery Feed
  Future<void> _initLocationAndFeed() async {
    // Wait for the frame to build so we can safely use 'ref'
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        debugPrint('📍 HOMESCREEN: Updating Location...');

        // 1. AWAIT the location update (This writes to DB)
        await ref.read(locationServiceProvider).updateUserLocation();
        debugPrint('✅ HOMESCREEN: Location Updated.');

        // 2. Refresh the feed provider to ensure it uses the NEW location data
        // This clears any old cached "empty" results
        ref.invalidate(discoveryFeedProvider);

        // 3. Update UI state to show the feed
        if (mounted) {
          setState(() {
            _isLocationReady = true;
          });
        }
      } catch (e) {
        debugPrint('❌ HOMESCREEN: Location Error: $e');
        // Even if location fails, we try to load the feed (maybe using old location)
        if (mounted) {
          setState(() {
            _isLocationReady = true;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // ✅ Helper to map API data to UI data
  List<UserProfile> _mapToUserProfiles(List<DiscoveryUser> discoveryUsers) {
    return discoveryUsers.map((user) {
      return UserProfile(
        id: user.profileId,
        name: user.displayName,
        age: user.age,
        distance: double.parse((user.distanceMeters / 1000).toStringAsFixed(1)),
        location: user.city.isNotEmpty ? user.city : 'Nearby',
        gender: mapGender(user.gender),
        imageUrls: user.mediaUrl != null
            ? [user.mediaUrl!]
            : ['https://picsum.photos/400/600'],
        bio:
            'Match Score: ${user.matchScore}% • ${user.sharedInterestsCount} shared interests',
        height: 'Ask me',
        activityLevel: 'Active',
        education: '',
        religion: '',
        zodiac: '',
        drinking: '',
        smoking: '',
        summary: user.bio.isNotEmpty ? user.bio : 'Swipe right to know more!',
        lookingFor: 'Connection',
        lookingForTags: [],
        quickestWay: '',
        hobbies: [],
        causes: [],
        simplePleasure: '',
        languages: [],
        spotifyArtists: [],
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    // ✅ CRITICAL CHANGE:
    // Only watch the feed provider if location is ready.
    // If not ready, we pass null or handle it in the body.
    final AsyncValue<List<DiscoveryUser>>? discoveryState = _isLocationReady
        ? ref.watch(discoveryFeedProvider)
        : null;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.menu,
            color: Theme.of(context).colorScheme.onSurface,
            size: 28,
          ),
          onPressed: () => _showMenuDialog(),
        ),
        title: Image.asset(
          'assests/images/blindly-text-logo.png',
          height: 24,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return Text(
              "Blindly",
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
            );
          },
        ),
        centerTitle: true,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.local_fire_department,
                  size: 16,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                const SizedBox(width: 4),
                Text(
                  '$_swipeCount/$_maxSwipes',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              // ✅ LOGIC BRANCHING:
              // 1. If location not ready -> Show Loading
              // 2. If ready -> Show Feed
              child: !_isLocationReady || discoveryState == null
                  ? _buildInitializingState()
                  : discoveryState.when(
                      loading: () => Center(
                        child: CircularProgressIndicator(
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                      error: (err, stack) => Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Text(
                            'Error loading matches: $err',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      data: (discoveryData) {
                        // 🔍 DEBUG LOGS
                        debugPrint(
                          '================ DISCOVERY DEBUG ================',
                        );
                        debugPrint('RAW COUNT: ${discoveryData.length}');
                        debugPrint(
                          'PROFILE IDS: ${discoveryData.map((e) => e.profileId).toList()}',
                        );
                        debugPrint(
                          'GENDERS FROM API: ${discoveryData.map((e) => e.gender).toList()}',
                        );

                        debugPrint(
                          '=================================================',
                        );

                        final profiles = _mapToUserProfiles(discoveryData);

                        if (profiles.isEmpty) {
                          return _buildEmptyState();
                        }

                        return Stack(
                          children: [
                            // -------------------------
                            // 1. Left/Right Indicators
                            // -------------------------
                            Positioned.fill(
                              child: Padding(
                                padding: const EdgeInsets.all(24.0),
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: AnimatedOpacity(
                                    opacity: _swipeProgress < -0.1
                                        ? (_swipeProgress.abs() * 2).clamp(
                                            0.0,
                                            1.0,
                                          )
                                        : 0.0,
                                    duration: const Duration(milliseconds: 100),
                                    child: Container(
                                      width: 80,
                                      height: 80,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                            .withValues(alpha: 0.4),
                                      ),
                                      child: const Icon(
                                        Icons.close,
                                        color: Colors.white,
                                        size: 50,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Positioned.fill(
                              child: Padding(
                                padding: const EdgeInsets.all(24.0),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: AnimatedOpacity(
                                    opacity: _swipeProgress > 0.1
                                        ? (_swipeProgress.abs() * 2).clamp(
                                            0.0,
                                            1.0,
                                          )
                                        : 0.0,
                                    duration: const Duration(milliseconds: 100),
                                    child: Container(
                                      width: 80,
                                      height: 80,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                            .withValues(alpha: 0.4),
                                      ),
                                      child: const Icon(
                                        Icons.favorite,
                                        color: Colors.white,
                                        size: 50,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            // -------------------------
                            // 2. Card Swiper
                            // -------------------------
                            CardSwiper(
                              controller: _controller,
                              cardsCount: profiles.length,
                              numberOfCardsDisplayed: 1,
                              padding: const EdgeInsets.all(24.0),
                              onSwipe: (prev, curr, dir) =>
                                  _onSwipe(prev, curr, dir, profiles),
                              onUndo: _onUndo,
                              cardBuilder: (context, index, horiz, vert) {
                                // Track swipe progress for indicators
                                WidgetsBinding.instance.addPostFrameCallback((
                                  _,
                                ) {
                                  if (mounted) {
                                    setState(
                                      () => _swipeProgress = horiz.toDouble(),
                                    );
                                  }
                                });

                                return ProfileSwipeCard(
                                  key: ValueKey(profiles[index].id),
                                  profile: profiles[index],
                                  horizontalThreshold: horiz.toDouble(),
                                  verticalThreshold: vert.toDouble(),
                                  onLike: () {
                                    if (_swipeCount > 0) {
                                      _handleLike(profiles[index]);
                                      _controller.swipe(
                                        CardSwiperDirection.right,
                                      );
                                    }
                                  },
                                  onBlock: () {
                                    if (_swipeCount > 0) {
                                      _handlePass(profiles[index]);
                                      _controller.swipe(
                                        CardSwiperDirection.left,
                                      );
                                    }
                                  },
                                  onReport: () {},
                                );
                              },
                            ),
                          ],
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  icon: Icons.person_outline,
                  label: 'Profile',
                  index: 0,
                  isSelected: _selectedIndex == 0,
                ),
                _buildNavItem(
                  icon: Icons.explore_outlined,
                  label: 'Discover',
                  index: 1,
                  isSelected: _selectedIndex == 1,
                ),
                _buildNavItem(
                  icon: Icons.people_outline,
                  label: 'Peoples',
                  index: 2,
                  isSelected: _selectedIndex == 2,
                ),
                _buildNavItem(
                  icon: Icons.favorite_outline,
                  label: 'Matches',
                  index: 3,
                  isSelected: _selectedIndex == 3,
                ),
                _buildNavItem(
                  icon: Icons.chat_bubble_outline,
                  label: 'Chat',
                  index: 4,
                  isSelected: _selectedIndex == 4,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ✅ New Loading Widget for Location Init
  Widget _buildInitializingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: Theme.of(context).colorScheme.secondary,
          ),
          SizedBox(height: 16),
          Text(
            "Updating your location...",
            style: TextStyle(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.5),
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
    required bool isSelected,
  }) {
    final Color selectedColor = Theme.of(context).colorScheme.secondary;
    final Color unselectedColor = Theme.of(context).colorScheme.onSurface;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? selectedColor : unselectedColor,
            size: 28,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontFamily: 'Poppins',
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              color: isSelected ? selectedColor : unselectedColor,
            ),
          ),
        ],
      ),
    );
  }

  void _showMenuDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Menu', style: TextStyle(fontFamily: 'Poppins')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(
                Icons.logout,
                color: Theme.of(context).colorScheme.error,
              ),
              title: Text(
                'Logout',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
              onTap: () async {
                Navigator.pop(context);
                await ref.read(authRepositoryProvider).signOut();
              },
            ),
          ],
        ),
      ),
    );
  }

  bool _onSwipe(
    int previousIndex,
    int? currentIndex,
    CardSwiperDirection direction,
    List<UserProfile> profiles,
  ) {
    setState(() {
      _swipeProgress = 0.0;
    });
    if (_swipeCount <= 0) {
      _showLimitReachedDialog();
      return false;
    }

    _triggerHapticFeedback(direction);
    setState(() {
      _swipeCount--;
    });

    final profile = profiles[previousIndex];
    if (direction == CardSwiperDirection.left) _handlePass(profile);
    if (direction == CardSwiperDirection.right) _handleLike(profile);

    if (currentIndex == null) _showNoMoreCardsDialog();
    return true;
  }

  bool _onUndo(
    int? previousIndex,
    int currentIndex,
    CardSwiperDirection direction,
  ) {
    if (!_isPremium) {
      _showPremiumDialog();
      return false;
    }
    HapticFeedback.mediumImpact();
    setState(() {
      _swipeCount++;
      _swipeProgress = 0.0;
    });
    return true;
  }

  void _triggerHapticFeedback(CardSwiperDirection direction) {
    HapticFeedback.selectionClick();
  }

  void _handlePass(UserProfile profile) {
    debugPrint('Passed: ${profile.name}');
  }

  void _handleLike(UserProfile profile) {
    showSuccessPopup(context, 'You liked ${profile.name}! 💚');
  }

  void _showPremiumDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Premium Feature'),
        content: const Text('Undo is for premium members.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showLimitReachedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Limit Reached'),
        content: const Text('No more swipes for today!'),
      ),
    );
  }

  void _showNoMoreCardsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('No More Profiles'),
        content: const Text('Check back later!'),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 100,
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 20),
          Text(
            'No profiles available',
            style: TextStyle(
              fontSize: 20,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}
