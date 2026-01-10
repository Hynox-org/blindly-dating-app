import 'package:flutter/material.dart';
import '../home/component/ProfileSwipeCard.dart';
import '../discovery/domain/models/discovery_user_model.dart';
import '../profile/profile.dart';
import 'liked_you_screen.dart';
import './../home/screens/home_screen.dart';

class MatchScreen extends StatefulWidget {
  final UserProfile currentUserProfile;
  final UserProfile matchedUserProfile;

  const MatchScreen({
    super.key,
    required this.currentUserProfile,
    required this.matchedUserProfile,
  });

  @override
  State<MatchScreen> createState() => _MatchScreenState();
}

class _MatchScreenState extends State<MatchScreen> {
  int _selectedIndex = 2; // Set to Peoples tab since this is shown from home

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Only the image - no fallback icons
                      Image.asset(
                        'assests/static/match_illustration.png',
                        height: 250,
                        errorBuilder: (context, error, stackTrace) {
                          return const SizedBox(height: 250);
                        },
                      ),

                      const SizedBox(height: 32),

                      const Text(
                        "It's a Match!",
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins',
                          color: Colors.black,
                        ),
                      ),

                      const SizedBox(height: 12),

                      Text(
                        'You and ${widget.matchedUserProfile.name} liked each other.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: 'Poppins',
                          color: Colors.grey[600],
                          height: 1.4,
                        ),
                      ),

                      const SizedBox(height: 48),

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
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Send a message',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      SizedBox(
                        width: double.infinity,
                        child: TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Keep swiping',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Poppins',
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
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
                  label: 'Liked You',
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
        if (index == 0) {
          // Navigate to Profile
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const ProfileScreen()),
            (route) => false,
          );
        } else if (index == 2) {
          // Navigate to Home Screen (Peoples/Swipe)
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
            (route) => false,
          );
        } else if (index == 3) {
          // Navigate to Liked You Screen
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const LikedYouScreen()),
            (route) => false,
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
}
