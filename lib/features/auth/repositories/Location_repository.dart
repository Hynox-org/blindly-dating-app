import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

class LocationService {
  final SupabaseClient _supabase;

  LocationService(this._supabase);

  Future<void> updateUserLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // 1. Check if GPS is enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // You might want to ask the user to enable it
      return;
    }

    // 2. Check Permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return;
    }

    // 3. Get the Position (Current Location)
    // 'high' accuracy is best for 5km radius checks
    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    await pushLocation(position.latitude, position.longitude);
  }

  /// Writes a fix to `profiles`, together with the district it falls in.
  ///
  /// The district is what Spotlight sells: a purchase reaches everyone whose
  /// stored district matches the buyer's, so it has to be kept current on
  /// every location update rather than resolved once at purchase time.
  /// A failed geocode sends null, and the RPC leaves the previous district
  /// alone — a stale district beats no district, which would make Spotlight
  /// unbuyable.
  Future<void> pushLocation(double lat, double lng) async {
    final district = await resolveDistrict(lat, lng);
    try {
      await _supabase.rpc(
        'update_passport_location',
        params: {'p_lat': lat, 'p_long': lng, 'p_district': district},
      );
      debugPrint(
        '✅ Passport location updated: $lat, $lng (${district ?? '?'})',
      );
    } catch (e) {
      debugPrint('❌ Error updating location: $e');
    }
  }

  /// Reverse-geocodes to a district name via Mapbox. Returns null on any
  /// failure; every caller treats null as "leave what is stored alone".
  static Future<String?> resolveDistrict(double lat, double lng) async {
    final token = dotenv.env['MAPBOX_ACCESS_TOKEN'];
    if (token == null || token.isEmpty) return null;

    try {
      final url = Uri.parse(
        'https://api.mapbox.com/geocoding/v5/mapbox.places/$lng,$lat.json'
        '?access_token=$token&types=district,place&limit=1',
      );
      final response = await http.get(url).timeout(const Duration(seconds: 8));
      if (response.statusCode != 200) return null;

      final features = json.decode(response.body)['features'] as List?;
      if (features == null || features.isEmpty) return null;

      final text = features.first['text'] as String?;
      final trimmed = text?.trim();
      return (trimmed == null || trimmed.isEmpty) ? null : trimmed;
    } catch (e) {
      debugPrint('⚠️ District lookup failed: $e');
      return null;
    }
  }
}
