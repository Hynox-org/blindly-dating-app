import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:blindly_dating_app/features/matching/repository/swipe_repository.dart';

import 'package:blindly_dating_app/features/discovery/presentation/screens/discovery_category_screen.dart';
import 'package:blindly_dating_app/features/discovery/presentation/widgets/discovery_profile_card.dart';

import '../../discovery_test_helpers.dart';

class MockSwipeRepo extends Mock implements SwipeRepository {}

void main() {
  testWidgets('renders the title, emoji and one card per profile', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(
        DiscoveryCategoryScreen(
          title: 'Nearby',
          emoji: '📍',
          users: profiles(6),
          interactions: const {},
        ),
      ),
    );

    expect(find.text('Nearby'), findsOneWidget);
    expect(find.text('📍'), findsOneWidget);
    // The grid is lazy, so assert the ends rather than a count.
    expect(find.text('P0, 27'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('P5, 27'), 300);
    expect(find.text('P5, 27'), findsOneWidget);
  });

  testWidgets('an interaction passed in is already drawn on the card', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(
        DiscoveryCategoryScreen(
          title: 'Nearby',
          emoji: '📍',
          users: profiles(2),
          interactions: const {'p0': 'liked'},
        ),
      ),
    );

    expect(find.byIcon(Icons.favorite), findsOneWidget);
  });

  testWidgets("the server's swipe_action is used when the session has none", (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(
        DiscoveryCategoryScreen(
          title: 'Nearby',
          emoji: '📍',
          users: [profile(id: 'x', swipeAction: 'passed')],
          interactions: const {},
        ),
      ),
    );

    expect(find.byIcon(Icons.undo_rounded), findsOneWidget);
  });

  testWidgets('a session action wins over the server one', (tester) async {
    await tester.pumpWidget(
      wrap(
        DiscoveryCategoryScreen(
          title: 'Nearby',
          emoji: '📍',
          users: [profile(id: 'x', swipeAction: 'passed')],
          interactions: const {'x': 'none'},
        ),
      ),
    );

    expect(find.byIcon(Icons.undo_rounded), findsNothing);
  });

  testWidgets('an empty category renders nothing but the header', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(
        DiscoveryCategoryScreen(
          title: 'Nearby',
          emoji: '📍',
          users: const [],
          interactions: const {},
        ),
      ),
    );

    expect(find.byType(DiscoveryProfileCard), findsNothing);
    expect(tester.takeException(), isNull);
  });

  group('undo', () {
    late MockSwipeRepo swipes;

    setUp(() => swipes = MockSwipeRepo());

    /// The map is the Discover page's own, handed over by reference — an undo
    /// here has to be visible there without anything being merged back.
    Future<void> pumpWithSwipes(
      WidgetTester tester,
      Map<String, String> interactions,
    ) {
      return tester.pumpWidget(
        wrap(
          DiscoveryCategoryScreen(
            title: 'Nearby',
            emoji: '📍',
            users: [profile(id: 'x')],
            interactions: interactions,
          ),
          bare: true,
          overrides: [swipeRepositoryProvider.overrideWithValue(swipes)],
        ),
      );
    }

    testWidgets('clears the overlay and writes back into the shared map', (
      tester,
    ) async {
      when(
        () => swipes.undoLastSwipe(
          targetProfileId: any(named: 'targetProfileId'),
        ),
      ).thenAnswer((_) async => true);

      final interactions = {'x': 'passed'};
      await pumpWithSwipes(tester, interactions);

      await tester.tap(find.byIcon(Icons.undo_rounded));
      await tester.pumpAndSettle();

      verify(() => swipes.undoLastSwipe(targetProfileId: 'x')).called(1);
      expect(interactions['x'], 'none');
      expect(find.byIcon(Icons.undo_rounded), findsNothing);
    });

    testWidgets('a rejected undo leaves the card alone and warns', (
      tester,
    ) async {
      when(
        () => swipes.undoLastSwipe(
          targetProfileId: any(named: 'targetProfileId'),
        ),
      ).thenAnswer((_) async => false);

      final interactions = {'x': 'passed'};
      await pumpWithSwipes(tester, interactions);

      await tester.tap(find.byIcon(Icons.undo_rounded));
      await tester.pumpAndSettle();

      expect(interactions['x'], 'passed');
      expect(find.byIcon(Icons.undo_rounded), findsOneWidget);
      expect(find.text('Something went wrong'), findsOneWidget);
    });

    testWidgets('a thrown undo is caught, not crashed on', (tester) async {
      when(
        () => swipes.undoLastSwipe(
          targetProfileId: any(named: 'targetProfileId'),
        ),
      ).thenThrow(Exception('offline'));

      await pumpWithSwipes(tester, {'x': 'passed'});

      await tester.tap(find.byIcon(Icons.undo_rounded));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Something went wrong'), findsOneWidget);
    });
  });
}
