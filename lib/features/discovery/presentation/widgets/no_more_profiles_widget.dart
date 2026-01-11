import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../povider/discovery_provider.dart';

class NoMoreProfilesWidget extends ConsumerStatefulWidget {
  const NoMoreProfilesWidget({super.key});

  @override
  ConsumerState<NoMoreProfilesWidget> createState() =>
      _NoMoreProfilesWidgetState();
}

class _NoMoreProfilesWidgetState extends ConsumerState<NoMoreProfilesWidget> {
  bool _isLoading = false;

  Future<void> _refresh() async {
    setState(() => _isLoading = true);
    await ref.read(discoveryFeedProvider.notifier).refreshFeed();
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 1. Friendly Illustration
          Container(
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle_outline,
              size: 80,
              color: Color(0xFFD4AF37),
            ),
          ),
          const SizedBox(height: 30),

          // 2. Professional Headline
          const Text(
            "You're all caught up!",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 12),

          // 3. Explanation
          Text(
            "There are no new profiles in your area matching your criteria right now.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey[600],
              height: 1.5,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 40),

          // 4. Action Button (Refresh)
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _refresh,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 0,
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      "Refresh Feed",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
            ),
          ),

          const SizedBox(height: 16),

          // 5. Secondary Action (Settings)
          TextButton(
            onPressed: () {
              // Navigate to Discovery Settings (to increase radius)
            },
            child: const Text(
              "Adjust Discovery Settings",
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}
