import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Make sure this path points to your actual model file
import '../../../features/discovery/domain/models/discovery_user_model.dart';

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

  // --------------------------------------------------
  // 🔧 CONFIG
  // --------------------------------------------------

  /// Dev mode ignores distance limits
  static const bool kDevMode = true;

  /// Huge radius when dev mode is ON (20,000 KM to cover the world)
  static const int _devRadiusKm = 20000;

  // --------------------------------------------------
  // 🔥 MAIN DISCOVERY FEED (OPTIMIZED FOR LISTS)
  // --------------------------------------------------
  Future<List<DiscoveryUser>> getDiscoveryFeed({
    required String currentMode,
    int radiusKm = 50,
    int limit = 20, // ✅ Production Grade: Batch size increased
    int offset = 0,
  }) async {
    try {
      final authUser = _supabase.auth.currentUser;
      if (authUser == null) {
        throw Exception('User not logged in');
      }

      final int effectiveRadius = kDevMode ? _devRadiusKm : radiusKm;

      debugPrint('🚀 DISCOVERY RPC CALL: get_discovery_prospects');
      debugPrint('MODE    : $currentMode');
      debugPrint('RADIUS  : $effectiveRadius KM');
      debugPrint('LIMIT   : $limit');
      debugPrint('OFFSET  : $offset');

      // 1. Call DB using reverted RPC
      final List<dynamic>? response = await _supabase.rpc(
        'get_discovery_prospects',
        params: {
          'p_mode': currentMode,
          'p_limit': limit,
          'p_offset': offset,
        },
      );

      if (response == null || response.isEmpty) {
        debugPrint('🧪 DISCOVERY: No results returned from RPC');
        return [];
      }

      debugPrint('🧪 DISCOVERY ROWS FOUND: ${response.length}');
      debugPrint('🧪 DISCOVERY FIRST ROW (RAW): ${response.first}');

      // 2. PARALLEL PROCESSING (Iterate Users)
      final futureUsers = response.map((raw) async {
        final Map<String, dynamic> data = Map<String, dynamic>.from(raw);

        // 🔍 EXTRACT LIST: Get the array of paths from DB (Column: image_urls)
        // Note: Postgres arrays often come as List<dynamic> in Supabase Flutter
        final List<dynamic> rawPaths = data['image_urls'] ?? [];
        final List<String> signedUrls = [];

        // 🔄 LOOP & SIGN: Process each image in the list
        for (var item in rawPaths) {
          String imagePath = item.toString();

          // Only sign if it looks like a path (not a full http URL)
          if (imagePath.isNotEmpty && !imagePath.startsWith('http')) {
            try {
              // 🛠️ Remove leading slash if present
              if (imagePath.startsWith('/')) {
                imagePath = imagePath.substring(1);
              }

              // ⚠️ CRITICAL: Ensure bucket name is correct ('user_photos')
              final signedUrl = await _supabase.storage
                  .from('user_photos')
                  .createSignedUrl(imagePath, 60 * 60); // 1 Hour Expiry

              signedUrls.add(signedUrl);
            } catch (e) {
              debugPrint('⚠️ Image sign failed for path: $imagePath');
              // Optional: Add original path or skip? We skip to keep UI clean.
            }
          } else if (imagePath.isNotEmpty) {
            // It's already a full URL (e.g. Google Auth photo), keep it.
            signedUrls.add(imagePath);
          }
        }

        // ✅ NEW: Sign Voice Intro URL
        if (data['voice_intro_url'] != null &&
            data['voice_intro_url'].toString().isNotEmpty &&
            !data['voice_intro_url'].toString().startsWith('http')) {
          try {
            String voicePath = data['voice_intro_url'].toString();
            if (voicePath.startsWith('/')) voicePath = voicePath.substring(1);
            final signedVoiceUrl = await _supabase.storage
                .from('user_voices')
                .createSignedUrl(voicePath, 60 * 60);
            data['voice_intro_url'] = signedVoiceUrl;
          } catch (e) {
            debugPrint('⚠️ Voice intro sign failed: $e');
          }
        }

        // ✅ UPDATE DATA: Replace the raw paths with the signed URLs
        data['image_urls'] = signedUrls;

        // ✅ Ensure numeric types are handled safely
        if (data['age'] == null) data['age'] = 0;
        if (data['distance_km'] == null) data['distance_km'] = 0.0;

        return DiscoveryUser.fromJson(data);
      });

      // 3. Wait for all users to be processed
      final List<DiscoveryUser> users = await Future.wait(futureUsers);

      return users;
    } catch (e, stackTrace) {
      debugPrint('🛑 DISCOVERY FEED FAILED');
      debugPrint(e.toString());
      debugPrint(stackTrace.toString());
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
      }
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

      // 1. Get My Profile ID
      final myProfileData = await _supabase
          .from('profiles')
          .select('id')
          .eq('user_id', authUserId)
          .maybeSingle();
      if (myProfileData == null) throw Exception('Self profile not found');
      final String myId = myProfileData['id'];

      // 2. Fetch Target Profile Data (Using same logic as discovery if possible, or direct)
      // For deep links, we might need a specific mode or the profile's current_mode.
      // Let's fetch the profile and its active mode data.
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

      // Extract the active mode (usually they only have one active mode per type, we'll take the first or current)
      final List<dynamic> modes = targetData['profile_modes'];
      final String currentMode = targetData['current_mode'] ?? 'date';
      final activeModeData = modes.firstWhere(
        (m) => m['mode'] == currentMode,
        orElse: () => modes.first,
      );

      // 3. Map to DiscoveryUser (Reuse common mapping logic if possible, otherwise manual)
      // Note: We need to sign URLs here too if we want images.
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

      // Calc age
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

      // Fetch signs for media
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

      // 4. CHECK RELATIONSHIP
      RelationshipState rel = RelationshipState.none;

      // Check Match first (highest priority)
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
        // Check Swipes
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
          // Check if they liked me
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
