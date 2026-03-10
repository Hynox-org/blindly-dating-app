import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/match_repository.dart';

import '../../chat/domain/models/recent_matches_model.dart';
import '../../chat/repository/recent_matches_repository.dart';

// 👉 ADD THIS — contains RecentMatchesNotifier
import '../provider/recent_matches_provider.dart';

/// =============================================================
/// SUPABASE CLIENT
/// =============================================================

final supabaseProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

/// =============================================================
/// MATCH REPOSITORY
/// =============================================================

final matchRepositoryProvider = Provider<MatchRepository>((ref) {
  return MatchRepository(ref.read(supabaseProvider));
});

/// =============================================================
/// RECENT MATCHES REPOSITORY
/// =============================================================

final recentMatchesRepositoryProvider = Provider<RecentMatchesRepository>((
  ref,
) {
  final supabase = ref.read(supabaseProvider);
  final matchRepo = ref.read(matchRepositoryProvider);

  return RecentMatchesRepository(supabase, matchRepo);
});

/// =============================================================
/// CURRENT PROFILE ID
/// =============================================================

final currentProfileIdProvider = FutureProvider<String>((ref) async {
  final userId = Supabase.instance.client.auth.currentUser!.id;

  debugPrint('🔍 DEBUG: Auth User ID: $userId');

  final response = await Supabase.instance.client
      .from('profiles')
      .select('id')
      .eq('user_id', userId)
      .maybeSingle();

  if (response == null) {
    throw Exception('❌ Profile not found for user $userId');
  }

  final profileId = response['id'] as String;

  debugPrint('🔍 DEBUG: Found Profile ID: $profileId');

  return profileId;
});

/// =============================================================
/// RECENT MATCHES — STATE NOTIFIER
/// =============================================================

final recentMatchesProvider =
    StateNotifierProvider<RecentMatchesNotifier, AsyncValue<List<RecentMatch>>>(
      (ref) {
        final repo = ref.watch(recentMatchesRepositoryProvider);
        return RecentMatchesNotifier(repo);
      },
    );

/// =============================================================
/// CONVERSATIONS
/// =============================================================

final conversationsProvider = FutureProvider<List<Map<String, dynamic>>>((
  ref,
) async {
  final profileId = await ref.watch(currentProfileIdProvider.future);

  debugPrint('🔍 DEBUG: Loading conversations for profile: $profileId');

  final matches = await ref
      .read(matchRepositoryProvider)
      .fetchConversations(profileId);

  debugPrint('🔍 DEBUG: Conversations count: ${matches.length}');

  return matches;
});

/// =============================================================
/// START CHAT
/// =============================================================

final startChatProvider = Provider<MatchRepository>((ref) {
  return ref.read(matchRepositoryProvider);
});
