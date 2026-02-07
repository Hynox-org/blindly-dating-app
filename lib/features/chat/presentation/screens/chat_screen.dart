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
                    // ================= Recent Matches =================
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        "Recent Matches",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    recentMatches.when(
                      data: (matches) {
                        if (matches.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Text("No new matches yet"),
                          );
                        }

                        return SizedBox(
                          height: 90,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: matches.length,
                            itemBuilder: (context, index) {
                              final match = matches[index];

                              final profileA = Map<String, dynamic>.from(
                                  match['profile_a'] ?? {});
                              final profileB = Map<String, dynamic>.from(
                                  match['profile_b'] ?? {});

                              Map<String, dynamic> otherProfile;
                              String? otherProfileId;

                              if (match['profile_a_id'] == profileId) {
                                otherProfile = profileB;
                                otherProfileId =
                                    match['profile_b_id']?.toString();
                              } else {
                                otherProfile = profileA;
                                otherProfileId =
                                    match['profile_a_id']?.toString();
                              }

                              final otherName =
                                  _getProfileName(otherProfile);
                              final photoUrl =
                                  otherProfile['photo_url']?.toString();
                              final otherImage =
                                  _getProfileImage(photoUrl, otherName);

                              return GestureDetector(
                                onTap: otherProfileId != null
                                    ? () async {
                                        final result =
                                            await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                ChatDetailScreen(
                                              matchId:
                                                  match['id'].toString(),
                                              name: otherName,
                                              imageUrl: otherImage,
                                              myProfileId: profileId,
                                              otherProfileId:
                                                  otherProfileId!, // ✅ FIXED
                                            ),
                                          ),
                                        );

                                        if (result == true &&
                                            context.mounted) {
                                          ref.invalidate(
                                              recentMatchesProvider);
                                          ref.invalidate(
                                              conversationsProvider);
                                        }
                                      }
                                    : null,
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 16, right: 8),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      CircleAvatar(
                                        radius: 30,
                                        backgroundImage:
                                            NetworkImage(otherImage),
                                      ),
                                      const SizedBox(height: 6),
                                      SizedBox(
                                        width: 60,
                                        child: Text(
                                          otherName,
                                          maxLines: 1,
                                          overflow:
                                              TextOverflow.ellipsis,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight:
                                                FontWeight.w500,
                                          ),
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
                        padding: EdgeInsets.all(16),
                        child: Center(
                            child: CircularProgressIndicator()),
                      ),
                      error: (e, _) => Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text("Error loading matches: $e"),
                      ),
                    ),

                    const Divider(height: 40),

                    // ================= Conversations =================
                    const Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        "Conversations",
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
