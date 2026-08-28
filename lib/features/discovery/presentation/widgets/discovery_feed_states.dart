import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import 'package:blindly_dating_app/l10n/app_localizations.dart';
import 'package:blindly_dating_app/features/discovery/presentation/widgets/discovery_profile_card.dart';

/// The three non-data states of the Discover feed. They are pure presentation
/// — every action is a callback — so the screen keeps only its fetching logic.

/// A shaped placeholder rather than a bare spinner, so the page keeps its
/// layout while the two RPCs land and nothing jumps when data arrives.
class DiscoveryFeedSkeleton extends StatelessWidget {
  const DiscoveryFeedSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      physics: const NeverScrollableScrollPhysics(),
      children: [
        for (var s = 0; s < 3; s++) ...[
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 26, 20, 14),
            child: _ShimmerBox(width: 168, height: 22),
          ),
          SizedBox(
            height: kDiscoveryCardHeight,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 3,
              separatorBuilder: (_, _) => const SizedBox(width: 14),
              itemBuilder: (_, _) => const _ShimmerBox(
                width: kDiscoveryCardWidth,
                height: kDiscoveryCardHeight,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _ShimmerBox extends StatelessWidget {
  final double width;
  final double height;

  const _ShimmerBox({required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(height > 40 ? 18 : 6),
      ),
    );
  }
}

/// "No location set" is the one error a Retry cannot fix — the profile has no
/// coordinates until the app records some, so send the user to settings.
class DiscoveryFeedError extends StatelessWidget {
  final Object error;
  final Future<void> Function() onRetry;

  const DiscoveryFeedError({
    super.key,
    required this.error,
    required this.onRetry,
  });

  bool get _needsLocation =>
      error.toString().toLowerCase().contains('no location set');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return RefreshIndicator(
      onRefresh: onRetry,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 32),
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.18),
          Icon(
            _needsLocation
                ? Icons.location_off_rounded
                : Icons.cloud_off_rounded,
            size: 56,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.35),
          ),
          const SizedBox(height: 20),
          Text(
            _needsLocation
                ? l10n.locationRequiredTitle
                : l10n.somethingWentWrong,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: theme.colorScheme.onSurface,
            ),
          ),
          if (_needsLocation) ...[
            const SizedBox(height: 10),
            Text(
              l10n.locationRequiredBody,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                height: 1.4,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
          const SizedBox(height: 28),
          FilledButton(
            onPressed: _needsLocation ? Geolocator.openAppSettings : onRetry,
            style: FilledButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              minimumSize: const Size(double.infinity, 52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: Text(
              _needsLocation ? l10n.settingsTitle : l10n.retry,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

class DiscoveryEmptyFeed extends StatelessWidget {
  final Future<void> Function() onRefresh;
  final VoidCallback onSeeMorePeople;

  /// An empty feed is usually a filter that is too narrow, so the fix is one
  /// tap away here instead of on the other tab.
  final VoidCallback onAdjustFilters;

  const DiscoveryEmptyFeed({
    super.key,
    required this.onRefresh,
    required this.onSeeMorePeople,
    required this.onAdjustFilters,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.05),
          Image.asset(
            'assets/static/discover_empty_state.png',
            width: double.infinity,
            height: 250,
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              l10n.reachedEndOfLine,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                height: 1.2,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              l10n.checkBackSoon,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                height: 1.4,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
              ),
            ),
          ),
          const SizedBox(height: 40),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                FilledButton(
                  onPressed: onSeeMorePeople,
                  style: FilledButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    minimumSize: const Size(double.infinity, 54),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    l10n.seeMorePeople,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: onAdjustFilters,
                  child: Text(
                    l10n.adjustYourFilters,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
