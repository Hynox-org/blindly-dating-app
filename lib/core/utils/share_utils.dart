import 'dart:io';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class ShareUtils {
  static Future<void> shareProfile(
    BuildContext context,
    dynamic profile, // Passed dynamically to avoid import casing issues
  ) async {
    try {
      // 1. Prepare Text
      final String shareText =
          "🔥 Check out ${profile.name} on Blindly!\n"
          "🎓 ${profile.age} years old, ${profile.distance.toStringAsFixed(1)} miles away.\n"
          "${profile.bio.isNotEmpty ? "📝 '${profile.bio}'\n\n" : ""}"
          "Open directly in app: https://app.blindly.com/profile/${profile.id}\n\n"
          "Download Blindly now to match!";

      // 2. Try to get their first image
      if (profile.imageUrls.isNotEmpty &&
          profile.imageUrls.first.startsWith('http')) {
        final imageUrl = profile.imageUrls.first;

        // Show loading indicator in UI while downloading
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Preparing profile..."),
            duration: Duration(milliseconds: 1500),
          ),
        );

        final response = await http.get(Uri.parse(imageUrl));

        if (response.statusCode == 200) {
          // Save to temp directory
          final tempDir = await getTemporaryDirectory();
          final file = File('${tempDir.path}/${profile.name}_blindly.jpg');
          await file.writeAsBytes(response.bodyBytes);

          // Share image + text
          // ignore: deprecated_member_use
          await Share.shareXFiles([XFile(file.path)], text: shareText);
          return;
        }
      }

      // 3. Fallback: Share Text Only (if no image or download fails)
      // ignore: deprecated_member_use
      await Share.share(shareText);
    } catch (e) {
      debugPrint("❌ Error sharing profile: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Could not share profile at this time."),
          ),
        );
      }
    }
  }
}
