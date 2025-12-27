import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/onboarding_step_model.dart';
import '../../../../core/utils/app_logger.dart';

final onboardingRepositoryProvider = Provider<OnboardingRepository>((ref) {
  return OnboardingRepository(Supabase.instance.client);
});

class OnboardingRepository {
  final SupabaseClient _supabase;

  OnboardingRepository(this._supabase);

  Future<OnboardingStep?> getStepConfig(String stepKey) async {
    try {
      final response = await _supabase
          .from('onboarding_steps')
          .select()
          .eq('step_key', stepKey)
          .maybeSingle();

      if (response == null) return null;
      return OnboardingStep.fromJson(response);
    } catch (e) {
      // Fallback or log error
      AppLogger.info('Error fetching step config: $e');
      return null;
    }
  }

  Future<OnboardingStep?> getStepByPosition(int position) async {
    try {
      final response = await _supabase
          .from('onboarding_steps')
          .select()
          .eq('step_position', position)
          .maybeSingle();

      if (response == null) return null;
      return OnboardingStep.fromJson(response);
    } catch (e) {
      AppLogger.info('Error fetching step by position: $e');
      return null;
    }
  }

  Future<List<OnboardingStep>> getAllSteps() async {
    try {
      final response = await _supabase
          .from('onboarding_steps')
          .select()
          .order('step_position', ascending: true);

      return (response as List).map((e) => OnboardingStep.fromJson(e)).toList();
    } catch (e) {
      AppLogger.info('Error fetching all steps: $e');
      return [];
    }
  }

  // Updates the status of a specific step in the JSONB map
  Future<void> updateStepStatus(
    String userId,
    String stepKey,
    String status, // 'completed', 'skipped'
  ) async {
    // 1. Fetch current map to ensure we merge correctly
    // (In a high concurrency implementation, use a Postgres function or jsonb_set)
    final profile = await getProfileRaw(userId);
    Map<String, dynamic> currentProgress = {};
    if (profile != null && profile['steps_progress'] != null) {
      currentProgress = Map<String, dynamic>.from(profile['steps_progress']);
    }

    // 2. Update key
    currentProgress[stepKey] = status;

    // 3. Save back
    await _supabase
        .from('profiles')
        .update({
          'steps_progress': currentProgress,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('user_id', userId);
  }

  // Force update complete
  Future<void> completeOnboarding(String userId) async {
    await _supabase
        .from('profiles')
        .update({
          'onboarding_status': 'complete',
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('user_id', userId);
  }

  // Updates arbitrary profile fields
  Future<void> updateProfileData(
    String userId,
    Map<String, dynamic> data,
  ) async {
    await _supabase.from('profiles').update(data).eq('user_id', userId);
  }

  Future<Map<String, dynamic>?> getProfileRaw(String userId) async {
    try {
      final response = await _supabase
          .from('profiles')
          .select()
          .eq('user_id', userId)
          .maybeSingle();
      return response;
    } catch (e) {
      AppLogger.info('Error fetching user profile: $e');
      return null;
    }
  }

  Future<bool> checkOnboardingStatus(String userId) async {
    try {
      final response = await _supabase
          .from('profiles')
          .select('onboarding_status')
          .eq('user_id', userId)
          .maybeSingle();

      if (response == null) return false;
      return response['onboarding_status'] == 'complete';
    } catch (e) {
      AppLogger.info('Error checking onboarding status: $e');
      return false;
    }
  }

  /// Validates that 'complete' status is backed by actual data.
  /// If data is missing (corruption/manual delete), it effectively "heals" the profile
  /// by reverting status to 'in_progress' so the user is routed correctly.
  Future<bool> validateAndFixOnboardingStatus(String userId) async {
    try {
      final profile = await getProfileRaw(userId);
      if (profile == null) return false;

      final status = profile['onboarding_status'] as String? ?? 'in_progress';
      final rawProgress = profile['steps_progress'];
      final Map<String, dynamic> stepsProgress = (rawProgress != null)
          ? Map<String, dynamic>.from(rawProgress)
          : {};

      // If marked complete, strict validation is required
      if (status == 'complete') {
        // 1. Sanity Check: Is progress empty? (User's specific case)
        if (stepsProgress.isEmpty) {
          AppLogger.info(
            'Integrity Check Failed: Status is Complete but Progress is Empty. Reverting to in_progress.',
          );

          await _supabase
              .from('profiles')
              .update({'onboarding_status': 'in_progress'})
              .eq('user_id', userId);

          return false; // Not complete anymore
        }

        // Potential future check: verifying all mandatory steps are present.
        // For now, the empty check covers the "null data" case.
      }

      return status == 'complete';
    } catch (e) {
      AppLogger.info('Error validating onboarding status: $e');
      return false;
    }
  }
}
