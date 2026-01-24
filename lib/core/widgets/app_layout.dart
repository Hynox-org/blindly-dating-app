import 'package:flutter/material.dart';
import '../../features/profile/profile.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/match/liked_you_screen.dart';
import '../../features/discovery/presentation/screens/discover_screen.dart';
import '../../features/chat/presentation/screens/chat_screen.dart';

class AppLayout extends StatelessWidget {
  final Widget child;
  final bool showFooter;
  final PreferredSizeWidget? appBar;
  final int selectedIndex;

  const AppLayout({
    super.key,
    required this.child,
    this.showFooter = true,
    this.appBar,
    this.selectedIndex = 2,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      body: child,
      bottomNavigationBar: showFooter ? _buildFooter(context) : null,
    );
  }

  // ✅ Centralized navigation logic
  void _handleNavigation(BuildContext context, int index) {
    if (index == 0) {
      // Navigate to Profile
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const ProfileScreen()),
        (route) => false,
      );
    } else if (index == 1) {
      // Navigate to Discover screen
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const DiscoverScreen()),
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
    } else if (index == 4) {
      // Navigate to Chat screen
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const ChatScreen()),
        (route) => false,
      );
    }
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Colors.white),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildNavItem(
                context: context,
                selectedIcon: Icons.person,
                unselectedIcon: Icons.person_outline,
                label: 'Profile',
                index: 0,
                isSelected: selectedIndex == 0,
              ),
              _buildNavItem(
                context: context,
                selectedIcon: Icons.explore,
                unselectedIcon: Icons.explore_outlined,
                label: 'Discover',
                index: 1,
                isSelected: selectedIndex == 1,
              ),
              _buildNavItem(
                context: context,
                selectedIcon: Icons.people,
                unselectedIcon: Icons.people_outline,
                label: 'Peoples',
                index: 2,
                isSelected: selectedIndex == 2,
              ),
              _buildNavItem(
                context: context,
                selectedIcon: Icons.favorite,
                unselectedIcon: Icons.favorite_border,
                label: 'Liked You',
                index: 3,
                isSelected: selectedIndex == 3,
              ),
              _buildNavItem(
                context: context,
                selectedIcon: Icons.chat_bubble,
                unselectedIcon: Icons.chat_bubble_outline,
                label: 'Chat',
                index: 4,
                isSelected: selectedIndex == 4,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required IconData selectedIcon,
    required IconData unselectedIcon,
    required String label,
    required int index,
    required bool isSelected,
  }) {
    final Color selectedColor = Theme.of(context).colorScheme.primary;
    final Color unselectedColor = Colors.grey;

    return GestureDetector(
      onTap: () => _handleNavigation(context, index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isSelected ? selectedIcon : unselectedIcon,
            color: isSelected ? selectedColor : unselectedColor,
            size: 28,
          ),
          const SizedBox(height: 4),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              color: isSelected ? selectedColor : unselectedColor,
            ),
            child: Text(label),
          ),
        ],
      ),
    );
  }
}