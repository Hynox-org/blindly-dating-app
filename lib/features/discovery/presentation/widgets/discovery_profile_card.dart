import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:blindly_dating_app/l10n/app_localizations.dart';
import 'package:blindly_dating_app/features/matching/domain/models/match_profile.dart';

/// The tile's proportions. The carousel, the skeleton and the "See all" grid
/// all size themselves from these, so the three never drift apart.
const double kDiscoveryCardWidth = 158;
const double kDiscoveryCardHeight = 244;

/// One profile tile. Shared by the Discover carousels and the "See all" grid
/// so the two never drift apart; the caller owns the size and the state.
class DiscoveryProfileCard extends StatelessWidget {
  final MatchProfile profile;

  /// 'liked' | 'super_liked' | 'passed' | 'none' — the session action layered
  /// over the server's, resolved by the caller.
  final String interaction;
  final bool isPlaying;
  final VoidCallback onTap;
  final VoidCallback onUndo;
  final VoidCallback onVoiceTap;

  const DiscoveryProfileCard({
    super.key,
    required this.profile,
    required this.interaction,
    required this.isPlaying,
    required this.onTap,
    required this.onUndo,
    required this.onVoiceTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    // A super like is still a like — checking only for 'liked' left
    // super-liked profiles with no heart on them.
    final isLiked = interaction == 'liked' || interaction == 'super_liked';
    final canUndo = interaction == 'passed';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: Colors.grey.shade200,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.10),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (profile.imageUrls.isNotEmpty)
              CachedNetworkImage(
                imageUrl: profile.imageUrls.first,
                fit: BoxFit.cover,
                placeholder: (_, _) => Container(color: Colors.grey.shade200),
                errorWidget: (_, _, _) => _avatarFallback(),
              )
            else
              _avatarFallback(),

            // Keeps the name legible over a bright photo.
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.center,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Color(0xCC000000)],
                ),
              ),
            ),

            if (profile.trustScore > 0)
              Positioned(
                top: 10,
                left: 10,
                child: _trustChip(profile.trustScore),
              ),

            Positioned(
              top: 8,
              right: 8,
              child: Column(
                children: [
                  if (isLiked)
                    _badge(
                      const Icon(Icons.favorite, size: 15, color: Colors.white),
                      background: theme.colorScheme.primary,
                    ),
                  if (isLiked && profile.isVerified) const SizedBox(height: 6),
                  if (profile.isVerified)
                    _badge(
                      const Icon(
                        Icons.verified_rounded,
                        size: 15,
                        color: Colors.white,
                      ),
                      background: const Color(0xFF2E86FF),
                    ),
                ],
              ),
            ),

            Positioned(
              left: 12,
              right: 12,
              bottom: 12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${profile.displayName}, ${profile.age}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      const Icon(
                        Icons.place_rounded,
                        size: 12,
                        color: Colors.white70,
                      ),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          l10n.kmAway(profile.distanceKm.toStringAsFixed(1)),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      if (profile.voiceIntroUrl != null)
                        GestureDetector(
                          onTap: onVoiceTap,
                          child: Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: isPlaying
                                  ? theme.colorScheme.primary
                                  : Colors.white.withValues(alpha: 0.25),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isPlaying
                                  ? Icons.stop_rounded
                                  : Icons.graphic_eq_rounded,
                              size: 14,
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),

            if (canUndo)
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.55),
                  ),
                  child: Center(
                    child: Tooltip(
                      message: l10n.undoNotForMe,
                      child: GestureDetector(
                        onTap: onUndo,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.undo_rounded, size: 22),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _avatarFallback() => Container(
    color: Colors.grey.shade300,
    child: Center(
      child: Text(
        profile.displayName.isNotEmpty
            ? profile.displayName[0].toUpperCase()
            : '?',
        style: TextStyle(
          fontSize: 40,
          fontWeight: FontWeight.w700,
          color: Colors.grey.shade500,
        ),
      ),
    ),
  );

  Widget _badge(Widget child, {required Color background}) => Container(
    padding: const EdgeInsets.all(5),
    decoration: BoxDecoration(color: background, shape: BoxShape.circle),
    child: child,
  );

  Widget _trustChip(int score) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
    decoration: BoxDecoration(
      color: Colors.black.withValues(alpha: 0.45),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.shield_rounded, size: 10, color: Color(0xFF4ADE80)),
        const SizedBox(width: 3),
        Text(
          '$score%',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    ),
  );
}
