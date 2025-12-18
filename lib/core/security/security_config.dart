import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:firebase_app_check/firebase_app_check.dart';

class SecurityConfig {
  static final _storage = const FlutterSecureStorage();

  // Initialize App Check (Placeholder for Firebase implementation)
  static Future<void> initializeAppCheck() async {
    // Initialize Firebase App Check
    await FirebaseAppCheck.instance.activate(
      androidProvider: AndroidProvider.playIntegrity,
    );
  }

  // SSL/TLS Pinning Configuration
  // WARNING: Replace these hashes with your actual certificate SHA-256 hashes
  static const List<String> _pinnedHashes = [
    'PzfKSv758ttsdJwUCkGhW/oxG9Wk1Y4N+NMkB5I7RXc=', // Supabase.co
  ];

  static List<String> get pinnedHashes => _pinnedHashes;

  // Secure Storage for Tokens
  static Future<void> saveToken(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  // Create a secure HTTP client with SSL Pinning
  static Future<http.Client> getSSLPinnedClient() async {
    final ioClient = HttpClient(
      context: SecurityContext(withTrustedRoots: true),
    );

    ioClient
        .badCertificateCallback = (X509Certificate cert, String host, int port) {
      // 1. Compute SHA-256 of the certificate DER
      final der = cert.der;
      final sha256Hash = sha256.convert(der).bytes;
      final base64Hash = base64Encode(sha256Hash);

      // 2. Check if the hash matches our pinned hashes
      // We check against the hash of the leaf certificate (or intermediate if configured so)
      // Standard public key pinning (HPKP) usually pins the public key, but for simplicity
      // and without external plugins, pinning the cert hash is a common simplified approach in Flutter.
      // However, pinning the Public Key (SPKI) is more robust for rotation.
      // Given the user instructions gave a specific commmand for SHA256 of the CERTIFICATE (via openssl x509... dgst...),
      // we compare the base64 hash.

      bool isValid = _pinnedHashes.contains(base64Hash);

      if (!isValid) {
        // print("SECURITY ALERT: Certificate mismatch! Server presented: $base64Hash");
      }

      return isValid;
    };

    return IOClient(ioClient);
  }

  static Future<String?> getToken(String key) async {
    return await _storage.read(key: key);
  }
}
