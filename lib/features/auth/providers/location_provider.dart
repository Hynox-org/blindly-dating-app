// features/discovery/providers/location_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:blindly_dating_app/features/auth/repositories/location_repository.dart'; // Adjust import to where you saved the class

final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationService(Supabase.instance.client);
});