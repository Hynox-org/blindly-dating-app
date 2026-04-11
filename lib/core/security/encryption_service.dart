import 'dart:typed_data';
import 'package:encrypt/encrypt.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:basic_utils/basic_utils.dart';
import 'package:pointycastle/export.dart';
import 'dart:convert';
import 'package:pointycastle/pointycastle.dart' as pc;

class EncryptionResult {
  final String cipherText;
  final String encryptedKeyForSender;   // ✅ NEW
  final String encryptedKeyForReceiver; // ✅ NEW
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

  // ==============================
  // ✅ NEW: Base64 Validation Helper
  // ==============================
  static bool _isValidBase64(String str) {
    try {
      base64Decode(str);
      return true;
    } catch (e) {
      return false;
    }
  }

  // ==============================
  // GET PRIVATE KEY
  // ==============================
  static Future<String?> getPrivateKeyPem() async {
    return await _secureStorage.read(key: 'private_key');
  }

  // ==============================
  // GET PUBLIC KEY (optional)
  // ==============================
  static Future<String?> getPublicKey() async {
    return await _secureStorage.read(key: 'public_key');
  }

  // ==============================
  // ENCRYPT MESSAGE
  // ==============================
  static Future<EncryptionResult> encryptMessage({
  required String message,
  required String receiverPublicKeyPem,
}) async {
  print('🔍 ENCRYPT: message length=${message.length}');

  final maxLength = 10000;
  String safeMessage = message.length > maxLength
      ? '${message.substring(0, maxLength)}[truncated]'
      : message;

  final messageBytes = utf8.encode(safeMessage);

  // 🔐 AES
  final aesKey = Key.fromSecureRandom(32);
  final iv = IV.fromSecureRandom(16);

  final aesEncrypter = Encrypter(AES(aesKey, mode: AESMode.cbc));
  final encryptedMessage = aesEncrypter.encryptBytes(messageBytes, iv: iv);

  final parser = RSAKeyParser();

  // ==============================
  // 🔐 Receiver encryption
  // ==============================
  final receiverPublicKey =
      parser.parse(receiverPublicKeyPem) as RSAPublicKey;

  final receiverEncrypter = Encrypter(
    RSA(
      publicKey: receiverPublicKey,
      encoding: RSAEncoding.OAEP,
      digest: RSADigest.SHA256,
    ),
  );

  final encryptedKeyForReceiver =
      receiverEncrypter.encryptBytes(aesKey.bytes);

  // ==============================
  // 🔐 Sender encryption (IMPORTANT FIX)
  // ==============================
  final myPublicKeyPem = await getPublicKey();

  if (myPublicKeyPem == null) {
    throw Exception("Sender public key not found");
  }

  final myPublicKey = parser.parse(myPublicKeyPem) as RSAPublicKey;

  final senderEncrypter = Encrypter(
    RSA(
      publicKey: myPublicKey,
      encoding: RSAEncoding.OAEP,
      digest: RSADigest.SHA256,
    ),
  );

  final encryptedKeyForSender =
      senderEncrypter.encryptBytes(aesKey.bytes);

  print('✅ ENCRYPT SUCCESS');

  return EncryptionResult(
    encryptedMessage.base64,
    encryptedKeyForSender.base64,
    encryptedKeyForReceiver.base64,
    iv.base64,
  );
}
  // ==============================
  // DECRYPT MESSAGE (FULLY FIXED + OPTIMIZED)
  // ==============================
  static Future<DecryptionResult> decryptMessage({
    required String cipherText,
    required String encryptedKey, // will be sender OR receiver key
    required String iv,
    String? symmetricKeyBase64, // ✅ OPTIONAL CACHED KEY
  }) async {
    try {
      if (!_isValidBase64(cipherText) || !_isValidBase64(iv)) {
        throw Exception("Invalid Base64");
      }

      Key aesKey;
      String? finalSymmetricKeyBase64 = symmetricKeyBase64;

      if (symmetricKeyBase64 != null && _isValidBase64(symmetricKeyBase64)) {
        // ✅ FAST PATH: Use cached key
        aesKey = Key(base64Decode(symmetricKeyBase64));
      } else {
        // 🔐 SLOW PATH: Decrypt key using RSA
        final privateKeyPem = await _secureStorage.read(key: 'private_key');
        if (privateKeyPem == null || privateKeyPem.trim().isEmpty) {
          throw Exception("Private key not found or empty in secure storage");
        }
        
        if (encryptedKey.trim().isEmpty || !_isValidBase64(encryptedKey)) {
          throw Exception("Invalid or empty Encrypted Key Base64");
        }

        final parser = RSAKeyParser();
        final privateKey = parser.parse(privateKeyPem) as RSAPrivateKey;

        final rsaDecrypter = Encrypter(
          RSA(
            privateKey: privateKey,
            encoding: RSAEncoding.OAEP,
            digest: RSADigest.SHA256,
          ),
        );

        Uint8List aesKeyBytes;
        try {
          aesKeyBytes = Uint8List.fromList(
            rsaDecrypter.decryptBytes(Encrypted.fromBase64(encryptedKey)),
          );
        } catch (e) {
          print('❌ RSA-OAEP Decryption failed: $e. Attempting PKCS1 fallback...');
          final fallbackCipher = pc.AsymmetricBlockCipher('RSA/PKCS1-v1_5')
            ..init(false, pc.PrivateKeyParameter<pc.RSAPrivateKey>(privateKey));
          aesKeyBytes = Uint8List.fromList(
            fallbackCipher.process(Uint8List.fromList(base64Decode(encryptedKey))),
          );
        }

        if (aesKeyBytes.length != 32) throw Exception("Invalid AES key length");
        aesKey = Key(aesKeyBytes);
        finalSymmetricKeyBase64 = base64Encode(aesKeyBytes);
      }

      final aesDecrypter = Encrypter(AES(aesKey, mode: AESMode.cbc));
      final decryptedBytes = aesDecrypter.decryptBytes(
        Encrypted.fromBase64(cipherText),
        iv: IV.fromBase64(iv),
      );

      return DecryptionResult(
        utf8.decode(decryptedBytes),
        finalSymmetricKeyBase64,
      );
    } catch (e) {
      print('❌ FULL DECRYPT ERROR: $e');
      rethrow;
    }
  }
}