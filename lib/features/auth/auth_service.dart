import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // 1. Send OTP (Step 1)
  Future<void> sendOtp(String phoneNumber) async {
    try {
      await _supabase.auth.signInWithOtp(
        phone: phoneNumber,
        // isWeb: true, // Uncomment if testing on Web
      );
      print("✅ OTP Sent to $phoneNumber");
    } catch (e) {
      print("❌ Error Sending OTP: $e");
      rethrow; // Pass error to UI to show alert
    }
  }

  // 2. Verify OTP (Step 2)
  Future<AuthResponse> verifyOtp(String phoneNumber, String otp) async {
    try {
      final response = await _supabase.auth.verifyOTP(
        type: OtpType.sms,
        token: otp,
        phone: phoneNumber,
      );
      
      print("✅ Login Success! User ID: ${response.user?.id}");
      return response;
    } catch (e) {
      print("❌ Invalid OTP: $e");
      rethrow;
    }
  }

  // 3. Logout (Utility)
  Future<void> signOut() async {
    await _supabase.auth.signOut();
    print("✅ Signed out");
  }
  
  // 4. Check if Logged In
  User? getCurrentUser() {
    return _supabase.auth.currentUser;
  }
}