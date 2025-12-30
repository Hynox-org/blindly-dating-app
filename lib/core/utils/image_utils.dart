import 'dart:io';
import 'dart:convert';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class ImageUtils {
  /// Compresses an image file to ensure it fits within API limits (AWS 6MB).
  /// Returns a Base64 string of the compressed image.
  static Future<String?> compressAndConvert(File file) async {
    try {
      final filePath = file.absolute.path;

      // Compress the image
      // - minWidth/minHeight: 1024 ensure it's not too huge (e.g. 4000px)
      // - quality: 85 keeps it looking good but drops size significantly
      final result = await FlutterImageCompress.compressWithFile(
        filePath,
        minWidth: 1024,
        minHeight: 1024,
        quality: 85,
        rotate: 0, // preserve orientation
      );

      if (result == null) {
        print("❌ ImageUtils: Compression returned null.");
        return null;
      }

      // DEBUG: Log the size difference
      final originalSize = await file.length();
      final compressedSize = result.length;
      print("📸 Compression: ${(originalSize / 1024).toStringAsFixed(2)} KB -> ${(compressedSize / 1024).toStringAsFixed(2)} KB");

      // Convert compressed bytes to Base64 string
      return base64Encode(result);

    } catch (e) {
      print("❌ ImageUtils Error: $e");
      return null;
    }
  }
}