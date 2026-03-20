import 'dart:typed_data';
import 'package:encrypt/encrypt.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:basic_utils/basic_utils.dart';
import 'package:pointycastle/export.dart';
import 'dart:convert'; // For utf8.encode/decode
// import 'package:pointycastle/src/parser/pem_parser.dart'; // Add this import

class EncryptionResult {
  final String cipherText;
  final String encryptedKey;
  final String iv;

  EncryptionResult(this.cipherText, this.encryptedKey, this.iv);
}

class EncryptionService {
  static final _secureStorage = const FlutterSecureStorage();

  // ==============================
  // GET PRIVATE KEY
  // ==============================
  static Future<String?> getPrivateKeyPem() async {
    return await _secureStorage.read(key: 'private_key');
  }

  // ==============================
  // ❌ REMOVE THIS (IMPORTANT)
  // ==============================
  // DO NOT generate keys here anymore
  // KeyService is responsible for key generation

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
    print('🔍 ENCRYPT: message length=${message.length}'); // DEBUG

    // ✅ 10k char LIMIT (safe for AES CBC + Base64)
    final maxLength = 10000;
    String safeMessage = message.length > maxLength
        ? message.substring(0, maxLength) + '[truncated]'
        : message;

    // ✅ UTF-8 encode FIRST
    final messageBytes = utf8.encode(safeMessage);
    print('🔍 ENCRYPT: bytes length=${messageBytes.length}'); // DEBUG

    final aesKey = Key.fromSecureRandom(32);
    final iv = IV.fromSecureRandom(16);

    // ✅ CBC + PKCS7 (default)
    final aesEncrypter = Encrypter(AES(aesKey, mode: AESMode.cbc,));

    // ✅ CRITICAL: encrypt BYTES not string
    final encryptedMessage = aesEncrypter.encryptBytes(messageBytes, iv: iv);

    final parser = RSAKeyParser();
    final publicKey = parser.parse(receiverPublicKeyPem) as RSAPublicKey;
    final rsaEncrypter = Encrypter(
      RSA(
        publicKey: publicKey,
        encoding: RSAEncoding.OAEP,
        digest: RSADigest.SHA256, // ✅ must match decrypt
      ),
    );
    final encryptedKey = rsaEncrypter.encryptBytes(aesKey.bytes);

    print('✅ ENCRYPT SUCCESS'); // DEBUG
    return EncryptionResult(
      encryptedMessage.base64,
      encryptedKey.base64,
      iv.base64,
    );
  }

  // ==============================
  // DECRYPT MESSAGE
  // ==============================
// ... other imports remain the same

static Future<String> decryptMessage({
  required String cipherText,
  required String encryptedKey,
  required String iv,
}) async {
  final privateKeyPem = await _secureStorage.read(key: 'private_key');

  if (privateKeyPem == null) {
    throw Exception("Private key not found");
  }

  // ✅ Proper PEM parsing (handles PKCS#1 & PKCS#8 automatically)
  final parser = RSAKeyParser();
  final privateKey = parser.parse(privateKeyPem) as RSAPrivateKey;

  final rsaDecrypter = Encrypter(
    RSA(
      privateKey: privateKey,
      encoding: RSAEncoding.OAEP,
      digest: RSADigest.SHA256,
    ),
  );

  // ✅ Decrypt AES key
  final aesKeyBytes =
      rsaDecrypter.decryptBytes(Encrypted.fromBase64(encryptedKey));

  final aesKey = Key(Uint8List.fromList(aesKeyBytes));
  final aesEncrypter = Encrypter(AES(aesKey, mode: AESMode.cbc));

  final decryptedBytes = aesEncrypter.decryptBytes(
    Encrypted.fromBase64(cipherText),
    iv: IV.fromBase64(iv),
  );

  return utf8.decode(decryptedBytes);
}
}
