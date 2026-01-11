import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';

// -------------------------------
// Custom Exception for UI
// -------------------------------
class SwipeException implements Exception {
  final String message;
  final String code;

  SwipeException(this.message, {this.code = 'UNKNOWN'});

  @override
  String toString() => message;
}

// -------------------------------
// Provider
// -------------------------------
final swipeRepositoryProvider = Provider<SwipeRepository>((ref) {
  return SwipeRepository(Supabase.instance.client);
});

// -------------------------------
// Repository
// -------------------------------
class SwipeRepository {
  final SupabaseClient _supabase;

  SwipeRepository(this._supabase);

  /// Records a swipe action
  ///
  /// actionType must be one of:
  /// - like
  /// - pass
  /// - super_like
  /// - rewind
  Future<void> recordSwipe({
    required String targetProfileId, // 👈 profiles.id (NOT auth.user.id)
    required String actionType,
  }) async {
    try {
      debugPrint('👉 RECORD SWIPE');
      debugPrint('TARGET PROFILE ID: $targetProfileId');
      debugPrint('ACTION TYPE: $actionType');

      final response = await _supabase.rpc(
        'record_swipe',
        params: {
          'p_target_profile_id': targetProfileId, // ✅ FIXED
          'p_action_type': actionType, // ✅ FIXED
        },
      );

      debugPrint('🧪 SWIPE RESPONSE: $response');

      // -------------------------------
      // Handle DB response
      // -------------------------------
      if (response is Map && response['success'] == false) {
        final code = response['code'] as String? ?? 'UNKNOWN';

        switch (code) {
          case 'LIKE_LIMIT_REACHED':
            throw SwipeException('Daily like limit reached', code: code);

          case 'PREMIUM_REQUIRED':
            throw SwipeException(
              'This feature is for premium users',
              code: code,
            );

          case 'PROFILE_NOT_FOUND':
            throw SwipeException('Profile not found', code: code);

          case 'INVALID_ACTION_TYPE':
            throw SwipeException('Invalid swipe action', code: code);

          default:
            throw SwipeException('Swipe failed: $code', code: code);
        }
      }

      // success == true → nothing else to do
      return;
    } on SwipeException {
      rethrow;
    } catch (e) {
      debugPrint('❌ SWIPE ERROR: $e');

      // Duplicate swipe → silently ignore
      if (e.toString().contains('unique_swipe_per_actor_target')) {
        return;
      }

      throw SwipeException(
        'Unexpected error while recording swipe',
        code: 'UNEXPECTED_ERROR',
      );
    }
  }
}
