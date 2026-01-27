import 'package:flutter/material.dart';
import '../../../../core/widgets/app_layout.dart';
import '../widgets/discover_empty_state.dart';

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
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text(
          'Discover',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      child: Container(color: Colors.white, child: const DiscoverEmptyState()),
    );
  }
}
