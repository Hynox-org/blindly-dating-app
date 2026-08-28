import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:blindly_dating_app/features/match/domain/models/liked_you_user_model.dart';

// ======================================================
// Provider
// ======================================================
final likedYouRepositoryProvider = Provider<LikedYouRepository>((ref) {
  return LikedYouRepository(Supabase.instance.client);
});

// ======================================================
// Repository
// ======================================================
/// Read-only: fetching the list is all that is left here. Match and Pass are
/// ordinary swipes recorded through SwipeRepository — the database trigger
/// makes the match and settles both sides' rows.
class LikedYouRepository {
  final SupabaseClient _supabase;

  LikedYouRepository(this._supabase);

  /// Matches the deck's lifetime — an hour expired mid-session.
  static const int _signedUrlTtl = 60 * 60 * 24 * 7;

  /// Who liked or super liked me, super likes first, newest first — the RPC
  /// orders, the client trusts.
  Future<List<LikedYouUser>> getUsersWhoLikedMe() async {
    if (_supabase.auth.currentUser == null) return [];

    final List<dynamic> response = await _supabase.rpc('get_likes_received');
    if (response.isEmpty) return [];

    final rows = [for (final r in response) Map<String, dynamic>.from(r)];

    // Sign whatever is a storage key, in one round trip.
    final toSign = <String>[];
    for (final row in rows) {
      final path = row['image_path'] as String? ?? '';
      if (path.isNotEmpty && !path.startsWith('http')) toSign.add(path);
    }

    final signed = <String, String>{};
    if (toSign.isNotEmpty) {
      try {
        final urls = await _supabase.storage
            .from('user_photos')
            .createSignedUrls(toSign, _signedUrlTtl);
        for (final u in urls) {
          signed[u.path] = u.signedUrl;
        }
      } catch (e) {
        debugPrint('⚠️ Liked-you image signing failed: $e');
      }
    }

    return [
      for (final row in rows)
        LikedYouUser.fromJson({
          ...row,
          'image_url': switch (row['image_path'] as String? ?? '') {
            '' => null,
            final p when p.startsWith('http') => p,
            final p => signed[p], // null if signing failed → fallback avatar
          },
        }),
    ];
  }
}
