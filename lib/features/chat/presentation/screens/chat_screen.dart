import 'package:flutter/material.dart';
import 'dart:math';
import '../../../../core/widgets/app_layout.dart';

import '../../../home/screens/connection_type_screen.dart';
import '../../../../core/utils/navigation_utils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../features/home/screens/home_screen.dart';

class ChatScreen extends ConsumerWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppLayout(
      selectedIndex: 4,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
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
          centerTitle: true,
          title: Text(
            'Chats',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(
                Icons.search,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              onPressed: () {},
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Recent Matches Header
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                child: Text(
                  'Recent matches',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),

              // Recent Matches Empty State (Placeholders)
              SizedBox(
                height: 60,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: 5, // Show 5 placeholders
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 16.0),
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          // border: Border.all(
                          //   color: Colors.grey[400]!,
                          //   width: 1,
                          //   style: BorderStyle.none, // Dotted simulation below
                          // ),
                        ),
                        child: CustomPaint(
                          painter: DottedBorderPainter(
                            color: Theme.of(context).colorScheme.outlineVariant,
                            strokeWidth: 2,
                            gap: 6,
                          ),
                          child: Center(
                            child: Icon(
                              Icons.person_add,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 16.0,
                ),
                child: Text(
                  'Your new matches will appear here.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              Divider(
                height: 32,
                thickness: 1,
                color: Theme.of(context).dividerColor,
              ),

              // Conversations Header
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                child: Text(
                  'Conversations',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),

              // Conversations Empty State
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      Image.asset(
                        'assets/static/chats_conversation_empty_state.png',
                        height: 200,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 32),
                      Text(
                        "Ready to make the first\nmove?",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "Once you match with someone, your conversations will show up here. Start the convo and let the vibes flow.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const HomeScreen(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.primary,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Find Your Vibe',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Custom Painter for Dotted Border
class DottedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double gap;

  DottedBorderPainter({
    required this.color,
    this.strokeWidth = 1.0,
    this.gap = 5.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap
          .round // Rounded caps
      ..style = PaintingStyle.stroke;

    // Approximate perimeter of an ellipse
    // p ≈ 2π * sqrt((a^2 + b^2) / 2)
    final double a = size.width / 2;
    final double b = size.height / 2;
    final double circumference = 2 * pi * sqrt((a * a + b * b) / 2);

    final double dashWidth =
        1.0; // Very short dash for "dot" look with round caps
    final int dashCount = (circumference / (dashWidth + gap)).floor();
    final double step = (pi * 2) / dashCount;

    for (int i = 0; i < dashCount; i++) {
      // Calculate arc for dash
      canvas.drawArc(
        Rect.fromLTWH(0, 0, size.width, size.height),
        step * i,
        step * 0.1, // Short arc
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
