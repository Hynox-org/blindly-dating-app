import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';

// ✅ Providers
import '../../auth/providers/auth_providers.dart';
import '../../../features/discovery/povider/discovery_provider.dart';
import '../../discovery/povider/swipe_provider.dart';
import '../../auth/providers/verification_provider.dart';

// ✅ Repositories & Models
import '../../discovery/repository/swipe_repository.dart';
import '../../discovery/domain/models/discovery_user_model.dart';

// ✅ Components
import '../component/ProfileSwipeCard.dart';
import '../../../../core/utils/gender_utils.dart';
import '../../../../core/utils/custom_popups.dart';

// ✅ NEW: Import the "No More Profiles" Widget
import '../../discovery/widgets/no_more_profiles_widget.dart';

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
        bio: 'Match Score: ${user.matchScore}% • ${user.sharedInterestsCount} shared interests',
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
    // 1. Check Verification Status (Loaded by Bootstrap)
    final bool isVerified = ref.watch(verificationStatusProvider);

    // 2. Get Data (Loaded by Bootstrap/Cache)
    final AsyncValue<List<DiscoveryUser>> discoveryState = ref.watch(discoveryFeedProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: _buildAppBar(),
      
      // ✅ THE GATEKEEPER LOGIC
      body: SafeArea(
        child: !isVerified
            ? _buildVerificationBlocker() // ⛔ STOP if not verified
            : Column(
                children: [
                  Expanded(
                    child: discoveryState.when(
                      loading: () => const Center(
                        child: CircularProgressIndicator(color: Color(0xFFD4AF37)),
                      ),
                      error: (err, stack) => _buildErrorState(err),
                      data: (discoveryData) {
                        final profiles = _mapToUserProfiles(discoveryData);

                        // ✅ NEW LOGIC: Show Smart Widget if list is empty
                        if (profiles.isEmpty) {
                          return const NoMoreProfilesWidget();
                        }

                        return _buildCardStack(profiles);
                      },
                    ),
                  ),
                ],
              ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ---------------------------------------------------------------------------
  // 🧩 WIDGET COMPONENTS
  // ---------------------------------------------------------------------------

  // ⛔ The Screen shown to Unverified Users
  Widget _buildVerificationBlocker() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.shield_outlined, size: 80, color: Colors.orange),
            const SizedBox(height: 24),
            const Text(
              "Verification Required",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              "To ensure a safe community, you must verify your profile before matching.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                // TODO: Navigate to Verification Screen
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Navigating to Verification...")),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
              ),
              child: const Text("Verify Now", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  // 🃏 The Card Swiper Stack
  Widget _buildCardStack(List<UserProfile> profiles) {
    return Stack(
      children: [
        CardSwiper(
          controller: _controller,
          cardsCount: profiles.length,
          numberOfCardsDisplayed: 1,
          padding: const EdgeInsets.all(24.0),
          onSwipe: (prev, curr, dir) => _onSwipe(prev, curr, dir, profiles),
          onUndo: _onUndo,
          cardBuilder: (context, index, horiz, vert) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) setState(() => _swipeProgress = horiz.toDouble());
            });

            return ProfileSwipeCard(
              key: ValueKey(profiles[index].id),
              profile: profiles[index],
              horizontalThreshold: horiz.toDouble(),
              verticalThreshold: vert.toDouble(),
              onLike: () {
                if (_swipeCount > 0) {
                  _controller.swipe(CardSwiperDirection.right);
                } else {
                  _showLimitReachedDialog();
                }
              },
              onBlock: () {
                _controller.swipe(CardSwiperDirection.left);
              },
              onReport: () {},
            );
          },
        ),
      ],
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
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
        errorBuilder: (_, __, ___) => const Text("Blindly", style: TextStyle(color: Colors.black)),
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
              const Icon(Icons.local_fire_department, size: 16, color: Colors.orange),
              const SizedBox(width: 4),
              Text(
                '$_swipeCount/$_maxSwipes',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, -2))],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(icon: Icons.person_outline, label: 'Profile', index: 0, isSelected: _selectedIndex == 0),
              _buildNavItem(icon: Icons.explore_outlined, label: 'Discover', index: 1, isSelected: _selectedIndex == 1),
              _buildNavItem(icon: Icons.people_outline, label: 'Peoples', index: 2, isSelected: _selectedIndex == 2),
              _buildNavItem(icon: Icons.favorite_outline, label: 'Matches', index: 3, isSelected: _selectedIndex == 3),
              _buildNavItem(icon: Icons.chat_bubble_outline, label: 'Chat', index: 4, isSelected: _selectedIndex == 4),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // ⚙️ LOGIC & HANDLERS
  // ---------------------------------------------------------------------------

  bool _onSwipe(int previousIndex, int? currentIndex, CardSwiperDirection direction, List<UserProfile> profiles) {
    setState(() => _swipeProgress = 0.0);

    String actionType = 'pass';
    if (direction == CardSwiperDirection.right) actionType = 'like';
    if (direction == CardSwiperDirection.top) actionType = 'super_like';

    // Optimistic Limit Check (Client Side)
    if (actionType != 'pass' && _swipeCount <= 0) {
      _showLimitReachedDialog();
      return false;
    }

    final profile = profiles[previousIndex];

    // 🚀 Call API
    ref.read(swipeProvider.notifier).swipe(
      targetProfileId: profile.id, 
      action: actionType,
    ).then((_) {
      if (actionType == 'like') {
        _triggerHapticFeedback(direction);
        _handleLike(profile);
      } else if (actionType == 'pass') {
        _handlePass(profile);
      }
    }).catchError((error) {
      debugPrint("❌ Swipe Failed: $error");
      
      // ✅ Handle Database-Enforced Limit Error
      if (error is SwipeException && error.code == 'LIMIT_REACHED') {
         _showLimitReachedDialog();
         _controller.undo(); // Visually undo the card
      } else if (!error.toString().contains('Duplicate')) {
         // Generic error (e.g. Network) - Undo card
         _controller.undo();
         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: ${error.toString()}")));
      }
    });

    if (actionType != 'pass') setState(() => _swipeCount--);
    
    // Note: NoMoreCards dialog is handled by the widget update when list becomes empty
    return true;
  }

  bool _onUndo(int? previousIndex, int currentIndex, CardSwiperDirection direction) {
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

  void _triggerHapticFeedback(CardSwiperDirection direction) => HapticFeedback.selectionClick();
  void _handlePass(UserProfile profile) => debugPrint('Passed: ${profile.name}');
  
  void _handleLike(UserProfile profile) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('You liked ${profile.name}! 💚'), backgroundColor: const Color.fromRGBO(65, 72, 51, 1), duration: const Duration(seconds: 1)),
    );
  }

  void _showPremiumDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Premium Feature'),
        content: const Text('Undo is for premium members.'),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
      ),
    );
  }

  void _showLimitReachedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Limit Reached'),
        content: const Text('No more swipes for today! Upgrade to Premium.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
        ],
      ),
    );
  }

  Widget _buildErrorState(Object err) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Text('Error loading matches: $err', textAlign: TextAlign.center),
      ),
    );
  }

  Widget _buildNavItem({required IconData icon, required String label, required int index, required bool isSelected}) {
    final Color selectedColor = const Color(0xFFD4AF37);
    final Color unselectedColor = Colors.black;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: isSelected ? selectedColor : unselectedColor, size: 28),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 12, fontFamily: 'Poppins', fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400, color: isSelected ? selectedColor : unselectedColor)),
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
              title: const Text('Logout', style: TextStyle(fontFamily: 'Poppins', color: Colors.red)),
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
}