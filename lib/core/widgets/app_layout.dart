import 'package:flutter/material.dart';
import '../../features/profile/profile.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/match/liked_you_screen.dart';

class AppLayout extends StatelessWidget {
  final Widget child;
  final bool showFooter;
  final PreferredSizeWidget? appBar;
  final int selectedIndex;

  const AppLayout({
    Key? key,
    required this.child,
    this.showFooter = true,
    this.appBar,
    this.selectedIndex = 2,
  }) : super(key: key);

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
      // TODO: Navigate to Discover screen when created
      // For now, do nothing or show coming soon
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
      // TODO: Navigate to Chat screen when created
      // For now, do nothing or show coming soon
    }
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
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
                context: context,
                icon: Icons.person_outline,
                label: 'Profile',
                index: 0,
                isSelected: selectedIndex == 0,
              ),
              _buildNavItem(
                context: context,
                icon: Icons.explore_outlined,
                label: 'Discover',
                index: 1,
                isSelected: selectedIndex == 1,
              ),
              _buildNavItem(
                context: context,
                icon: Icons.people_outline,
                label: 'Peoples',
                index: 2,
                isSelected: selectedIndex == 2,
              ),
              _buildNavItem(
                context: context,
                icon: Icons.favorite_outline,
                label: 'Liked You',
                index: 3,
                isSelected: selectedIndex == 3,
              ),
              _buildNavItem(
                context: context,
                icon: Icons.chat_bubble_outline,
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
    required IconData icon,
    required String label,
    required int index,
    required bool isSelected,
  }) {
    final Color selectedColor = Theme.of(context).colorScheme.secondary;
    final Color unselectedColor = Theme.of(context).colorScheme.onSurface;

    return GestureDetector(
      onTap: () => _handleNavigation(context, index),
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
