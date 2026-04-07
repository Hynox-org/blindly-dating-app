import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:basic_utils/basic_utils.dart';

class KeyService {
  static final _storage = const FlutterSecureStorage();
  static final _supabase = Supabase.instance.client;

  static Future<void> generateAndStoreKeys(String userId) async {
    final existingPrivate = await _storage.read(key: 'private_key');
    final existingPublic = await _storage.read(key: 'public_key');

    String publicPem;

    if (existingPrivate == null || existingPublic == null) {
      final pair = CryptoUtils.generateRSAKeyPair(keySize: 2048);
      final privateKey = pair.privateKey as RSAPrivateKey;
      final publicKey = pair.publicKey as RSAPublicKey;

      final privatePem = CryptoUtils.encodeRSAPrivateKeyToPem(privateKey);
      publicPem = CryptoUtils.encodeRSAPublicKeyToPem(publicKey);

      await _storage.write(key: 'private_key', value: privatePem);
      await _storage.write(key: 'public_key', value: publicPem);

      print("🔐 New keypair generated & stored");
    } else {
      print("🔐 Existing keypair found");
      publicPem = existingPublic; // ✅ Direct reuse
    }

    // ✅ ALWAYS upload public key
    try {
      final response = await _supabase
    .from('profiles')
    .update({'public_key': publicPem})
    .eq('user_id', userId)
    .select(); // 👈 REQUIRED to get updated data

print("🔍 SUPABASE UPDATE RESPONSE:");
print(response);
      print("✅ Public key ensured in DB for user: $userId");
    } catch (e) {
      print("❌ Public key upload failed: $e");
    }
  }
}