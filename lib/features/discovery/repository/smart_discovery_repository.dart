import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/models/discovery_user_model.dart';
import '../domain/models/discovery_landing_data.dart';

final smartDiscoveryRepositoryProvider = Provider<SmartDiscoveryRepository>((
  ref,
) {
  return SmartDiscoveryRepository(Supabase.instance.client);
});

class SmartDiscoveryRepository {
  final SupabaseClient _supabase;

  SmartDiscoveryRepository(this._supabase);

  Future<DiscoveryLandingData> getSmartDiscoveryFeed({
    required String mode,
  }) async {
    try {
      final searchMode = mode.toLowerCase();
      // 1. Call the new Edge Function
      final response = await _supabase.functions.invoke(
        'smart-discovery',
        body: {'mode': searchMode},
      );

      if (response.status != 200) {
        throw Exception(
          'Failed to get smart discovery feed: ${response.status}',
        );
      }

      debugPrint('👉 SMART DISCOVERY EDGE FN RAW DATA: ${response.data}');

      // 2. Parse the AWS UUIDs from the Edge Function
      final Map<String, dynamic> responseData = response.data['data'] ?? {};
      final Map<String, List<dynamic>> categories =
          Map<String, List<dynamic>>.from(responseData['categories'] ?? {});

      debugPrint('👉 PARSED CATEGORIES: $categories');

      // 3. Extract all unique UUIDs to fetch profiles in one batch
      final Set<String> allUuids = {};
      categories.forEach((key, uuids) {
        allUuids.addAll(uuids.cast<String>());
      });

      if (allUuids.isEmpty) {
        debugPrint('👉 WARNING: No UUIDs returned from Edge Function/AWS!');
        return DiscoveryLandingData(feeds: {}, lastRefreshedAt: DateTime.now());
      }

      debugPrint('👉 FETCHING THESE UUIDS FROM DB: $allUuids');

      // 4. Fetch the full user profiles for these UUIDs from Supabase
      final profilesResponse = await _supabase
          .from('profiles')
          .select('''
            id,
            display_name,
            birth_date,
            gender,
            work_title,
            profile_modes (
              id,
              bio,
              mode,
              is_active,
              profile_mode_media (
                media_url,
                is_primary,
                created_at,
                is_deleted
              )
            )
          ''')
          .inFilter('id', allUuids.toList())
          .eq('profile_modes.mode', searchMode)
          .eq('profile_modes.is_active', true)
          .eq('profile_modes.profile_mode_media.is_deleted', false);

      // Helper to sign a list of paths
      Future<List<String>> signImages(List<dynamic> rawPaths) async {
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

      // 4.5 Fetch Swipe State for these UUIDs
      final authUserId = _supabase.auth.currentUser?.id;
      final Map<String, String> swipeInteractions = {};

      if (authUserId != null && allUuids.isNotEmpty) {
        // We need the user's profile ID to query the swipes table
        final myProfileResponse = await _supabase
            .from('profiles')
            .select('id')
            .eq('user_id', authUserId)
            .maybeSingle();

        if (myProfileResponse != null) {
          final myProfileId = myProfileResponse['id'] as String;

          // Fetch all swipes from me to these users (typically within the batch, or all-time)
          final swipesResponse = await _supabase
              .from('swipes')
              .select('target_id, action_type')
              .eq('actor_id', myProfileId)
              .inFilter('target_id', allUuids.toList());

          for (var row in swipesResponse) {
            final targetId = row['target_id'] as String;
            final action = row['action_type'] as String;
            swipeInteractions[targetId] = action;
          }
        }
      }

      // Quick dictionary lookup for fetched profiles
      final Map<String, DiscoveryUser> profileLookup = {};

      for (var row in profilesResponse) {
        final profileData = Map<String, dynamic>.from(row);
        final modes = List<dynamic>.from(profileData['profile_modes'] ?? []);

        if (modes.isNotEmpty) {
          final activeMode = modes.first;
          profileData['bio'] = activeMode['bio'];
          profileData['mode_id'] = activeMode['id'];

          // Extract images safely
          final mediaList = List<dynamic>.from(
            activeMode['profile_mode_media'] ?? [],
          );
          mediaList.sort((a, b) {
            // Sort by primary first, then newest
            if (a['is_primary'] == true && b['is_primary'] != true) return -1;
            if (a['is_primary'] != true && b['is_primary'] == true) return 1;
            return (b['created_at'] ?? '').compareTo(a['created_at'] ?? '');
          });

          final rawImages = mediaList
              .map((m) => m['media_url'])
              .take(3)
              .toList();
          profileData['image_urls'] = await signImages(rawImages);

          // Calculate Age dummy (matching standard logic)
          if (profileData['birth_date'] != null) {
            final dob = DateTime.tryParse(profileData['birth_date']);
            if (dob != null) {
              final age = DateTime.now().year - dob.year;
              profileData['age'] = age;
            }
          }

          // Inject swipe action if exists
          final pId = profileData['id'] as String;
          if (swipeInteractions.containsKey(pId)) {
            final dbAction = swipeInteractions[pId]!;
            String uiAction = dbAction; // default

            // Map DB enums to UI states
            if (dbAction == 'like') {
              uiAction = 'liked';
            } else if (dbAction == 'pass') {
              uiAction = 'passed';
            } else if (dbAction == 'super_like') {
              uiAction = 'super_liked';
            }

            profileData['swipe_action'] = uiAction;
          }

          // Format JSON for model
          profileData['profile_id'] = pId;
          profileLookup[pId] = DiscoveryUser.fromJson(profileData);
        }
      }

      // 5. Re-map the UUIDs back into their categories preserving category order
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
}
