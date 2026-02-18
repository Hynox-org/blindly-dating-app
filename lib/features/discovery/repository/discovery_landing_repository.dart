import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/models/discovery_user_model.dart';

final discoveryLandingRepositoryProvider = Provider<DiscoveryLandingRepository>(
  (ref) {
    return DiscoveryLandingRepository(Supabase.instance.client);
  },
);

class DiscoveryLandingRepository {
  final SupabaseClient _supabase;

  DiscoveryLandingRepository(this._supabase);

  Future<Map<String, List<DiscoveryUser>>> getDiscoveryLandingFeed({
    required double lat,
    required double long,
    int radiusKm = 100,
    String? mode, // Accepts 'date', 'bff', etc.
  }) async {
    try {
      final response = await _supabase.rpc(
        'get_discovery_landing_feed',
        params: {
          'current_lat': lat,
          'current_long': long,
          'radius_km': radiusKm,
          'limit_per_category': 10,
          'p_mode_override': mode, // Pass the override
        },
      );

      final Map<String, dynamic> data = Map<String, dynamic>.from(response);
      final Map<String, List<DiscoveryUser>> result = {};

      // Helper to sign a list of paths
      Future<List<String>> signImages(List<dynamic> rawPaths) async {
        final List<String> signedUrls = [];
        const String bucketName = 'user_photos'; // Correct bucket name

        for (var item in rawPaths) {
          String path = item.toString();
          if (path.isNotEmpty) {
            try {
              // If it's already a full URL, try to extract path if it matches our bucket
              // Otherwise treat as path
              if (path.startsWith('http')) {
                if (path.contains('/$bucketName/')) {
                  final parts = path.split('/$bucketName/');
                  if (parts.length > 1) {
                    path = parts.last.split('?').first;
                    path = Uri.decodeComponent(path);
                  }
                } else {
                  // External or other bucket, just keep as is
                  signedUrls.add(path);
                  continue;
                }
              }

              // Remove leading slash if any
              if (path.startsWith('/')) path = path.substring(1);

              final signedUrl = await _supabase.storage
                  .from(bucketName)
                  .createSignedUrl(path, 60 * 60);
              signedUrls.add(signedUrl);
            } catch (e) {
              debugPrint('Error signing image: $path, $e');
              // Fallback to original if signing fails
              signedUrls.add(path);
            }
          }
        }
        return signedUrls;
      }

      // Proccess categories in parallel or sequence
      for (var category in data.keys) {
        final List<dynamic> rawUsers = data[category] ?? [];
        final List<DiscoveryUser> processedUsers = [];

        for (var u in rawUsers) {
          final userData = Map<String, dynamic>.from(u);

          // Sign images
          final List<dynamic> rawImages = userData['image_urls'] ?? [];
          final signed = await signImages(rawImages);
          userData['image_urls'] = signed;

          processedUsers.add(DiscoveryUser.fromJson(userData));
        }
        result[category] = processedUsers;
      }

      return result;
    } catch (e) {
      debugPrint('Error fetching discovery landing feed: $e');
      rethrow;
    }
  }
}
