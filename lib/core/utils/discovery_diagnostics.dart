import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../features/auth/providers/auth_providers.dart';
import 'package:geolocator/geolocator.dart';
import '../../features/location/data/location_repository.dart';

class DiscoveryDiagnostics {
  static Future<void> fixProfile(WidgetRef ref) async {
    final supabase = Supabase.instance.client;
    final user = ref.read(authRepositoryProvider).currentUser;

    if (user == null) {
      debugPrint('🔴 Fixer: User is null');
      return;
    }

    debugPrint('🔧 STARTING DISCOVERY FIXER for ${user.id} 🔧');

    try {
      // 1. Fetch Profile to get Gender
      final profile = await supabase
          .from('profiles')
          .select('id, gender')
          .eq('user_id', user.id)
          .maybeSingle();

      if (profile == null) {
        debugPrint('🔴 Fixer: Profile NOT FOUND');
        return;
      }

      final gender = profile['gender'] as String?;
      debugPrint('   Current Gender: $gender');

      // 4. Update Location (Use Repository)
      debugPrint('   Updating Location...');
      try {
        // Check permission strictly
        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
        }

        if (permission == LocationPermission.whileInUse ||
            permission == LocationPermission.always) {
          final position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.medium,
          );
          debugPrint(
            '   Got Position: ${position.latitude}, ${position.longitude}',
          );

          // Call Repo
          await ref.read(locationRepositoryProvider).updateLocation(position);
          debugPrint('🟢 Location Repository Call SUCCESS');

          // Also try direct RPC just in case repo fails or is different logic
          await Supabase.instance.client.rpc(
            'update_passport_location',
            params: {'p_lat': position.latitude, 'p_long': position.longitude},
          );
          debugPrint('🟢 Passport RPC Call SUCCESS');
        } else {
          debugPrint('🔴 Location Permission Denied');
        }
      } catch (e) {
        debugPrint('🔴 Location Fix Failed: $e');
      }
    } catch (e) {
      debugPrint('🔴 Fixer Error: $e');
    }
    debugPrint('🔧 FIX COMPLETE - PLEASE RE-RUN DIAGNOSTICS 🔧');
  }

  static Future<void> runDiagnostics(WidgetRef ref) async {
    // ... existing diagnostics logic ...
    // For now, I'll keep runDiagnostics as READ ONLY.
    // I will modify HomeScreen to call fixProfile.
    final supabase = Supabase.instance.client;
    final user = ref.read(authRepositoryProvider).currentUser;

    if (user == null) {
      debugPrint('🔴 Diagnostics: User is null');
      return;
    }

    debugPrint('🔵 STARTING DISCOVERY DIAGNOSTICS for ${user.id} 🔵');

    try {
      // 1. Check Profile
      final profile = await supabase
          .from('profiles')
          .select()
          .eq('user_id', user.id)
          .maybeSingle();

      if (profile == null) {
        debugPrint('🔴 Profile: NOT FOUND');
      } else {
        debugPrint('🟢 Profile: FOUND');
        debugPrint('   ID: ${profile['id']}');
        debugPrint('   Gender: ${profile['gender']}');
        // debugPrint('   Looking For: ${profile['looking_for']}'); // REMOVED
        debugPrint(
          '   Location: ${profile['location_geom'] != null ? "Present" : "NULL"}',
        );
        debugPrint('   City: ${profile['city']}');

        // AUTO-FIX SUGGESTION
        if (profile['location_geom'] == null) {
          debugPrint('⚠️ CRITICAL DATA MISSING. ATTEMPTING AUTO-FIX...');
          await fixProfile(ref);
          // Re-run diagnostics recursively? No, just finish.
          debugPrint('⚠️ AUTO-FIX RAN. PLEASE TAP BUTTON AGAIN.');
          return;
        }
      }

      if (profile == null) return;
      final profileId = profile['id'];

      // 2. Check Modes
      final modes = await supabase
          .from('profile_modes')
          .select()
          .eq('profile_id', profileId);

      debugPrint('🟡 Profile Modes: ${modes.length} found');
      for (final m in modes) {
        debugPrint(
          '   Mode: ${m['mode']} | Active: ${m['is_active']} | Bio: ${m['bio']}',
        );
      }

      // 3. Test RPC Call
      debugPrint('🟣 Testing RPC get_discovery_feed_v2...');
      try {
        final rpcResult = await supabase.rpc(
          'get_discovery_feed_v2',
          params: {
            'p_mode': 'date',
            'p_radius_meters': 10000000, // 10,000 km
            'p_limit': 10,
            'p_offset': 0,
          },
        );
        final list = rpcResult as List;
        debugPrint('🟣 RPC Result Count: ${list.length}');
        if (list.isNotEmpty) {
          debugPrint('   Sample: ${list.first}');
        }
      } catch (e) {
        debugPrint('🔴 RPC Failed: $e');
      }
    } catch (e) {
      debugPrint('🔴 Diagnostics Error: $e');
    }
    debugPrint('🔵 DIAGNOSTICS COMPLETE 🔵');
  }
}
