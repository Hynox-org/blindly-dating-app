import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:basic_utils/basic_utils.dart';
import 'package:encrypt/encrypt.dart';

class KeyService {
  static final _storage = const FlutterSecureStorage();
  static final _supabase = Supabase.instance.client;

  static Future<void> generateAndStoreKeys(String userId) async {
    final existingPrivate = await _storage.read(key: 'private_key');
    final existingPublic = await _storage.read(key: 'public_key');

    bool keysNeedRegeneration = false;

    if (existingPrivate == null || existingPublic == null) {
      print("🔐 Keys missing. Need regeneration.");
      keysNeedRegeneration = true;
    } else {
      // ✅ SELF-TEST: Verify if private and public keys actually match
      print("🔐 Existing keypair found locally. Running self-test...");
      final isHealthy = await _validateKeypair(existingPrivate, existingPublic);
      if (!isHealthy) {
        print("⚠️ LOCAL KEYPAIR CORRUPTED (Mismatch). Forcing regeneration...");
        keysNeedRegeneration = true;
      } else {
        print("✅ Local keypair is healthy.");
      }
    }

    String publicPem;

    if (keysNeedRegeneration) {
      final pair = CryptoUtils.generateRSAKeyPair(keySize: 2048);
      final privateKey = pair.privateKey as RSAPrivateKey;
      final publicKey = pair.publicKey as RSAPublicKey;

      final privatePem = CryptoUtils.encodeRSAPrivateKeyToPem(privateKey);
      publicPem = CryptoUtils.encodeRSAPublicKeyToPem(publicKey);

      await _storage.write(key: 'private_key', value: privatePem);
      await _storage.write(key: 'public_key', value: publicPem);

      print("✨ Fresh keypair generated & stored");
    } else {
      publicPem = existingPublic!;
    }

    // ✅ ENHANCED SYNC: Verify if server has the SAME public key
    try {
      final thumbprint = publicPem.substring(publicPem.length - 20).replaceAll('\n', '').trim();
      print("🔐 Local Public Key Thumbprint: ...$thumbprint");

      final profileRes = await _supabase
          .from('profiles')
          .select('public_key')
          .eq('user_id', userId)
          .maybeSingle();

      final serverPublicKey = profileRes?['public_key'];

      // Normalize for comparison
      final normalizedServerKey = serverPublicKey?.replaceAll('\r', '').trim();
      final normalizedLocalKey = publicPem.replaceAll('\r', '').trim();

      if (normalizedServerKey == null || normalizedServerKey != normalizedLocalKey) {
        print("🔄 Server key mismatch or missing. Syncing...");
        await _supabase
            .from('profiles')
            .update({'public_key': publicPem})
            .eq('user_id', userId);
        print("✅ Public key synchronized to DB for user: $userId");
      } else {
        print("✅ Public key verified on server (Thumbprint matches).");
      }
    } catch (e) {
      print("❌ Public key sync failed: $e");
      try {
        await _supabase
            .from('profiles')
            .update({'public_key': publicPem})
            .eq('user_id', userId);
      } catch (_) {}
    }
  }

  // ✅ CRYPTO SELF-TEST
  static Future<bool> _validateKeypair(String privatePem, String publicPem) async {
    try {
      final parser = RSAKeyParser();
      final privateKey = parser.parse(privatePem) as RSAPrivateKey;
      final publicKey = parser.parse(publicPem) as RSAPublicKey;

      final testPlaintext = "validation_test_${DateTime.now().millisecondsSinceEpoch}";
      
      // Encrypt with Public
      final encrypter = Encrypter(RSA(publicKey: publicKey, encoding: RSAEncoding.OAEP, digest: RSADigest.SHA256));
      final encrypted = encrypter.encrypt(testPlaintext);
      
      // Decrypt with Private
      final decrypter = Encrypter(RSA(privateKey: privateKey, encoding: RSAEncoding.OAEP, digest: RSADigest.SHA256));
      final decoded = decrypter.decrypt(encrypted);

      return decoded == testPlaintext;
    } catch (e) {
      print("❌ Self-test error: $e");
      return false;
    }
  }
}
