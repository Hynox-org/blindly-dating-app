import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../features/discovery/domain/models/discovery_user_model.dart';
import '../../../features/discovery/domain/models/discovery_landing_data.dart';

// ======================================================
// Provider
// ======================================================
final discoveryRepositoryProvider = Provider<DiscoveryRepository>((ref) {
  return DiscoveryRepository(Supabase.instance.client);
});

// ======================================================
// Repository
// ======================================================
class DiscoveryRepository {
  final SupabaseClient _supabase;

  DiscoveryRepository(this._supabase);

  /// Dev mode hides some auth-screen affordances (see authentication_screen.dart)
  static const bool kDevMode = true;

  /// Storage URLs are signed for a week. An hour used to be enough for one
  /// screen, but a deck loaded before the app went to the background came back
  /// to dead image links. Nothing here is cached longer than a week anyway —
  /// every fetch re-signs.
  static const int _signedUrlTtl = 60 * 60 * 24 * 7;

  // --------------------------------------------------
  // 📸 HELPER: SIGN IMAGES
  // --------------------------------------------------
  /// One round trip for the whole batch. Signing them one at a time meant
  /// ~60 sequential calls for a 20-profile deck, which is most of the wait
  /// the user sees on first load.
  Future<List<String>> _signImages(List<dynamic> rawPaths) async {
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
        path = Uri.decodeComponent(path.split('/$bucketName/').last.split('?').first);
      }
      if (path.startsWith('/')) path = path.substring(1);
      toSign.add(path);
    }

    if (toSign.isEmpty) return ready;

    try {
      final signed = await _supabase.storage
          .from(bucketName)
          .createSignedUrls(toSign, _signedUrlTtl);
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
  // 🔥 MAIN DISCOVERY FEED (FLAT LIST FOR SWIPER CARD)
  // --------------------------------------------------
  Future<(List<DiscoveryUser>, bool)> getDiscoveryFeed({
    required String currentMode,
    int limit = 20,
  }) async {
    try {
      final authUser = _supabase.auth.currentUser;
      if (authUser == null) throw Exception('User not logged in');

      // Swiped/blocked profiles are excluded server-side, so every call returns
      // the next unseen batch — no offset needed.
      final List<dynamic>? response = await _supabase.rpc(
        'get_discovery_prospects',
        params: {
          'p_mode': currentMode,
          'p_limit': limit,
        },
      );

      if (response == null || response.isEmpty) {
        return (<DiscoveryUser>[], true);
      }

      final exhausted = response.length < limit;

      final futureUsers = response.map((raw) async {
        final Map<String, dynamic> data = Map<String, dynamic>.from(raw);

        // Sign image URLs safely as they come back raw from the RPC
        final rawImages = List<dynamic>.from(data['image_urls'] ?? []);
        data['image_urls'] = await _signImages(rawImages);

        // Process voice intro
        if (data['voice_intro_url'] != null &&
            data['voice_intro_url'].toString().isNotEmpty &&
            !data['voice_intro_url'].toString().startsWith('http')) {
          try {
            String voicePath = data['voice_intro_url'].toString();
            if (voicePath.startsWith('/')) voicePath = voicePath.substring(1);
            final signedVoiceUrl = await _supabase.storage
                .from('user_voices')
                .createSignedUrl(voicePath, _signedUrlTtl);
            data['voice_intro_url'] = signedVoiceUrl;
          } catch (e) {
            debugPrint('⚠️ Voice intro sign failed: $e');
          }
        }

        return DiscoveryUser.fromJson(data);
      });

      final users = await Future.wait(futureUsers);
      return (users, exhausted);
    } catch (e, stackTrace) {
      debugPrint('🛑 DISCOVERY FEED FAILED: $e');
      debugPrint(stackTrace.toString());
      rethrow;
    }
  }

  // --------------------------------------------------
  // 🌟 SMART DISCOVERY FEED (CATEGORIZED FOR LANDING)
  // --------------------------------------------------
  Future<DiscoveryLandingData> getSmartDiscoveryFeed({
    required String mode,
  }) async {
    try {
      final searchMode = mode.toLowerCase();
      
      // 1. Today's categorised ids. The set is seeded on the date server-side,
      //    so it stays put for 24h and rotates at midnight.
      final List<dynamic>? rows = await _supabase.rpc(
        'get_discovery_categories',
        params: {'p_mode': searchMode},
      );

      final Map<String, List<dynamic>> categories = {};
      final Set<String> allUuids = {};
      for (final row in rows ?? const []) {
        final category = row['category'] as String;
        final id = row['profile_id'] as String;
        categories.putIfAbsent(category, () => <dynamic>[]).add(id);
        allUuids.add(id);
      }

      if (allUuids.isEmpty) {
        return DiscoveryLandingData(feeds: {}, lastRefreshedAt: DateTime.now());
      }

      // 4. Fetch the hydrated profiles
      final List<dynamic>? profilesResponse = await _supabase.rpc(
        'hydrate_discovery_profiles',
        params: {
          'payload': {
            'p_ids': allUuids.toList(),
            'p_mode': searchMode,
          },
        },
      );

      final Map<String, DiscoveryUser> profileLookup = {};

      if (profilesResponse != null) {
        for (var row in profilesResponse) {
          final profileData = Map<String, dynamic>.from(row);

          final rawImages = List<dynamic>.from(profileData['image_urls'] ?? []);
          profileData['image_urls'] = await _signImages(rawImages);

          if (profileData['voice_intro_url'] != null) {
            final String rawVoicePath = profileData['voice_intro_url'];
            if (!rawVoicePath.startsWith('http')) {
              try {
                profileData['voice_intro_url'] = await _supabase.storage
                    .from('user_voices')
                    .createSignedUrl(rawVoicePath, _signedUrlTtl);
              } catch (_) {}
            }
          }

          final pId = profileData['profile_id'] as String;
          profileLookup[pId] = DiscoveryUser.fromJson(profileData);
        }
      }

      // Re-map into categories
      final Map<String, List<DiscoveryUser>> finalFeeds = {};
      categories.forEach((categoryName, uuidsList) {
        final List<DiscoveryUser> usersForCategory = [];
        for (var uuid in uuidsList) {
          if (profileLookup.containsKey(uuid)) {
            usersForCategory.add(profileLookup[uuid]!);
          }
        }
        if (usersForCategory.isNotEmpty) {
          finalFeeds[categoryName] = usersForCategory;
        }
      });

      return DiscoveryLandingData(
        feeds: finalFeeds,
        lastRefreshedAt: DateTime.now(),
      );
    } catch (e) {
      debugPrint('Error fetching smart discovery feed: $e');
      rethrow;
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
        await _supabase.from('profile_modes')
          .update({'is_active': true})
          .eq('profile_id', profileId)
          .eq('mode', dbMode);
      }

      // Also ensure the main profile table is in sync
      await _supabase.from('profiles')
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
  // 📁 SAVE FILTERS (PER MODE)
  // --------------------------------------------------
  Future<void> saveDiscoveryFilters(String mode, Map<String, dynamic> filters) async {
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

      debugPrint('✅ Discovery filters saved for mode: $mode');
    } catch (e) {
      debugPrint('❌ Failed to save discovery filters: $e');
    }
  }

  Future<Map<String, dynamic>?> getDiscoveryFilters(String mode) async {
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
      debugPrint('❌ Failed to fetch discovery filters: $e');
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
  Future<DiscoveryUser?> getDiscoveryUser(
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
    data['image_urls'] =
        await _signImages(List<dynamic>.from(data['image_urls'] ?? []));

    final voice = data['voice_intro_url']?.toString() ?? '';
    if (voice.isNotEmpty && !voice.startsWith('http')) {
      try {
        data['voice_intro_url'] = await _supabase.storage
            .from('user_voices')
            .createSignedUrl(voice, _signedUrlTtl);
      } catch (_) {}
    }

    return DiscoveryUser.fromJson(data);
  }

  // --------------------------------------------------
  // 🤝 RELATIONSHIP STATUS (FOR DEEP LINKS)
  // --------------------------------------------------
  Future<DiscoveryUser?> getProfileWithRelationship(String targetProfileId) async {
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
      
      final List<String> signedUrls = [];
      for (var m in rawMedia) {
        String path = m['media_url'];
         if (path.isNotEmpty && !path.startsWith('http')) {
            try {
              if (path.startsWith('/')) path = path.substring(1);
              final url = await _supabase.storage.from('user_photos').createSignedUrl(path, _signedUrlTtl);
              signedUrls.add(url);
            } catch (_) {}
         } else if (path.isNotEmpty) {
           signedUrls.add(path);
         }
      }
      mappedData['image_urls'] = signedUrls;

      RelationshipState rel = RelationshipState.none;

      final match = await _supabase
          .from('matches')
          .select('status, chat_started')
          .or('and(user_a_id.eq.$myId,user_b_id.eq.$targetProfileId),and(user_a_id.eq.$targetProfileId,user_b_id.eq.$myId)')
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

      return DiscoveryUser.fromJson(mappedData).copyWith(relationship: rel);
    } catch (e) {
      debugPrint('❌ Error fetching profile with relationship: $e');
      return null;
    }
  }
}
