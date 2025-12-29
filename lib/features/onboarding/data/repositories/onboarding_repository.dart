import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/onboarding_step_model.dart';
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

  Future<void> saveUserInterests(String userId, List<String> chipIds) async {
    // 0. Resolve Profile ID from Auth ID (userId)
    final profileResponse = await _supabase
        .from('profiles')
        .select('id')
        .eq('user_id', userId)
        .maybeSingle();

    if (profileResponse == null) {
      throw Exception('Profile not found for user $userId');
    }

    final profileId = profileResponse['id'] as String;

    // 1. Delete existing interests for this user (full replacement strategy)
    await _supabase
        .from('profile_interest_chips')
        .delete()
        .eq('profile_id', profileId);

    // 2. Insert new selections
    if (chipIds.isNotEmpty) {
      final data = chipIds
          .map(
            (chipId) => {
              'profile_id': profileId,
              'chip_id': chipId,
              'created_at': DateTime.now().toIso8601String(),
            },
          )
          .toList();

      await _supabase.from('profile_interest_chips').insert(data);
    }
  }

  Future<List<LifestyleCategory>> getLifestyleCategoriesWithChips() async {
    try {
      // 1. Fetch Categories
      final categoriesResponse = await _supabase
          .from('lifestyle_categories')
          .select()
          .order('id');
      final categories = (categoriesResponse as List)
          .map((e) => LifestyleCategory.fromJson(e))
          .toList();

      // 2. Fetch Chips
      final chipsResponse = await _supabase
          .from('lifestyle_chips')
          .select()
          .eq('is_active', true);
      final chips = (chipsResponse as List)
          .map((e) => LifestyleChip.fromJson(e))
          .toList();

      // 3. Associate Chips with Categories
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

  Future<void> saveLifestylePreferences(
    String userId,
    List<String> chipIds,
  ) async {
    // 0. Resolve Profile ID
    final profileResponse = await _supabase
        .from('profiles')
        .select('id')
        .eq('user_id', userId)
        .maybeSingle();

    if (profileResponse == null) {
      throw Exception('Profile not found for user $userId');
    }

    final profileId = profileResponse['id'] as String;

    // 1. Delete existing lifestyle chips for this user
    await _supabase
        .from('profile_lifestyle_chips')
        .delete()
        .eq('profile_id', profileId);

    // 2. Insert new selections
    if (chipIds.isNotEmpty) {
      final data = chipIds
          .map(
            (chipId) => {
              'profile_id': profileId,
              'chip_id': chipId,
              'created_at': DateTime.now().toIso8601String(),
            },
          )
          .toList();

      await _supabase.from('profile_lifestyle_chips').insert(data);
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
          // You might want to sort by category or some other field
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
    // 0. Resolve Profile ID
    final profileResponse = await _supabase
        .from('profiles')
        .select('id')
        .eq('user_id', userId)
        .maybeSingle();

    if (profileResponse == null) {
      throw Exception('Profile not found for user $userId');
    }

    final profileId = profileResponse['id'] as String;

    // 1. Delete existing prompts for this user (full replacement)
    await _supabase
        .from('profile_prompts')
        .delete()
        .eq('profile_id', profileId);

    // 2. Insert new prompts
    if (prompts.isNotEmpty) {
      final data = prompts.map((p) {
        // Ensure profile_id is set correctly (just in case the model didn't have it or it differs)
        // But the model is created in UI, better to force it here or trust it.
        // Let's trust the UI creates it or we override it here.
        // Actually, creating a new map is safer.
        return {
          'profile_id': profileId,
          'prompt_template_id': p.promptTemplateId,
          'user_response': p.userResponse,
          'prompt_display_order': p.promptDisplayOrder,
          'created_at': DateTime.now().toIso8601String(),
        };
      }).toList();

      await _supabase.from('profile_prompts').insert(data);
    }
  }

  // --- Fetch User Selections methods for Bidirectional Navigation ---

  Future<List<String>> getUserInterestChips(String userId) async {
    try {
      // 1. Get profile ID
      final profile = await getProfileRaw(userId);
      if (profile == null) return [];
      final profileId = profile['id'];

      // 2. Fetch chips
      final response = await _supabase
          .from('profile_interest_chips')
          .select('chip_id')
          .eq('profile_id', profileId);

      return (response as List).map((e) => e['chip_id'] as String).toList();
    } catch (e) {
      AppLogger.info('Error fetching user interest chips: $e');
      return [];
    }
  }

  Future<List<String>> getUserLifestyleChips(String userId) async {
    try {
      final profile = await getProfileRaw(userId);
      if (profile == null) return [];
      final profileId = profile['id'];

      final response = await _supabase
          .from('profile_lifestyle_chips')
          .select('chip_id')
          .eq('profile_id', profileId);

      return (response as List).map((e) => e['chip_id'] as String).toList();
    } catch (e) {
      AppLogger.info('Error fetching user lifestyle chips: $e');
      return [];
    }
  }

  Future<List<ProfilePrompt>> getUserProfilePrompts(String userId) async {
    try {
      final profile = await getProfileRaw(userId);
      if (profile == null) return [];
      final profileId = profile['id'];

      final response = await _supabase
          .from('profile_prompts')
          .select()
          .eq('profile_id', profileId)
          .order('prompt_display_order'); // Order by display order

      return (response as List).map((e) => ProfilePrompt.fromJson(e)).toList();
    } catch (e) {
      AppLogger.info('Error fetching user profile prompts: $e');
      return [];
    }
  }
}
