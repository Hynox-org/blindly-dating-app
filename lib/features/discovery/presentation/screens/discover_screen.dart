import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import 'package:blindly_dating_app/core/providers/connection_mode_provider.dart';
import 'package:blindly_dating_app/core/utils/navigation_utils.dart';
import 'package:blindly_dating_app/core/widgets/app_layout.dart';
import 'package:blindly_dating_app/features/discovery/domain/models/discovery_landing_data.dart';
import 'package:blindly_dating_app/features/discovery/presentation/discovery_card_actions.dart';
import 'package:blindly_dating_app/features/discovery/presentation/screens/discovery_category_screen.dart';
import 'package:blindly_dating_app/features/discovery/presentation/widgets/discovery_profile_card.dart';
import 'package:blindly_dating_app/features/discovery/provider/discovery_landing_provider.dart';
import 'package:blindly_dating_app/features/matching/domain/models/match_profile.dart';
import 'package:blindly_dating_app/features/matching/presentation/screens/connection_type_screen.dart';
import 'package:blindly_dating_app/features/matching/presentation/screens/filter_screen.dart';
import 'package:blindly_dating_app/features/matching/provider/filter_provider.dart';
import 'package:blindly_dating_app/features/people/people_screen.dart';

/// Carousel order is fixed here rather than taken from the feed map, so the
/// page reads the same every time regardless of which categories came back.
const _sections = <({String key, String emoji})>[
  (key: 'top_picks', emoji: '🔥'),
  (key: 'nearby', emoji: '📍'),
  (key: 'shared_interests', emoji: '🤝'),
  (key: 'new_faces', emoji: '👋'),
  (key: 'recently_active', emoji: '⏱️'),
];

const double _cardWidth = 158;
const double _cardHeight = 244;

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

  /// Filters live in the database and are read by the RPC, so the save has to
  /// land before the refetch — and the refetch has to bypass the 5-minute
  /// cache, or changing a filter would appear to do nothing.
  Future<void> _openFilters() async {
    await NavigationUtils.navigateToWithSlide(context, const FilterScreen());
    await ref.read(filterProvider.notifier).flush();
    if (mounted) await _fetchData(forceRefresh: true);
  }

  // ------------------------------------------------------------------ build
  @override
  Widget build(BuildContext context) {
    ref.listen(connectionModeProvider, (previous, next) {
      if (previous != next) _fetchData();
    });

    final theme = Theme.of(context);
    final state = ref.watch(discoveryLandingProvider);
    final isDating = ref.watch(connectionModeProvider).toLowerCase() == 'date';

    return AppLayout(
      showFooter: true,
      selectedIndex: 1,
      appBar: AppBar(
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
      ),
      child: Container(
        color: Colors.white,
        child: state.when(
          skipLoadingOnReload: true,
          data: _buildContent,
          loading: _buildSkeleton,
          error: (err, _) => _buildError(err),
        ),
      ),
    );
  }

  // ----------------------------------------------------------------- states
  /// A shaped placeholder rather than a bare spinner, so the page keeps its
  /// layout while the two RPCs land and nothing jumps when data arrives.
  Widget _buildSkeleton() {
    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      physics: const NeverScrollableScrollPhysics(),
      children: [
        for (var s = 0; s < 3; s++) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 26, 20, 14),
            child: _shimmerBox(width: 168, height: 22),
          ),
          SizedBox(
            height: _cardHeight,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 3,
              separatorBuilder: (_, _) => const SizedBox(width: 14),
              itemBuilder: (_, _) =>
                  _shimmerBox(width: _cardWidth, height: _cardHeight),
            ),
          ),
        ],
      ],
    );
  }

  Widget _shimmerBox({required double width, required double height}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(height > 40 ? 18 : 6),
      ),
    );
  }

  /// "No location set" is the one error a Retry cannot fix — the profile has
  /// no coordinates until the app records some, so send the user to settings.
  Widget _buildError(Object err) {
    final needsLocation = err.toString().toLowerCase().contains(
      'no location set',
    );
    final theme = Theme.of(context);

    return RefreshIndicator(
      onRefresh: () => _fetchData(forceRefresh: true),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 32),
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.18),
          Icon(
            needsLocation
                ? Icons.location_off_rounded
                : Icons.cloud_off_rounded,
            size: 56,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.35),
          ),
          const SizedBox(height: 20),
          Text(
            needsLocation ? l10n.locationRequiredTitle : l10n.somethingWentWrong,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: theme.colorScheme.onSurface,
            ),
          ),
          if (needsLocation) ...[
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
            onPressed: needsLocation
                ? Geolocator.openAppSettings
                : () => _fetchData(forceRefresh: true),
            style: FilledButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              minimumSize: const Size(double.infinity, 52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: Text(
              needsLocation ? l10n.settingsTitle : l10n.retry,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(DiscoveryLandingData data) {
    final sections = [
      for (final s in _sections)
        if (data.feeds[s.key]?.isNotEmpty == true)
          (emoji: s.emoji, title: _titleFor(s.key), users: data.feeds[s.key]!),
    ];

    if (sections.isEmpty) return _buildEmpty();

    return RefreshIndicator(
      onRefresh: () => _fetchData(forceRefresh: true),
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 28),
        itemCount: sections.length,
        itemBuilder: (context, i) {
          final s = sections[i];
          return _buildSection(s.emoji, s.title, s.users);
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

  Widget _buildEmpty() {
    final theme = Theme.of(context);

    return RefreshIndicator(
      onRefresh: () => _fetchData(forceRefresh: true),
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
                  onPressed: () => Navigator.pushAndRemoveUntil(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (_, _, _) => const PeopleScreen(),
                      transitionDuration: Duration.zero,
                      reverseTransitionDuration: Duration.zero,
                    ),
                    (route) => false,
                  ),
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
                // An empty feed is usually a filter that is too narrow, so put
                // the fix one tap away instead of on the other tab.
                TextButton(
                  onPressed: _openFilters,
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

  // --------------------------------------------------------------- sections
  Widget _buildSection(String emoji, String title, List<MatchProfile> users) {
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
              // Below four the carousel already shows everyone, so "See all"
              // would lead to the same faces in a taller box.
              if (users.length > 4)
                TextButton(
                  onPressed: () => _openCategory(emoji, title, users),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    l10n.seeAll,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 3,
                  ),
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
                ),
            ],
          ),
        ),
        SizedBox(
          height: _cardHeight,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            itemCount: users.length,
            separatorBuilder: (_, _) => const SizedBox(width: 14),
            itemBuilder: (context, i) {
              final user = users[i];
              return SizedBox(
                width: _cardWidth,
                child: DiscoveryProfileCard(
                  profile: user,
                  interaction: interactionFor(user),
                  isPlaying: isPlaying(user),
                  onTap: () => openProfile(user),
                  onUndo: () => undo(user),
                  onVoiceTap: () => toggleVoice(user),
                ),
              );
            },
          ),
        ),
      ],
    );
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
}
