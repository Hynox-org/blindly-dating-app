import 'package:supabase_flutter/supabase_flutter.dart';

class MatchRepository {
  final SupabaseClient client;
  MatchRepository(this.client);

  // =============================================================
  // 🔥 FALLBACK: Fetch missing profile by ID
  // =============================================================
  Future<Map<String, dynamic>?> _fetchProfileById(String profileId) async {
    try {
      final response = await client
          .from('profiles')
          .select('id, display_name, user_id')
          .eq('id', profileId)
          .maybeSingle();

      if (response != null) {
        final profile = Map<String, dynamic>.from(response);
        final photoUrl = await _getFirstPhotoUrl(profile['user_id']);
        profile['photo_url'] = photoUrl;

        print('✅ FALLBACK profile loaded: ${profile['display_name']}');
        return profile;
      }

      print('❌ Profile not found: $profileId');
      return null;
    } catch (e) {
      print('❌ Fallback error for $profileId: $e');
      return null;
    }
  }

  // =============================================================
  // 🔵 RECENT MATCHES - WITH FALLBACK
  // =============================================================
  Future<List<Map<String, dynamic>>> fetchRecentMatches(String profileId) async {
    final now = DateTime.now().toIso8601String();

    final res = await client
        .from('matches')
        .select('''
          *,
          profile_a:profiles!matches_profile_a_fkey(
            id, display_name, user_id
          ),
          profile_b:profiles!matches_profile_b_fkey(
            id, display_name, user_id
          )
        ''')
        .eq('chat_started', false)
        .eq('status', 'active')
        .gt('expires_at', now)
        .or('profile_a_id.eq.$profileId,profile_b_id.eq.$profileId')
        .order('matched_at', ascending: false);

    final matchesWithPhotos = <Map<String, dynamic>>[];

    for (final match in res) {
      final matchWithPhotos = Map<String, dynamic>.from(match);

      // 🔥 Profile A
      if (match['profile_a']?['user_id'] != null) {
        final profileA = Map<String, dynamic>.from(match['profile_a']);
        profileA['photo_url'] =
            await _getFirstPhotoUrl(profileA['user_id']);
        matchWithPhotos['profile_a'] = profileA;
      }

      // 🔥 Profile B
      if (match['profile_b']?['user_id'] != null) {
        final profileB = Map<String, dynamic>.from(match['profile_b']);
        profileB['photo_url'] =
            await _getFirstPhotoUrl(profileB['user_id']);
        matchWithPhotos['profile_b'] = profileB;
      } else if (match['profile_b_id'] != null) {
        print('🔍 profile_b JOIN failed, fallback...');
        final profileB = await _fetchProfileById(match['profile_b_id']);
        if (profileB != null) {
          matchWithPhotos['profile_b'] = profileB;
        }
      }

      matchesWithPhotos.add(matchWithPhotos);
    }

    return matchesWithPhotos;
  }

  // =============================================================
  // 🟢 CONVERSATIONS
  // =============================================================
  Future<List<Map<String, dynamic>>> fetchConversations(String profileId) async {
    final res = await client
        .from('matches')
        .select('''
          *,
          profile_a:profiles!matches_profile_a_fkey(
            id, display_name, user_id
          ),
          profile_b:profiles!matches_profile_b_fkey(
            id, display_name, user_id
          )
        ''')
        .eq('chat_started', true)
        .or('profile_a_id.eq.$profileId,profile_b_id.eq.$profileId')
        .order('matched_at', ascending: false);

    final matchesWithPhotos = <Map<String, dynamic>>[];

    for (final match in res) {
      final matchWithPhotos = Map<String, dynamic>.from(match);

      // Profile A
      if (match['profile_a']?['user_id'] != null) {
        final profileA = Map<String, dynamic>.from(match['profile_a']);
        profileA['photo_url'] =
            await _getFirstPhotoUrl(profileA['user_id']);
        matchWithPhotos['profile_a'] = profileA;
      }

      // Profile B
      if (match['profile_b']?['user_id'] != null) {
        final profileB = Map<String, dynamic>.from(match['profile_b']);
        profileB['photo_url'] =
            await _getFirstPhotoUrl(profileB['user_id']);
        matchWithPhotos['profile_b'] = profileB;
      } else if (match['profile_b_id'] != null) {
        final profileB = await _fetchProfileById(match['profile_b_id']);
        if (profileB != null) {
          matchWithPhotos['profile_b'] = profileB;
        }
      }

      matchesWithPhotos.add(matchWithPhotos);
    }

    return matchesWithPhotos;
  }

  // =============================================================
  // 📸 STORAGE — FIXED VERSION
  // =============================================================
  Future<String?> _getFirstPhotoUrl(String? userId) async {
    if (userId == null) return null;

    try {
      final files = await client.storage
          .from('user_photos')
          .list(path: userId); // 👈 NO trailing slash

      if (files.isEmpty) {
        print('📸 No photos found for user: $userId');
        return null;
      }

      final firstFile = files.first;

      final signedUrl = await client.storage
          .from('user_photos')
          .createSignedUrl(
            '$userId/${firstFile.name}',
            3600,
          );

      print('📸 Signed URL for $userId → ${firstFile.name}');
      return signedUrl;
    } catch (e) {
      print('❌ Storage error for $userId: $e');
      return null;
    }
  }

  // =============================================================
  // 🔥 START CHAT & SEND MESSAGE
  // =============================================================
  Future<bool> startChatAndSendMessage({
    required String matchId,
    required String senderProfileId,
    required String receiverProfileId,
    required String messageContent,
  }) async {
    try {
      final match = await client
          .from('matches')
          .select('expires_at, status, chat_started')
          .eq('id', matchId)
          .single();

      if (match['chat_started'] == true) {
        await _sendMessage(
          matchId: matchId,
          senderProfileId: senderProfileId,
          receiverProfileId: receiverProfileId,
          content: messageContent,
        );
        return true;
      }

      final expiresAtRaw = match['expires_at'];
      if (expiresAtRaw != null) {
        final expiresAt = DateTime.parse(expiresAtRaw).toUtc();
        final nowUtc = DateTime.now().toUtc();
        print('⏳ Expiry check: now=$nowUtc expires=$expiresAt');
        if (nowUtc.isAfter(expiresAt)) {
          print('❌ Match expired');
          return false;
        }
      }

      await client.from('matches').update({
        'chat_started': true,
        'chat_started_at': DateTime.now().toIso8601String(),
        // 'status': 'chatting',
        // 'expires_at': null,
      }).eq('id', matchId);

      await _sendMessage(
        matchId: matchId,
        senderProfileId: senderProfileId,
        receiverProfileId: receiverProfileId,
        content: messageContent,
      );

      return true;
    } catch (e) {
      print('❌ Chat error: $e');
      return false;
    }
  }

  Future<void> _sendMessage({
    required String matchId,
    required String senderProfileId,
    required String receiverProfileId,
    required String content,
  }) async {
    await client.from('messages').insert({
      'match_id': matchId,
      'sender_profile_id': senderProfileId,
      'receiver_profile_id': receiverProfileId,
      'content': content,
      'is_read': false,
    });
  }

  Future<bool> isChatStarted(String matchId) async {
    final match = await client
        .from('matches')
        .select('chat_started')
        .eq('id', matchId)
        .single();

    return match['chat_started'] == true;
  }
}
