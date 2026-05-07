import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class IcebreakerResponse {
  final Map<String, String> bothProfiles;
  final Map<String, String> recipientOnly;

  IcebreakerResponse({
    required this.bothProfiles,
    required this.recipientOnly,
  });

  factory IcebreakerResponse.fromJson(Map<String, dynamic> json) {
    final icebreakers = json['icebreakers'] as Map<String, dynamic>;
    
    return IcebreakerResponse(
      bothProfiles: Map<String, String>.from(icebreakers['both_profiles']),
      recipientOnly: Map<String, String>.from(icebreakers['recipient_only']),
    );
  }
}

class IcebreakerService {
  static Future<IcebreakerResponse?> fetchAiIcebreakers({
    required String senderId,
    required String recipientId,
  }) async {
    try {
      final url = dotenv.get('AWS_ICEBREAKER_URL');
      if (url.isEmpty) {
        print('❌ AWS_ICEBREAKER_URL is not set in .env');
        return null;
      }

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'sender_id': senderId,
          'recipient_id': recipientId,
        }),
      ).timeout(const Duration(seconds: 120));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return IcebreakerResponse.fromJson(data);
        }
      }
      
      print('❌ Icebreaker API error: ${response.statusCode} - ${response.body}');
      return null;
    } catch (e) {
      print('❌ Icebreaker Service error: $e');
      return null;
    }
  }
}
