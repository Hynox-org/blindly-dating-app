import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final verificationRepositoryProvider = Provider((ref) {
  return VerificationRepository(Supabase.instance.client);
});

class VerificationRepository {
  final SupabaseClient _supabase;

  VerificationRepository(this._supabase);

  /// 1. CALL EDGE FUNCTION: Get the Veriff URL
  Future<String> createSession() async {
    try {
      // Calls the 'create-veriff-session' Edge Function we deployed
      final response = await _supabase.functions.invoke('create-veriff-session');
      
      final data = response.data;
      if (data == null || data['url'] == null) {
        throw Exception('Failed to generate verification URL');
      }
      
      return data['url'] as String;
    } catch (e) {
      throw Exception('Error creating session: $e');
    }
  }

  /// 2. CALL DB RPC: Check the status (Polling)
  /// We use the 'get_verification_status' SQL function we created.
  Future<Map<String, dynamic>> checkStatus() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not logged in');

      final response = await _supabase.rpc(
        'get_verification_status',
        params: {'p_profile_id': userId},
      );

      return Map<String, dynamic>.from(response);
    } catch (e) {
      throw Exception('Error checking status: $e');
    }
  }
}