import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/onboarding_step_model.dart';
import '../../../../core/utils/app_logger.dart';
import '../../domain/models/lifestyle_category_model.dart';
import '../../domain/models/lifestyle_chip_model.dart';
import '../../domain/models/prompt_category_model.dart';
import '../../domain/models/prompt_template_model.dart';
import '../../domain/models/profile_prompt_model.dart';

final onboardingRepositoryProvider = Provider<OnboardingRepository>((ref) {
  return OnboardingRepository(Supabase.instance.client);
});

class OnboardingRepository {
  final SupabaseClient _supabase;

  OnboardingRepository(this._supabase);

  // --- Profile Mode Helpers ---

  Future<String> getOrUpdateProfileModeId(String userId, String mode) async {
    final profile = await getProfileRaw(userId);
    if (profile == null) throw Exception('Profile not found for $userId');
    final profileId = profile['id'] as String;

    final response = await _supabase
        .from('profile_modes')
        .select('id')
        .eq('profile_id', profileId)
        .eq('mode', mode)
        .maybeSingle();

    if (response != null) {
      return response['id'] as String;
    }

    // Fallback: Create if missing (should be handled by AuthRepo, but for safety)
    final createResponse = await _supabase
        .from('profile_modes')
        .insert({'profile_id': profileId, 'mode': mode, 'is_active': true})
        .select('id')
        .single();

    return createResponse['id'] as String;
  }

  // ... [Existing Step Configuration Methods remain unchanged] ...

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

  Future<List<OnboardingStep>> getMandatorySteps() async {
    try {
      final response = await _supabase
          .from('onboarding_steps')
          .select()
          .eq('is_mandatory', true)
          .order('step_position', ascending: true);

      return (response as List).map((e) => OnboardingStep.fromJson(e)).toList();
    } catch (e) {
      AppLogger.info('Error fetching mandatory steps: $e');
      return [];
    }
  }

  Future<void> updateStepStatus(
    String userId,
    String stepKey,
    String status,
  ) async {
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
          'onboarding_status': 'complete',
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('user_id', userId);
  }

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
            'Integrity Check Failed: Status is Complete but Progress is Empty. Reverting to in_progress.',
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

  Future<List<Map<String, dynamic>>> getInterestChips() async {
    try {
      final response = await _supabase
          .from('interest_chips')
          .select()
          .eq('is_active', true)
          .order('section');

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      AppLogger.info('Error fetching interest chips: $e');
      return [];
    }
  }

  // ✅ UPDATED: Save to profile_mode_interestchips (Multi-mode Schema)
  Future<void> saveUserInterests(String userId, List<String> chipIds) async {
    try {
      final profileModeId = await getOrUpdateProfileModeId(userId, 'date');

      // 1. Delete existing
      await _supabase
          .from('profile_mode_interestchips')
          .delete()
          .eq('profile_mode_id', profileModeId);

      // 2. Insert new
      if (chipIds.isNotEmpty) {
        final data = chipIds
            .map((id) => {'profile_mode_id': profileModeId, 'chip_id': id})
            .toList();

        await _supabase.from('profile_mode_interestchips').insert(data);
      }
    } catch (e) {
      AppLogger.info('Error saving interests: $e');
      throw Exception('Failed to save interests: $e');
    }
  }

  Future<List<LifestyleCategory>> getLifestyleCategoriesWithChips() async {
    try {
      final categoriesResponse = await _supabase
          .from('lifestyle_categories')
          .select()
          .order('id');
      final categories = (categoriesResponse as List)
          .map((e) => LifestyleCategory.fromJson(e))
          .toList();

      final chipsResponse = await _supabase
          .from('lifestyle_chips')
          .select()
          .eq('is_active', true);
      final chips = (chipsResponse as List)
          .map((e) => LifestyleChip.fromJson(e))
          .toList();

      final List<LifestyleCategory> result = [];
      for (var category in categories) {
        final categoryChips = chips
            .where((c) => c.categoryId == category.id)
            .toList();
        result.add(category.copyWith(chips: categoryChips));
      }

      return result;
    } catch (e) {
      AppLogger.info('Error fetching lifestyle categories: $e');
      return [];
    }
  }

  // ✅ UPDATED: Save to profile_mode_lifestylechips (Multi-mode Schema)
  Future<void> saveLifestylePreferences(
    String userId,
    List<String> chipIds,
  ) async {
    try {
      final profileModeId = await getOrUpdateProfileModeId(userId, 'date');

      // 1. Delete existing
      await _supabase
          .from('profile_mode_lifestylechips')
          .delete()
          .eq('profile_mode_id', profileModeId);

      // 2. Insert new
      if (chipIds.isNotEmpty) {
        final data = chipIds
            .map((id) => {'profile_mode_id': profileModeId, 'chip_id': id})
            .toList();

        await _supabase.from('profile_mode_lifestylechips').insert(data);
      }
    } catch (e) {
      AppLogger.info('Error saving lifestyle preferences: $e');
      throw Exception('Failed to save lifestyle preferences: $e');
    }
  }

  // --- Profile Prompts ---

  Future<List<PromptCategory>> getPromptCategories() async {
    try {
      final response = await _supabase
          .from('prompt_categories')
          .select()
          .eq('is_active', true)
          .order('id');

      return (response as List).map((e) => PromptCategory.fromJson(e)).toList();
    } catch (e) {
      AppLogger.info('Error fetching prompt categories: $e');
      return [];
    }
  }

