import 'package:flutter/material.dart';
import '../../domain/models/match_model.dart';

class MatchPopup extends StatelessWidget {
  final MatchModel match;
  final VoidCallback onChat;
  final VoidCallback onClose;

  const MatchPopup({
    super.key,
    required this.match,
    required this.onChat,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.black,
      insetPadding: EdgeInsets.zero,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "It's a Match! 🎉",
            style: TextStyle(
              fontSize: 32,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),

          // Profile Images (placeholder for now)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              CircleAvatar(radius: 50, backgroundColor: Colors.grey),
              SizedBox(width: 16),
              CircleAvatar(radius: 50, backgroundColor: Colors.grey),
            ],
          ),

          const SizedBox(height: 32),

          ElevatedButton(
            onPressed: onChat,
            child: const Text('Send Message'),
          ),
          TextButton(
            onPressed: onClose,
            child: const Text('Keep Swiping'),
          ),
        ],
      ),
    );
  }
}
