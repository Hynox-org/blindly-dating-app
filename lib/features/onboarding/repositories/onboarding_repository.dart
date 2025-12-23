import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/utils/app_logger.dart';

class OnboardingRepository {
  final SupabaseClient _client;

  OnboardingRepository(this._client);

  /// Checks if the user has completed onboarding by verifying if a profile exists.
  /// Returns `true` if profile exists (onboarding complete), `false` otherwise.
  Future<bool> checkOnboardingStatus(String userId) async {
    try {
      final response = await _client
          .from('profiles')
          .select('onboarding_status')
          .eq('user_id', userId)
          .maybeSingle();

      if (response == null) return false;
      return response['onboarding_status'] == 'complete';
    } catch (e, stackTrace) {
      AppLogger.error(
        'ONBOARDING_REPO: Failed to check onboarding status',
        e,
        stackTrace,
      );
      // specific error handling if needed, essentially fetch failed = false or rethrow
      // attempting to follow safe default: if we can't check, assume not onboarded?
      // or rethrow to let UI handle "something went wrong"
      rethrow;
    }
  }
}
