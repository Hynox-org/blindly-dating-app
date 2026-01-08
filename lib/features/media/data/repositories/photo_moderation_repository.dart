import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

// CHECK YOUR IMPORTS:
import '../../../../core/utils/app_logger.dart';
import '../../../../core/utils/image_utils.dart'; // <--- Critical: Import the helper

// 1. Define the possible outcomes
enum ModerationDecision { allow, review, block, error }

// 2. Create a Result Class to hold both Decision AND Reason
class ModerationResult {
  final ModerationDecision decision;
  final String? reason; // The user-friendly message from Lambda

  ModerationResult(this.decision, {this.reason});
}

class PhotoModerationRepository {
  // Get URL from env
  String get _apiUrl =>
      dotenv.env['AWS_MODERATION_URL'] ??
      "https://2v97f9v05m.execute-api.ap-south-1.amazonaws.com/prod/moderate-photo";

  // CHANGED: Returns ModerationResult instead of just the Enum
  Future<ModerationResult> moderateImage({
    required File imageFile,
    required String source, // 'profile', 'verification', or 'chat'
  }) async {
    try {
      AppLogger.info("🔄 Compressing and sending image...");

      // 3. COMPRESS & CONVERT (Fixes 6MB Limit / 500 Error)
      final String? base64Image = await ImageUtils.compressAndConvert(
        imageFile,
      );

      if (base64Image == null) {
        AppLogger.error('❌ Moderation Error: Image compression failed');
        return ModerationResult(
          ModerationDecision.error,
          reason: "Could not process image.",
        );
      }

      // 4. Prepare the JSON Body
      final body = jsonEncode({
        "images": [base64Image],
        "source": source,
      });

      // 5. Send POST Request to AWS
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {"Content-Type": "application/json"},
        body: body,
      );

      if (response.statusCode != 200) {
        AppLogger.error('❌ Moderation API Error: ${response.body}');
        return ModerationResult(
          ModerationDecision.error,
          reason: "Server Error: ${response.statusCode}",
        );
      }

      // 6. Parse the Result
      final List<dynamic> jsonResponse = jsonDecode(response.body);
      if (jsonResponse.isEmpty) {
        return ModerationResult(
          ModerationDecision.error,
          reason: "Empty response from server.",
        );
      }

      final result = jsonResponse[0];
      final String decisionStr = result['decision'] ?? 'BLOCK';

      // CAPTURE THE REASON (This comes from your Lambda)
      final String? reasonStr = result['reason'];

      if (decisionStr == 'BLOCK') {
        AppLogger.info('❌ BLOCKED: $reasonStr');
      } else {
        AppLogger.info('✅ ALLOWED');
      }

      // 7. Map String to Enum
      ModerationDecision decisionEnum;
      switch (decisionStr) {
        case 'ALLOW':
          decisionEnum = ModerationDecision.allow;
          break;
        case 'REVIEW':
          decisionEnum = ModerationDecision.review;
          break;
        case 'BLOCK':
          decisionEnum = ModerationDecision.block;
          break;
        default:
          decisionEnum = ModerationDecision.block;
      }

      // 8. Return the full result object
      return ModerationResult(decisionEnum, reason: reasonStr);
    } catch (e) {
      AppLogger.error('Moderation Exception', e);
      return ModerationResult(
        ModerationDecision.error,
        reason: "Connection failed. Please check internet.",
      );
    }
  }
}
