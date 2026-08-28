import 'package:flutter/material.dart';

import 'package:blindly_dating_app/l10n/app_localizations.dart';
import 'package:blindly_dating_app/features/discovery/presentation/widgets/discovery_profile_card.dart';
import 'package:blindly_dating_app/features/matching/domain/models/match_profile.dart';

/// One titled row of the Discover feed: a header and a horizontal strip of
/// [DiscoveryProfileCard]s. The caller owns the interaction state and every
/// action, so this stays a pure presentation widget.
class DiscoveryCarousel extends StatelessWidget {
  final String emoji;
  final String title;
  final List<MatchProfile> users;

  /// Below five profiles the carousel already shows everyone, so "See all"
  /// would lead to the same faces in a taller box — a count chip goes there
  /// instead and [onSeeAll] is never called.
  static const seeAllThreshold = 4;

  final String Function(MatchProfile) interactionFor;
  final bool Function(MatchProfile) isPlaying;
  final void Function(MatchProfile) onTap;
  final void Function(MatchProfile) onUndo;
  final void Function(MatchProfile) onVoiceTap;
  final VoidCallback onSeeAll;

  const DiscoveryCarousel({
    super.key,
    required this.emoji,
    required this.title,
    required this.users,
    required this.interactionFor,
    required this.isPlaying,
    required this.onTap,
    required this.onUndo,
    required this.onVoiceTap,
    required this.onSeeAll,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 26, 20, 14),
          child: Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                    color: Colors.black87,
                  ),
                ),
              ),
              if (users.length > seeAllThreshold)
                _seeAllButton(context)
              else
                _countChip(),
            ],
          ),
        ),
        SizedBox(
          height: kDiscoveryCardHeight,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            itemCount: users.length,
            separatorBuilder: (_, _) => const SizedBox(width: 14),
            itemBuilder: (context, i) {
              final user = users[i];
              return SizedBox(
                width: kDiscoveryCardWidth,
                child: DiscoveryProfileCard(
                  profile: user,
                  interaction: interactionFor(user),
                  isPlaying: isPlaying(user),
                  onTap: () => onTap(user),
                  onUndo: () => onUndo(user),
                  onVoiceTap: () => onVoiceTap(user),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _seeAllButton(BuildContext context) => TextButton(
    onPressed: onSeeAll,
    style: TextButton.styleFrom(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      minimumSize: Size.zero,
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    ),
    child: Text(
      AppLocalizations.of(context).seeAll,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: Theme.of(context).colorScheme.primary,
      ),
    ),
  );

  Widget _countChip() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
    decoration: BoxDecoration(
      color: Colors.grey.shade100,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      '${users.length}',
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: Colors.grey.shade700,
      ),
    ),
  );
}
