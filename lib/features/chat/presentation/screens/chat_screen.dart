import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// For Uri.encodeComponent

import '../../providers/chat_providers.dart';
import '../../../../core/widgets/app_layout.dart';
import './chat_conversation_screen.dart';
import './chat_detail_screen.dart';
// Custom painter for dotted border effect (KEEP THIS)
class DottedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double gap;

  DottedBorderPainter({
    required this.color,
    required this.strokeWidth,
    required this.gap,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..addOval(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPath(
      _dashPath(path, strokeWidth * 2, gap),
      paint,
    );
  }

  Path _dashPath(Path source, double dashWidth, double dashSpace) {
    final dest = Path();
    for (final metric in source.computeMetrics()) {
      double dist = 0.0;
      while (dist < metric.length) {
        final len = (dist + dashWidth > metric.length)
            ? metric.length - dist
            : dashWidth;
        dest.addPath(metric.extractPath(dist, dist + len), Offset.zero);
        dist += dashWidth + dashSpace;
      }
    }
    return dest;
  }

  @override
  bool shouldRepaint(DottedBorderPainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.strokeWidth != strokeWidth ||
      oldDelegate.gap != gap;
}

class ChatScreen extends ConsumerWidget {
  const ChatScreen({super.key});

  String _getProfileName(dynamic profileData) {
    if (profileData == null) return 'Unknown User';
    
    // Handle both Map and RecentMatch
    if (profileData is Map<String, dynamic>) {
      return profileData['display_name']?.toString() ?? 'Unknown User';
    }
    return 'Unknown User';
  }

  String _getProfileImage(String? photoUrl, String fallbackName) {
    if (photoUrl?.isNotEmpty == true) return photoUrl!;
    return "https://ui-avatars.com/api/?name=${Uri.encodeComponent(fallbackName)}"
        "&size=128&background=4F46E5&color=fff";
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileIdAsync = ref.watch(currentProfileIdProvider);
    final recentMatches = ref.watch(recentMatchesProvider); // ✅ StateNotifier
    final conversations = ref.watch(conversationsProvider);

    return AppLayout(
      showFooter: true,
      selectedIndex: 4,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text("Chats"),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          titleTextStyle: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
          elevation: 0.5,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                ref.invalidate(currentProfileIdProvider);
                ref.invalidate(recentMatchesProvider);
                ref.invalidate(conversationsProvider);
              },
            ),
          ],
        ),
        body: profileIdAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Profile Error: $error'),
                ElevatedButton(
                  onPressed: () => ref.invalidate(currentProfileIdProvider),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
          data: (profileId) {
            return RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(recentMatchesProvider);
                ref.invalidate(conversationsProvider);
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ================= Recent Matches ✅ =================
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

                    recentMatches.when(
                      data: (matches) {
                        if (matches.isEmpty) {
                          return Column(
                            children: [
                              SizedBox(
                                height: 80,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  itemCount: 5,
                                  itemBuilder: (context, index) {
                                    return Padding(
                                      padding: const EdgeInsets.only(right: 16.0),
                                      child: Container(
                                        width: 60,
                                        height: 60,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.grey.shade100,
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
                                              color: Theme.of(context).colorScheme.onSurfaceVariant,
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
                                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                                child: Text(
                                  'Your new matches will appear here.',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Theme.of(context).colorScheme.onSurface,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          );
                        }

                        return SizedBox(
                          height: 100,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: matches.length,
                            itemBuilder: (context, index) {
                              final match = matches[index];
                              
                              // ✅ Handle RecentMatch model data structure
                              final otherProfileId = match.profileId;
                              final otherName = match.displayName;
                              final photoUrl = match.imageUrl ?? '';

                              return Padding(
                                padding: const EdgeInsets.only(right: 16.0),
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => ChatDetailScreen(
                                          name: otherName,
                                          imageUrl: _getProfileImage(photoUrl, otherName),
                                          matchId: match.matchId,
                                          myProfileId: profileId,
                                          otherProfileId: otherProfileId,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Column(
                                    children: [
                                      CircleAvatar(
                                        radius: 30,
                                        backgroundImage: photoUrl.isNotEmpty
                                            ? NetworkImage(photoUrl)
                                            : null,
                                        child: photoUrl.isEmpty
                                            ? Text(
                                                otherName.substring(0, 1).toUpperCase(),
                                                style: const TextStyle(
                                                  fontSize: 24,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              )
                                            : null,
                                      ),
                                      const SizedBox(height: 8),
                                      SizedBox(
                                        width: 60,
                                        child: Text(
                                          otherName,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 12,
                                          ),
                                          textAlign: TextAlign.center,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                      loading: () => const Padding(
                        padding: EdgeInsets.all(24),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                      error: (e, st) => Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            Text("Error loading matches: $e"),
                            ElevatedButton(
                              onPressed: () => ref.invalidate(recentMatchesProvider),
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // ================= Conversations =================
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

                    conversations.when(
                      data: (matches) {
                        if (matches.isEmpty) {
                          return Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              children: [
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
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: matches.length,
                          itemBuilder: (context, index) {
                            final match = matches[index];

                            final profileA = Map<String, dynamic>.from(
                                match['user_a'] ?? {});
                            final profileB = Map<String, dynamic>.from(
                                match['user_b'] ?? {});

                            final otherProfile = match['user_a_id'] == profileId
                                ? profileB
                                : profileA;

                            final otherName = _getProfileName(otherProfile);
                            final photoUrl = otherProfile['photo_url']?.toString();
                            final otherImage = _getProfileImage(photoUrl, otherName);

                            return ListTile(
                              leading: CircleAvatar(
                                backgroundImage: NetworkImage(otherImage),
                              ),
                              title: Text(
                                otherName,
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                              subtitle: const Text("Tap to continue chatting"),
                              trailing: match['chat_started'] == true
                                  ? const Icon(
                                      Icons.chat_bubble_outline,
                                      color: Colors.green,
                                    )
                                  : null,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ChatConversationScreen(
                                      matchId: match['id'].toString(),
                                      otherUserName: otherName,
                                      otherUserImage: otherImage,
                                      myProfileId: profileId,
                                      otherProfileId: otherProfile['id'].toString(),
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        );
                      },
                      loading: () => const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                      error: (e, _) => Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Text("Error loading conversations: $e"),
                            ElevatedButton(
                              onPressed: () => ref.invalidate(conversationsProvider),
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 100),
                  ],
                ),
              ),
            );
          },
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
