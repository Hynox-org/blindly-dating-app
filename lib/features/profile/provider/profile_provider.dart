import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/providers/connection_mode_provider.dart';
import '../domain/models/profile_user_model.dart';
import '../domain/repositories/profile_repository.dart';
import '../../onboarding/domain/models/lifestyle_chip_model.dart';
import '../../onboarding/domain/models/profile_prompt_model.dart';

final currentUserProfileProvider =
    AsyncNotifierProvider<CurrentUserProfileNotifier, ProfileUser>(
      () => CurrentUserProfileNotifier(),
    );

class CurrentUserProfileNotifier extends AsyncNotifier<ProfileUser> {
  @override
  Future<ProfileUser> build() async {
    final client = Supabase.instance.client;
    final authId = client.auth.currentUser?.id;

    // Watch connection mode to re-fetch when mode changes (e.g. Date <-> BFF)
    final currentMode = ref.watch(connectionModeProvider).toLowerCase();

    if (authId == null) throw Exception("User not logged in");

    return _fetchProfile(authId, currentMode);
  }

  /// Manually updates the local state with a new profile object.
  /// Use this for immediate UI feedback after a successful database update.
  void updateProfile(ProfileUser updatedProfile) {
    state = AsyncData(updatedProfile);
  }

  /// Triggers a fresh re-fetch from the database.
  Future<void> refreshProfile() async {
    state = const AsyncLoading();
    final authId = Supabase.instance.client.auth.currentUser?.id;
    final currentMode = ref.read(connectionModeProvider).toLowerCase();

    if (authId == null) {
      state = AsyncError(Exception("User not logged in"), StackTrace.current);
      return;
    }

    state = await AsyncValue.guard(() => _fetchProfile(authId, currentMode));
  }

  /// Recalculates the current user's trust score.
  ///
  /// The RPC resolves the profile from auth.uid() and refuses to touch any
  /// other user's profile, so no identifier is needed or accepted.
  /// [identifier] is ignored and kept only for existing call sites.
  Future<void> triggerTrustCalculation([String? identifier]) async {
    try {
      final result = await Supabase.instance.client
          .rpc('recalculate_trust_score');

      debugPrint('✅ Trust score recalculated: $result');
      await refreshProfile();
    } catch (e) {
      debugPrint('❌ Error triggering trust calculation: $e');
    }
  }

  /// Unified method to update profile in Supabase, update local state, and trigger trust calculation.
  Future<void> updateProfileAndRecalculateTrust({
    required String userId, // This can be Auth ID or Profile ID
    required Map<String, dynamic> updates,
    required ProfileUser updatedProfile,
  }) async {
    try {
      final repo = ref.read(profileRepositoryProvider);
      
      // The repository update logic also needs to be robust about which ID it uses.
      // We pass the ID to the repo.
      await repo.updateProfile(userId, updates);

      // Update local state for immediate feedback
      updateProfile(updatedProfile);

      // Trigger trust calculation using the same ID (the provider will resolve it to Profile ID)
      await triggerTrustCalculation(userId);
    } catch (e) {
      debugPrint('❌ Error in updateProfileAndRecalculateTrust: $e');
      rethrow;
    }
  }