  Future<List<PromptTemplate>> getPromptTemplates() async {
    try {
      final response = await _supabase
          .from('prompt_templates')
          .select()
          .eq('is_active', true)
          .order('category_id');

      return (response as List).map((e) => PromptTemplate.fromJson(e)).toList();
    } catch (e) {
      AppLogger.info('Error fetching prompt templates: $e');
      return [];
    }
  }

  Future<void> saveProfilePrompts(
    String userId,
    List<ProfilePrompt> prompts,
  ) async {
    final profileModeId = await getOrUpdateProfileModeId(userId, 'date');

    await _supabase
        .from('profile_mode_prompts')
        .delete()
        .eq('profile_mode_id', profileModeId);

    if (prompts.isNotEmpty) {
      final data = prompts.map((p) {
        return {
          'profile_mode_id': profileModeId,
          'prompt_template_id': p.promptTemplateId,
          'user_response': p.userResponse,
          'display_order': p
              .promptDisplayOrder, // Column name changed to display_order in new schema
          'created_at': DateTime.now().toIso8601String(),
        };
      }).toList();

      await _supabase.from('profile_mode_prompts').insert(data);
    }
  }

  // --- Fetch User Selections methods for Bidirectional Navigation ---

  // ✅ UPDATED: Fetch from profile_mode_interestchips
  Future<List<String>> getUserInterestChips(String userId) async {
    try {
      final profileModeId = await getOrUpdateProfileModeId(userId, 'date');

      final response = await _supabase
          .from('profile_mode_interestchips')
          .select('chip_id')
          .eq('profile_mode_id', profileModeId);

      return (response as List).map((e) => e['chip_id'] as String).toList();
    } catch (e) {
      AppLogger.info('Error fetching user interest chips: $e');
      return [];
    }
  }

  // ✅ UPDATED: Fetch from profile_mode_lifestylechips
  Future<List<String>> getUserLifestyleChips(String userId) async {
    try {
      final profileModeId = await getOrUpdateProfileModeId(userId, 'date');

      final response = await _supabase
          .from('profile_mode_lifestylechips')
          .select('chip_id')
          .eq('profile_mode_id', profileModeId);

      return (response as List).map((e) => e['chip_id'] as String).toList();
    } catch (e) {
      AppLogger.info('Error fetching user lifestyle chips: $e');
      return [];
    }
  }

  Future<List<ProfilePrompt>> getUserProfilePrompts(String userId) async {
    try {
      final profileModeId = await getOrUpdateProfileModeId(userId, 'date');

      final response = await _supabase
          .from('profile_mode_prompts')
          .select()
          .eq('profile_mode_id', profileModeId)
          .order('display_order');

      return (response as List).map((e) {
        // Map display_order back to prompt_display_order for the model if needed,
        // or update model to use display_order. Assuming model needs previous name for now.
        final map = Map<String, dynamic>.from(e);
        map['prompt_display_order'] = e['display_order'];
        return ProfilePrompt.fromJson(map);
      }).toList();
    } catch (e) {
      AppLogger.info('Error fetching user profile prompts: $e');
      return [];
    }
  }

  // --- Bio Methods ---

  Future<void> saveBio(
    String userId,
    String bio, {
    String mode = 'date',
  }) async {
    try {
      final profileModeId = await getOrUpdateProfileModeId(userId, mode);

      await _supabase
          .from('profile_modes')
          .update({'bio': bio, 'updated_at': DateTime.now().toIso8601String()})
          .eq('id', profileModeId);
    } catch (e) {
      AppLogger.info('Error saving bio: $e');
      throw Exception('Failed to save bio: $e');
    }
  }

  Future<String?> getUserBio(String userId, {String mode = 'date'}) async {
    try {
      final profileIdResponse = await _supabase
          .from('profiles')
          .select('id')
          .eq('user_id', userId)
          .maybeSingle();

      if (profileIdResponse == null) return null;
      final profileId = profileIdResponse['id'];

      final response = await _supabase
          .from('profile_modes')
          .select('bio')
          .eq('profile_id', profileId)
          .eq('mode', mode)
          .maybeSingle();

      return response?['bio'] as String?;
    } catch (e) {
      AppLogger.info('Error fetching user bio: $e');
      return null;
    }
  }

  // --- Language Methods ---

  Future<void> saveUserLanguages(
    String userId,
    List<String> languageCodes,
  ) async {
    try {
      final profile = await getProfileRaw(userId);
      if (profile == null) throw Exception('Profile not found for $userId');
      final profileId = profile['id'] as String;

      // 1. Delete existing
      await _supabase
          .from('profile_languages')
          .delete()
          .eq('profile_id', profileId);

      // 2. Insert new
      if (languageCodes.isNotEmpty) {
        final data = languageCodes
            .map((code) => {'profile_id': profileId, 'language_code': code})
            .toList();

        await _supabase.from('profile_languages').insert(data);
      }
    } catch (e) {
      AppLogger.info('Error saving languages: $e');
      throw Exception('Failed to save languages: $e');
    }
  }

  Future<List<String>> getUserLanguages(String userId) async {
    try {
      final profile = await getProfileRaw(userId);
      if (profile == null) return [];
      final profileId = profile['id'] as String;

      final response = await _supabase
          .from('profile_languages')
          .select('language_code')
          .eq('profile_id', profileId);

      return (response as List)
          .map((e) => e['language_code'] as String)
          .toList();
    } catch (e) {
      AppLogger.info('Error fetching user languages: $e');
      return [];
    }
  }
}
