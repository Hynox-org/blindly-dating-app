import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:blindly_dating_app/features/matching/domain/models/match_profile.dart';

// ======================================================
// Provider
// ======================================================
final matchingRepositoryProvider = Provider<MatchingRepository>((ref) {
  return MatchingRepository(Supabase.instance.client);
});

// ======================================================
// Repository
// ======================================================
/// Everything both feeds need: the caller's active mode, the saved filters,
/// media signing, and hydrating one profile on its own. The feeds themselves
/// live in PeopleFeedRepository and DiscoveryFeedRepository.
class MatchingRepository {
  final SupabaseClient _supabase;

  MatchingRepository(this._supabase);

  /// Dev mode hides some auth-screen affordances (see authentication_screen.dart)
  static const bool kDevMode = true;

  /// Storage URLs are signed for a week. An hour used to be enough for one
  /// screen, but a deck loaded before the app went to the background came back
  /// to dead image links. Nothing here is cached longer than a week anyway —
  /// every fetch re-signs.
  static const int signedUrlTtl = 60 * 60 * 24 * 7;

  // --------------------------------------------------
  // 📸 SIGN IMAGES
  // --------------------------------------------------
  /// One round trip for the whole batch. Signing them one at a time meant
  /// ~60 sequential calls for a 20-profile deck, which is most of the wait
  /// the user sees on first load.
  Future<List<String>> signImages(List<dynamic> rawPaths) async {
    const String bucketName = 'user_photos';

    // Already-public URLs pass straight through; the rest become storage keys.
    final List<String> ready = [];
    final List<String> toSign = [];

    for (final item in rawPaths) {
      String path = item.toString();
      if (path.isEmpty) continue;

      if (path.startsWith('http')) {
        if (!path.contains('/$bucketName/')) {
          ready.add(path);
          continue;
        }
        path = Uri.decodeComponent(
          path.split('/$bucketName/').last.split('?').first,
        );
      }
      if (path.startsWith('/')) path = path.substring(1);
      toSign.add(path);
    }

    if (toSign.isEmpty) return ready;

    try {
      final signed = await _supabase.storage
          .from(bucketName)
          .createSignedUrls(toSign, signedUrlTtl);
      return [
        ...ready,
        for (final s in signed) s.signedUrl,
      ];
    } catch (e) {
      debugPrint('Error signing images: $e');
      return [...ready, ...toSign];
    }
  }

  // --------------------------------------------------
  // 🎙 SIGN VOICE INTRO
  // --------------------------------------------------
  /// Returns [rawPath] untouched when it is already a URL, or when signing
  /// fails — a dead voice intro must never take the whole card down.
  Future<String?> signVoice(String? rawPath) async {
    final path = rawPath?.trim() ?? '';
    if (path.isEmpty || path.startsWith('http')) return rawPath;

    try {
      return await _supabase.storage
          .from('user_voices')
          .createSignedUrl(
            path.startsWith('/') ? path.substring(1) : path,
            signedUrlTtl,
          );
    } catch (e) {
      debugPrint('⚠️ Voice intro sign failed: $e');
      return rawPath;
    }
  }

  // --------------------------------------------------
  // 🛠 ENSURE PROFILE MODE EXISTS
  // --------------------------------------------------
  Future<void> ensureProfileMode(String mode) async {
    final dbMode = mode.toLowerCase();
    if (dbMode != 'date' && dbMode != 'bff') return;

    try {
      final authUserId = _supabase.auth.currentUser?.id;
      if (authUserId == null) return;

      final profileData = await _supabase
          .from('profiles')
          .select('id')
          .eq('user_id', authUserId)
          .maybeSingle();

      if (profileData == null) return;

      final String profileId = profileData['id'];

      final existing = await _supabase
          .from('profile_modes')
          .select('id')
          .eq('profile_id', profileId)
          .eq('mode', dbMode)
          .maybeSingle();

      if (existing == null) {
        await _supabase.from('profile_modes').insert({
          'profile_id': profileId,
          'mode': dbMode,
          'is_active': true,
        });
      } else {
        // Force it to be active if it exists but is inactive
        await _supabase
            .from('profile_modes')
            .update({'is_active': true})
            .eq('profile_id', profileId)
            .eq('mode', dbMode);
      }

      // Also ensure the main profile table is in sync
      await _supabase
          .from('profiles')
          .update({'current_mode': dbMode})
          .eq('id', profileId);
    } catch (e) {
      debugPrint('❌ Failed to ensure profile mode: $e');
    }
  }

