import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

final locationRepositoryProvider = Provider((ref) => LocationRepository());

class LocationRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<void> updateLocation(Position position) async {
    try {
      await _supabase.functions.invoke(
        'update-location',
        body: {'latitude': position.latitude, 'longitude': position.longitude},
      );
    } on FunctionException catch (e) {
      // Supabase Function specific error
      throw Exception('Function Error: ${e.status} - ${e.details}');
    } catch (e) {
      throw Exception('Failed to update location: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getDiscoveryFeed({
    double radiusKm = 50.0,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final response = await _supabase.rpc(
        'get_discovery_feed',
        params: {'p_radius_km': radiusKm, 'p_limit': limit, 'p_offset': offset},
      );

      // Postgrest returns a list of dynamic
      return List<Map<String, dynamic>>.from(response as List);
    } catch (e) {
      throw Exception('Failed to fetch discovery feed: $e');
    }
  }
}
