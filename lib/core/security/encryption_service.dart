import 'dart:typed_data';
import 'package:encrypt/encrypt.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'package:pointycastle/export.dart' as pc;

class EncryptionResult {
  final String cipherText;
  final String encryptedKeyForSender;
  final String encryptedKeyForReceiver;
  final String iv;

  EncryptionResult(
    this.cipherText,
    this.encryptedKeyForSender,
    this.encryptedKeyForReceiver,
    this.iv,
  );
}

class DecryptionResult {
  final String text;
  final String? decryptedSymmetricKey; // Base64

  DecryptionResult(this.text, this.decryptedSymmetricKey);
}

class EncryptionService {
  static final _secureStorage = const FlutterSecureStorage();

  static bool _isValidBase64(String str) {
    try {
      base64Decode(str);
      return str.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  static Future<String?> getPrivateKeyPem() async {
    return await _secureStorage.read(key: 'private_key');
  }

  static Future<String?> getPublicKey() async {
    return await _secureStorage.read(key: 'public_key');
  }

  /// Encrypts a message using a hybrid approach:
  /// 1. Use the provided symmetric key OR generate a random 256-bit AES key.
  /// 2. Generate a 96-bit IV (standard for GCM).
  /// 3. Encrypt the message with AES-GCM.
  /// 4. Wraps the AES key for both sender and receiver using RSA-OAEP (SHA-256).
  static Future<EncryptionResult> encryptMessage({
    required String message,
    required String receiverPublicKeyPem,
    String? symmetricKeyBase64, // Optional: reuse an existing match key
  }) async {
    final messageBytes = utf8.encode(message);

    Key aesKey;
    if (symmetricKeyBase64 != null && _isValidBase64(symmetricKeyBase64)) {
      aesKey = Key.fromBase64(symmetricKeyBase64);
    } else {
      // 1. Generate Symmetric Key (32 bytes = 256 bits)
      aesKey = Key.fromSecureRandom(32);
    }

    // 2. Generate IV (12 bytes is the recommended length for AES-GCM)
    final iv = IV.fromSecureRandom(12);

    // 3. Encrypt payload with AES-GCM
    final aesEncrypter = Encrypter(AES(aesKey, mode: AESMode.gcm));
    final encryptedMessage = aesEncrypter.encryptBytes(messageBytes, iv: iv);

    final parser = RSAKeyParser();

    // 4. Wrap key for Receiver
    final receiverPublicKey = parser.parse(receiverPublicKeyPem) as pc.RSAPublicKey;
    final receiverEncrypter = Encrypter(
      RSA(
        publicKey: receiverPublicKey,
        encoding: RSAEncoding.OAEP,
        digest: RSADigest.SHA256,
      ),
    );
    final encryptedKeyForReceiver = receiverEncrypter.encryptBytes(aesKey.bytes);

    // 5. Wrap key for Sender
    final myPublicKeyPem = await getPublicKey();
    if (myPublicKeyPem == null) throw Exception("Sender public key not found");
    final myPublicKey = parser.parse(myPublicKeyPem) as pc.RSAPublicKey;
    final senderEncrypter = Encrypter(
      RSA(
        publicKey: myPublicKey,
        encoding: RSAEncoding.OAEP,
        digest: RSADigest.SHA256,
      ),
    );
    final encryptedKeyForSender = senderEncrypter.encryptBytes(aesKey.bytes);

    return EncryptionResult(
      encryptedMessage.base64,
      encryptedKeyForSender.base64,
      encryptedKeyForReceiver.base64,
      iv.base64,
    );
  }

  /// Decrypts a message:
  /// 1. (Fast Path) Try using the provided cached symmetric key.
  /// 2. (Self-Healing) If decryption fails, unwrap the unique key using RSA and retry.
  static Future<DecryptionResult> decryptMessage({
    required String cipherText,
    required String encryptedKey, // The RSA-wrapped AES key
    required String iv,
    String? symmetricKeyBase64, // Cached unwrapped key
  }) async {
    try {
      if (!_isValidBase64(cipherText) || !_isValidBase64(iv)) {
        throw Exception("Invalid content or IV format");
      }

      // --- ATTEMPT 1: Fast path with cached key ---
      if (symmetricKeyBase64 != null && _isValidBase64(symmetricKeyBase64)) {
        try {
          final aesKey = Key.fromBase64(symmetricKeyBase64);
          final aesDecrypter = Encrypter(AES(aesKey, mode: AESMode.gcm));
          final decryptedBytes = aesDecrypter.decryptBytes(
            Encrypted.fromBase64(cipherText),
            iv: IV.fromBase64(iv),
          );
          return DecryptionResult(utf8.decode(decryptedBytes), symmetricKeyBase64);
        } catch (e) {
          print('⚠️ Cached key failed (likely key mismatch). Retrying with RSA... Error: $e');
          // Fall through to RSA logic below
        }
      }

      // --- ATTEMPT 2: Fallback to RSA unwrapping ---
      if (!_isValidBase64(encryptedKey)) throw Exception("Invalid encrypted key format");

      final privateKeyPem = await _secureStorage.read(key: 'private_key');
      if (privateKeyPem == null) throw Exception("Private key not found locally");

      final parser = RSAKeyParser();
      final privateKey = parser.parse(privateKeyPem) as pc.RSAPrivateKey;

      final rsaDecrypter = Encrypter(
        RSA(
          privateKey: privateKey,
          encoding: RSAEncoding.OAEP,
          digest: RSADigest.SHA256,
        ),
      );

      final aesKeyBytes = rsaDecrypter.decryptBytes(Encrypted.fromBase64(encryptedKey));
      if (aesKeyBytes.length != 32) throw Exception("Invalid unwrapped key length");

      final aesKey = Key(Uint8List.fromList(aesKeyBytes));
      final finalSymmetricKeyBase64 = base64Encode(aesKeyBytes);

      // Decrypt payload with newly unwrapped key
      final aesDecrypter = Encrypter(AES(aesKey, mode: AESMode.gcm));
      final decryptedBytes = aesDecrypter.decryptBytes(
        Encrypted.fromBase64(cipherText),
        iv: IV.fromBase64(iv),
      );

      return DecryptionResult(utf8.decode(decryptedBytes), finalSymmetricKeyBase64);
    } catch (e) {
      print('❌ Decryption failed completely: $e');
      rethrow;
    }
  }
}