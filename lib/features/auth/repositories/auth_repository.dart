import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/utils/app_logger.dart';

class AuthRepository {
  final SupabaseClient _client;

  // List of phone numbers configured as "Test Phone Numbers" in Supabase Dashboard.
  // NOTE: According to Supabase Dashboard, these should NOT have the '+' prefix.
  static const Map<String, String> testNumbers = {
    '919952213571': '123456', // User's number
    '919999999999': '123456', // Generic test number
  };

  AuthRepository(this._client);

  /// Signs in with phone number by sending an OTP via Supabase.
  Future<void> signInWithPhone(String phone) async {
    // Strip the '+' prefix if it exists to match Supabase Test Number configuration
    final formattedPhone = phone.startsWith('+') ? phone.substring(1) : phone;

    AppLogger.info(
      'SUPABASE AUTH: Attempting to sign in with phone (stripped): $formattedPhone',
    );

    try {
      await _client.auth.signInWithOtp(
        phone: formattedPhone,
        shouldCreateUser: true,
      );
      AppLogger.info('SUPABASE AUTH: signInWithOtp call successful');
    } catch (e, stackTrace) {
      AppLogger.error('SUPABASE AUTH: Failed to signInWithOtp', e, stackTrace);
      rethrow;
    }
  }

  /// Verifies the phone OTP via Supabase.
  Future<AuthResponse> verifyPhoneOTP(String phone, String token) async {
    final strippedPhone = phone.startsWith('+') ? phone.substring(1) : phone;

    return await _client.auth.verifyOTP(
      phone: strippedPhone,
      token: token,
      type: OtpType.sms,
    );
  }

  /// Signs in with email by sending an OTP (Magic Link or OTP).
  /// Note: Blindly flow uses OTP according to UI.
  Future<void> signInWithEmail(String email) async {
    await _client.auth.signInWithOtp(email: email, shouldCreateUser: true);
  }

  /// Verifies the email OTP.
  Future<AuthResponse> verifyEmailOTP(String email, String token) async {
    return await _client.auth.verifyOTP(
      email: email,
      token: token,
      type: OtpType.email,
    );
  }

  /// Signs in with email and password.
  Future<AuthResponse> signInWithPassword(String email, String password) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  /// Signs up with email and password.
  Future<AuthResponse> signUpWithEmail(String email, String password) async {
    return await _client.auth.signUp(email: email, password: password);
  }

  /// Sign in with Google (OAuth flow).
  Future<void> signInWithGoogle() async {
    await _client.auth.signInWithOAuth(
      OAuthProvider.google,
      // redirectTo: kIsWeb ? null : 'io.supabase.blindly://login-callback/',
    );
  }

  /// Returns the current user.
  User? get currentUser => _client.auth.currentUser;

  /// Stream of auth state changes.
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  /// Signs out the user.
  Future<void> signOut() async {
    await _client.auth.signOut();
  }
}
