import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
  final String _lambdaUrl = dotenv.env['AWS_SWIPE_FEED_URL'] ?? '';

  DiscoveryRepository(this._supabase);

  // --------------------------------------------------
  // 🔧 CONFIG
  // --------------------------------------------------

  /// Dev mode ignores distance limits
  static const bool kDevMode = true;

  /// Huge radius when dev mode is ON (20,000 KM to cover the world)
  static const int _devRadiusKm = 20000;

  // --------------------------------------------------
  // 📸 HELPER: SIGN IMAGES
  // --------------------------------------------------
  Future<List<String>> _signImages(List<dynamic> rawPaths) async {
    final List<String> signedUrls = [];
    const String bucketName = 'user_photos';

    for (var item in rawPaths) {
      String path = item.toString();
      if (path.isNotEmpty) {
        try {
          if (path.startsWith('http')) {
            if (path.contains('/$bucketName/')) {
              final parts = path.split('/$bucketName/');
              if (parts.length > 1) {
                path = parts.last.split('?').first;
                path = Uri.decodeComponent(path);
              }
            } else {
              signedUrls.add(path);
              continue;
            }
          }

          if (path.startsWith('/')) path = path.substring(1);

          final signedUrl = await _supabase.storage
              .from(bucketName)
              .createSignedUrl(path, 60 * 60);
          signedUrls.add(signedUrl);
        } catch (e) {
          debugPrint('Error signing image: $path, $e');
          signedUrls.add(path);
        }
      }
    }
    return signedUrls;
  }

  // --------------------------------------------------
  // 🔥 MAIN DISCOVERY FEED (FLAT LIST FOR SWIPER CARD)
  // --------------------------------------------------
  Future<(List<DiscoveryUser>, bool)> getDiscoveryFeed({
    required String currentMode,
    int radiusKm = 50,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final authUser = _supabase.auth.currentUser;
      if (authUser == null) throw Exception('User not logged in');

      final myProfileResponse = await _supabase
          .from('profiles')
          .select('id')
          .eq('user_id', authUser.id)
          .maybeSingle();

      if (myProfileResponse == null) throw Exception('Profile not found');
      final String myProfileId = myProfileResponse['id'];

      // 🛡️ FIX: Ensure the profile mode exists and is active before calling Lambda
      await ensureProfileMode(currentMode);

      debugPrint('🚀 CALLING LAMBDA: $_lambdaUrl');
      final lambdaResponse = await http.post(
        Uri.parse(_lambdaUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'profile_id': myProfileId}),
      );

      if (lambdaResponse.statusCode != 200) {
        debugPrint('🛑 LAMBDA ERROR: ${lambdaResponse.statusCode} - ${lambdaResponse.body}');
        throw Exception('Failed to get profiles from Lambda: ${lambdaResponse.body}');
      }

      final Map<String, dynamic> lambdaData = jsonDecode(lambdaResponse.body);
      debugPrint('🧪 LAMBDA RAW RESPONSE (SWIPE): ${lambdaResponse.body}');

      // Extract ids dynamically whether the lambda returned "profiles" array or "categories" dict
      List<String> profileIds = [];
      if (lambdaData.containsKey('profiles')) {
        profileIds = List<String>.from(lambdaData['profiles']);
      } else if (lambdaData.containsKey('categories')) {
        final Map<String, dynamic> cats = lambdaData['categories'];
        final Set<String> uniqueIds = {};
        for (var list in cats.values) {
          uniqueIds.addAll(List<String>.from(list));
        }
        profileIds = uniqueIds.toList();
      }

      final bool exhausted = lambdaData['exhausted'] ?? profileIds.isEmpty;

      if (profileIds.isEmpty) {
        return (<DiscoveryUser>[], exhausted);
      }

      debugPrint('🚀 HYDRATING PROFILES: ${profileIds.length} users');
      final List<dynamic>? response = await _supabase.rpc(
        'hydrate_discovery_profiles',
        params: {
          'payload': {
            'p_ids': profileIds,
            'p_mode': currentMode,
          },
        },
      );

      if (response == null || response.isEmpty) {
        return (<DiscoveryUser>[], exhausted);
      }

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
                .createSignedUrl(voicePath, 3600);
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
      
      // 1. Call the Edge Function wrapper for smart discovery categories
      final response = await _supabase.functions.invoke(
        'smart-discovery',
        body: {'mode': searchMode},
      );

      if (response.status != 200) {
        throw Exception('Failed to get smart discovery feed: ${response.status}');
      }

      final Map<String, dynamic> responseData = response.data['data'] ?? {};
      final Map<String, List<dynamic>> categories =
          Map<String, List<dynamic>>.from(responseData['categories'] ?? {});

      // Flatten UUIDs to fetch profiles in one DB batch
      final Set<String> allUuids = {};
      categories.forEach((key, uuids) {
        allUuids.addAll(uuids.cast<String>());
      });

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
                    .createSignedUrl(rawVoicePath, 3600);
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
  // ⏪ UNDO LAST SWIPE
  // --------------------------------------------------
  Future<bool> undoLastSwipe() async {
    try {
      final response = await _supabase.rpc('undo_last_swipe');
      return response as bool;
    } catch (e) {
      debugPrint('❌ Undo RPC failed: $e');
      return false;
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
              final url = await _supabase.storage.from('user_photos').createSignedUrl(path, 3600);
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
