import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../../../core/utils/app_logger.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';

// 1. Define the possible outcomes
enum ModerationDecision { allow, review, block, error }

class PhotoModerationRepository {
  // Get URL from env
  String get _apiUrl =>
      dotenv.env['AWS_MODERATION_URL'] ??
      "https://2v97f9v05m.execute-api.ap-south-1.amazonaws.com/prod/moderate-photo";

  Future<ModerationDecision> moderateImage({
    required File imageFile,
    required String source, // 'profile', 'verification', or 'chat'
  }) async {
    try {
      // 2. Convert Image to Base64
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);
      // 3. Prepare the JSON Body
      // The API expects "images" as a list
      final body = jsonEncode({
        "images": [base64Image],
        "source": source,
      });

      // 4. Send POST Request to AWS
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {"Content-Type": "application/json"},
        body: body,
      );

      if (response.statusCode != 200) {
        AppLogger.error('Moderation API Error: ${response.statusCode}');
        return ModerationDecision.error;
      }

      // 5. Parse the Result
      final List<dynamic> jsonResponse = jsonDecode(response.body);
      if (jsonResponse.isEmpty) return ModerationDecision.error;

      final result = jsonResponse[0];
      final String decision = result['decision'] ?? 'BLOCK';

      AppLogger.info('Moderation Result: $decision');

      // 6. Return the decision as an Enum
      switch (decision) {
        case 'ALLOW':
          return ModerationDecision.allow;
        case 'REVIEW':
          return ModerationDecision.review;
        case 'BLOCK':
          return ModerationDecision.block;
        default:
          return ModerationDecision.block;
      }
    } catch (e) {
      AppLogger.error('Moderation Exception', e);
      return ModerationDecision.error; // Fail safe (Block if error)
    }
  }
}
