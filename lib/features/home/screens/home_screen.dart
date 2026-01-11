import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';

// ✅ 1. Providers

import '../../../features/discovery/povider/discovery_provider.dart';

// ✅ 2. Models
import '../../discovery/domain/models/discovery_user_model.dart';

// ✅ 3. Components
import '../component/ProfileSwipeCard.dart';
import '../../../../core/utils/gender_utils.dart';
import '../../../../core/utils/custom_popups.dart';

// ✅ 4. New Integrations
import '../../../../core/services/bootstrap_service.dart';
import '../../discovery/presentation/widgets/no_more_profiles_widget.dart';
import '../../discovery/povider/swipe_provider.dart';
import '../../../../core/utils/navigation_utils.dart';
import 'connection_type_screen.dart';

// ✅ 5. Layout
import '../../../../core/widgets/app_layout.dart';

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
  double _swipeProgress = 0.0;

  // ✅ Controls the initialization flow
  bool _isLocationReady = false;

  @override
  void initState() {
    super.initState();
    _initLocationAndFeed();
  }

  /// ✅ SEQUENTIAL INITIALIZATION
  /// Uses BootstrapService to handle everything (Cache, Location, Network)
  Future<void> _initLocationAndFeed() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        debugPrint('🚀 HOMESCREEN: initializing Bootstrap...');

        // 1. Initialize App Services (Hive, Cache, Background Refresh)
        await ref.read(bootstrapServiceProvider).initApp();
        debugPrint('✅ HOMESCREEN: Bootstrap Complete.');

        // 2. Update UI state to show the feed
        if (mounted) {
          setState(() {
            _isLocationReady = true;
          });
        }
      } catch (e) {
        debugPrint('❌ HOMESCREEN: Bootstrap Error: $e');
        // Even if it fails, we try to load the feed (maybe using old location/cache)
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
    final AsyncValue<List<DiscoveryUser>>? discoveryState = _isLocationReady
        ? ref.watch(discoveryFeedProvider)
        : null;

    return AppLayout(
      showFooter: true,
      selectedIndex: 2, // ✅ Home/Peoples tab selected
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.more_vert,
            color: Theme.of(context).colorScheme.onSurface,
            size: 28,
          ),
          onPressed: () => _showModeMenu(),
        ),
        title: Text(
          "Blindly",
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              Icons.reply,
              color: Theme.of(context).colorScheme.onSurface,
              size: 28,
            ),
            onPressed: () => _onUndo(null, 0, CardSwiperDirection.left),
          ),
          IconButton(
            icon: Icon(
              Icons.tune,
              color: Theme.of(context).colorScheme.onSurface,
              size: 28,
            ),
            onPressed: () {
              debugPrint("Filter button pressed");
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
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
                        final profiles = _mapToUserProfiles(discoveryData);

                        if (profiles.isEmpty) {
                          return _buildEmptyState();
                        }

                        return Stack(
                          children: [
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

                            CardSwiper(
                              controller: _controller,
                              cardsCount: profiles.length,
                              numberOfCardsDisplayed: 1,
                              padding: const EdgeInsets.all(24.0),
                              allowedSwipeDirection:
                                  const AllowedSwipeDirection.only(
                                    left: true,
                                    right: true,
                                  ),
                              onSwipe: (prev, curr, dir) =>
                                  _onSwipe(prev, curr, dir, profiles),
                              onUndo: _onUndo,
                              cardBuilder: (context, index, horiz, vert) {
                                // Track swipe progress for indicators
                                if ((_swipeProgress - horiz).abs() > 10.0 ||
                                    (horiz == 0 && _swipeProgress != 0)) {
                                  WidgetsBinding.instance.addPostFrameCallback((
                                    _,
                                  ) {
                                    if (mounted &&
                                            (_swipeProgress - horiz).abs() >
                                                10.0 ||
                                        (horiz == 0 && _swipeProgress != 0)) {
                                      setState(
                                        () => _swipeProgress = horiz.toDouble(),
                                      );
                                    }
                                  });
                                }

                                return ProfileSwipeCard(
                                  key: ValueKey(profiles[index].id),
                                  profile: profiles[index],
                                  horizontalThreshold: horiz.toDouble(),
                                  verticalThreshold: vert.toDouble(),
                                  isHomeScreen: true,
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
                                  onReport: () {
                                    debugPrint(
                                      'Report: ${profiles[index].name}',
                                    );
                                  },
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
    );
  }

  Widget _buildInitializingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: Theme.of(context).colorScheme.secondary,
          ),
          const SizedBox(height: 16),
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

  void _showModeMenu() {
    NavigationUtils.navigateToWithSlide(context, const ConnectionTypeScreen());
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
    ref
        .read(swipeProvider.notifier)
        .swipe(targetProfileId: profile.id, action: 'pass');
  }

  void _handleLike(UserProfile profile) {
    showSuccessPopup(context, 'You liked ${profile.name}! 💚');
    ref
        .read(swipeProvider.notifier)
        .swipe(targetProfileId: profile.id, action: 'like');
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
    return NoMoreProfilesWidget(
      onAdjustFilters: () {
        debugPrint("Adjust Filters clicked from No Feed Screen");
        // Trigger the same filter logic as the app bar button
        // For now, just show a message since the filter logic implementation isn't visible in the snippets
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Filter capability coming soon!")),
        );
      },
      onNotifyMe: () {
        debugPrint("Notify Me clicked");
        showSuccessPopup(context, "We'll notify you when new people join! 🔔");
      },
    );
  }
}
