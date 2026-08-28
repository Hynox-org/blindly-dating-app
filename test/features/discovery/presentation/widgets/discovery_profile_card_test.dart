import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:blindly_dating_app/features/discovery/presentation/widgets/discovery_profile_card.dart';
import 'package:blindly_dating_app/features/matching/domain/models/match_profile.dart';

import '../../discovery_test_helpers.dart';

void main() {
  int taps = 0, undos = 0, voiceTaps = 0;

  setUp(() => taps = undos = voiceTaps = 0);

  Future<void> pumpCard(
    WidgetTester tester, {
    required MatchProfile p,
    String interaction = 'none',
    bool isPlaying = false,
  }) {
    return tester.pumpWidget(
      wrap(
        SizedBox(
          width: 158,
          height: 244,
          child: DiscoveryProfileCard(
            profile: p,
            interaction: interaction,
            isPlaying: isPlaying,
            onTap: () => taps++,
            onUndo: () => undos++,
            onVoiceTap: () => voiceTaps++,
          ),
        ),
      ),
    );
  }

  testWidgets('shows name, age and distance', (tester) async {
    await pumpCard(tester, p: profile(name: 'Ana', age: 27, distanceKm: 3.14));

    expect(find.text('Ana, 27'), findsOneWidget);
    expect(find.text('3.1 km away'), findsOneWidget);
  });

  testWidgets('falls back to an initial when there is no photo', (
    tester,
  ) async {
    await pumpCard(tester, p: profile(name: 'ana'));

    expect(find.text('A'), findsOneWidget);
  });

  testWidgets('falls back to ? for a blank name', (tester) async {
    await pumpCard(tester, p: profile(name: ''));

    expect(find.text('?'), findsOneWidget);
  });

  testWidgets('draws the heart for a like', (tester) async {
    await pumpCard(tester, p: profile(), interaction: 'liked');

    expect(find.byIcon(Icons.favorite), findsOneWidget);
  });

  testWidgets('draws the heart for a super like too', (tester) async {
    await pumpCard(tester, p: profile(), interaction: 'super_liked');

    expect(find.byIcon(Icons.favorite), findsOneWidget);
  });

  testWidgets('no heart when there is no interaction', (tester) async {
    await pumpCard(tester, p: profile(), interaction: 'none');

    expect(find.byIcon(Icons.favorite), findsNothing);
  });

  testWidgets('a pass shows the undo overlay and calls back', (tester) async {
    await pumpCard(tester, p: profile(), interaction: 'passed');

    expect(find.byIcon(Icons.undo_rounded), findsOneWidget);
    await tester.tap(find.byIcon(Icons.undo_rounded));
    expect(undos, 1);
  });

  testWidgets('no undo overlay for a like', (tester) async {
    await pumpCard(tester, p: profile(), interaction: 'liked');

    expect(find.byIcon(Icons.undo_rounded), findsNothing);
  });

  testWidgets('tapping the card opens the profile', (tester) async {
    await pumpCard(tester, p: profile());

    await tester.tap(find.byType(DiscoveryProfileCard));
    expect(taps, 1);
  });

  testWidgets('the verified badge follows the flag', (tester) async {
    await pumpCard(tester, p: profile(isVerified: true));
    expect(find.byIcon(Icons.verified_rounded), findsOneWidget);

    await pumpCard(tester, p: profile(isVerified: false));
    expect(find.byIcon(Icons.verified_rounded), findsNothing);
  });

  testWidgets('the trust chip only appears above zero', (tester) async {
    await pumpCard(tester, p: profile(trustScore: 82));
    expect(find.text('82%'), findsOneWidget);

    await pumpCard(tester, p: profile(trustScore: 0));
    expect(find.byIcon(Icons.shield_rounded), findsNothing);
  });

  testWidgets('no voice button without a voice intro', (tester) async {
    await pumpCard(tester, p: profile());

    expect(find.byIcon(Icons.graphic_eq_rounded), findsNothing);
  });

  testWidgets('the voice button toggles icon and calls back', (tester) async {
    final p = profile(voiceIntroUrl: 'https://x/voice.m4a');

    await pumpCard(tester, p: p);
    expect(find.byIcon(Icons.graphic_eq_rounded), findsOneWidget);
    await tester.tap(find.byIcon(Icons.graphic_eq_rounded));
    expect(voiceTaps, 1);

    await pumpCard(tester, p: p, isPlaying: true);
    expect(find.byIcon(Icons.stop_rounded), findsOneWidget);
  });

  testWidgets('a long name is ellipsised, not overflowed', (tester) async {
    await pumpCard(tester, p: profile(name: 'Anastasia' * 6));

    expect(tester.takeException(), isNull);
  });
}
