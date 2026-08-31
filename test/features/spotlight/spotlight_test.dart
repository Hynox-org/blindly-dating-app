import 'package:flutter_test/flutter_test.dart';

import 'package:blindly_dating_app/features/matching/domain/models/match_profile.dart';
import 'package:blindly_dating_app/features/spotlight/presentation/spotlight_screen.dart';
import 'package:blindly_dating_app/features/spotlight/repository/spotlight_repository.dart';

/// The deck's own rules are covered in supabase/tests/spotlight_test.sql, where
/// they actually live. What can go wrong on this side is narrower: a column
/// that silently stops being read, and a countdown that formats badly.
void main() {
  group('MatchProfile.isSpotlight', () {
    Map<String, dynamic> row(Map<String, dynamic> extra) => {
      'profile_id': 'p1',
      'display_name': 'Test',
      'age': 30,
      'distance_km': 1.0,
      'bio': '',
      'mode_id': 'm1',
      'image_urls': <String>[],
      'gender': 'F',
      ...extra,
    };

    test('reads is_spotlight from the RPC row', () {
      expect(MatchProfile.fromJson(row({'is_spotlight': true})).isSpotlight,
          isTrue);
      expect(MatchProfile.fromJson(row({'is_spotlight': false})).isSpotlight,
          isFalse);
    });

    test('defaults to false when the column is absent', () {
      // hydrate_discovery_profiles does not return the flag, and the Likes
      // screen builds profiles from it. A missing column must read as "not
      // spotlighted", never as null blowing up the card.
      expect(MatchProfile.fromJson(row({})).isSpotlight, isFalse);
    });

    test('copyWith carries the flag instead of dropping it', () {
      final lit = MatchProfile.fromJson(row({'is_spotlight': true}));
      expect(lit.copyWith(displayName: 'Renamed').isSpotlight, isTrue);
      expect(lit.copyWith(isSpotlight: false).isSpotlight, isFalse);
    });
  });

  group('SpotlightPackage.fromJson', () {
    test('parses an integer price without losing it', () {
      final package = SpotlightPackage.fromJson({
        'id': 'pkg',
        'code': 'spotlight_60m',
        'duration_minutes': 60,
        'price_inr': 5000,
      });
      expect(package.durationMinutes, 60);
      expect(package.priceInr, 5000.0);
    });

    test('parses the numeric(10,2) that Postgres actually returns', () {
      // price_inr is NUMERIC, so PostgREST sends it as a JSON number that may
      // carry decimals. Reading it as int would throw.
      final package = SpotlightPackage.fromJson({
        'id': 'pkg',
        'code': 'spotlight_5m',
        'duration_minutes': 5,
        'price_inr': 250.00,
      });
      expect(package.priceInr, 250.0);
    });
  });

  group('ActiveSpotlight.fromJson', () {
    test('converts the timestamp to local time', () {
      final active = ActiveSpotlight.fromJson({
        'id': 'a1',
        'mode': 'date',
        'district': 'Coimbatore',
        'starts_at': '2026-08-31T10:00:00Z',
        'expires_at': '2026-08-31T11:00:00Z',
        'seconds_remaining': 3600,
      });
      expect(active.district, 'Coimbatore');
      expect(active.secondsRemaining, 3600);
      expect(active.expiresAt.isUtc, isFalse);
      expect(
        active.expiresAt.toUtc(),
        DateTime.utc(2026, 8, 31, 11),
      );
    });

    test('treats a missing remainder as expired rather than crashing', () {
      final active = ActiveSpotlight.fromJson({
        'id': 'a1',
        'mode': 'bff',
        'district': 'Chennai',
        'starts_at': '2026-08-31T10:00:00Z',
        'expires_at': '2026-08-31T11:00:00Z',
      });
      expect(active.secondsRemaining, 0);
    });
  });

  group('formatRemaining', () {
    test('shows m:ss under an hour', () {
      expect(formatRemaining(const Duration(minutes: 4, seconds: 7)), '4:07');
      expect(formatRemaining(const Duration(seconds: 9)), '0:09');
      expect(formatRemaining(const Duration(minutes: 59, seconds: 59)), '59:59');
    });

    test('rolls over to h:mm:ss at exactly one hour', () {
      expect(formatRemaining(const Duration(hours: 1)), '1:00:00');
      expect(
        formatRemaining(const Duration(hours: 1, minutes: 5, seconds: 3)),
        '1:05:03',
      );
    });

    test('never counts backwards past zero', () {
      // The ticker can fire once after expiry; a "-1:-1 left" banner would be
      // the visible symptom.
      expect(formatRemaining(const Duration(seconds: -5)), '0:00');
      expect(formatRemaining(Duration.zero), '0:00');
    });
  });
}
