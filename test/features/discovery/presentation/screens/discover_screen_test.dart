import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:blindly_dating_app/core/providers/connection_mode_provider.dart';
import 'package:blindly_dating_app/features/discovery/domain/models/discovery_landing_data.dart';
import 'package:blindly_dating_app/features/discovery/presentation/screens/discover_screen.dart';
import 'package:blindly_dating_app/features/discovery/presentation/widgets/discovery_profile_card.dart';
import 'package:blindly_dating_app/features/discovery/repository/discovery_feed_repository.dart';
import 'package:blindly_dating_app/features/matching/domain/models/match_profile.dart';
import 'package:blindly_dating_app/features/matching/repository/matching_repository.dart';

import '../../discovery_test_helpers.dart';

class MockFeedRepo extends Mock implements DiscoveryFeedRepository {}

class MockMatchingRepo extends Mock implements MatchingRepository {}

void main() {
  late MockFeedRepo repo;

  setUp(() => repo = MockFeedRepo());

  /// The real screen, with only the two things it cannot reach in a test
  /// (the Supabase-backed feed and mode) swapped out.
  /// The real screen, with only the two things it cannot reach in a test
  /// (the Supabase-backed feed and mode) swapped out.
  Future<void> pumpScreen(WidgetTester tester, {String mode = 'Date'}) {
    useTallView(tester, height: 2400);

    return tester.pumpWidget(
      wrap(
        const DiscoverScreen(),
        bare: true,
        overrides: [
          discoveryFeedRepositoryProvider.overrideWithValue(repo),
          connectionModeProvider.overrideWith(
            (ref) =>
                ConnectionModeNotifier(MockMatchingRepo(), null)..state = mode,
          ),
        ],
      ),
    );
  }

  void answerWith(Map<String, List<MatchProfile>> feeds) {
    when(
      () => repo.getDiscoveryFeed(mode: any(named: 'mode')),
    ).thenAnswer((_) async => DiscoveryLandingData(feeds: feeds));
  }

  testWidgets('shows the skeleton while the feed is in flight', (tester) async {
    final gate = Completer<DiscoveryLandingData>();
    when(
      () => repo.getDiscoveryFeed(mode: any(named: 'mode')),
    ).thenAnswer((_) => gate.future);

    await pumpScreen(tester);
    await tester.pump(); // let the post-frame fetch start

    expect(find.byType(DiscoveryProfileCard), findsNothing);
    expect(find.text('Discover'), findsWidgets); // app bar + nav label

    gate.complete(DiscoveryLandingData(feeds: {}));
    await tester.pumpAndSettle();
  });

  testWidgets('the screen asks for the lower-cased current mode', (
    tester,
  ) async {
    answerWith({});
    await pumpScreen(tester, mode: 'Bff');
    await tester.pumpAndSettle();

    verify(() => repo.getDiscoveryFeed(mode: 'bff')).called(1);
  });

  testWidgets('renders sections in the fixed order, not the map order', (
    tester,
  ) async {
    answerWith({
      // Deliberately reversed relative to how the page should read.
      'recently_active': profiles(1, prefix: 'r'),
      'nearby': profiles(1, prefix: 'n'),
      'top_picks': profiles(1, prefix: 't'),
    });

    await pumpScreen(tester);
    await tester.pumpAndSettle();

    final ys = [
      for (final t in ['Top Picks For You', 'Nearby', 'Recently Active'])
        tester.getTopLeft(find.text(t)).dy,
    ];
    expect(ys, orderedEquals([...ys]..sort()));
  });

  testWidgets('an unknown category is not rendered', (tester) async {
    answerWith({
      'nearby': profiles(1, prefix: 'n'),
      'mystery_category': profiles(1, prefix: 'm'),
    });

    await pumpScreen(tester);
    await tester.pumpAndSettle();

    expect(find.text('Nearby'), findsOneWidget);
    expect(find.text('M0, 27'), findsNothing);
  });

  testWidgets('an empty category is skipped', (tester) async {
    answerWith({'nearby': const [], 'top_picks': profiles(1, prefix: 't')});

    await pumpScreen(tester);
    await tester.pumpAndSettle();

    expect(find.text('Nearby'), findsNothing);
    expect(find.text('Top Picks For You'), findsOneWidget);
  });

  testWidgets('See all appears only above four profiles', (tester) async {
    answerWith({'nearby': profiles(4, prefix: 'n')});
    await pumpScreen(tester);
    await tester.pumpAndSettle();

    expect(find.text('See all'), findsNothing);
    expect(find.text('4'), findsOneWidget); // the count chip instead
  });

  testWidgets('See all is offered once there are more than four', (
    tester,
  ) async {
    answerWith({'nearby': profiles(5, prefix: 'n')});
    await pumpScreen(tester);
    await tester.pumpAndSettle();

    expect(find.text('See all'), findsOneWidget);
  });

  testWidgets('an empty feed shows the empty state, not a blank page', (
    tester,
  ) async {
    answerWith({});
    await pumpScreen(tester);
    await tester.pumpAndSettle();

    expect(find.textContaining('reached the end'), findsOneWidget);
    expect(find.byType(DiscoveryProfileCard), findsNothing);
  });

  testWidgets('a generic failure offers Retry and retries', (tester) async {
    when(
      () => repo.getDiscoveryFeed(mode: any(named: 'mode')),
    ).thenThrow(Exception('network down'));

    await pumpScreen(tester);
    await tester.pumpAndSettle();

    expect(find.text('Retry'), findsOneWidget);

    answerWith({'nearby': profiles(1, prefix: 'n')});
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();

    expect(find.text('Nearby'), findsOneWidget);
  });

  testWidgets('a missing location sends the user to settings, not Retry', (
    tester,
  ) async {
    when(
      () => repo.getDiscoveryFeed(mode: any(named: 'mode')),
    ).thenThrow(Exception('No location set for this profile'));

    await pumpScreen(tester);
    await tester.pumpAndSettle();

    expect(find.text('Retry'), findsNothing);
    expect(find.byIcon(Icons.location_off_rounded), findsOneWidget);
  });

  testWidgets('pull to refresh forces a refetch past the cache', (
    tester,
  ) async {
    answerWith({'nearby': profiles(1, prefix: 'n')});
    await pumpScreen(tester);
    await tester.pumpAndSettle();

    // A real pull: many small moves, then release. A single-step drag never
    // crosses the indicator's threshold.
    final gesture = await tester.startGesture(
      tester.getCenter(find.text('Nearby')),
    );
    // RefreshIndicator arms at 25% of the viewport height.
    for (var i = 0; i < 40; i++) {
      await gesture.moveBy(const Offset(0, 25));
      await tester.pump();
    }
    await gesture.up();
    await tester.pumpAndSettle();

    verify(() => repo.getDiscoveryFeed(mode: 'date')).called(2);
  });

  testWidgets('a mode change refetches the feed', (tester) async {
    answerWith({'nearby': profiles(1, prefix: 'n')});
    await pumpScreen(tester);
    await tester.pumpAndSettle();

    final ctx = tester.element(find.byType(DiscoverScreen));
    ProviderScope.containerOf(ctx).read(connectionModeProvider.notifier).state =
        'Bff';
    await tester.pumpAndSettle();

    verify(() => repo.getDiscoveryFeed(mode: 'bff')).called(1);
  });
}
