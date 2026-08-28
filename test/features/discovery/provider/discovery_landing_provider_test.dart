import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:blindly_dating_app/features/discovery/domain/models/discovery_landing_data.dart';
import 'package:blindly_dating_app/features/discovery/provider/discovery_landing_provider.dart';
import 'package:blindly_dating_app/features/discovery/repository/discovery_feed_repository.dart';

import '../discovery_test_helpers.dart';

class MockRepo extends Mock implements DiscoveryFeedRepository {}

DiscoveryLandingData feedFor(String name) => DiscoveryLandingData(
  feeds: {
    'nearby': [profile(id: name, name: name)],
  },
);

void main() {
  late MockRepo repo;
  late DiscoveryLandingNotifier notifier;

  setUp(() {
    repo = MockRepo();
    notifier = DiscoveryLandingNotifier(repo);
  });

  tearDown(() {
    if (notifier.mounted) notifier.dispose();
  });

  void answerWith(DiscoveryLandingData data) {
    when(
      () => repo.getDiscoveryFeed(mode: any(named: 'mode')),
    ).thenAnswer((_) async => data);
  }

  test('starts loading and ends with the fetched data', () async {
    answerWith(feedFor('a'));
    expect(notifier.state, isA<AsyncLoading<DiscoveryLandingData>>());

    await notifier.fetchFeed(mode: 'date');

    expect(notifier.state.value!.feeds['nearby']!.single.profileId, 'a');
  });

  test('lower-cases the mode before it reaches the repository', () async {
    answerWith(feedFor('a'));

    await notifier.fetchFeed(mode: 'Date');

    verify(() => repo.getDiscoveryFeed(mode: 'date')).called(1);
  });

  test('defaults to date when no mode is given', () async {
    answerWith(feedFor('a'));

    await notifier.fetchFeed();

    verify(() => repo.getDiscoveryFeed(mode: 'date')).called(1);
  });

  test('a second visit in the same mode is served from cache', () async {
    answerWith(feedFor('a'));

    await notifier.fetchFeed(mode: 'Date');
    await notifier.fetchFeed(mode: 'date'); // same mode, different casing

    verify(() => repo.getDiscoveryFeed(mode: 'date')).called(1);
  });

  test('forceRefresh bypasses the cache', () async {
    answerWith(feedFor('a'));

    await notifier.fetchFeed(mode: 'date');
    await notifier.fetchFeed(mode: 'date', forceRefresh: true);

    verify(() => repo.getDiscoveryFeed(mode: 'date')).called(2);
  });

  test('a mode change always refetches', () async {
    answerWith(feedFor('a'));

    await notifier.fetchFeed(mode: 'date');
    await notifier.fetchFeed(mode: 'bff');

    verify(() => repo.getDiscoveryFeed(mode: 'date')).called(1);
    verify(() => repo.getDiscoveryFeed(mode: 'bff')).called(1);
  });

  test('a mode change clears the old feed while the new one loads', () async {
    answerWith(feedFor('a'));
    await notifier.fetchFeed(mode: 'date');

    final gate = Completer<DiscoveryLandingData>();
    when(
      () => repo.getDiscoveryFeed(mode: 'bff'),
    ).thenAnswer((_) => gate.future);

    final pending = notifier.fetchFeed(mode: 'bff');
    // Not still showing the date feed under a bff header.
    expect(notifier.state, isA<AsyncLoading<DiscoveryLandingData>>());

    gate.complete(feedFor('b'));
    await pending;
    expect(notifier.state.value!.feeds['nearby']!.single.profileId, 'b');
  });

  test('a slow earlier response cannot overwrite a newer one', () async {
    final slow = Completer<DiscoveryLandingData>();
    when(
      () => repo.getDiscoveryFeed(mode: 'date'),
    ).thenAnswer((_) => slow.future);
    when(
      () => repo.getDiscoveryFeed(mode: 'bff'),
    ).thenAnswer((_) async => feedFor('bff'));

    final first = notifier.fetchFeed(mode: 'date');
    final second = notifier.fetchFeed(mode: 'bff');

    await second;
    slow.complete(feedFor('date'));
    await first;

    expect(notifier.state.value!.feeds['nearby']!.single.profileId, 'bff');
  });

  test('a stale failure cannot clobber a newer success', () async {
    final slow = Completer<DiscoveryLandingData>();
    when(
      () => repo.getDiscoveryFeed(mode: 'date'),
    ).thenAnswer((_) => slow.future);
    when(
      () => repo.getDiscoveryFeed(mode: 'bff'),
    ).thenAnswer((_) async => feedFor('bff'));

    final first = notifier.fetchFeed(mode: 'date');
    await notifier.fetchFeed(mode: 'bff');

    slow.completeError(Exception('boom'));
    await first;

    expect(notifier.state.hasError, isFalse);
    expect(notifier.state.value!.feeds['nearby']!.single.profileId, 'bff');
  });

  test('a failure surfaces as an error state', () async {
    when(
      () => repo.getDiscoveryFeed(mode: any(named: 'mode')),
    ).thenThrow(Exception('no location set'));

    await notifier.fetchFeed(mode: 'date');

    expect(notifier.state.hasError, isTrue);
  });

  test('a failed fetch is not cached — the next visit retries', () async {
    when(
      () => repo.getDiscoveryFeed(mode: any(named: 'mode')),
    ).thenThrow(Exception('boom'));

    await notifier.fetchFeed(mode: 'date');
    await notifier.fetchFeed(mode: 'date');

    verify(() => repo.getDiscoveryFeed(mode: 'date')).called(2);
  });

  test('a response arriving after dispose is dropped', () async {
    final gate = Completer<DiscoveryLandingData>();
    when(
      () => repo.getDiscoveryFeed(mode: any(named: 'mode')),
    ).thenAnswer((_) => gate.future);

    final pending = notifier.fetchFeed(mode: 'date');
    notifier.dispose();
    gate.complete(feedFor('a'));

    await expectLater(pending, completes);
  });

  test('the riverpod provider wires the repository through', () async {
    answerWith(feedFor('a'));
    final container = ProviderContainer(
      overrides: [discoveryFeedRepositoryProvider.overrideWithValue(repo)],
    );
    addTearDown(container.dispose);

    await container.read(discoveryLandingProvider.notifier).fetchFeed();

    expect(container.read(discoveryLandingProvider).value, isNotNull);
  });
}
