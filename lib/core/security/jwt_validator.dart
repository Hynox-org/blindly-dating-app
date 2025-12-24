import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import '../utils/app_logger.dart';

class JwtValidator {
  /// Validates the structure and generic claims of a JWT.
  /// This acts as a client-side middleware check before sending requests.
  static bool validateToken(String token) {
    if (token.isEmpty) return false;

    try {
      // Decode standard JWT
      final jwt = JWT.decode(token);

      // Check Expiry
      if (jwt.payload is Map<String, dynamic>) {
        final payload = jwt.payload as Map<String, dynamic>;

        if (payload.containsKey('exp')) {
          final exp = payload['exp'];
          if (exp is int) {
            final expiryDate = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
            if (DateTime.now().isAfter(expiryDate)) {
              AppLogger.warning('SECURITY: Token expired.');
              return false;
            }
          }
        }

        // Check Not Before (nbf)
        if (payload.containsKey('nbf')) {
          final nbf = payload['nbf'];
          if (nbf is int) {
            final nbfDate = DateTime.fromMillisecondsSinceEpoch(nbf * 1000);
            if (DateTime.now().isBefore(nbfDate)) {
              AppLogger.warning('SECURITY: Token not yet valid.');
              return false;
            }
          }
        }
      }

      return true;
    } catch (e) {
      AppLogger.error('SECURITY: Invalid JWT format.', e);
      return false;
    }
  }
}
