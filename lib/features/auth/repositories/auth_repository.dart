import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// 1. THE PROVIDER
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(Supabase.instance.client);
});

// 2. THE REPOSITORY
class AuthRepository {
  final SupabaseClient _supabase;

  AuthRepository(this._supabase);

  // --- A. SESSION MANAGEMENT ---
  
  // 1. Stream (Heartbeat)
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  // 2. Getter (Snapshot) -> THIS WAS MISSING
  Session? get currentSession => _supabase.auth.currentSession;
  
  // 3. Current User ID (Helper)
  String? get currentUserId => _supabase.auth.currentUser?.id;

  // --- B. OTP LOGIC ---
  
  Future<void> signInWithOtp(String phone) async {
    try {
      await _supabase.auth.signInWithOtp(
        phone: "+91$phone",
        channel: OtpChannel.sms,
      );
    } catch (e) {
      throw _parseSupabaseError(e);
    }
  }

  Future<void> verifyOtp(String phone, String token) async {
    try {
      await _supabase.auth.verifyOTP(
        type: OtpType.sms,
        token: token,
        phone: "+91$phone",
      );
    } catch (e) {
      throw _parseSupabaseError(e);
    }
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  // --- C. ERROR HANDLING ---
  String _parseSupabaseError(dynamic error) {
    final msg = error.toString();
    if (msg.contains("Service currently unavailable due to hook") || msg.contains("429")) {
      return "⏳ Rate Limit Hit: Please wait 10 minutes.";
    } else if (msg.contains("Token has expired")) {
      return "❌ Invalid or Expired OTP.";
    }
    return "⚠️ Error: ${msg.replaceAll('AuthException:', '').trim()}";
  }
}