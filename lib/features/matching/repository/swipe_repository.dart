import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';

// ======================================================
// Custom Exception
// ======================================================
class SwipeException implements Exception {
  final String message;

  SwipeException(this.message);

  @override
  String toString() => message;
}

// ======================================================
// Provider
// ======================================================
final swipeRepositoryProvider = Provider<SwipeRepository>((ref) {
  return SwipeRepository(Supabase.instance.client);
});

// ======================================================
// Repository
// ======================================================
class SwipeRepository {
  final SupabaseClient _supabase;

  SwipeRepository(this._supabase);

  // --------------------------------------------------
  // 👍 RECORD SWIPE (like / pass / super_like)
  // --------------------------------------------------
  /// Returns true when this swipe produced a match — the backend knows,
  /// because the trigger that creates the match runs inside the same call.
  /// A replayed swipe reports false, so a match is only ever celebrated once.
  Future<bool> recordSwipe({
    required String targetProfileId,
    required String action, // like | pass | super_like
  }) async {
    try {
      final response = await _supabase.rpc(
        'record_swipe',
        params: {
          'p_target_profile_id': targetProfileId,
          'p_action_type': action,
        },
      );

      if (response is Map && response['success'] == false) {
        throw SwipeException(
          'Backend rejected swipe: ${response['code'] ?? 'UNKNOWN_ERROR'}',
        );
      }

      return response is Map && response['matched'] == true;
    } catch (e) {
      if (e is SwipeException) rethrow;
      debugPrint('❌ RECORD SWIPE ERROR: $e');
      throw SwipeException('Failed to record swipe: $e');
    }
  }

  // --------------------------------------------------
  // ↩️ UNDO A SWIPE
  // --------------------------------------------------
  /// With [targetProfileId] the swipe on that exact profile is reverted —
  /// which is what the deck wants, since it knows which card it put back.
  /// Without it the backend falls back to the caller's most recent swipe.
  ///
  /// Returns false when there was nothing to undo, or when the pair already
  /// has a chat going and the match can no longer be taken back.
  Future<bool> undoLastSwipe({String? targetProfileId}) async {
    try {
      final result = await _supabase.rpc(
        'undo_last_swipe',
        params: {'p_target_profile_id': targetProfileId},
      );
      return result == true;
    } catch (e) {
      debugPrint('❌ UNDO ERROR: $e');
      throw SwipeException('Failed to undo swipe');
    }
  }
}
