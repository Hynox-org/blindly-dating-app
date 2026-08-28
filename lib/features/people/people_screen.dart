import 'package:flutter/material.dart';
import 'package:blindly_dating_app/l10n/app_localizations.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ✅ 1. Providers
import 'package:blindly_dating_app/features/people/provider/people_feed_provider.dart';
import 'package:blindly_dating_app/features/matching/provider/filter_provider.dart';
import '../../../../core/providers/session_provider.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../../../core/providers/connection_mode_provider.dart';

// ✅ 2. Models
import 'package:blindly_dating_app/features/matching/domain/models/match_profile.dart';
import 'package:blindly_dating_app/features/onboarding/domain/models/lifestyle_chip_model.dart';

// ✅ 3. Components
import 'package:blindly_dating_app/features/matching/presentation/widgets/profile_swipe_card.dart';
import 'package:blindly_dating_app/features/people/component/swipe_deck.dart';
import '../../../../core/utils/custom_popups.dart';
import '../../../../core/widgets/match_dialog.dart';
import 'package:blindly_dating_app/features/people/widgets/no_more_people_widget.dart';
import '../../../../core/utils/navigation_utils.dart';
import 'package:blindly_dating_app/features/matching/presentation/screens/connection_type_screen.dart';
import 'package:blindly_dating_app/features/people/screens/filter_screen.dart';
import 'package:blindly_dating_app/features/notifications/screens/notifications_screen.dart';
import 'package:blindly_dating_app/features/notifications/services/push_notification_service.dart';

// ✅ 4. Layout
import '../../../../core/widgets/app_layout.dart';

class PeopleScreen extends ConsumerStatefulWidget {
  const PeopleScreen({super.key});

  @override
  ConsumerState<PeopleScreen> createState() => _PeopleScreenState();
}

// ✅ Added: with SingleTickerProviderStateMixin
class _PeopleScreenState extends ConsumerState<PeopleScreen> {
  AppLocalizations get l10n => AppLocalizations.of(context);


  final SwipeDeckController _deck = SwipeDeckController();

  /// Live drag offset of the top card. A ValueNotifier rather than state so
  /// dragging repaints the two indicators and nothing else.
  final ValueNotifier<Offset> _dragOffset = ValueNotifier(Offset.zero);

  // 🔒 Run location update only once
  bool _locationUpdateDone = false;
  // ✅ Controls the initialization flow
  bool _isLocationReady = false;

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

