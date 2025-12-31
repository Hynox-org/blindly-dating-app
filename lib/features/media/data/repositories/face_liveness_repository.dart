import 'dart:convert';
import 'package:http/http.dart' as http;

class FaceLivenessRepository {
  // --- CONFIGURATION ---
  // 1. Paste the API URL you created in AWS Lambda
  final String _baseUrl = "https://uuzryyufz7.execute-api.ap-south-1.amazonaws.com/default/FaceLivenessBackend"; 
  
  // 2. Paste the password you set in the Python code
  final String _apiKey = "my-secret-pass-2026"; 

  /// Step 1: Call Backend to Start Session
  Future<String?> startLivenessSession() async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          "Content-Type": "application/json",
          "x-api-key": _apiKey, // Sends the password
        },
        body: jsonEncode({"action": "start"}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['session_id'];
      } else {
        print("Error starting session: ${response.body}");
        return null;
      }
    } catch (e) {
      print("Exception starting session: $e");
      return null;
    }
  }

  /// Step 2: Call Backend to Get Result
  Future<Map<String, dynamic>> getLivenessResult(String sessionId) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          "Content-Type": "application/json",
          "x-api-key": _apiKey,
        },
        body: jsonEncode({
          "action": "result", 
          "session_id": sessionId
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {"status": "FAILED", "error": response.body};
      }
    } catch (e) {
      return {"status": "FAILED", "error": e.toString()};
    }
  }
}