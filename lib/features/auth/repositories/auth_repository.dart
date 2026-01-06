import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/utils/app_logger.dart';
import '../../../core/security/jwt_validator.dart';

class AuthRepository {
  final SupabaseClient _client;

  // List of phone numbers configured as "Test Phone Numbers" in Supabase Dashboard.
  // NOTE: According to Supabase Dashboard, these should NOT have the '+' prefix.
  static const Map<String, String> testNumbers = {
    '919952213571': '123456', // User's number
    '919999999999': '123456', // Generic test number
  };

  AuthRepository(this._client);

  /// Checks if the user has exceeded the OTP rate limit (3 attempts per 10 minutes).
  Future<void> _checkOtpRateLimit(String identifier) async {
    final prefs = await SharedPreferences.getInstance();
    final key =
        'otp_limit_${identifier.replaceAll(RegExp(r'\W'), '')}'; // Sanitize key
    final now = DateTime.now().millisecondsSinceEpoch;
    const windowDuration = 10 * 60 * 1000; // 10 minutes in ms
    const maxAttempts = 3;

    List<String> attempts = prefs.getStringList(key) ?? [];

    // Filter attempts within the time window
    attempts.retainWhere((ts) {
      final timestamp = int.tryParse(ts) ?? 0;
      return now - timestamp < windowDuration;
    });

    if (attempts.length >= maxAttempts) {
      AppLogger.warning('AUTH_REPO: Rate limit exceeded for $identifier');
      throw const AuthException(
        'Too many OTP attempts. Please wait 10 minutes before trying again.',
        statusCode: '429',
      );
    }

    // Record new attempt
    attempts.add(now.toString());
    await prefs.setStringList(key, attempts);
  }

  /// Signs in with phone number by sending an OTP via Supabase.
  Future<void> signInWithPhone(String phone) async {
    // Strip the '+' prefix if it exists to match Supabase Test Number configuration
    final formattedPhone = phone.startsWith('+') ? phone.substring(1) : phone;

    // Check Rate Limit before calling API
    await _checkOtpRateLimit(formattedPhone);

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

    final response = await _client.auth.verifyOTP(
      phone: strippedPhone,
      token: token,
      type: OtpType.sms,
    );
    if (response.user != null) {
      await createProfile(response.user!.id);
    }
    return response;
  }

  /// Signs in with email by sending an OTP (Magic Link or OTP).
  /// Note: Blindly flow uses OTP according to UI.
  Future<void> signInWithEmail(String email) async {
    // Check Rate Limit
    await _checkOtpRateLimit(email);

    await _client.auth.signInWithOtp(email: email, shouldCreateUser: true);
  }

  /// Verifies the email OTP.
  Future<AuthResponse> verifyEmailOTP(String email, String token) async {
    final response = await _client.auth.verifyOTP(
      email: email,
      token: token,
      type: OtpType.email,
    );
    if (response.user != null) {
      await createProfile(response.user!.id);
    }
    return response;
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
    try {
      // Web Client ID from Google Cloud Console (for Supabase to verify the token)
      // This is required even for Android/iOS to verify the ID token on the backend.
      final webClientId = dotenv.env['WEB_CLIENT_ID'];
      if (webClientId == null) {
        throw const AuthException('WEB_CLIENT_ID not found in .env');
      }

      final GoogleSignIn googleSignIn = GoogleSignIn(
        serverClientId: webClientId,
      );

      // Force account picker by signing out first
      await googleSignIn.signOut();

      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        throw const AuthException('Sign in cancelled', statusCode: 'CANCELLED');
      }
      final googleAuth = await googleUser.authentication;

      final accessToken = googleAuth.accessToken;
      final idToken = googleAuth.idToken;

      if (idToken == null) {
        throw const AuthException('No ID Token found from Google Sign-In');
      }

      final response = await _client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      if (response.user != null) {
        await createProfile(response.user!.id);
      }

      AppLogger.info('AUTH_REPO: Google Sign-In successful');
    } catch (e, stackTrace) {
      AppLogger.error('AUTH_REPO: Google Sign-In failed', e, stackTrace);
      rethrow;
    }
  }

  /// Returns the current user.
  User? get currentUser => _client.auth.currentUser;

  /// Stream of auth state changes.
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  /// Signs out the user.
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  /// Creates a profile for the user.
  Future<void> createProfile(String userId) async {
    try {
      await _client.from('profiles').upsert({
        'user_id': userId,
      }, onConflict: 'user_id');
      AppLogger.info('AUTH_REPO: Profile created/updated for user: $userId');
    } catch (e, stackTrace) {
      AppLogger.error('AUTH_REPO: Failed to create profile', e, stackTrace);
      throw Exception('Failed to create profile: $e');
    }
  }

  /// Checks if the current session is expired.
  bool isSessionExpired() {
    final session = _client.auth.currentSession;
    if (session == null) {
      return true;
    }
    // Basic expiry check
    final now = DateTime.now();
    if (session.expiresAt != null) {
      final expiresAt = DateTime.fromMillisecondsSinceEpoch(
        session.expiresAt! * 1000,
      );
      return now.isAfter(expiresAt.subtract(const Duration(seconds: 60)));
    }

    // Explicit JWT validation middleware
    if (!JwtValidator.validateToken(session.accessToken)) {
      AppLogger.warning('AUTH_REPO: Session token failed validation.');
      return true;
    }

    return false;
  }

  /// Refreshes the session if needed.
  /// This is usually handled automatically by the SDK, but can be called manually.
  Future<void> recoverSession() async {
    final session = _client.auth.currentSession;
    if (session != null) {
      // Refreshing the session handled by the SDK when making calls,
      // but explicitly we can just get the session which might trigger refresh logic internal to the SDK
      // or we can use refreshSession() if available, but verifyOTP/signIn usually sets this up.
      // For Supabase Flutter v2, refreshing is automatic.
      // If we really need to force a refresh, there isn't a direct public method always exposed easily without a refresh token flow,
      // but effectively checking state is enough.
      // However, if we want to ensure we have a valid session to proceed:
      try {
        await _client.auth.refreshSession();
      } catch (e) {
        AppLogger.error('AUTH_REPO: Failed to refresh session', e);
        // If refresh fails, it likely means the session is truly dead.
      }
    }
  }

  /// Deletes the current user's account.
  /// Tries to call a Supabase RPC function 'delete_user_account'.
  /// If that fails (e.g. function doesn't exist), it falls back to basic sign out.
  Future<void> deleteAccount() async {
    try {
      final user = currentUser;
      if (user != null) {
        try {
          await _client.rpc('delete_user_account');
          AppLogger.info('AUTH_REPO: Account deleted via RPC');
        } catch (rpcError) {
          AppLogger.warning(
            'AUTH_REPO: delete_user_account RPC failed or missing. $rpcError',
          );
        }
      }
    } catch (e, stackTrace) {
      AppLogger.error('AUTH_REPO: Failed to delete account', e, stackTrace);
    } finally {
      await signOut();
    }
  }
}
