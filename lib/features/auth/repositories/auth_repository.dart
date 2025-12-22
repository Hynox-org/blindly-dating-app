import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/utils/app_logger.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthRepository {
  final SupabaseClient _client;

  static const Map<String, String> testNumbers = {
    '919952213571': '123456',
    '919999999999': '123456',
  };

  AuthRepository(this._client);

  Future<void> signInWithPhone(String phone) async {
    final formattedPhone = phone.startsWith('+') ? phone.substring(1) : phone;
    AppLogger.info('SUPABASE AUTH: Attempting to sign in: $formattedPhone');

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

  Future<AuthResponse> verifyPhoneOTP(String phone, String token) async {
    final strippedPhone = phone.startsWith('+') ? phone.substring(1) : phone;
    return await _client.auth.verifyOTP(
      phone: strippedPhone,
      token: token,
      type: OtpType.sms,
    );
  }

  Future<void> signInWithEmail(String email) async {
    await _client.auth.signInWithOtp(email: email, shouldCreateUser: true);
  }

  Future<AuthResponse> verifyEmailOTP(String email, String token) async {
    return await _client.auth.verifyOTP(
      email: email,
      token: token,
      type: OtpType.email,
    );
  }

  Future<AuthResponse> signInWithPassword(String email, String password) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<AuthResponse> signUpWithEmail(String email, String password) async {
    return await _client.auth.signUp(email: email, password: password);
  }

  // -----------------------------------------------------------------------
  // ✅ FIXED GOOGLE SIGN-IN (Professional Flow)
  // -----------------------------------------------------------------------
  Future<User?> signInWithGoogle() async {
    try {
      AppLogger.info('AUTH_REPO: Starting Google Sign-In');

      // YOUR WEB CLIENT ID
      const webClientId = '278291948676-ofhkifkkovhisslgigf59pnjc9vu0p7m.apps.googleusercontent.com';

      final GoogleSignIn googleSignIn = GoogleSignIn(
        serverClientId: webClientId,
      );

      // 1. Force Account Picker
      // By signing out locally first, we ensure the "Choose Account" 
      // box appears every time.
      await googleSignIn.signOut();

      // 2. Open the Popup
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        AppLogger.info('AUTH_REPO: Google Sign-In cancelled');
        return null; // Return null so UI knows to do nothing
      }

      // 3. Fetch Tokens
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final String? idToken = googleAuth.idToken;
      final String? accessToken = googleAuth.accessToken;

      if (idToken == null) {
        throw Exception('Google ID Token is null');
      }

      // 4. Send to Supabase
      final AuthResponse response = await _client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      AppLogger.info('AUTH_REPO: Google Sign-In successful');
      
      // 5. Return the User object so the UI can navigate immediately
      return response.user;

    } catch (e, stackTrace) {
      AppLogger.error('AUTH_REPO: Google Sign-In failed', e, stackTrace);
      rethrow;
    }
  }

  User? get currentUser => _client.auth.currentUser;
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  // -----------------------------------------------------------------------
  // ✅ STANDARD SIGN OUT
  // -----------------------------------------------------------------------
  Future<void> signOut() async {
    await _client.auth.signOut();
    
    // We use .signOut() instead of .disconnect(). 
    // This clears the local session (so they can pick an account next time),
    // but KEEPS the permissions (so they don't have to "Consent" again).
    try {
      await GoogleSignIn().signOut();
    } catch (_) {}
  }

  Future<void> createProfile(String userId) async {
    try {
      await _client.from('profiles').upsert({'user_id': userId});
      AppLogger.info('AUTH_REPO: Profile created/updated for user: $userId');
    } catch (e, stackTrace) {
      AppLogger.error('AUTH_REPO: Failed to create profile', e, stackTrace);
      throw Exception('Failed to create profile: $e');
    }
  }
}