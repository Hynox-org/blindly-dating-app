import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/onboarding_step_model.dart';
import '../../../../core/utils/app_logger.dart';
import '../../domain/models/lifestyle_category_model.dart';
import '../../domain/models/lifestyle_chip_model.dart';
import '../../domain/models/prompt_category_model.dart';
import '../../domain/models/prompt_template_model.dart';
import '../../domain/models/profile_prompt_model.dart';

// ✅ NEW: Import Cache Service
import '../../../discovery/repository/discovery_cache_service.dart';

final onboardingRepositoryProvider = Provider<OnboardingRepository>((ref) {
  return OnboardingRepository(Supabase.instance.client);
});

class OnboardingRepository {
  final SupabaseClient _supabase;
  
  // ✅ NEW: Cache Service Instance
  final _cacheService = DiscoveryCacheService();

  OnboardingRepository(this._supabase);

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

  Future<void> updateStepStatus(
    String userId,
    String stepKey,
    String status,
  ) async {
    // We use getProfileRaw here. Since we updated getProfileRaw to handle offline,
    // this logic needs to be robust. However, writing to DB (update) will still fail offline.
    // That is expected behavior (you can't save progress offline).
    // The critical part is *reading* the profile to know where to start.
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

  // ✅ CRITICAL UPDATE: Handle Offline Caching
  Future<Map<String, dynamic>?> getProfileRaw(String userId) async {
    try {
      // 1. Try Network First
      final response = await _supabase
          .from('profiles')
          .select()
          .eq('user_id', userId)
          .maybeSingle();
      
      // 2. If success, Save to Cache
      if (response != null) {
        await _cacheService.saveMyProfile(response);
      }
      return response;
    } catch (e) {
      // 3. If Network Error, Read from Cache
      final errString = e.toString();
      if (errString.contains('SocketException') || 
          errString.contains('ClientException') || 
          errString.contains('Network request failed')) {
        
        AppLogger.info('⚠️ Offline: Fetching profile from local cache...');
        final cachedProfile = _cacheService.getMyProfile();
        
        if (cachedProfile != null) {
          AppLogger.info('✅ Cache Hit: Found local profile.');
          return cachedProfile;
        }
      }
      
      AppLogger.info('Error fetching user profile: $e');
      return null;
    }
  }

  Future<bool> checkOnboardingStatus(String userId) async {
    try {
      // We reuse getProfileRaw now so it benefits from the cache!
      final profile = await getProfileRaw(userId);
      if (profile == null) return false;
      return profile['onboarding_status'] == 'complete';
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
          // This fix assumes we are online. If offline, we probably shouldn't revert status.
          // But since this is a validation step, it's safer to trust the cache if offline.
          AppLogger.info(
            'Integrity Check Failed: Status is Complete but Progress is Empty.',
          );
          // Only attempt to fix on server if we think we are online (simple heuristic or try/catch)
          try {
             await _supabase
                .from('profiles')
                .update({'onboarding_status': 'in_progress'})
                .eq('user_id', userId);
          } catch (_) {
            // Ignore write errors if offline
          }
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

  Future<void> saveUserInterests(String userId, List<String> chipIds) async {
    try {
      await _supabase
          .from('profiles')
          .update({
            'selected_interest_ids': chipIds,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('user_id', userId);
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

  Future<void> saveLifestylePreferences(
    String userId,
    List<String> chipIds,
  ) async {
    try {
      await _supabase
          .from('profiles')
          .update({
            'selected_lifestyle_ids': chipIds,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('user_id', userId);
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
    final profileResponse = await _supabase
        .from('profiles')
        .select('id')
        .eq('user_id', userId)
        .maybeSingle();

    if (profileResponse == null) {
      throw Exception('Profile not found for user $userId');
    }

    final profileId = profileResponse['id'] as String;

    await _supabase
        .from('profile_prompts')
        .delete()
        .eq('profile_id', profileId);

    if (prompts.isNotEmpty) {
      final data = prompts.map((p) {
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

  // --- Fetch User Selections ---

  Future<List<String>> getUserInterestChips(String userId) async {
    try {
      final response = await _supabase
          .from('profiles')
          .select('selected_interest_ids')
          .eq('user_id', userId)
          .maybeSingle();

      if (response == null || response['selected_interest_ids'] == null) {
        return [];
      }

      return List<String>.from(response['selected_interest_ids']);
    } catch (e) {
      AppLogger.info('Error fetching user interest chips: $e');
      return [];
    }
  }

  Future<List<String>> getUserLifestyleChips(String userId) async {
    try {
      final response = await _supabase
          .from('profiles')
          .select('selected_lifestyle_ids')
          .eq('user_id', userId)
          .maybeSingle();

      if (response == null || response['selected_lifestyle_ids'] == null) {
        return [];
      }

      return List<String>.from(response['selected_lifestyle_ids']);
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
          .order('prompt_display_order');

      return (response as List).map((e) => ProfilePrompt.fromJson(e)).toList();
    } catch (e) {
      AppLogger.info('Error fetching user profile prompts: $e');
      return [];
    }
  }
}