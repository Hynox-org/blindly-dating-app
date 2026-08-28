import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:blindly_dating_app/features/matching/compatibility/compatibility_report_model.dart';

final compatibilityRepositoryProvider = Provider<CompatibilityRepository>((ref) {
  return CompatibilityRepository(Supabase.instance.client);
});

class CompatibilityRepository {
  final SupabaseClient _supabase;

  CompatibilityRepository(this._supabase);

  /// Scores one pair and returns the worded explanation.
  ///
  /// Only ever called from the compatibility screen, never from the deck: the
  /// explanation costs an LLM call, so computing it for every card the user
  /// scrolls past would be almost entirely wasted.
  Future<CompatibilityReport> fetch(
    String targetProfileId, {
    bool refresh = false,
  }) async {
    final response = await _supabase.functions.invoke(
      'compatibility-explanation',
      body: {'target_profile_id': targetProfileId, 'refresh': refresh},
    );

    final data = Map<String, dynamic>.from(response.data ?? const {});
    if (data['success'] != true) {
      debugPrint('❌ Compatibility failed: ${data['error']}');
      throw Exception(data['error'] ?? 'Could not work out compatibility');
    }

    return CompatibilityReport.fromJson(data);
  }
}

/// Lazy by construction: nothing runs until a widget watches this family, which
/// only happens once the user opens the compatibility screen.
final compatibilityProvider =
    FutureProvider.autoDispose.family<CompatibilityReport, String>((
      ref,
      targetProfileId,
    ) {
      return ref
          .watch(compatibilityRepositoryProvider)
          .fetch(targetProfileId);
    });
