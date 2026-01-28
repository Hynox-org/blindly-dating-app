import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:geolocator/geolocator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ✅ 1. Providers
import '../../../features/discovery/povider/discovery_provider.dart';
import '../../discovery/povider/swipe_provider.dart';
import '../../../../core/providers/session_provider.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../../../core/providers/connection_mode_provider.dart';

// ✅ 2. Models
import '../../discovery/domain/models/discovery_user_model.dart';

// ✅ 3. Components
import '../component/ProfileSwipeCard.dart';
import '../../../../core/utils/gender_utils.dart';
import '../../../../core/utils/custom_popups.dart';
import '../../discovery/presentation/widgets/no_more_profiles_widget.dart';
import '../../../../core/utils/navigation_utils.dart';
import 'connection_type_screen.dart';

// ✅ 4. Layout
import '../../../../core/widgets/app_layout.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

// ✅ Added: with SingleTickerProviderStateMixin
class _HomeScreenState extends ConsumerState<HomeScreen> {
  final CardSwiperController _controller = CardSwiperController();

  // State Variables
  double _swipeProgress = 0.0;

  // 🔒 Run location update only once
  bool _locationUpdateDone = false;
  // ✅ Controls the initialization flow
  bool _isLocationReady = false;
  bool _isDeckFinished = false; // <--- ADD THIS
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _initLocationAndFeed();
  }

  // ✅ NEW FUNCTION: Handles undo when the deck is empty
  void _handleManualUndo(List<DiscoveryUser> mainDeck) {
    if (mainDeck.isEmpty) return;

    HapticFeedback.mediumImpact();

    // 1. Undo the database action
    ref.read(swipeProvider.notifier).undo();

    // 2. Bring the Swiper back
    setState(() {
      _isDeckFinished = false;
      // Set the index to the last card so it appears correctly
      _currentIndex = mainDeck.length - 1;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _updatePassportLocationOnce() async {
    if (_locationUpdateDone) return;
    _locationUpdateDone = true;

    try {
      final permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        await Geolocator.requestPermission();
      }

      final finalPermission = await Geolocator.checkPermission();

      if (finalPermission == LocationPermission.denied ||
          finalPermission == LocationPermission.deniedForever) {
        debugPrint('📍 Location permission denied');
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
        timeLimit: const Duration(seconds: 6),
      );

      await Supabase.instance.client.rpc(
        'update_passport_location',
        params: {'p_lat': position.latitude, 'p_long': position.longitude},
      );

      debugPrint('📍 Passport location updated (HomeScreen)');
    } catch (e) {
      debugPrint('⚠️ Passport location update skipped: $e');
    }
  }

  Future<void> _initLocationAndFeed() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // ✅ 1. CHECK SESSION FLAG
      // If we already updated location this session, skip the heavy lifting.
      final isAlreadyUpdated = ref.read(locationUpdateSessionProvider);

      if (isAlreadyUpdated) {
        debugPrint('⏩ Session: Location already updated. Skipping.');
        if (mounted) setState(() => _isLocationReady = true);
        return;
      }

      // ✅ 2. RUN UPDATE (First time only)
      try {
        await _updatePassportLocationOnce();

        // ✅ 3. SET FLAG TO TRUE
        // Next time you come here, it will skip this block.
        ref.read(locationUpdateSessionProvider.notifier).state = true;
      } catch (e) {
        debugPrint('❌ HOMESCREEN: Location update failed: $e');
      } finally {
        if (mounted) {
          setState(() {
            _isLocationReady = true;
          });
        }
      }
    });
  }

  // ✅ Helper to map API data to UI data
  List<UserProfile> _mapToUserProfiles(List<DiscoveryUser> discoveryUsers) {
    return discoveryUsers.map((user) {
      final imgUrl = user.mediaUrl;

      return UserProfile(
        id: user.profileId,
        name: user.displayName,
        age: user.age,
        distance: double.parse((user.distanceMeters / 1000).toStringAsFixed(1)),
        location: user.city.isNotEmpty ? user.city : 'Nearby',
        gender: mapGender(user.gender),
        imageUrls: imgUrl != null && imgUrl.isNotEmpty
            ? [imgUrl]
            : [
                'https://ui-avatars.com/api/?name=${Uri.encodeComponent(user.displayName)}&background=random&size=600&bold=true&font-size=0.5',
              ],
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
    // ✅ NEW: Watch the DiscoveryState object (which holds mainDeck + historyDeck)
    final DiscoveryState feedState = _isLocationReady
        ? ref.watch(discoveryFeedProvider)
        : DiscoveryState(mainDeck: [], isLoading: true);

    final mainDeck = feedState.mainDeck;
    final isLoading = feedState.isLoading;
    final historyDeck = feedState.historyDeck;

    return AppLayout(
      showFooter: true,
      selectedIndex: 2, // ✅ Home/Peoples tab selected
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
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
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              Icons.reply,
              color: historyDeck.isEmpty
                  ? Colors.grey
                  : Theme.of(context).colorScheme.onSurface,
              size: 28,
            ),
            // ✅ NEW: Just trigger the controller.
            // This will automatically fire the _onUndo callback below.
            onPressed: () {
              // ✅ NEW LOGIC:
              // If the deck is finished, do Manual Undo. Otherwise, do Controller Undo.
              final showEmptyState = mainDeck.isEmpty || _isDeckFinished;

              if (showEmptyState && mainDeck.isNotEmpty) {
                _handleManualUndo(mainDeck);
              } else {
                _controller.undo();
              }
            },
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
              // 1. Check Location -> 2. Check Loading -> 3. Check Initial Empty -> 4. Show Stack
              child: !_isLocationReady
                  ? _buildInitializingState()
                  : isLoading
                  ? _buildInitializingState()
                  : (mainDeck.isEmpty || _isDeckFinished)
                  ? _buildEmptyState() // Show immediately if 0 matches found
                  : Stack(
                      children: [
                        // --------------------------------------------------
                        // 0. LAYER ZERO: The Empty State (Background)
                        // --------------------------------------------------
                        // ✅ FIX 1: Only render this when 1 or fewer cards left.
                        // // This solves "background peeking".
                        // if (mainDeck.length <= 1)
                        //   Positioned.fill(child: _buildEmptyState()),

                        // --------------------------------------------------
                        // 1. LAYER ONE: Right Indicator (Cross / Pass)
                        // --------------------------------------------------
                        Positioned.fill(
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: AnimatedOpacity(
                                opacity: _swipeProgress < -0.1
                                    ? (_swipeProgress.abs() * 2).clamp(0.0, 1.0)
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

                        // --------------------------------------------------
                        // 2. LAYER TWO: Left Indicator (Heart / Like)
                        // --------------------------------------------------
                        Positioned.fill(
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: AnimatedOpacity(
                                opacity: _swipeProgress > 0.1
                                    ? (_swipeProgress.abs() * 2).clamp(0.0, 1.0)
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

                        // --------------------------------------------------
                        // 3. LAYER THREE: The Card Swiper (Top)
                        // --------------------------------------------------
                        CardSwiper(
                          controller: _controller,
                          // ✅ 1. ADD KEY: Prevents "ghost" cards from old states
                          key: ValueKey(
                            mainDeck.isNotEmpty
                                ? mainDeck.first.profileId
                                : 'empty',
                          ),

                          cardsCount: mainDeck.length,
                          // ✅ ADD THIS LINE:
                          initialIndex: _currentIndex,
                          numberOfCardsDisplayed: 1,
                          padding: const EdgeInsets.all(10.0),

                          // ✅ 2. ADD LOOP FALSE: Stops random restarts
                          isLoop: false,

                          allowedSwipeDirection:
                              const AllowedSwipeDirection.only(
                                left: true,
                                right: true,
                              ),
                          onSwipe: (prev, curr, dir) =>
                              _onSwipe(prev, curr, dir, mainDeck),
                          onUndo: _onUndo,

                          // ✅ 3. ADD ON END: Triggers the empty state when you swipe the last card
                          onEnd: () {
                            debugPrint("✅ Deck finished locally");
                            setState(() {
                              _isDeckFinished = true;
                            });
                          },

                          cardBuilder: (context, index, horiz, vert) {
                            // Track swipe progress for indicators
                            if ((_swipeProgress - horiz).abs() > 10.0 ||
                                (horiz == 0 && _swipeProgress != 0)) {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                if (mounted &&
                                    ((_swipeProgress - horiz).abs() > 10.0 ||
                                        (horiz == 0 && _swipeProgress != 0))) {
                                  setState(
                                    () => _swipeProgress = horiz.toDouble(),
                                  );
                                }
                              });
                            }

                            // ✅ Map Single Profile on the fly
                            final uiProfile = _mapToUserProfiles([
                              mainDeck[index],
                            ]).first;

                            return ProfileSwipeCard(
                              key: ValueKey(mainDeck[index].profileId),
                              profile: uiProfile,
                              horizontalThreshold: horiz.toDouble(),
                              verticalThreshold: vert.toDouble(),
                              isHomeScreen: true,
                              onLike: () {
                                _handleLike(uiProfile);
                                _controller.swipe(CardSwiperDirection.right);
                              },
                              onBlock: () {
                                _handlePass(uiProfile);
                                _controller.swipe(CardSwiperDirection.left);
                              },
                              onReport: () {
                                debugPrint('Report: ${uiProfile.name}');
                              },
                            );
                          },
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // 2. UPDATED LOADING SCREEN (Logo instead of Spinner)
  Widget _buildInitializingState() {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(child: AppLoader()),
    );
  }

  void _showModeMenu() {
    final currentMode = ref.read(connectionModeProvider);
    // If for some reason provider fails or is empty, fallback to 'Date'
    final initial = currentMode.isNotEmpty ? currentMode : 'Date';

    NavigationUtils.navigateToWithSlide(
      context,
      ConnectionTypeScreen(initialMode: initial),
    );
  }

  // -----------------------------------------------------------------------
  // ✅ UPDATED SWIPE LOGIC
  // -----------------------------------------------------------------------
  bool _onSwipe(
    int previousIndex,
    int? currentIndex,
    CardSwiperDirection direction,
    List<DiscoveryUser> currentDeck,
  ) {
    setState(() {
      _swipeProgress = 0.0;
      _currentIndex = currentIndex ?? 0;
    });

    _triggerHapticFeedback(direction);

    // 1. Identify User
    final swipedUser = currentDeck[previousIndex];
    final uiProfile = _mapToUserProfiles([swipedUser]).first;

    // 2. DB Record (Fire & Forget)
    if (direction == CardSwiperDirection.left) {
      _handlePass(uiProfile);
    } else if (direction == CardSwiperDirection.right) {
      _handleLike(uiProfile);
    }

    // 3. Update Provider (Consume Card)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref
            .read(discoveryFeedProvider.notifier)
            .consumeCard(swipedUser, previousIndex);
      }
    });

    return true;
  }

  // -----------------------------------------------------------------------
  // ✅ UPDATED UNDO LOGIC
  // -----------------------------------------------------------------------
  bool _onUndo(
    int? previousIndex,
    int currentIndex,
    CardSwiperDirection direction,
  ) {
    // 1. Check History
    final historyDeck = ref.read(discoveryFeedProvider).historyDeck;
    if (historyDeck.isEmpty) return false;

    // Optional: Premium Check
    // if (!_isPremium) { _showPremiumDialog(); return false; }

    HapticFeedback.mediumImpact();

    // 2. Logic: Move Memory (Provider)
    ref.read(discoveryFeedProvider.notifier).undoSwipe();

    // 3. Logic: Delete DB Record
    ref.read(swipeProvider.notifier).undo();

    // ❌ DELETED: _controller.undo();
    // (Removing this stops the infinite loop)

    setState(() {
      _swipeProgress = 0.0;
    });

    return true; // Returning true tells the Controller "Yes, proceed with the animation"
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
    // showSuccessPopup(context, 'You liked ${profile.name}! 💚');
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

  Widget _buildEmptyState() {
    return NoMoreProfilesWidget(
      onAdjustFilters: () {
        debugPrint("Adjust Filters clicked from No Feed Screen");
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