  Future<ProfileUser> _fetchProfile(String authId, String currentMode) async {
    final client = Supabase.instance.client;
    try {
      // 1. Fetch Common Profile Data (Profiles Table)
      final Map<String, dynamic>? profileDataRaw = await client
          .from('profiles')
          .select()
          .eq('user_id', authId)
          .maybeSingle();

      if (profileDataRaw == null) return _getEmptyProfile(authId);

      final profileId = profileDataRaw['id'] as String;

      // 2. Fetch Mode-Specific Data (Profile Modes Table)
      final allModesData = await client
          .from('profile_modes')
          .select('id, mode, bio, looking_for')
          .eq('profile_id', profileId);

      final dateMode = allModesData.firstWhere(
        (m) => (m['mode'] as String).toLowerCase() == 'date',
        orElse: () => <String, dynamic>{},
      );
      final bffMode = allModesData.firstWhere(
        (m) => (m['mode'] as String).toLowerCase() == 'bff',
        orElse: () => <String, dynamic>{},
      );

      final currentModeData = currentMode == 'date' ? dateMode : bffMode;

      final String bio = currentModeData['bio'] ?? '';
      final List<dynamic> lookingForModesRaw =
          currentModeData['looking_for'] ?? [];
      final String profileModeId = currentModeData['id'] ?? '';

      // 3. Parallel Fetching of Related Data (only if mode exists)
      List<String> finalImageUrls = [];
      List<String> interestNames = [];
      List<LifestyleChip> lifestyleList = [];
      List<ProfilePrompt> promptList = [];
      String? voiceIntroUrl;
      int? voiceIntroDuration;

      if (profileModeId.isNotEmpty) {
        // Future.wait for better performance
        await Future.wait([
          // A. Fetch Media
          _fetchMedia(
            client,
            profileModeId,
          ).then((urls) => finalImageUrls = urls),

          // B. Fetch Interests
          _fetchInterests(
            client,
            profileModeId,
          ).then((names) => interestNames = names),

          // C. Fetch Lifestyle
          _fetchLifestyle(
            client,
            profileModeId,
          ).then((items) => lifestyleList = items),

          // D. Fetch Prompts
          _fetchPrompts(
            client,
            profileModeId,
            profileId,
          ).then((prompts) => promptList = prompts),

          // E. Fetch & Sign Voice Intro (Global for any mode)
          _fetchVoiceIntro(client, profileId).then((data) {
            voiceIntroUrl = data?['url'];
            voiceIntroDuration = data?['duration'];
          }),
        ]);
      } else {
        // Default fallback if mode doesn't exist yet
        finalImageUrls = ['https://picsum.photos/400/600'];
      }

      // E. Fetch Languages (now from profiles.languages text[] column)
      final List<String> languageNames =
          (profileDataRaw['languages'] as List?)
              ?.map((e) => e as String)
              .toList() ??
          [];

      // Override bio and looking_for in profileDataRaw with mode-specific data
      final Map<String, dynamic> finalProfileData = Map.from(profileDataRaw);
      finalProfileData['bio'] = bio;
      finalProfileData['looking_for'] = lookingForModesRaw;
      finalProfileData['voice_intro_url'] = voiceIntroUrl;
      finalProfileData['voice_intro_duration'] = voiceIntroDuration;
      finalProfileData['date_mode_id'] = dateMode['id'];
      finalProfileData['bff_mode_id'] = bffMode['id'];

      return ProfileUser.fromJson(
        finalProfileData,
        finalImageUrls,
        interestNames: interestNames,
        languageNames: languageNames,
        promptList: promptList,
        lifestyleList: lifestyleList,
      );
    } catch (e, stack) {
      debugPrint('❌ ERROR in _fetchProfile: $e\n$stack');
      rethrow;
    }
  }
}

// --- Helper Fetch Functions ---

Future<List<String>> _fetchMedia(
  SupabaseClient client,
  String profileModeId,
) async {
  try {
    final List<dynamic> mediaData = await client
        .from('profile_mode_media')
        .select('media_url')
        .eq('profile_mode_id', profileModeId)
        .eq('media_type', 'photo')
        .order('is_primary', ascending: false)
        .order('display_order', ascending: true)
        .limit(6);

    if (mediaData.isNotEmpty) {
      List<String> urls = [];
      for (var item in mediaData) {
        final String rawPath = item['media_url'];
        // Check if it's already a full URL (e.g. from Google Auth or placeholders)
        if (rawPath.startsWith('http')) {
          urls.add(rawPath);
        } else {
          final String signedUrl = await client.storage
              .from('user_photos')
              .createSignedUrl(rawPath, 60 * 60);
          urls.add(signedUrl);
        }
      }
      return urls;
    }
  } catch (e) {
    debugPrint('⚠️ Media Fetch Error: $e');
  }
  return ['https://picsum.photos/400/600'];
}

