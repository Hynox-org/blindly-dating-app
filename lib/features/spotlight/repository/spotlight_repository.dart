import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// A purchasable spotlight window. Duration and price come from
/// `spotlight_packages` rather than the client, because `purchase_spotlight`
/// charges what the table says — a client that invented its own price would
/// simply be ignored.
class SpotlightPackage {
  final String id;
  final String code;
  final int durationMinutes;
  final double priceInr;

  const SpotlightPackage({
    required this.id,
    required this.code,
    required this.durationMinutes,
    required this.priceInr,
  });

  factory SpotlightPackage.fromJson(Map<String, dynamic> json) {
    return SpotlightPackage(
      id: json['id'] as String,
      code: json['code'] as String,
      durationMinutes: json['duration_minutes'] as int,
      priceInr: (json['price_inr'] as num).toDouble(),
    );
  }
}

/// A spotlight that is running right now.
class ActiveSpotlight {
  final String id;
  final String mode;
  final String district;
  final DateTime expiresAt;
  final int secondsRemaining;

  const ActiveSpotlight({
    required this.id,
    required this.mode,
    required this.district,
    required this.expiresAt,
    required this.secondsRemaining,
  });

  factory ActiveSpotlight.fromJson(Map<String, dynamic> json) {
    return ActiveSpotlight(
      id: json['id'] as String,
      mode: json['mode'] as String,
      district: json['district'] as String,
      expiresAt: DateTime.parse(json['expires_at'] as String).toLocal(),
      secondsRemaining: json['seconds_remaining'] as int? ?? 0,
    );
  }
}

/// Raised when the backend knows where the user is not.
class SpotlightNoDistrict implements Exception {
  const SpotlightNoDistrict();
}

class SpotlightRepository {
  final SupabaseClient _supabase;

  SpotlightRepository(this._supabase);

  Future<List<SpotlightPackage>> getPackages() async {
    final rows = await _supabase
        .from('spotlight_packages')
        .select()
        .eq('is_active', true)
        .order('sort_order');

    return [
      for (final row in rows)
        SpotlightPackage.fromJson(Map<String, dynamic>.from(row)),
    ];
  }

  /// The live window for [mode], or null when nothing is running.
  Future<ActiveSpotlight?> getActive(String mode) async {
    final rows = await _supabase.rpc('get_my_spotlight') as List<dynamic>?;
    if (rows == null) return null;

    for (final row in rows) {
      final map = Map<String, dynamic>.from(row as Map);
      if ((map['mode'] as String).toLowerCase() == mode.toLowerCase()) {
        return ActiveSpotlight.fromJson(map);
      }
    }
    return null;
  }

  /// Buys [package] for [mode]. There is no payment provider yet: the RPC
  /// writes a completed purchase directly. When a gateway is added, this is
  /// the one call that changes — the deck already refuses anything that is
  /// not `payment_status = 'completed'`.
  ///
  /// Buying while a window is already running appends to it rather than
  /// starting a second overlapping one.
  Future<ActiveSpotlight> purchase({
    required SpotlightPackage package,
    required String mode,
  }) async {
    try {
      final row = await _supabase.rpc(
        'purchase_spotlight',
        params: {'p_package_id': package.id, 'p_mode': mode.toLowerCase()},
      );

      final map = Map<String, dynamic>.from(row as Map);
      final expiresAt = DateTime.parse(map['expires_at'] as String).toLocal();

      return ActiveSpotlight(
        id: map['id'] as String,
        mode: map['mode'] as String,
        district: map['district'] as String,
        expiresAt: expiresAt,
        secondsRemaining: expiresAt.difference(DateTime.now()).inSeconds,
      );
    } on PostgrestException catch (e) {
      // The buyer has no district yet, so there is nobody to be shown to.
      // Worth its own type: the screen offers a location retry instead of a
      // generic failure.
      if (e.message.contains('No district set')) {
        throw const SpotlightNoDistrict();
      }
      rethrow;
    }
  }
}

final spotlightRepositoryProvider = Provider<SpotlightRepository>(
  (ref) => SpotlightRepository(Supabase.instance.client),
);
