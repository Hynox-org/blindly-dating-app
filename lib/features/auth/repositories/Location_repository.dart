import 'package:geolocator/geolocator.dart';
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

    // 4. Send to Supabase (Call the RPC function)
    try {
      await _supabase.rpc('update_passport_location', params: {
        'p_lat': position.latitude,
        'p_long': position.longitude,
      });
      print("✅ Passport Location Updated: ${position.latitude}, ${position.longitude}");
    } catch (e) {
      print("❌ Error updating location: $e");
    }
  }
}