Future<List<String>> _fetchInterests(
  SupabaseClient client,
  String profileModeId,
) async {
  try {
    // Join query: profile_mode_interestchips -> interest_chips
    final List<dynamic> data = await client
        .from('profile_mode_interestchips')
        .select('interest_chips(label)') // inner join
        .eq('profile_mode_id', profileModeId);

    return data
        .map((item) => item['interest_chips']['label'] as String)
        .toList();
  } catch (e) {
    debugPrint('⚠️ Interest Fetch Error: $e');
    return [];
  }
}

Future<List<LifestyleChip>> _fetchLifestyle(
  SupabaseClient client,
  String profileModeId,
) async {
  try {
    // Join query: profile_mode_lifestylechips -> lifestyle_chips -> lifestyle_categories
    final List<dynamic> data = await client
        .from('profile_mode_lifestylechips')
        .select(
          'lifestyle_chips(id, category_id, label, is_active, lifestyle_categories(key))',
        )
        .eq('profile_mode_id', profileModeId);

    return data.map((item) {
      // Create a map that includes the category info at the top level for correct parsing if needed,
      // or rely on the nested structure if fromJson handles it.
      // My updated fromJson expects 'lifestyle_categories' inside the json passed to it.
      // item['lifestyle_chips'] contains the chip data AND the nested 'lifestyle_categories' map.
      return LifestyleChip.fromJson(item['lifestyle_chips']);
    }).toList();
  } catch (e) {
    debugPrint('⚠️ Lifestyle Fetch Error: $e');
    return [];
  }
}

Future<List<ProfilePrompt>> _fetchPrompts(
  SupabaseClient client,
  String profileModeId,
  String profileId,
) async {
  try {
    // Join query: profile_mode_prompts -> prompt_templates
    final List<dynamic> data = await client
        .from('profile_mode_prompts')
        .select(
          'id, user_response, display_order, prompt_templates(id, prompt_text)',
        )
        .eq('profile_mode_id', profileModeId)
        .order('display_order');

    return data.map((item) {
      return ProfilePrompt(
        id: item['id'],
        profileId:
            profileId, // We use the main profile ID for the model usually
        promptTemplateId: item['prompt_templates']['id'],
        userResponse: item['user_response'],
        promptDisplayOrder: item['display_order'],
        promptQuestion: item['prompt_templates']['prompt_text'],
      );
    }).toList();
  } catch (e) {
    debugPrint('⚠️ Prompt Fetch Error: $e');
    return [];
  }
}

Future<Map<String, dynamic>?> _fetchVoiceIntro(
  SupabaseClient client,
  String profileId,
) async {
  try {
    final data = await client
        .from('profile_mode_media')
        .select('media_url, duration_seconds, profile_modes!inner(profile_id)')
        .eq('profile_modes.profile_id', profileId)
        .eq('media_type', 'voice_intro')
        .eq('is_deleted', false)
        .order('created_at', ascending: false)
        .limit(1)
        .maybeSingle();

    if (data != null && data['media_url'] != null) {
      final String rawPath = data['media_url'];
      String finalUrl = rawPath;
      if (!rawPath.startsWith('http')) {
        finalUrl = await client.storage
            .from('user_voices')
            .createSignedUrl(rawPath, 3600);
      }
      return {'url': finalUrl, 'duration': data['duration_seconds']};
    }
  } catch (e) {
    debugPrint('⚠️ Voice Intro Fetch Error: $e');
  }
  return null;
}

ProfileUser _getEmptyProfile(String id) {
  return ProfileUser(
    id: id,
    name: 'New User',
    age: 18,
    gender: '',
    city: 'Unknown',
    bio: 'Tap Edit to set up your profile',
    imageUrls: ['https://picsum.photos/400/600'],
    interests: [],
    education: '',
    profession: '',
    completionPercentage: 0.0,
  );
}
