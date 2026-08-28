import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:blindly_dating_app/features/discovery/presentation/discovery_card_actions.dart';
import 'package:blindly_dating_app/features/discovery/presentation/widgets/discovery_profile_card.dart';
import 'package:blindly_dating_app/features/matching/domain/models/match_profile.dart';

/// Where "See all" goes: one carousel, unrolled into a grid.
///
/// It renders the profiles the Discover page already has in memory rather than
/// paging the server — a category is capped at ten rows by
/// `get_discovery_categories`, so there is nothing further to fetch.
class DiscoveryCategoryScreen extends ConsumerStatefulWidget {
  final String title;
  final String emoji;
  final List<MatchProfile> users;

  /// The Discover page's own session map, passed by reference so a swipe made
  /// here shows on the carousel behind it.
  final Map<String, String> interactions;

  const DiscoveryCategoryScreen({
    super.key,
    required this.title,
    required this.emoji,
    required this.users,
    required this.interactions,
  });

  @override
  ConsumerState<DiscoveryCategoryScreen> createState() =>
      _DiscoveryCategoryScreenState();
}

class _DiscoveryCategoryScreenState
    extends ConsumerState<DiscoveryCategoryScreen>
    with DiscoveryCardActions {
  @override
  void initState() {
    super.initState();
    userInteractions = widget.interactions;
    initCardActions();
  }

  @override
  void dispose() {
    disposeCardActions();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            Text(widget.emoji, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                widget.title,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 14,
          mainAxisSpacing: 16,
          childAspectRatio: kDiscoveryCardWidth / kDiscoveryCardHeight,
        ),
        itemCount: widget.users.length,
        itemBuilder: (context, i) {
          final user = widget.users[i];
          return DiscoveryProfileCard(
            profile: user,
            interaction: interactionFor(user),
            isPlaying: isPlaying(user),
            onTap: () => openProfile(user),
            onUndo: () => undo(user),
            onVoiceTap: () => toggleVoice(user),
          );
        },
      ),
    );
  }
}
