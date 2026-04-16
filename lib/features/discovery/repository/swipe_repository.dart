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
  Future<void> recordSwipe({
    required String targetProfileId,
    required String action, // like | pass | super_like
  }) async {
    try {
      debugPrint('👉 RECORD SWIPE');
      debugPrint('TARGET: $targetProfileId');
      debugPrint('ACTION: $action');

      final response = await _supabase.rpc(
        'record_swipe',
        params: {
          'p_target_profile_id': targetProfileId,
          'p_action_type': action,
        },
      );

      // We need to parse the response to see if success = true
      if (response != null && response is Map<String, dynamic>) {
        if (response['success'] == false) {
          final code = response['code'] ?? 'UNKNOWN_ERROR';
          debugPrint('❌ RECORD SWIPE REJECTED BY BACKEND: $code');
          if (code == 'LIKE_LIMIT_REACHED') {
            throw SwipeException('LIKE_LIMIT_REACHED');
          }
          throw SwipeException('Backend rejected swipe: $code');
        }
      }

      // If no exception → success
      debugPrint('✅ Swipe recorded successfully');
    } catch (e) {
      debugPrint('❌ RECORD SWIPE ERROR: $e');

      if (e is SwipeException) rethrow;

      // Ignore duplicate swipe (unique constraint)
      if (e.toString().contains('unique_swipe_per_actor_target')) {
        debugPrint('⚠️ Duplicate swipe ignored');
        return;
      }

      throw SwipeException('Failed to record swipe: $e');
    }
  }

  // --------------------------------------------------
  // ↩️ UNDO LAST SWIPE
  // --------------------------------------------------
  Future<bool> undoLastSwipe() async {
    try {
      debugPrint('↩️ UNDO LAST SWIPE');

      final result = await _supabase.rpc('undo_last_swipe');

      // undo_last_swipe RETURNS boolean
      final success = result == true;

      debugPrint('🧪 UNDO RESULT: $success');
      return success;
    } catch (e) {
      debugPrint('❌ UNDO ERROR: $e');
      throw SwipeException('Failed to undo swipe');
    }
  }
}
