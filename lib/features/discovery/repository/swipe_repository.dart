import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';


// ======================================================
// Custom Exception (used by UI & Provider)
// ======================================================
class SwipeException implements Exception {
  final String message;
  final String code;

  SwipeException(this.message, {this.code = 'UNKNOWN'});

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
  // RECORD SWIPE
  // --------------------------------------------------
  /// actionType must be one of:
  /// - like
  /// - pass
  /// - super_like
  /// - rewind (handled via undo function instead)
  Future<void> recordSwipe({
    required String targetProfileId, // profiles.id
    required String actionType,
  }) async {
    try {
      debugPrint('👉 RECORD SWIPE');
      debugPrint('TARGET PROFILE ID: $targetProfileId');
      debugPrint('ACTION TYPE: $actionType');

      final response = await _supabase.rpc(
        'record_swipe',
        params: {
          'p_target_profile_id': targetProfileId,
          'p_action_type': actionType,
        },
      );

      debugPrint('🧪 SWIPE RESPONSE: $response');

      if (response is Map && response['success'] == false) {
        final code = response['code'] as String? ?? 'UNKNOWN';

        switch (code) {
          case 'LIKE_LIMIT_REACHED':
            throw SwipeException(
              'Daily like limit reached',
              code: code,
            );

          case 'PREMIUM_REQUIRED':
            throw SwipeException(
              'This feature is for premium users',
              code: code,
            );

          case 'PROFILE_NOT_FOUND':
            throw SwipeException(
              'Profile not found',
              code: code,
            );

          case 'INVALID_ACTION_TYPE':
            throw SwipeException(
              'Invalid swipe action',
              code: code,
            );

          default:
            throw SwipeException(
              'Swipe failed: $code',
              code: code,
            );
        }
      }

      // success == true → do nothing
      return;
    } on SwipeException {
      rethrow;
    } catch (e) {
      debugPrint('❌ SWIPE ERROR: $e');

      // Ignore duplicate swipe silently
      if (e.toString().contains('unique_swipe_per_actor_target')) {
        return;
      }

      throw SwipeException(
        'Unexpected error while recording swipe',
        code: 'UNEXPECTED_ERROR',
      );
    }
  }


  // --------------------------------------------------
  // UNDO LAST SWIPE (PREMIUM ONLY)
  // --------------------------------------------------
  Future<void> undoLastSwipe() async {
    try {
      debugPrint('↩️ UNDO LAST SWIPE');

      final response = await _supabase.rpc('undo_last_swipe');

      debugPrint('🧪 UNDO RESPONSE: $response');

      if (response is Map && response['success'] == false) {
        final code = response['code'] as String? ?? 'UNKNOWN';

        switch (code) {
          case 'PREMIUM_REQUIRED':
            throw SwipeException(
              'Undo is a premium feature',
              code: code,
            );

          case 'NO_SWIPE_FOUND':
            throw SwipeException(
              'No swipe to undo',
              code: code,
            );

          case 'PROFILE_NOT_FOUND':
            throw SwipeException(
              'Profile not found',
              code: code,
            );

          default:
            throw SwipeException(
              'Undo failed: $code',
              code: code,
            );
        }
      }

      return;
    } on SwipeException {
      rethrow;
    } catch (e) {
      debugPrint('❌ UNDO ERROR: $e');

      throw SwipeException(
        'Unexpected error while undoing swipe',
        code: 'UNEXPECTED_ERROR',
      );
    }
  }
}
