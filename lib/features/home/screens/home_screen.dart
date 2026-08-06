import 'package:flutter/material.dart';
import 'package:blindly_dating_app/l10n/app_localizations.dart';
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
import '../../onboarding/domain/models/lifestyle_chip_model.dart';

// ✅ 3. Components
import '../component/ProfileSwipeCard.dart';
import '../../../../core/utils/custom_popups.dart';
import '../../discovery/presentation/widgets/no_more_profiles_widget.dart';
import '../../../../core/utils/navigation_utils.dart';
import 'connection_type_screen.dart';
import '../../discovery/presentation/screens/filter_screen.dart';
import '../../notifications/screens/notifications_screen.dart';
import '../../notifications/services/push_notification_service.dart';

// ✅ 4. Layout
import '../../../../core/widgets/app_layout.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

// ✅ Added: with SingleTickerProviderStateMixin
class _HomeScreenState extends ConsumerState<HomeScreen> {
  AppLocalizations get l10n => AppLocalizations.of(context);


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
    
    // 🔔 Listen for multi-device conflicts as they happen
    PushNotificationService.multiDeviceConflictToken.addListener(_onTokenConflictChanged);
  }

  void _onTokenConflictChanged() {
    final token = PushNotificationService.multiDeviceConflictToken.value;
    if (token != null && mounted) {
      _showEnforcedMultiDeviceDialog(token);
    }
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
    PushNotificationService.multiDeviceConflictToken.removeListener(_onTokenConflictChanged);
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
      // Push notifications are now initialized in main.dart

      // ✅ 1. CHECK SESSION FLAG
      // If we already updated location this session, skip the heavy lifting.
      final isAlreadyUpdated = ref.read(locationUpdateSessionProvider);

      if (isAlreadyUpdated) {
        debugPrint('⏩ Session: Location already updated. Skipping.');
        if (mounted) {
          debugPrint('🏠 HOMESCREEN: Setting _isLocationReady = true (cached)');
          setState(() => _isLocationReady = true);
        }
        return;
      }

      // ✅ 2. RUN UPDATE (First time only)
      try {
        await _updatePassportLocationOnce();

        // ✅ 3. SET FLAG TO TRUE
        // Next time you come here, it will skip this block.
        if (mounted) {
          ref.read(locationUpdateSessionProvider.notifier).state = true;
        }
      } catch (e) {
        debugPrint('❌ HOMESCREEN: Location update failed: $e');
      } finally {
        if (mounted) {
          debugPrint('🏠 HOMESCREEN: Setting _isLocationReady = true (final)');
          setState(() {
            _isLocationReady = true;
          });
          // 🚀 Initial check in case it already fired
          _onTokenConflictChanged();
        }
      }
    });
  }


  void _showEnforcedMultiDeviceDialog(String currentToken) {
    showDialog(
      context: context,
      barrierDismissible: false, // Force a choice
      builder: (context) => WillPopScope(
        onWillPop: () async => false, // Prevent back button dismissal
        child: Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.devices_other,
                    color: Theme.of(context).colorScheme.primary,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  l10n.multiDeviceTitle,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.multiDeviceBody,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Colors.black54,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () async {
                      Navigator.pop(context);
                      final success = await PushNotificationService.instance.clearOtherDevices(currentToken);
                      if (success && mounted) {
                        showSuccessPopup(context, l10n.signedOutOtherDevices);
                      }
                    },
                    child: Text(l10n.signOutOtherDevices, style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.grey[600],
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () async {
                      // ❌ Log out current device if they refuse
                      Navigator.pop(context);
                      await Supabase.instance.client.auth.signOut();
                      if (mounted) {
                        Navigator.of(context).pushNamedAndRemoveUntil('/auth', (route) => false);
                      }
                    },
                    child: Text(l10n.logOutThisDevice),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ✅ Helper to map API data to UI data
  List<UserProfile> _mapToUserProfiles(List<DiscoveryUser> discoveryUsers) {
    return discoveryUsers.map((user) {
      // 1. Get the list of images directly from the Model
      // (The Repository has already signed them and put them in this list)
      List<String> profileImages = List.from(user.imageUrls);

      // 2. Safety Fallback: If the list is empty, show a text avatar
      // This ensures the card doesn't look broken.
      if (profileImages.isEmpty) {
        profileImages.add(
          'https://ui-avatars.com/api/?name=${Uri.encodeComponent(user.displayName)}&background=random&size=500&bold=true',
        );
      }

      // 3. Determine Gender String (for UI display)
      final genderStr = user.gender.isNotEmpty
          ? (user.gender.startsWith('M')
                ? 'Male'
                : (user.gender.startsWith('F') ? 'Female' : 'Male'))
          : 'Male';

      return UserProfile(
        id: user.profileId,
        name: user.displayName,
        age: user.age,
        distance: double.parse((user.distanceKm / 1000).toStringAsFixed(1)),
        location:
            user.hometown ?? l10n.nearby, // Dynamic Location
        gender: genderStr,
        imageUrls: profileImages, // ✅ PASS THE LIST FROM DB
        bio: user.bio, // Use actual bio or empty
        subTitle: user.workTitle ?? '', // Fallback to empty if null
        height: user.height != null ? l10n.heightCm('${user.height}') : '',
        activityLevel: user.exercise ?? '',
        education: user.education ?? '',
        school: user.school ?? '',
        religion: user.religion ?? '',
        zodiac: user.zodiac ?? '',
        drinking: user.drinking ?? '',
        smoking: user.smoking ?? '',
        politics: user.politics ?? '',
        kids: user.kids ?? '',
        hometown: user.hometown ?? '',
        workCompany: user.workCompany ?? '',
        summary: user.bio.isNotEmpty ? user.bio : l10n.swipeRightHint,
        lookingForModes: user.lookingForModes,
        quickestWay: '', // Add if available
        prompts: user.prompts, // ✅ Pass Prompts here
        hobbies: user.interests,
        lifestyleItems: user.lifestyle
            .map(
              (label) => LifestyleChip(
                id: '',
                categoryId: 0,
                label: label,
                isActive: true,
              ),
            )
            .toList(), // ✅ Map strings to dummy LifestyleChips
        causes: user.causes, // ✅ Dynamic Causes
        simplePleasure: '',
        languages: user.languages, // ✅ Dynamic Languages
        spotifyArtists: user.spotifyArtists, // ✅ Dynamic Spotify
        isVerified: user.isVerified,
        verificationLevel: user.verificationLevel,
        trustScore: user.trustScore, // ✅ Pass Trust Score
        voiceIntroUrl: user.voiceIntroUrl,
        voiceIntroDuration: user.voiceIntroDuration,
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    // ✅ Listen for Location Rejection from Lambda
    ref.listen<DiscoveryState>(discoveryFeedProvider, (prev, next) {
      if (next.hasLocationError && (prev == null || !prev.hasLocationError)) {
        _showLocationRequiredDialog();
      }
    });

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
              Icons.notifications_none,
              color: Theme.of(context).colorScheme.onSurface,
              size: 28,
            ),
            onPressed: () {
              NavigationUtils.navigateToWithSlide(
                context,
                const NotificationsScreen(),
              );
            },
          ),
          IconButton(
            icon: Icon(
              Icons.reply,
              // Grey out if there is nothing to undo
              color: historyDeck.isEmpty
                  ? Colors.grey
                  : Theme.of(context).colorScheme.onSurface,
              size: 28,
            ),
            onPressed: () {
              // 1. Safety Check
              if (historyDeck.isEmpty) return;

              HapticFeedback.mediumImpact();

              // 2. Memory LIFO Restore
              ref.read(discoveryFeedProvider.notifier).undoLastSwipe();

              // 3. Database DB Restore
              ref.read(swipeProvider.notifier).undo();

              // 4. Force UI Mount & Refresh
              if (mounted) {
                if (_isDeckFinished || mainDeck.isEmpty) {
                  setState(() {
                    _isDeckFinished = false;
                    _currentIndex = 0;
                  });
                }
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
              NavigationUtils.navigateToWithSlide(
                context,
                const FilterScreen(),
              );
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
                          numberOfCardsDisplayed: 1, // ✅ Depth of 3 like Bumble
                          backCardOffset: const Offset(
                            0,
                            40,
                          ), // ✅ Distinct stack
                          scale: 0.9, // ✅ Visible scaling
                          threshold: 50, // More responsive for smooth feel
                          duration: const Duration(
                            milliseconds: 500,
                          ), // ✅ Butter smooth slow animation
                          padding: const EdgeInsets.all(10.0),

                          // ✅ 2. ADD LOOP FALSE: Stops random restarts
                          isLoop: true,

                          allowedSwipeDirection:
                              const AllowedSwipeDirection.only(
                                left: true,
                                right: true,
                                up: true,
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
                              mode: ProfileCardMode.swipe, // ✅ Swipe Mode
                              onLike: () {
                                _controller.swipe(CardSwiperDirection.right);
                              },
                              onPause: () {
                                _controller.swipe(CardSwiperDirection.left);
                              },
                              onSuperLike: () {
                                _controller.swipe(CardSwiperDirection.top);
                              },
                              onBlock: () {
                                // Default pass if pause not used
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
      // We don't strictly need _currentIndex for the logic anymore,
      // but keeping it 0 is safer.
      _currentIndex = 0;
    });

    _triggerHapticFeedback(direction);

    // 1. Identify User (Safely)
    // Since we always show the top card (Index 0), the swiped user is likely at 0.
    // However, the 'previousIndex' passed by the library might be 0.
    if (currentDeck.isEmpty) return true;

    // We target the exact card being swiped away using previousIndex.
    final swipedUser = currentDeck[previousIndex];
    final uiProfile = _mapToUserProfiles([swipedUser]).first;

    // 2. DB Record
    if (direction == CardSwiperDirection.left) {
      _handlePause(uiProfile);
    } else if (direction == CardSwiperDirection.right) {
      _handleLike(uiProfile);
    } else if (direction == CardSwiperDirection.top) {
      _handleSuperLike(uiProfile);
    }

    // 3. Update Provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(discoveryFeedProvider.notifier).onSwipe(swipedUser);
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
    // 1. Check History from Provider
    final historyDeck = ref.read(discoveryFeedProvider).historyDeck;
    if (historyDeck.isEmpty) return false;

    HapticFeedback.mediumImpact();

    // 2. Logic: Move Memory (Provider)
    // ✅ FIX: Use 'undoLastSwipe' to match the new Provider method name
    ref.read(discoveryFeedProvider.notifier).undoLastSwipe();

    // 3. Logic: Delete DB Record
    ref.read(swipeProvider.notifier).undo();

    setState(() {
      _swipeProgress = 0.0;
      _isDeckFinished = false; // Ensure we exit empty state
    });

    return true;
  }

  void _triggerHapticFeedback(CardSwiperDirection direction) {
    HapticFeedback.selectionClick();
  }

  void _handleLike(UserProfile profile) {
    // showSuccessPopup(context, 'You liked ${profile.name}! 💚');
    ref
        .read(swipeProvider.notifier)
        .swipe(targetProfileId: profile.id, action: 'like');
  }

  void _handleSuperLike(UserProfile profile) {
    debugPrint('Super Liked: ${profile.name}');
    ref
        .read(swipeProvider.notifier)
        .swipe(targetProfileId: profile.id, action: 'super_like');
  }

  void _handlePause(UserProfile profile) {
    debugPrint('Paused: ${profile.name}');
    ref
        .read(swipeProvider.notifier)
        .swipe(targetProfileId: profile.id, action: 'pass');
  }


  void _showLocationRequiredDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(l10n.locationRequiredTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text(
          l10n.locationRequiredBody,
          style: const TextStyle(height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Geolocator.openAppSettings();
            },
            // Using app theme colors as per guidelines
            child: Text(l10n.settingsTitle, style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.pop(context);
              ref.read(discoveryFeedProvider.notifier).refreshFeed();
            },
            child: Text(l10n.retry, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return NoMoreProfilesWidget(
      onAdjustFilters: () {
        NavigationUtils.navigateToWithSlide(context, const FilterScreen());
      },
      onNotifyMe: () {
        debugPrint("Notify Me clicked");
        showSuccessPopup(context, l10n.notifyMeSnack);
      },
    );
  }
}
