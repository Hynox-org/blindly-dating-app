import 'package:flutter_test/flutter_test.dart';

import 'package:blindly_dating_app/features/discovery/repository/discovery_feed_repository.dart';
import 'package:blindly_dating_app/features/matching/domain/models/match_profile.dart';

import '../discovery_test_helpers.dart';

void main() {
  group('parseCategoryRows', () {
    test('groups by category and keeps the server order', () {
      final result = parseCategoryRows([
        {'category': 'nearby', 'profile_id': 'a'},
        {'category': 'top_picks', 'profile_id': 'b'},
        {'category': 'nearby', 'profile_id': 'c'},
      ]);

      expect(result, {
        'nearby': ['a', 'c'],
        'top_picks': ['b'],
      });
    });

    test('returns empty for null and empty input', () {
      expect(parseCategoryRows(null), isEmpty);
      expect(parseCategoryRows([]), isEmpty);
    });

    test('drops malformed rows instead of throwing', () {
      final result = parseCategoryRows([
        {'category': 'nearby', 'profile_id': 'a'},
        {'category': null, 'profile_id': 'b'},
        {'category': 'nearby', 'profile_id': null},
        {'category': '', 'profile_id': 'c'},
        {'category': 'nearby', 'profile_id': ''},
        {'category': 'nearby', 'profile_id': 42},
        'not-a-row',
      ]);

      expect(result, {
        'nearby': ['a'],
      });
    });

    test('a profile may appear in several categories', () {
      final result = parseCategoryRows([
        {'category': 'nearby', 'profile_id': 'a'},
        {'category': 'new_faces', 'profile_id': 'a'},
      ]);

      expect(result, {
        'nearby': ['a'],
        'new_faces': ['a'],
      });
    });
  });

  group('assembleFeeds', () {
    final a = profile(id: 'a', name: 'Ana');
    final b = profile(id: 'b', name: 'Bea');
    final lookup = {'a': a, 'b': b};

    test('maps ids back to profiles in order', () {
      final feeds = assembleFeeds({
        'nearby': ['b', 'a'],
      }, lookup);

      expect(feeds['nearby']!.map((p) => p.profileId), ['b', 'a']);
    });

    test('skips ids with no hydrated profile', () {
      final feeds = assembleFeeds({
        'nearby': ['a', 'ghost'],
      }, lookup);

      expect(feeds['nearby']!.map((p) => p.profileId), ['a']);
    });

    test('drops a category left with nothing', () {
      final feeds = assembleFeeds({
        'nearby': ['ghost'],
        'top_picks': ['a'],
      }, lookup);

      expect(feeds.keys, ['top_picks']);
    });

    test('de-duplicates a profile listed twice in one category', () {
      final feeds = assembleFeeds({
        'nearby': ['a', 'a', 'b'],
      }, lookup);

      expect(feeds['nearby']!.map((p) => p.profileId), ['a', 'b']);
    });

    test('empty in, empty out', () {
      expect(assembleFeeds({}, lookup), isEmpty);
      expect(assembleFeeds({'nearby': <String>[]}, lookup), isEmpty);
    });

    test('the same profile can land in two categories', () {
      final feeds = assembleFeeds({
        'nearby': ['a'],
        'new_faces': ['a'],
      }, lookup);

      expect(feeds['nearby']!.single, isA<MatchProfile>());
      expect(feeds['new_faces']!.single.profileId, 'a');
    });
  });
}
