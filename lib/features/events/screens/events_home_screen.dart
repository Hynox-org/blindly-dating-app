import 'package:flutter/material.dart';
import '../../home/screens/connection_type_screen.dart';
import '../../../../core/utils/navigation_utils.dart';
import 'events_discover_screen.dart';
import 'events_booked_screen.dart';
import 'events_upcoming_screen.dart';

class EventsHomeScreen extends StatefulWidget {
  const EventsHomeScreen({super.key});

  @override
  State<EventsHomeScreen> createState() => _EventsHomeScreenState();
}

class _EventsHomeScreenState extends State<EventsHomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    EventsDiscoverScreen(),
    EventsBookedScreen(),
    EventsUpcomingScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          onPressed: () => _showModeMenu(context),
        ),
        title: Text(
          "Events",
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
      ),
      body: IndexedStack(index: _selectedIndex, children: _screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            height: 60,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildNavItem(
                  context: context,
                  selectedIcon: Icons.explore,
                  unselectedIcon: Icons.explore_outlined,
                  label: 'Discover',
                  index: 0,
                  isSelected: _selectedIndex == 0,
                ),
                _buildNavItem(
                  context: context,
                  selectedIcon: Icons.confirmation_number,
                  unselectedIcon: Icons.confirmation_number_outlined,
                  label: 'Booked',
                  index: 1,
                  isSelected: _selectedIndex == 1,
                ),
                _buildNavItem(
                  context: context,
                  selectedIcon: Icons.calendar_today,
                  unselectedIcon: Icons.calendar_today_outlined,
                  label: 'Upcoming',
                  index: 2,
                  isSelected: _selectedIndex == 2,
                ),
              ],
            ),
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
          onTap: () => _onItemTapped(index),
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

  void _showModeMenu(BuildContext context) {
    NavigationUtils.navigateToWithSlide(
      context,
      const ConnectionTypeScreen(initialMode: 'Events'),
    );
  }
}
