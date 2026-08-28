import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:blindly_dating_app/core/providers/connection_mode_provider.dart';
import 'package:blindly_dating_app/core/utils/navigation_utils.dart';
import 'package:blindly_dating_app/core/widgets/app_layout.dart';
import 'package:blindly_dating_app/features/discovery/domain/models/discovery_landing_data.dart';
import 'package:blindly_dating_app/features/discovery/presentation/discovery_card_actions.dart';
import 'package:blindly_dating_app/features/discovery/presentation/screens/discovery_category_screen.dart';
import 'package:blindly_dating_app/features/discovery/presentation/widgets/discovery_carousel.dart';
import 'package:blindly_dating_app/features/discovery/presentation/widgets/discovery_feed_states.dart';
import 'package:blindly_dating_app/features/discovery/provider/discovery_landing_provider.dart';
import 'package:blindly_dating_app/features/matching/domain/models/match_profile.dart';
import 'package:blindly_dating_app/features/matching/presentation/screens/connection_type_screen.dart';
import 'package:blindly_dating_app/features/matching/presentation/screens/filter_screen.dart';
import 'package:blindly_dating_app/features/matching/provider/filter_provider.dart';
import 'package:blindly_dating_app/features/people/people_screen.dart';

/// Carousel order is fixed here rather than taken from the feed map, so the
/// page reads the same every time regardless of which categories came back —
/// and a category the app does not know about is simply not rendered.
const _sections = <({String key, String emoji})>[
  (key: 'top_picks', emoji: '🔥'),
  (key: 'nearby', emoji: '📍'),
  (key: 'shared_interests', emoji: '🤝'),
  (key: 'new_faces', emoji: '👋'),
  (key: 'recently_active', emoji: '⏱️'),
];

class DiscoverScreen extends ConsumerStatefulWidget {
  const DiscoverScreen({super.key});

  @override
  ConsumerState<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends ConsumerState<DiscoverScreen>
    with DiscoveryCardActions {
  @override
  void initState() {
    super.initState();
    initCardActions();
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchData());
  }

  @override
  void dispose() {
    disposeCardActions();
    super.dispose();
  }

  // --------------------------------------------------------------- fetching
  /// No location lookup here on purpose: the server reads the caller's
  /// position from `profiles.location_geom`. This used to take a GPS fix it
  /// then discarded, and swallowing the resulting error left the page
  /// spinning forever whenever permission was denied.
  Future<void> _fetchData({bool forceRefresh = false}) {
    return ref
        .read(discoveryLandingProvider.notifier)
        .fetchFeed(
          mode: ref.read(connectionModeProvider),
          forceRefresh: forceRefresh,
        );
  }

  Future<void> _refresh() => _fetchData(forceRefresh: true);

  /// Filters live in the database and are read by the RPC, so the save has to
  /// land before the refetch — and the refetch has to bypass the cache, or
  /// changing a filter would appear to do nothing.
  Future<void> _openFilters() async {
    await NavigationUtils.navigateToWithSlide(context, const FilterScreen());
    await ref.read(filterProvider.notifier).flush();
    if (mounted) await _refresh();
  }

  /// The grid shares this page's interaction map, so a swipe made over there
  /// is already reflected here — nothing to merge on the way back.
  Future<void> _openCategory(
    String emoji,
    String title,
    List<MatchProfile> users,
  ) async {
    await stopVoice();
    if (!mounted) return;

    await NavigationUtils.navigateToWithSlide(
      context,
      DiscoveryCategoryScreen(
        title: title,
        emoji: emoji,
        users: users,
        interactions: userInteractions,
      ),
    );

    if (mounted) setState(() {});
  }

  void _openPeopleTab() => Navigator.pushAndRemoveUntil(
    context,
    PageRouteBuilder(
      pageBuilder: (_, _, _) => const PeopleScreen(),
      transitionDuration: Duration.zero,
      reverseTransitionDuration: Duration.zero,
    ),
    (route) => false,
  );

  // ------------------------------------------------------------------ build
  @override
  Widget build(BuildContext context) {
    ref.listen(connectionModeProvider, (previous, next) {
      if (previous != next) _fetchData();
    });

    final state = ref.watch(discoveryLandingProvider);

    return AppLayout(
      showFooter: true,
      selectedIndex: 1,
      appBar: _appBar(),
      child: Container(
        color: Colors.white,
        child: state.when(
          skipLoadingOnReload: true,
          data: _buildContent,
          loading: () => const DiscoveryFeedSkeleton(),
          error: (err, _) => DiscoveryFeedError(error: err, onRetry: _refresh),
        ),
      ),
    );
  }

  PreferredSizeWidget _appBar() {
    final theme = Theme.of(context);
    final isDating = ref.watch(connectionModeProvider).toLowerCase() == 'date';

    return AppBar(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: Icon(Icons.more_vert, color: theme.colorScheme.onSurface),
        onPressed: () => NavigationUtils.navigateToWithSlide(
          context,
          const ConnectionTypeScreen(),
        ),
      ),
      title: Text(
        l10n.discover,
        style: TextStyle(
          color: theme.colorScheme.onSurface,
          fontSize: 22,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.tune_rounded, color: theme.colorScheme.onSurface),
          tooltip: isDating ? l10n.datingPreference : l10n.bffPreference,
          onPressed: _openFilters,
        ),
      ],
    );
  }

  Widget _buildContent(DiscoveryLandingData data) {
    final sections = [
      for (final s in _sections)
        if (data.feeds[s.key]?.isNotEmpty == true)
          (emoji: s.emoji, title: _titleFor(s.key), users: data.feeds[s.key]!),
    ];

    if (sections.isEmpty) {
      return DiscoveryEmptyFeed(
        onRefresh: _refresh,
        onSeeMorePeople: _openPeopleTab,
        onAdjustFilters: _openFilters,
      );
    }

    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView.builder(
        // Without this the list is only scrollable once it overflows, so on a
        // short feed the pull-to-refresh gesture did nothing at all.
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 28),
        itemCount: sections.length,
        itemBuilder: (context, i) {
          final s = sections[i];
          return DiscoveryCarousel(
            emoji: s.emoji,
            title: s.title,
            users: s.users,
            interactionFor: interactionFor,
            isPlaying: isPlaying,
            onTap: openProfile,
            onUndo: undo,
            onVoiceTap: toggleVoice,
            onSeeAll: () => _openCategory(s.emoji, s.title, s.users),
          );
        },
      ),
    );
  }

  String _titleFor(String key) => switch (key) {
    'top_picks' => l10n.topPicksForYou,
    'nearby' => l10n.nearby,
    'shared_interests' => l10n.sharedInterests,
    'new_faces' => l10n.newFaces,
    _ => l10n.recentlyActive,
  };
}
