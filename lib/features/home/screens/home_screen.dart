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

// ✅ 4. Screens
import '../../profile/profile.dart';
import '../../match/liked_you_screen.dart';

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

  // ✅ Controls the initialization flow
  bool _isLocationReady = false;

  @override
  void initState() {
    super.initState();
    _initLocationAndFeed();
  }

  /// ✅ SEQUENTIAL INITIALIZATION
  /// 1. Updates Passport Location first
  /// 2. Then enables the Discovery Feed
  Future<void> _initLocationAndFeed() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        debugPrint('📍 HOMESCREEN: Updating Location...');
        await ref.read(locationServiceProvider).updateUserLocation();
        debugPrint('✅ HOMESCREEN: Location Updated.');
        ref.invalidate(discoveryFeedProvider);

        if (mounted) {
          setState(() {
            _isLocationReady = true;
          });
        }
      } catch (e) {
        debugPrint('❌ HOMESCREEN: Location Error: $e');
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

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.black, size: 28),
          onPressed: () => _showMenuDialog(),
        ),
        title: Image.asset(
          'assests/images/blindly-text-logo.png',
          height: 24,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return const Text("Blindly", style: TextStyle(color: Colors.black));
          },
        ),
        centerTitle: true,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.local_fire_department,
                  size: 16,
                  color: Colors.orange,
                ),
                const SizedBox(width: 4),
                Text(
                  '$_swipeCount/$_maxSwipes',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.black,
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
              child: !_isLocationReady || discoveryState == null
                  ? _buildInitializingState()
                  : discoveryState.when(
                      loading: () => const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFFD4AF37),
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
                                        color: Colors.grey[400],
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
                                        color: Colors.grey[400],
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
                              onSwipe: (prev, curr, dir) =>
                                  _onSwipe(prev, curr, dir, profiles),
                              onUndo: _onUndo,
                              cardBuilder: (context, index, horiz, vert) {
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
                                    debugPrint('Report: ${profiles[index].name}');
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
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
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
                  label: 'Liked You', // ✅ Changed from 'Matches'
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

  Widget _buildInitializingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Color(0xFFD4AF37)),
          SizedBox(height: 16),
          Text(
            "Updating your location...",
            style: TextStyle(color: Colors.grey, fontFamily: 'Poppins'),
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
    final Color selectedColor = const Color(0xFFD4AF37);
    final Color unselectedColor = Colors.black;

    return GestureDetector(
      onTap: () {
        if (index == 0) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => const ProfileScreen(),
            ),
            (route) => false,
          );
        } else if (index == 2) {
          // Already on Home - do nothing
          setState(() {
            _selectedIndex = index;
          });
        } else if (index == 3) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const LikedYouScreen(),
            ),
          );
        } else {
          setState(() {
            _selectedIndex = index;
          });
        }
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
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                'Logout',
                style: TextStyle(fontFamily: 'Poppins', color: Colors.red),
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

  // ✅ Updated to show match dialog
  void _handleLike(UserProfile profile) {
    // TODO: Replace with actual match check from your backend API
    bool isMatch = false; // Set to true when both users like each other
    
    if (isMatch) {
      _showMatchDialog(profile);
    } else {
      showSuccessPopup(context, 'You liked ${profile.name}! 💚');
    }
  }

  // ✅ Match Dialog
  void _showMatchDialog(UserProfile profile) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assests/static/match_illustration.png',
                height: 200,
                errorBuilder: (context, error, stackTrace) {
                  return const SizedBox(height: 200);
                },
              ),
              const SizedBox(height: 24),
              const Text(
                "It's a Match!",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'You and ${profile.name} liked each other.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'Poppins',
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    // TODO: Navigate to chat with matched user
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A5A4A),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Send a message',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Keep swiping',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins',
                    color: Colors.grey,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
          Icon(Icons.people_outline, size: 100, color: Colors.grey[400]),
          const SizedBox(height: 20),
          Text(
            'No profiles available',
            style: TextStyle(fontSize: 20, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}
