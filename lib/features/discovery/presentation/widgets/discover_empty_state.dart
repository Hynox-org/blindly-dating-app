import 'package:flutter/material.dart';

class DiscoverEmptyState extends StatelessWidget {
  const DiscoverEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/static/discover_empty_state.png',
              height: 250,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 32),
            const Text(
              "You've reached the end of the line!",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              "Check back soon for more people or try adjusting your filters to see more profiles.",
              style: TextStyle(
                fontSize: 14,
                color: Colors.black.withOpacity(0.7),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  // Action for "See More Peoples"
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3F4631), // Dark Olive Green
                  foregroundColor: const Color(0xFFC7A166), // Gold/Tan
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'See More Peoples',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
