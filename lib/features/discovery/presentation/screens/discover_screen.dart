import 'package:flutter/material.dart';
import '../../../../core/widgets/app_layout.dart';
import '../widgets/discover_empty_state.dart';
import '../../../home/screens/connection_type_screen.dart';
import '../../../../core/utils/navigation_utils.dart';

class DiscoverScreen extends StatelessWidget {
  const DiscoverScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      showFooter: true,
      selectedIndex: 1, // Discover tab index
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.more_vert,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          onPressed: () {
            NavigationUtils.navigateToWithSlide(
              context,
              const ConnectionTypeScreen(),
            );
          },
        ),
        title: Text(
          'Discover',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      child: Container(color: Colors.white, child: const DiscoverEmptyState()),
    );
  }
}
