import 'dart:convert';
import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:blindly_dating_app/core/utils/app_logger.dart';

enum PhotoDecision {
  /// Passed, and already in storage at [PhotoModerationResult.path].
  allow,

  /// The photo itself is the problem. The user has to pick a different one.
  reject,

  /// Something on our side went wrong. Worth retrying with the same photo.
  failure,
}

/// One verdict, for one photo.
///
/// [code] is a stable identifier the screen turns into localized copy -- the
/// service never sends prose, because the app speaks six languages and it
/// speaks none of them.
class PhotoModerationResult {
  final PhotoDecision decision;
  final String code;

  /// Storage path inside the `user_photos` bucket. Only ever set on [allow]:
  /// the service uploads what it accepts, so a rejected photo has no path and
  /// nothing to hand to the database later.
  final String? path;

  const PhotoModerationResult(this.decision, this.code, {this.path});

  const PhotoModerationResult.failure(this.code)
    : decision = PhotoDecision.failure,
      path = null;
}

class PhotoModerationRepository {
  static const int maxPhotos = 6;

  /// Six photos, two Rekognition calls each, plus the uploads. Generous, but
  /// finite -- the old code had no timeout and could hang behind the loader
  /// until the user killed the app.
  static const Duration _timeout = Duration(seconds: 45);

  String? get _apiUrl => dotenv.env['AWS_MODERATION_URL'];

  /// Moderates [files] in one request and returns one result per file, in
  /// order. Never throws and never returns a short list: callers can always
  /// zip the results back onto their photos.
  Future<List<PhotoModerationResult>> moderate(List<File> files) async {
    assert(files.length <= maxPhotos);

    List<PhotoModerationResult> allFailed(String code) =>
        List.generate(files.length, (_) => PhotoModerationResult.failure(code));

    final url = _apiUrl;
    if (url == null || url.isEmpty) {
      AppLogger.error('Moderation: AWS_MODERATION_URL is not configured');
      return allFailed('unavailable');
    }

    final token = Supabase.instance.client.auth.currentSession?.accessToken;
    if (token == null) {
      return allFailed('unauthorized');
    }

    try {
      final images = <String>[];
      for (final file in files) {
        images.add(base64Encode(await file.readAsBytes()));
      }

      final response = await http
          .post(
            Uri.parse(url),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode({'images': images}),
          )
          .timeout(_timeout);

      if (response.statusCode != 200) {
        AppLogger.error('Moderation: HTTP ${response.statusCode}');
        return allFailed(
          response.statusCode == 401 ? 'unauthorized' : 'unavailable',
        );
      }

      final results =
          (jsonDecode(response.body) as Map<String, dynamic>)['results']
              as List<dynamic>;
      if (results.length != files.length) {
        AppLogger.error('Moderation: expected ${files.length} results');
        return allFailed('unavailable');
      }

      return results.map(_parse).toList();
    } catch (e) {
      AppLogger.error('Moderation request failed', e);
      return allFailed('unavailable');
    }
  }

  PhotoModerationResult _parse(dynamic raw) {
    final result = raw as Map<String, dynamic>;
    final code = result['code'] as String? ?? 'unavailable';
    switch (result['decision']) {
      case 'ALLOW':
        final path = result['path'] as String?;
        // An acceptance without a path is not an acceptance -- there is
        // nothing to save.
        if (path == null) return const PhotoModerationResult.failure('unavailable');
        return PhotoModerationResult(PhotoDecision.allow, code, path: path);
      case 'REJECT':
        return PhotoModerationResult(PhotoDecision.reject, code);
      default:
        return PhotoModerationResult.failure(code);
    }
  }
}
