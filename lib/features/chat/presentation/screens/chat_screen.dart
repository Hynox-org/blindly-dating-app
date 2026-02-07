import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/chat_providers.dart';
import '../../../../core/widgets/app_layout.dart';
import 'chat_detail_screen.dart';
import 'chat_conversation_screen.dart';

class ChatScreen extends ConsumerWidget {
  const ChatScreen({super.key});

  String _getProfileName(Map<String, dynamic>? profile) {
    if (profile == null || profile.isEmpty) return 'Unknown User';
    return profile['display_name']?.toString() ?? 'Unknown User';
  }

  String _getProfileImage(String? photoUrl, String fallbackName) {
    if (photoUrl?.isNotEmpty == true) return photoUrl!;
    return "https://ui-avatars.com/api/?name=${Uri.encodeComponent(fallbackName)}"
        "&size=128&background=4F46E5&color=fff";
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileIdAsync = ref.watch(currentProfileIdProvider);
    final recentMatches = ref.watch(recentMatchesProvider);
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
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    conversations.when(
                      data: (matches) {
                        if (matches.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.all(24),
                            child: Center(
                                child: Text("No conversations yet")),
                          );
                        }

                        return ListView.builder(
                          shrinkWrap: true,
                          physics:
                              const NeverScrollableScrollPhysics(),
                          itemCount: matches.length,
                          itemBuilder: (context, index) {
                            final match = matches[index];

                            final profileA =
                                Map<String, dynamic>.from(
                                    match['profile_a'] ?? {});
                            final profileB =
                                Map<String, dynamic>.from(
                                    match['profile_b'] ?? {});

                            final otherProfile =
                                match['profile_a_id'] ==
                                        profileId
                                    ? profileB
                                    : profileA;

                            final otherName =
                                _getProfileName(otherProfile);
                            final photoUrl =
                                otherProfile['photo_url']
                                    ?.toString();
                            final otherImage =
                                _getProfileImage(
                                    photoUrl, otherName);

                            return ListTile(
                              leading: CircleAvatar(
                                backgroundImage:
                                    NetworkImage(otherImage),
                              ),
                              title: Text(
                                otherName,
                                style: const TextStyle(
                                    fontWeight:
                                        FontWeight.w600),
                              ),
                              subtitle: const Text(
                                  "Tap to continue chatting"),
                              trailing:
                                  match['chat_started'] == true
                                      ? const Icon(
                                          Icons.chat_bubble_outline,
                                          color: Colors.green)
                                      : null,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        ChatConversationScreen(
                                      matchId:
                                          match['id'].toString(),
                                      otherUserName:
                                          otherName,
                                      otherUserImage:
                                          otherImage,
                                      myProfileId:
                                          profileId,
                                      otherProfileId:
                                          otherProfile['id']
                                              .toString(),
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
                        child: Center(
                            child: CircularProgressIndicator()),
                      ),
                      error: (e, _) => Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                            "Error loading conversations: $e"),
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