  @override
  void dispose() {
    _dragOffset.dispose();
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

      debugPrint('📍 Passport location updated (PeopleScreen)');
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
  UserProfile _toUserProfile(MatchProfile user) {
      // Photos are already signed by the repository, and the feed no longer
      // returns anyone without one.
      final profileImages = List<String>.from(user.imageUrls);

      // Determine Gender String (for UI display)
      final genderStr = user.gender.isNotEmpty
          ? (user.gender.startsWith('M')
                ? 'Male'
                : (user.gender.startsWith('F') ? 'Female' : 'Male'))
          : 'Male';

      return UserProfile(
        id: user.profileId,
        name: user.displayName,
        age: user.age,
        // The RPC already returns kilometres.
        distance: user.distanceKm,
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
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<PeopleFeedState>(peopleFeedProvider, (prev, next) {
      if (next.hasLocationError && (prev == null || !prev.hasLocationError)) {
        _showLocationRequiredDialog();
      }
      // A swipe or undo the backend refused. Say so once, then forget it —
      // a modal here would interrupt the deck for a transient network blip.
      if (next.error != null && next.error != prev?.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            behavior: SnackBarBehavior.floating,
          ),
        );
        ref.read(peopleFeedProvider.notifier).clearNotices();
      }
      // That like was mutual — this is the one interruption worth making.
      if (next.matchedWith != null && next.matchedWith != prev?.matchedWith) {
        showMatchDialog(context, next.matchedWith!);
        ref.read(peopleFeedProvider.notifier).clearNotices();
      }
    });

    final feed = _isLocationReady
        ? ref.watch(peopleFeedProvider)
        : const PeopleFeedState(isLoading: true);

    final deck = feed.deck;

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
              color: feed.history.isEmpty
                  ? Colors.grey
                  : Theme.of(context).colorScheme.onSurface,
              size: 28,
            ),
            onPressed: feed.history.isEmpty
                ? null
                : () {
                    HapticFeedback.mediumImpact();
                    // One path: the notifier restores the card and reverts
                    // the row for that same profile.
                    ref.read(peopleFeedProvider.notifier).undo();
                  },
          ),
          IconButton(
            icon: Icon(
              Icons.tune,
              color: Theme.of(context).colorScheme.onSurface,
              size: 28,
            ),
            onPressed: _openFilters,
          ),
          const SizedBox(width: 8),
        ],
      ),
      child: SafeArea(
        child: !_isLocationReady || feed.isLoading
            ? _buildInitializingState()
            : deck.isEmpty
                ? (feed.isFetchingMore
                    ? _buildInitializingState()
                    : _buildEmptyState())
                : _buildDeck(deck),
      ),
    );
  }

  // --------------------------------------------------------------- the deck
  Widget _buildDeck(List<MatchProfile> deck) {
    return Stack(
      children: [
        Positioned.fill(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: SwipeDeck(
              controller: _deck,
              itemCount: deck.length,
              onDrag: (offset) => _dragOffset.value = offset,
              onSwipe: (index, action) => _onSwipe(deck[index], action),
              cardBuilder: (context, index, depth) {
                final user = deck[index];
                return ProfileSwipeCard(
                  key: ValueKey(user.profileId),
                  profile: _toUserProfile(user),
                  mode: ProfileCardMode.swipe,
                  onLike: () => _deck.swipe(SwipeAction.like),
                  onPause: () => _deck.swipe(SwipeAction.pass),
                  onSuperLike: () => _deck.swipe(SwipeAction.superLike),
                  onBlock: () => _deck.swipe(SwipeAction.pass),
                  onReport: () {
                    debugPrint('Report: ${user.displayName}');
                  },
                );
              },
            ),
          ),
        ),
        // Indicators sit above the card and repaint on their own — the deck
        // itself never rebuilds this screen while a finger is down.
        Positioned.fill(
          child: IgnorePointer(
            child: ValueListenableBuilder<Offset>(
              valueListenable: _dragOffset,
              builder: (context, drag, _) => _buildSwipeIndicators(drag),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSwipeIndicators(Offset drag) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Stack(
        children: [
          // Swipe right → Like, so the heart belongs on the right.
          _indicator(
            Alignment.centerRight,
            Icons.favorite,
            (drag.dx / 120).clamp(0.0, 1.0),
          ),
          _indicator(
            Alignment.centerLeft,
            Icons.close,
            (-drag.dx / 120).clamp(0.0, 1.0),
          ),
        ],
      ),
    );
  }

  Widget _indicator(Alignment alignment, IconData icon, double opacity) {
    if (opacity <= 0.01) return const SizedBox.shrink();
    return Align(
      alignment: alignment,
      child: Opacity(
        opacity: opacity,
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
          child: Icon(icon, color: Colors.white, size: 50),
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

  /// Opens the filters, then rebuilds the deck against them. The filters live
  /// in the database and are read by the RPC, so the save has to land first.
  Future<void> _openFilters() async {
    await NavigationUtils.navigateToWithSlide(context, const FilterScreen());
    await ref.read(filterProvider.notifier).flush();
    if (mounted) ref.read(peopleFeedProvider.notifier).refreshFeed();
  }

  // -----------------------------------------------------------------------
  // SWIPE
  // -----------------------------------------------------------------------
  void _onSwipe(MatchProfile user, SwipeAction action) {
    HapticFeedback.selectionClick();

    ref.read(peopleFeedProvider.notifier).swipe(
          user,
          switch (action) {
            SwipeAction.like => SwipeIntent.like,
            SwipeAction.pass => SwipeIntent.pass,
            SwipeAction.superLike => SwipeIntent.superLike,
          },
        );
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
              ref.read(peopleFeedProvider.notifier).refreshFeed();
            },
            child: Text(l10n.retry, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return NoMorePeopleWidget(
      onAdjustFilters: _openFilters,
      onNotifyMe: () {
        debugPrint("Notify Me clicked");
        showSuccessPopup(context, l10n.notifyMeSnack);
      },
    );
  }
}
