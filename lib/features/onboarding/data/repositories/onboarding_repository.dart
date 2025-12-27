import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/onboarding_step_model.dart';
import '../../../../core/utils/app_logger.dart';

// The Provider Definition
final onboardingRepositoryProvider = Provider<OnboardingRepository>((ref) {
  return OnboardingRepository(Supabase.instance.client);
});

class OnboardingRepository {
  final SupabaseClient _supabase;

  OnboardingRepository(this._supabase);

  // ===========================================================================
  // SECTION 1: CONFIGURATION (Fetching Steps) - [EXISTING CODE]
  // ===========================================================================

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

  // ===========================================================================
  // SECTION 2: NEW SPECIFIC ENDPOINTS (Strict Data Handling) - [NEW ADDITION]
  // This is where we safely update specific profile fields
  // ===========================================================================

  /// Endpoint 1: Update Display Name
  Future<void> updateDisplayName(String userId, String name) async {
    // Safety: Enforce DB limit of 100 chars
    if (name.length > 100) name = name.substring(0, 100);
    await _updateProfileField(userId, {'display_name': name});
  }

  /// Endpoint 2: Update Birth Date
  /// FIX: Converts DateTime -> "YYYY-MM-DD" string for Postgres DATE type
  Future<void> updateBirthDate(String userId, DateTime date) async {
    final dateString = date.toIso8601String().split('T').first;
    await _updateProfileField(userId, {'birth_date': dateString});
  }

  /// Endpoint 3: Update Gender
  /// TRANSLATES UI strings ('Male', 'Female') -> DB Enum ('M', 'F', 'NB', 'Prefer Not')
  Future<void> updateGender(String userId, String genderLabel) async {
    String dbValue;
    
    // Map the UI text to the Database Enum value
    switch (genderLabel) {
      case 'Male': 
        dbValue = 'M'; 
        break;
      case 'Female': 
        dbValue = 'F'; 
        break;
      case 'Non-binary': 
        dbValue = 'NB'; 
        break;
      case 'Prefer not to say': 
        dbValue = 'Prefer Not'; 
        break;
      default:
        // Fallback or error if something unexpected comes in
        dbValue = 'Prefer Not';
    }

    await _updateProfileField(userId, {'gender': dbValue});
  }
  /// Endpoint 4: Update Bio
  Future<void> updateBio(String userId, String bio) async {
    await _updateProfileField(userId, {'bio': bio});
  }

  /// Endpoint 5: Update Location
  Future<void> updateLocationText(String userId, String city, String state, String country) async {
    await _updateProfileField(userId, {
      'city': city,
      'state': state,
      'country': country,
    });
  }

  /// Internal Helper: The logic that actually touches the database
  Future<void> _updateProfileField(String userId, Map<String, dynamic> updates) async {
    try {
      final data = {
        ...updates,
        'updated_at': DateTime.now().toIso8601String(),
      };
      await _supabase.from('profiles').update(data).eq('user_id', userId);
      AppLogger.info('REPO: Updated fields: ${updates.keys}');
    } catch (e) {
      AppLogger.error('REPO: Update failed for ${updates.keys}', e);
      throw Exception('Database update failed: $e');
    }
  }

  // ===========================================================================
  // SECTION 3: PROGRESS & STATUS - [EXISTING CODE]
  // ===========================================================================

  Future<void> updateStepStatus(String userId, String stepKey, String status) async {
    final profile = await getProfileRaw(userId);
    Map<String, dynamic> currentProgress = {};
    if (profile != null && profile['steps_progress'] != null) {
      currentProgress = Map<String, dynamic>.from(profile['steps_progress']);
    }

    currentProgress[stepKey] = status;

    await _supabase
        .from('profiles')
        .update({
          'steps_progress': currentProgress,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('user_id', userId);
  }

  Future<void> completeOnboarding(String userId) async {
    await _supabase
        .from('profiles')
        .update({
          'onboarding_status': 'complete', // NOTE: 'complete' (not 'completed') based on your old code
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('user_id', userId);
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

  // ===========================================================================
  // SECTION 4: INTEGRITY CHECKS - [EXISTING CODE]
  // ===========================================================================

  Future<bool> validateAndFixOnboardingStatus(String userId) async {
    try {
      final profile = await getProfileRaw(userId);
      if (profile == null) return false;

      final status = profile['onboarding_status'] as String? ?? 'in_progress';
      final rawProgress = profile['steps_progress'];
      final Map<String, dynamic> stepsProgress = (rawProgress != null)
          ? Map<String, dynamic>.from(rawProgress)
          : {};

      if (status == 'complete') {
        if (stepsProgress.isEmpty) {
          AppLogger.info(
            'Integrity Check Failed: Status is Complete but Progress is Empty. Reverting.',
          );
          await _supabase
              .from('profiles')
              .update({'onboarding_status': 'in_progress'})
              .eq('user_id', userId);
          return false;
        }
      }
      return status == 'complete';
    } catch (e) {
      AppLogger.info('Error validating onboarding status: $e');
      return false;
    }
  }
}