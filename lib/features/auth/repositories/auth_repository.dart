import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../core/utils/app_logger.dart';
import '../../../core/security/jwt_validator.dart';

class AuthRepository {
  final SupabaseClient _client;

  // List of phone numbers configured as "Test Phone Numbers" in Supabase Dashboard.
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
    final formattedPhone = phone.startsWith('+') ? phone.substring(1) : phone;

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
  Future<void> signInWithEmail(String email) async {
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

  /// Sign in with Google (OAuth flow) - NATIVE FLOW (v7.0.0+)
  Future<void> signInWithGoogle() async {
    AppLogger.info('AUTH_REPO: Starting Google Sign-In flow');
    try {
      final webClientId = dotenv.env['WEB_CLIENT_ID'];
      if (webClientId == null) {
        throw const AuthException('WEB_CLIENT_ID not found in .env');
      }

      final GoogleSignIn googleSignIn = GoogleSignIn.instance;

      // 1. Initialize Configuration (Required in v7)
      AppLogger.info('AUTH_REPO: Initializing GoogleSignIn');
      await googleSignIn.initialize(serverClientId: webClientId);

      // Force account picker by signing out first
      AppLogger.info('AUTH_REPO: Signing out from local Google session');
      try {
        await googleSignIn.signOut();
      } catch (e) {
        AppLogger.warning('AUTH_REPO: Local Google signOut failed: $e');
      }

      // 2. Authenticate
      AppLogger.info('AUTH_REPO: Calling googleSignIn.authenticate()');
      final GoogleSignInAccount? googleUser;
      try {
        googleUser = await googleSignIn.authenticate();
      } catch (e) {
        AppLogger.warning('AUTH_REPO: Google Sign-In call failed: $e');
        if (e.toString().contains('network_error')) {
          throw const AuthException('Network error during Google Sign-In');
        }
        rethrow;
      }

      // 3. Get Tokens (authentication is a GETTER in 7.0+)
      AppLogger.info('AUTH_REPO: Retrieving authentication tokens');
      final googleAuth = googleUser.authentication;
      final idToken = googleAuth.idToken;

      if (idToken == null) {
        AppLogger.error('AUTH_REPO: No ID Token found in googleAuth');
        throw const AuthException('No ID Token found from Google Sign-In');
      }

      // 4. Sign in to Supabase
      AppLogger.info('AUTH_REPO: Signing in to Supabase with ID Token');
      final response = await _client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
      );

      if (response.user != null) {
        AppLogger.info('AUTH_REPO: Supabase auth successful, creating/updating profile');
        await createProfile(response.user!.id);
      }

      AppLogger.info('AUTH_REPO: Google Sign-In flow completed successfully');
    } catch (e, stackTrace) {
      if (e is AuthException) {
        AppLogger.warning('AUTH_REPO: Google Sign-In AuthException: ${e.message}');
        rethrow;
      }
      AppLogger.error('AUTH_REPO: Unexpected failure in signInWithGoogle', e, stackTrace);
      rethrow;
    }
  }

  /// Returns the current user.
  User? get currentUser => _client.auth.currentUser;

  /// Stream of auth state changes.
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  /// Signs out the user and purges all cached app state.
  Future<void> signOut() async {
    try {
      // 1. Sign out of Supabase
      await _client.auth.signOut();

      // 2. Sign out of Google locally
      try {
        await GoogleSignIn.instance.signOut();
      } catch (e) {
        AppLogger.warning('AUTH_REPO: Local Google signOut failed: $e');
      }

      // 3. Clear local SharedPreferences (OTP rate limits, cached session tokens, user flags)
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();
        AppLogger.info('AUTH_REPO: SharedPreferences cleared on signOut');
      } catch (e) {
        AppLogger.error('AUTH_REPO: Failed to clear SharedPreferences: $e');
      }

      // 4. Clear Hive local cache (chat cache, match keys)
      try {
        if (Hive.isBoxOpen('chat_cache')) {
          await Hive.box('chat_cache').clear();
        }
        if (Hive.isBoxOpen('match_keys')) {
          await Hive.box('match_keys').clear();
        }
        AppLogger.info('AUTH_REPO: Hive boxes cleared on signOut');
      } catch (e) {
        AppLogger.error('AUTH_REPO: Failed to clear Hive boxes: $e');
      }
    } catch (e, stackTrace) {
      AppLogger.error('AUTH_REPO: Exception during signOut: $e', e, stackTrace);
      rethrow;
    }
  }

  /// Creates a profile for the user and initializes default 'date' mode.
  Future<void> createProfile(String userId) async {
    try {
      final profileResponse = await _client
          .from('profiles')
          .upsert({'user_id': userId}, onConflict: 'user_id')
          .select('id')
          .single();

      final profileId = profileResponse['id'] as String;

      await _client.from('profile_modes').upsert([
        {'profile_id': profileId, 'mode': 'date', 'is_active': true},
        {'profile_id': profileId, 'mode': 'bff', 'is_active': true},
      ], onConflict: 'profile_id, mode');

      AppLogger.info(
        'AUTH_REPO: Profile and default Mode created/updated for user: $userId',
      );
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
    final now = DateTime.now();
    if (session.expiresAt != null) {
      final expiresAt = DateTime.fromMillisecondsSinceEpoch(
        session.expiresAt! * 1000,
      );
      return now.isAfter(expiresAt.subtract(const Duration(seconds: 60)));
    }

    if (!JwtValidator.validateToken(session.accessToken)) {
      AppLogger.warning('AUTH_REPO: Session token failed validation.');
      return true;
    }

    return false;
  }

  /// Refreshes the session if needed.
  Future<void> recoverSession() async {
    final session = _client.auth.currentSession;
    if (session != null) {
      try {
        await _client.auth.refreshSession();
      } catch (e) {
        AppLogger.error('AUTH_REPO: Failed to refresh session', e);
      }
    }
  }

  /// Deletes the current user's account.
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
