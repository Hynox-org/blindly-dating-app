import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    // Add haptic feedback
    HapticFeedback.lightImpact();

    if (index == selectedIndex) {
      return; // Prevent navigation if already on the tab
    }

    Widget? page;

    if (index == 0) {
      page = const ProfileScreen();
    } else if (index == 1) {
      page = const DiscoverScreen();
    } else if (index == 2) {
      page = const HomeScreen();
    } else if (index == 3) {
      page = const LikedYouScreen();
    } else if (index == 4) {
      page = ChatScreen();
    }

    if (page != null) {
      Navigator.pushAndRemoveUntil(
        context,
        _createRoute(page),
        (route) => false,
      );
    }
  }

  Route _createRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: Duration.zero,
      reverseTransitionDuration: Duration.zero,
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: Colors.white),
      child: SafeArea(
        // Keep SafeArea but remove padding to let InkWell hit edges
        child: SizedBox(
          height: 60, // Fixed height for consistency
          child: Row(
            crossAxisAlignment:
                CrossAxisAlignment.stretch, // Stretch children to fill height
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

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _handleNavigation(context, index),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isSelected ? selectedIcon : unselectedIcon,
                color: isSelected ? selectedColor : unselectedColor,
                size: 26,
              ),
              const SizedBox(height: 6),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected ? selectedColor : unselectedColor,
                ),
                child: Text(label),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
