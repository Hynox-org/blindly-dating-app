import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:blindly_dating_app/features/discovery/presentation/screens/discovery_profile_detail_screen.dart';
import 'package:blindly_dating_app/features/matching/domain/models/match_profile.dart';
import 'package:blindly_dating_app/features/matching/repository/swipe_repository.dart';

import '../../discovery_test_helpers.dart';

class MockSwipeRepo extends Mock implements SwipeRepository {}

/// [ProfileSwipeCard] keeps an animation running, so pumpAndSettle never
/// returns on this screen. Pump a fixed number of frames instead.
Future<void> settle(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
  await tester.pump(const Duration(milliseconds: 400));
}

/// The action row sits below the fold of the card's own scroll view, so every
/// tap has to bring it into view first.
Future<void> tapAt(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await settle(tester);
  await tester.tap(finder);
}

void main() {
  late MockSwipeRepo swipes;

  setUp(() {
    swipes = MockSwipeRepo();
    when(
      () => swipes.recordSwipe(
        targetProfileId: any(named: 'targetProfileId'),
        action: any(named: 'action'),
      ),
    ).thenAnswer((_) async => false);
    when(
      () =>
          swipes.undoLastSwipe(targetProfileId: any(named: 'targetProfileId')),
    ).thenAnswer((_) async => true);
  });

  /// Pushes the detail screen onto a route and returns a reader for whatever
  /// it eventually pops — that value is the whole contract between this screen
  /// and the Discover page.
  Future<String? Function()> pumpDetail(
    WidgetTester tester, {
    required MatchProfile user,
    String initialState = 'none',
  }) async {
    // The card's action buttons sit below the default 800x600 test window.
    useTallView(tester);

    String? popped;
    var didPop = false;
    final navKey = GlobalKey<NavigatorState>();

    await tester.pumpWidget(
      wrap(
        const Scaffold(),
        bare: true,
        navigatorKey: navKey,
        overrides: [swipeRepositoryProvider.overrideWithValue(swipes)],
      ),
    );

    unawaited(
      navKey.currentState!
          .push<String>(
            MaterialPageRoute(
              builder: (_) => DiscoveryProfileDetailScreen(
                user: user,
                initialState: initialState,
              ),
            ),
          )
          .then((r) {
            didPop = true;
            popped = r;
          }),
    );
    await settle(tester);

    return () => didPop ? (popped ?? 'null') : 'still-open';
  }

  testWidgets('an un-swiped profile is offered Like and Not for me', (
    tester,
  ) async {
    await pumpDetail(tester, user: profile());

    expect(find.text('Like'), findsOneWidget);
    expect(find.text('Not for me'), findsOneWidget);
  });

  testWidgets('someone who already liked you gets Match / Pass', (
    tester,
  ) async {
    final user = profile().copyWith(relationship: RelationshipState.likedMe);
    await pumpDetail(tester, user: user);

    expect(find.text('Match'), findsOneWidget);
    expect(find.text('Like'), findsNothing);
  });

  testWidgets('a liked profile shows the liked banner, not the buttons', (
    tester,
  ) async {
    await pumpDetail(tester, user: profile(), initialState: 'liked');

    expect(find.text('Like'), findsNothing);
    expect(find.byIcon(Icons.undo), findsNothing);
  });

  testWidgets('a super-liked profile counts as liked, not un-swiped', (
    tester,
  ) async {
    await pumpDetail(tester, user: profile(), initialState: 'super_liked');

    expect(find.text('Like'), findsNothing);
    expect(find.text('Not for me'), findsNothing);
  });

  testWidgets('a passed profile shows undo instead', (tester) async {
    await pumpDetail(tester, user: profile(), initialState: 'passed');

    expect(find.byIcon(Icons.undo), findsOneWidget);
    expect(find.text('Like'), findsNothing);
  });

  testWidgets('liking records the swipe and pops liked', (tester) async {
    final result = await pumpDetail(tester, user: profile());

    await tapAt(tester, find.text('Like'));
    await settle(tester);

    verify(
      () => swipes.recordSwipe(targetProfileId: 'p1', action: 'like'),
    ).called(1);
    expect(result(), 'liked');
  });

  testWidgets('passing pops passed', (tester) async {
    final result = await pumpDetail(tester, user: profile());

    await tapAt(tester, find.text('Not for me'));
    await settle(tester);

    verify(
      () => swipes.recordSwipe(targetProfileId: 'p1', action: 'pass'),
    ).called(1);
    expect(result(), 'passed');
  });

  testWidgets('a successful undo pops none', (tester) async {
    final result = await pumpDetail(
      tester,
      user: profile(),
      initialState: 'passed',
    );

    await tapAt(tester, find.byIcon(Icons.undo));
    await settle(tester);

    expect(result(), 'none');
  });

  testWidgets('a failed swipe keeps the screen open and warns', (tester) async {
    when(
      () => swipes.recordSwipe(
        targetProfileId: any(named: 'targetProfileId'),
        action: any(named: 'action'),
      ),
    ).thenThrow(Exception('offline'));

    await pumpDetail(tester, user: profile());
    await tapAt(tester, find.text('Like'));
    await settle(tester);

    expect(find.text('Something went wrong'), findsOneWidget);
    expect(find.text('Like'), findsOneWidget); // still here, still tappable
  });

  testWidgets('a double tap only records one swipe', (tester) async {
    final gate = Completer<bool>();
    when(
      () => swipes.recordSwipe(
        targetProfileId: any(named: 'targetProfileId'),
        action: any(named: 'action'),
      ),
    ).thenAnswer((_) => gate.future);

    await pumpDetail(tester, user: profile());

    await tapAt(tester, find.text('Like'));
    await tester.pump();
    await tapAt(tester, find.text('Like'));
    await tester.pump();

    gate.complete(false);
    await settle(tester);

    verify(
      () => swipes.recordSwipe(
        targetProfileId: any(named: 'targetProfileId'),
        action: any(named: 'action'),
      ),
    ).called(1);
  });

  testWidgets('undo names the profile it is undoing', (tester) async {
    await pumpDetail(tester, user: profile(), initialState: 'passed');

    await tapAt(tester, find.byIcon(Icons.undo));
    await settle(tester);

    verify(() => swipes.undoLastSwipe(targetProfileId: 'p1')).called(1);
  });

  testWidgets('a rejected undo leaves the screen open and warns', (
    tester,
  ) async {
    when(
      () =>
          swipes.undoLastSwipe(targetProfileId: any(named: 'targetProfileId')),
    ).thenAnswer((_) async => false);

    await pumpDetail(tester, user: profile(), initialState: 'passed');
    await tapAt(tester, find.byIcon(Icons.undo));
    await settle(tester);

    expect(find.text('Something went wrong'), findsOneWidget);
    expect(find.byIcon(Icons.undo), findsOneWidget);
  });

  testWidgets('closing pops null so the caller keeps its own state', (
    tester,
  ) async {
    final result = await pumpDetail(tester, user: profile());

    await tapAt(tester, find.byIcon(Icons.close));
    await settle(tester);

    expect(result(), 'null');
  });

  testWidgets('a profile with no photo still renders', (tester) async {
    await pumpDetail(
      tester,
      user: profile(name: 'Ana', imageUrls: const []),
    );

    expect(tester.takeException(), isNull);
    expect(find.textContaining('Ana'), findsWidgets);
  });
}