  // --------------------------------------------------
  // 🔄 SOURCE OF TRUTH: PROFILES TABLE
  // --------------------------------------------------
  Future<String> fetchCurrentMode() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return 'date';

      final response = await _supabase
          .from('profiles')
          .select('current_mode')
          .eq('user_id', userId)
          .maybeSingle();

      if (response != null && response['current_mode'] != null) {
        return response['current_mode'] as String;
      }
    } catch (e) {
      debugPrint('⚠️ Failed to fetch current mode from DB: $e');
    }
    return 'date';
  }

  Future<void> updateCurrentMode(String mode) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      await _supabase
          .from('profiles')
          .update({'current_mode': mode})
          .eq('user_id', userId);
    } catch (e) {
      debugPrint('❌ Failed to update current mode in DB: $e');
    }
  }

  // --------------------------------------------------
  // 📁 FILTERS (PER MODE)
  // --------------------------------------------------
  Future<void> saveFilters(String mode, Map<String, dynamic> filters) async {
    try {
      final authUserId = _supabase.auth.currentUser?.id;
      if (authUserId == null) return;

      final profileData = await _supabase
          .from('profiles')
          .select('id')
          .eq('user_id', authUserId)
          .maybeSingle();

      if (profileData == null) return;
      final String profileId = profileData['id'];

      await _supabase
          .from('profile_modes')
          .update({'filters': filters})
          .eq('profile_id', profileId)
          .eq('mode', mode.toLowerCase());

      debugPrint('✅ Filters saved for mode: $mode');
    } catch (e) {
      debugPrint('❌ Failed to save filters: $e');
    }
  }

  Future<Map<String, dynamic>?> getFilters(String mode) async {
    try {
      final authUserId = _supabase.auth.currentUser?.id;
      if (authUserId == null) return null;

      final profileData = await _supabase
          .from('profiles')
          .select('id')
          .eq('user_id', authUserId)
          .maybeSingle();

      if (profileData == null) return null;
      final String profileId = profileData['id'];

      final response = await _supabase
          .from('profile_modes')
          .select('filters')
          .eq('profile_id', profileId)
          .eq('mode', mode.toLowerCase())
          .maybeSingle();

      return response?['filters'] as Map<String, dynamic>?;
    } catch (e) {
      debugPrint('❌ Failed to fetch filters: $e');
      return null;
    }
  }

  // --------------------------------------------------
  // ⚡ SINGLE PROFILE, ONE ROUND TRIP
  // --------------------------------------------------
  /// Full card data for one profile via `hydrate_discovery_profiles` — one
  /// RPC plus one batched signing call. The likes screen uses this instead of
  /// [getProfileWithRelationship], whose seven sequential queries were the
  /// visible lag when opening a card.
  Future<MatchProfile?> getProfile(
    String profileId, {
    required String mode,
  }) async {
    final List<dynamic>? rows = await _supabase.rpc(
      'hydrate_discovery_profiles',
      params: {
        'payload': {
          'p_ids': [profileId],
          'p_mode': mode.toLowerCase(),
        },
      },
    );

    if (rows == null || rows.isEmpty) return null;

    final data = Map<String, dynamic>.from(rows.first);
    data['image_urls'] = await signImages(
      List<dynamic>.from(data['image_urls'] ?? []),
    );
    data['voice_intro_url'] = await signVoice(
      data['voice_intro_url']?.toString(),
    );

    return MatchProfile.fromJson(data);
  }

  // --------------------------------------------------
  // 🤝 RELATIONSHIP STATUS (FOR DEEP LINKS)
  // --------------------------------------------------
  Future<MatchProfile?> getProfileWithRelationship(
    String targetProfileId,
  ) async {
    try {
      final authUserId = _supabase.auth.currentUser?.id;
      if (authUserId == null) throw Exception('User not logged in');

      final myProfileData = await _supabase
          .from('profiles')
          .select('id')
          .eq('user_id', authUserId)
          .maybeSingle();
      if (myProfileData == null) throw Exception('Self profile not found');
      final String myId = myProfileData['id'];

      final targetData = await _supabase
          .from('profiles')
          .select('''
            *,
            profile_modes!inner(*)
          ''')
          .eq('id', targetProfileId)
          .eq('profile_modes.is_active', true)
          .maybeSingle();

      if (targetData == null) return null;

      final List<dynamic> modes = targetData['profile_modes'];
      final String currentMode = targetData['current_mode'] ?? 'date';
      final activeModeData = modes.firstWhere(
        (m) => m['mode'] == currentMode,
        orElse: () => modes.first,
      );

      final Map<String, dynamic> mappedData = {
        'profile_id': targetData['id'],
        'display_name': targetData['display_name'],
        'age': 0, // Need to calc
        'distance_km': 0.0, // Need location
        'bio': activeModeData['bio'],
        'mode_id': activeModeData['id'],
        'image_urls': [], // Sign below
        'gender': targetData['gender'],
        'work_title': targetData['work_title'],
        'is_verified': targetData['is_verified'],
        'verification_level': targetData['verification_level'],
      };

      if (targetData['birth_date'] != null) {
        final birthDate = DateTime.parse(targetData['birth_date']);
        final today = DateTime.now();
        int age = today.year - birthDate.year;
        if (today.month < birthDate.month ||
            (today.month == birthDate.month && today.day < birthDate.day)) {
          age--;
        }
        mappedData['age'] = age;
      }

      final List<dynamic> rawMedia = await _supabase
          .from('profile_mode_media')
          .select('media_url')
          .eq('profile_mode_id', activeModeData['id'])
          .eq('is_deleted', false)
          .order('is_primary', ascending: false)
          .limit(3);

      mappedData['image_urls'] = await signImages([
        for (final m in rawMedia) m['media_url'],
      ]);

      RelationshipState rel = RelationshipState.none;

      final match = await _supabase
          .from('matches')
          .select('status, chat_started')
          .or(
            'and(user_a_id.eq.$myId,user_b_id.eq.$targetProfileId),and(user_a_id.eq.$targetProfileId,user_b_id.eq.$myId)',
          )
          .maybeSingle();

      if (match != null) {
        if (match['status'] == 'blocked') {
          rel = RelationshipState.blocked;
        } else if (match['chat_started'] == true) {
          rel = RelationshipState.chatStarted;
        } else {
          rel = RelationshipState.matched;
        }
      } else {
        final mySwipe = await _supabase
            .from('swipes')
            .select('action_type')
            .eq('actor_id', myId)
            .eq('target_id', targetProfileId)
            .maybeSingle();

        if (mySwipe != null) {
          final action = mySwipe['action_type'];
          if (action == 'like' || action == 'super_like') {
            rel = RelationshipState.likedByMe;
          } else {
            rel = RelationshipState.skippedByMe;
          }
        } else {
          final theirSwipe = await _supabase
              .from('swipes')
              .select('action_type')
              .eq('actor_id', targetProfileId)
              .eq('target_id', myId)
              .eq('action_type', 'like')
              .maybeSingle();

          if (theirSwipe != null) {
            rel = RelationshipState.likedMe;
          }
        }
      }

      return MatchProfile.fromJson(mappedData).copyWith(relationship: rel);
    } catch (e) {
      debugPrint('❌ Error fetching profile with relationship: $e');
      return null;
    }
  }
}
