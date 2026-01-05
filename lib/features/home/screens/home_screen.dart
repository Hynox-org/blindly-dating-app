import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import '../../auth/providers/auth_providers.dart';
import './../component/ProfileSwipeCard.dart';
import './../../profile/profile.dart';
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});


  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}


class _HomeScreenState extends ConsumerState<HomeScreen> {
  final CardSwiperController _controller = CardSwiperController();
  int _swipeCount = 10;
  final int _maxSwipes = 10;
  final bool _isPremium = false;
  int _selectedIndex = 2; // Peoples tab selected by default
  
  // Track swipe direction for showing buttons
  double _swipeProgress = 0.0;
  
  // Sample profiles with complete data
  final List<UserProfile> _profiles = [
    UserProfile(
      id: '1',
      name: 'Vignesh',
      age: 27,
      distance: 2.0,
      bio: 'UX/X designer',
      imageUrls: [
        'https://picsum.photos/400/600',
        'https://picsum.photos/401/600',
        'https://picsum.photos/402/600',
      ],
      height: '170 cm',
      activityLevel: 'Active',
      education: 'Post graduate',
      gender: 'Men',
      religion: 'Hindu',
      zodiac: 'Taurus',
      drinking: 'Yes',
      smoking: 'Yes',
      summary: 'Need Netflix recommendations? I\'m looking for someone who\'s down for deep conversations, spontaneous weekend plans, and cozy nights in.',
      lookingFor: 'Mutual respect, peace and the feeling that you can be your true self',
      lookingForTags: [
        'Fun, casual dates',
        'Ambition',
        'Confidence',
        'Emotional intelligence',
        'Long term relationship',
        'Loyalty',
        'Humility',
        'Humor'
      ],
      quickestWay: '"Showing up with pure intentions - not just pretty words"',
      hobbies: ['Dance', 'Cricket', 'Whiskey', 'Bar', 'KFC', 'Football', 'Beaches', 'Arabic', 'Fish'],
      causes: ['Reproductive rights', 'LGBTQ', 'Feminism', 'Neurodiversity', 'End religious hate', 'Human rights', 'Environmentalism'],
      simplePleasure: '"Chai and chips, walks, drives (Not anybody! I know, but definitely something I enjoy)"',
      languages: ['Tamil', 'English', 'Malayalam'],
      location: 'Coimbatore',
      spotifyArtists: ['Mir kalima', 'Harris jayaraj', 'AR Rahman', 'Benny dayal', 'XXX tentacion', 'Vedan', 'Arijit singh', 'Snoop dog', 'Benny'],
    ),
    UserProfile(
      id: '2',
      name: 'Emma',
      age: 23,
      distance: 1.5,
      bio: 'Coffee enthusiast',
      imageUrls: [
        'https://picsum.photos/403/600',
        'https://picsum.photos/404/600',
        'https://picsum.photos/405/600',
      ],
      height: '165 cm',
      activityLevel: 'Moderate',
      education: 'Graduate',
      gender: 'Women',
      religion: 'Christian',
      zodiac: 'Gemini',
      drinking: 'Socially',
      smoking: 'No',
      summary: 'Bookworm by day, Netflix binger by night. Love trying new cafes and having deep conversations.',
      lookingFor: 'Someone who appreciates good coffee and great books',
      lookingForTags: ['Coffee dates', 'Book clubs', 'Movie nights', 'Deep talks'],
      quickestWay: '"Recommend me a good book or a hidden cafe"',
      hobbies: ['Reading', 'Coffee tasting', 'Writing', 'Photography'],
      causes: ['Education', 'Mental health', 'Animal rights'],
      simplePleasure: '"A good book with a cup of coffee on a rainy day"',
      languages: ['English', 'Hindi'],
      location: 'Mumbai',
      spotifyArtists: ['Ed Sheeran', 'Taylor Swift', 'Arijit Singh'],
    ),
    UserProfile(
      id: '3',
      name: 'Olivia',
      age: 26,
      distance: 3.5,
      bio: 'Fitness enthusiast',
      imageUrls: [
        'https://picsum.photos/406/600',
        'https://picsum.photos/407/600',
        'https://picsum.photos/408/600',
      ],
      height: '168 cm',
      activityLevel: 'Very active',
      education: 'Post graduate',
      gender: 'Women',
      religion: 'Hindu',
      zodiac: 'Leo',
      drinking: 'No',
      smoking: 'No',
      summary: 'Fitness trainer and yoga instructor. Living a healthy lifestyle and inspiring others to do the same.',
      lookingFor: 'Active partner who loves fitness and healthy living',
      lookingForTags: ['Gym buddy', 'Yoga partner', 'Healthy lifestyle', 'Morning person'],
      quickestWay: '"Join me for a morning run or yoga session"',
      hobbies: ['Gym', 'Yoga', 'Running', 'Hiking', 'Cooking healthy meals'],
      causes: ['Health awareness', 'Environmental protection', 'Women empowerment'],
      simplePleasure: '"A successful workout followed by a healthy smoothie"',
      languages: ['English', 'Tamil', 'Hindi'],
      location: 'Bangalore',
      spotifyArtists: ['Imagine Dragons', 'The Chainsmokers', 'Alan Walker'],
    ),
  ];


  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.black, size: 28),
          onPressed: () {
            _showMenuDialog();
          },
        ),
        title: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
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
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  fontFamily: 'Poppins',
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.tune, color: Colors.black, size: 24),
            onPressed: () {
              // TODO: Open filter settings
            },
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfileScreen(),
                  ),
                );
              },
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFD4AF37), width: 2),
                ),
                child: ClipOval(
                  child: Image.network(
                    'https://picsum.photos/100/100',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.person, color: Colors.grey),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Card swiper with background indicators
            Expanded(
              child: _profiles.isEmpty
                  ? _buildEmptyState()
                  : Stack(
                      children: [
                        // ============ BACKGROUND SWIPE INDICATORS ============
// In your home_screen.dart Stack children, replace with this:

Stack(
  children: [
    // ⭐ RIGHT side - X mark (shows when swiping LEFT - card moves left, X appears on right)
    Positioned.fill(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Align(
          alignment: Alignment.centerRight,
          child: AnimatedOpacity(
            opacity: _swipeProgress < -0.1 ? (_swipeProgress.abs() * 2).clamp(0.0, 1.0) : 0.0,
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
    
    // ⭐ LEFT side - Heart mark (shows when swiping RIGHT - card moves right, Heart appears on left)
    Positioned.fill(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Align(
          alignment: Alignment.centerLeft,
          child: AnimatedOpacity(
            opacity: _swipeProgress > 0.1 ? (_swipeProgress.abs() * 2).clamp(0.0, 1.0) : 0.0,
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
  ] ),
                // ============ CARD SWIPER ============
                        CardSwiper(
                          controller: _controller,
                          cardsCount: _profiles.length,
                          numberOfCardsDisplayed: 1,
                          backCardOffset: const Offset(0, 0),
                          padding: const EdgeInsets.all(24.0),
                          scale: 1.0,
                          duration: const Duration(milliseconds: 300),
                          maxAngle: 30,
                          threshold: 50,
                          isLoop: false,
                          allowedSwipeDirection: const AllowedSwipeDirection.only(
                            left: true,
                            right: true,
                            up: false,
                            down: false,
                          ),
                          onSwipe: _onSwipe,
                          onUndo: _onUndo,
                          cardBuilder: (
                            context,
                            index,
                            horizontalThreshold,
                            verticalThreshold,
                          ) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              if (mounted) {
                                setState(() {
                                  _swipeProgress = horizontalThreshold.toDouble();
                                });
                              }
                            });

                            return ProfileSwipeCard(
                              key: ValueKey(_profiles[index].id), // Add key to reset scroll position
                              profile: _profiles[index],
                              horizontalThreshold: horizontalThreshold.toDouble(),
                              verticalThreshold: verticalThreshold.toDouble(),
                              onLike: () {
                                if (_swipeCount > 0) {
                                  _handleLike(_profiles[index]);
                                  _controller.swipe(CardSwiperDirection.right);
                                } else {
                                  _showLimitReachedDialog();
                                }
                              },
                              onBlock: () {
                                if (_swipeCount > 0) {
                                  _handlePass(_profiles[index]);
                                  _controller.swipe(CardSwiperDirection.left);
                                } else {
                                  _showLimitReachedDialog();
                                }
                              },
                              onReport: () {
                                if (_swipeCount > 0) {
                                  _handleSuperLike(_profiles[index]);
                                } else {
                                  _showLimitReachedDialog();
                                }
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
      // Bottom Navigation Bar
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
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
              leading: const Icon(Icons.settings),
              title: const Text('Settings', style: TextStyle(fontFamily: 'Poppins')),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.help_outline),
              title: const Text('Help & Support', style: TextStyle(fontFamily: 'Poppins')),
              onTap: () {
                Navigator.pop(context);
              },
            ),
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


  bool _onSwipe(
    int previousIndex,
    int? currentIndex,
    CardSwiperDirection direction,
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

    final profile = _profiles[previousIndex];
    
    switch (direction) {
      case CardSwiperDirection.left:
        _handlePass(profile);
        break;
      case CardSwiperDirection.right:
        _handleLike(profile);
        break;
      default:
        break;
    }

    if (currentIndex == null) {
      _showNoMoreCardsDialog();
    }

    return true;
  }


  bool _onUndo(
    int? previousIndex,
    int currentIndex,
    CardSwiperDirection direction,
  ) {
    if (!_isPremium) {
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
    switch (direction) {
      case CardSwiperDirection.left:
        HapticFeedback.lightImpact();
        break;
      case CardSwiperDirection.right:
        HapticFeedback.mediumImpact();
        break;
      default:
        HapticFeedback.selectionClick();
    }
  }


  void _handlePass(UserProfile profile) {
    debugPrint('Passed: ${profile.name}');
    HapticFeedback.lightImpact();
  }


  void _handleLike(UserProfile profile) {
    debugPrint('Liked: ${profile.name}');
    HapticFeedback.mediumImpact();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('You liked ${profile.name}! 💚', style: const TextStyle(fontFamily: 'Poppins')),
        duration: const Duration(milliseconds: 1500),
        backgroundColor: const Color.fromRGBO(65, 72, 51, 1),
      ),
    );
  }


  void _handleSuperLike(UserProfile profile) {
    debugPrint('Super Liked: ${profile.name}');
    HapticFeedback.heavyImpact();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: const [
            Icon(Icons.star, color: Color(0xFFD4AF37), size: 28),
            SizedBox(width: 10),
            Text('Super Like!', style: TextStyle(fontFamily: 'Poppins')),
          ],
        ),
        content: Text('You super liked ${profile.name}! ⭐', style: const TextStyle(fontFamily: 'Poppins')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: const Color.fromRGBO(65, 72, 51, 1),
            ),
            child: const Text('OK', style: TextStyle(fontFamily: 'Poppins')),
          ),
        ],
      ),
    );
  }


  void _showPremiumDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Premium Feature', style: TextStyle(fontFamily: 'Poppins')),
        content: const Text(
          'Undo is a premium feature. Upgrade to Premium to rewind your last swipe!',
          style: TextStyle(fontFamily: 'Poppins'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(fontFamily: 'Poppins')),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromRGBO(65, 72, 51, 1),
            ),
            child: const Text('Upgrade', style: TextStyle(fontFamily: 'Poppins')),
          ),
        ],
      ),
    );
  }


  void _showLimitReachedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Daily Limit Reached', style: TextStyle(fontFamily: 'Poppins')),
        content: const Text(
          'You\'ve used all your daily swipes. Come back tomorrow or upgrade to Premium for unlimited swipes!',
          style: TextStyle(fontFamily: 'Poppins'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK', style: TextStyle(fontFamily: 'Poppins')),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromRGBO(65, 72, 51, 1),
            ),
            child: const Text('Go Premium', style: TextStyle(fontFamily: 'Poppins')),
          ),
        ],
      ),
    );
  }


  void _showNoMoreCardsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('No More Profiles', style: TextStyle(fontFamily: 'Poppins')),
        content: const Text(
          'You\'ve seen all available profiles in your area. Check back later for new matches!',
          style: TextStyle(fontFamily: 'Poppins'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK', style: TextStyle(fontFamily: 'Poppins')),
          ),
        ],
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
            color: Colors.grey[400],
          ),
          const SizedBox(height: 20),
          Text(
            'No profiles available',
            style: TextStyle(
              fontSize: 20,
              fontFamily: 'Poppins',
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}
