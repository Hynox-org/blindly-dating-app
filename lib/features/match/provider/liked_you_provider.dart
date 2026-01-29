import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/models/liked_you_user_model.dart';
import '../repository/liked_you_repository.dart';

// ======================================================
// ❤️ Liked You Notifier (With Realtime Support)
// ======================================================
class LikedYouNotifier extends StateNotifier<AsyncValue<List<LikedYouUser>>> {
  final LikedYouRepository _repository;
  
  // Keep track of the realtime subscription
  RealtimeChannel? _likesChannel;

  LikedYouNotifier(this._repository) : super(const AsyncLoading()) {
    // 1. Initial Load (Show Spinner)
    _loadLikedYou(forceLoading: true);
    
    // 2. Start Listening for new Likes
    _subscribeToNewLikes();
  }

  // --------------------------------------------------
  // 🔥 LOAD USERS WHO LIKED ME
  // --------------------------------------------------
  // ✅ ADDED: forceLoading parameter for silent updates
  Future<void> _loadLikedYou({bool forceLoading = true}) async {
    try {
      // Only show loading spinner if forced (initial load)
      if (forceLoading) {
        state = const AsyncLoading();
      }

      final users = await _repository.getUsersWhoLikedMe();

      if (mounted) {
        state = AsyncData(users);
      }
    } catch (e, st) {
      if (mounted) {
        state = AsyncError(e, st);
      }
    }
  }

  // --------------------------------------------------
  // 📡 SUBSCRIBE TO NEW LIKES (Realtime)
  // --------------------------------------------------
  Future<void> _subscribeToNewLikes() async {
    final client = Supabase.instance.client;
    final authId = client.auth.currentUser?.id;

    if (authId == null) return;

    try {
      // A. Get My Profile ID first (needed to filter swipes targeting ME)
      // We do this lightweight fetch to ensure we subscribe to the right ID
      final profileData = await client
          .from('profiles')
          .select('id')
          .eq('user_id', authId)
          .maybeSingle();

      if (profileData == null) return;
      final myProfileId = profileData['id'];

      debugPrint('📡 Subscribing to likes for profile: $myProfileId');

      // B. Listen to INSERT events on the 'swipes' table
      _likesChannel = client.channel('public:swipes:$myProfileId')
          .onPostgresChanges(
            event: PostgresChangeEvent.insert,
            schema: 'public',
            table: 'swipes',
            // ✅ FILTER: Only notify if I am the target
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'target_profile_id',
              value: myProfileId,
            ),
            callback: (payload) {
              final newRecord = payload.newRecord;
              
              // ✅ CHECK: Is it a Like?
              if (newRecord['action'] == 'like' || newRecord['action'] == 'superlike') {
                 debugPrint('🔔 New Like Detected! Updating list silently...');
                 // Refresh list without loading spinner
                 _loadLikedYou(forceLoading: false); 
              }
            },
          )
          .subscribe();

    } catch (e) {
      debugPrint('⚠️ Error subscribing to likes: $e');
    }
  }

  // --------------------------------------------------
  // 🔁 PUBLIC REFRESH
  // --------------------------------------------------
  Future<void> refresh() async {
    await _loadLikedYou(forceLoading: true);
  }

  // --------------------------------------------------
  // ⏯ PASS USER
  // --------------------------------------------------
  Future<void> passUser(String fromProfileId) async {
    try {
      await _repository.ignoreLike(fromProfileId);
      // Refresh to remove card
      await _loadLikedYou(forceLoading: false);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  // --------------------------------------------------
  // 🤝 MATCH USER
  // --------------------------------------------------
  Future<void> matchUser(String otherProfileId) async {
    try {
      await _repository.matchUser(otherProfileId: otherProfileId);
      // Refresh to remove card (it moved to matches)
      await _loadLikedYou(forceLoading: false);
    } catch (e) {
      rethrow;
    }
  }

  // --------------------------------------------------
  // 🗑️ DISPOSE
  // --------------------------------------------------
  @override
  void dispose() {
    if (_likesChannel != null) {
      Supabase.instance.client.removeChannel(_likesChannel!);
    }
    super.dispose();
  }
}

// ======================================================
// Provider
// ======================================================
final likedYouProvider =
    StateNotifierProvider.autoDispose<LikedYouNotifier, AsyncValue<List<LikedYouUser>>>((
  ref,
) {
  final repository = ref.watch(likedYouRepositoryProvider);
  return LikedYouNotifier(repository);
});