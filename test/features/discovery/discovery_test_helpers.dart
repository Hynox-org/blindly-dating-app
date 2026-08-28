import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:blindly_dating_app/l10n/app_localizations.dart';
import 'package:blindly_dating_app/features/matching/domain/models/match_profile.dart';

/// Only the fields the Discover surfaces actually read; everything else takes
/// the model's default so a new field never breaks these tests.
MatchProfile profile({
  String id = 'p1',
  String name = 'Ana',
  int age = 27,
  double distanceKm = 3.14,
  List<String> imageUrls = const [],
  String? swipeAction,
  String? voiceIntroUrl,
  bool isVerified = false,
  int trustScore = 0,
}) {
  return MatchProfile(
    profileId: id,
    displayName: name,
    age: age,
    distanceKm: distanceKm,
    bio: '',
    modeId: 'date',
    imageUrls: imageUrls,
    gender: 'Female',
    swipeAction: swipeAction,
    voiceIntroUrl: voiceIntroUrl,
    isVerified: isVerified,
    trustScore: trustScore,
  );
}

/// Wraps a widget in the minimum the Discover surfaces need: a Riverpod scope,
/// a Material ancestor and the generated localizations.
///
/// [bare] skips the Scaffold for widgets that bring their own; [navigatorKey]
/// gives a test a handle to push routes it wants the pop result from.
Widget wrap(
  Widget child, {
  List<Override> overrides = const [],
  GlobalKey<NavigatorState>? navigatorKey,
  bool bare = false,
}) {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp(
      navigatorKey: navigatorKey,
      locale: const Locale('en'),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: bare ? child : Scaffold(body: child),
    ),
  );
}

/// Sizes the test window so a surface taller than the default 800x600 is fully
/// laid out — otherwise lazy lists never build their lower half and ordering
/// assertions pass on widgets that were never there.
void useTallView(WidgetTester tester, {double height = 1800}) {
  tester.view.physicalSize = Size(1000, height);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
}

/// A [MatchProfile] list of [count] distinct profiles.
List<MatchProfile> profiles(int count, {String prefix = 'p'}) => [
  for (var i = 0; i < count; i++)
    profile(id: '$prefix$i', name: '$prefix$i'.toUpperCase()),
];
