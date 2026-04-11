import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:basic_utils/basic_utils.dart';
import 'package:pointycastle/export.dart';

class KeyService {
  static final _storage = const FlutterSecureStorage();
  static final _supabase = Supabase.instance.client;

  /// Generates a new 2048-bit RSA keypair if not already present.
  /// Then ensures the public key is uploaded to the backend.
  static Future<void> generateAndStoreKeys(String userId) async {
    final existingPrivate = await _storage.read(key: 'private_key');
    final existingPublic = await _storage.read(key: 'public_key');

    String publicPem;

    if (existingPrivate == null || existingPublic == null) {
      print("🔐 Generating new 2048-bit RSA keypair...");
      final pair = CryptoUtils.generateRSAKeyPair(keySize: 2048);
      final privateKey = pair.privateKey as RSAPrivateKey;
      final publicKey = pair.publicKey as RSAPublicKey;

      final privatePem = CryptoUtils.encodeRSAPrivateKeyToPem(privateKey);
      publicPem = CryptoUtils.encodeRSAPublicKeyToPem(publicKey);

      await _storage.write(key: 'private_key', value: privatePem);
      await _storage.write(key: 'public_key', value: publicPem);

      print("✅ New keypair generated & stored locally");
    } else {
      print("🔐 Existing keypair found locally");
      publicPem = existingPublic;
    }

    // Always ensure the backend has the matching public key
    await _syncPublicKeyWithBackend(userId, publicPem);
  }

  static Future<void> _syncPublicKeyWithBackend(String userId, String publicPem) async {
    try {
      final response = await _supabase
          .from('profiles')
          .update({'public_key': publicPem})
          .eq('user_id', userId)
          .select();

      if (response.isNotEmpty) {
        print("✅ Public key synced with backend for user: $userId");
      } else {
        print("⚠️ Public key sync returned empty response. Check RLS or user_id.");
      }
    } catch (e) {
      print("❌ Public key sync failed: $e");
    }
  }

  /// Force regeneration of keys (useful if padding schemes change or keys are compromised)
  static Future<void> rotateKeys(String userId) async {
    await _storage.delete(key: 'private_key');
    await _storage.delete(key: 'public_key');
    await generateAndStoreKeys(userId);
  }
}