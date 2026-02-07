import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/match_repository.dart';

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
/// CURRENT LOGGED IN PROFILE ID - FIXED ✅
/// =============================================================

final currentProfileIdProvider = FutureProvider<String>((ref) async {
  final userId = Supabase.instance.client.auth.currentUser!.id;
  print('🔍 DEBUG: Auth User ID: $userId');
  
  // Get PROFILE ID from profiles table using auth user_id
  final response = await Supabase.instance.client
      .from('profiles')
      .select('id')
      .eq('user_id', userId)  // profiles.user_id links to auth.users.id
      .maybeSingle();
  
  if (response == null) {
    throw Exception('❌ Profile not found for user $userId');
  }
  
  final profileId = response['id'] as String;
  print('🔍 DEBUG: Found Profile ID: $profileId');
  return profileId;
});

/// =============================================================
/// RECENT MATCHES (chat_started = false & not expired)
/// =============================================================

final recentMatchesProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final profileId = await ref.watch(currentProfileIdProvider.future);
  print('🔍 DEBUG: Loading recent matches for profile: $profileId');
  
  final matches = await ref
      .read(matchRepositoryProvider)
      .fetchRecentMatches(profileId);
      
  print('🔍 DEBUG: Recent matches count: ${matches.length}');
  return matches;
});

/// =============================================================
/// CONVERSATIONS (chat_started = true)
/// =============================================================

final conversationsProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final profileId = await ref.watch(currentProfileIdProvider.future);
  print('🔍 DEBUG: Loading conversations for profile: $profileId');
  
  final matches = await ref
      .read(matchRepositoryProvider)
      .fetchConversations(profileId);
      
  print('🔍 DEBUG: Conversations count: ${matches.length}');
  return matches;
});

/// =============================================================
/// START CHAT ACTION PROVIDER
/// =============================================================

final startChatProvider = Provider<MatchRepository>((ref) {
  return ref.read(matchRepositoryProvider);
});
