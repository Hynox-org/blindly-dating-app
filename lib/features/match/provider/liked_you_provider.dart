import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:blindly_dating_app/features/match/domain/models/liked_you_user_model.dart';
import 'package:blindly_dating_app/features/match/repository/liked_you_repository.dart';
import 'package:blindly_dating_app/features/matching/repository/swipe_repository.dart';

// ======================================================
// ❤️ Liked You Notifier (With Realtime Support)
// ======================================================
class LikedYouNotifier extends StateNotifier<AsyncValue<List<LikedYouUser>>> {
  final LikedYouRepository _repository;
  final SwipeRepository _swipes;

  RealtimeChannel? _likesChannel;

  LikedYouNotifier(this._repository, this._swipes)
      : super(const AsyncLoading()) {
    _loadLikedYou(forceLoading: true);
    _subscribeToNewLikes();
  }

  // --------------------------------------------------
  // 🔥 LOAD USERS WHO LIKED ME
  // --------------------------------------------------
  Future<void> _loadLikedYou({bool forceLoading = true}) async {
    try {
      if (forceLoading) state = const AsyncLoading();

      final users = await _repository.getUsersWhoLikedMe();
      if (mounted) state = AsyncData(users);
    } catch (e, st) {
      // Keep whatever list we have; only show the error screen when there is
      // nothing better to show.
      if (mounted && state.valueOrNull == null) state = AsyncError(e, st);
    }
  }

  // --------------------------------------------------
  // 📡 SUBSCRIBE TO NEW LIKES (Realtime)
  // --------------------------------------------------
  Future<void> _subscribeToNewLikes() async {
    try {
      final client = Supabase.instance.client;
      final authId = client.auth.currentUser?.id;
      if (authId == null) return;

      final profileData = await client
          .from('profiles')
          .select('id')
          .eq('user_id', authId)
          .maybeSingle();
      if (profileData == null || !mounted) return;

      _likesChannel = client.realtime
          .channel('public:swipes:${profileData['id']}')
          .onPostgresChanges(
            event: PostgresChangeEvent.insert,
            schema: 'public',
            table: 'swipes',
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'target_id',
              value: profileData['id'],
            ),
            callback: (payload) {
              final action = payload.newRecord['action_type'];
              if (action == 'like' || action == 'super_like') {
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
  Future<void> refresh({bool forceLoading = false}) =>
      _loadLikedYou(forceLoading: forceLoading);

  // --------------------------------------------------
  // 🤝 MATCH / ⏯ PASS — one path, same verb as the deck
  // --------------------------------------------------
  /// Match = I like them back; the swipe trigger creates the match and
  /// settles their row. Pass = ordinary pass; the trigger rejects their like.
  /// Optimistic: the card leaves at once and returns if the write fails.
  ///
  /// Returns true when the answer produced a match, so the screen can
  /// celebrate it. A failed write returns false and restores the card.
  Future<bool> respond(LikedYouUser user, {required bool match}) async {
    final before = state.valueOrNull;
    if (before != null) {
      state = AsyncData([
        for (final u in before)
          if (u.profileId != user.profileId) u,
      ]);
    }

    try {
      return await _swipes.recordSwipe(
        targetProfileId: user.profileId,
        action: match ? 'like' : 'pass',
      );
    } catch (e) {
      debugPrint('❌ Liked-you ${match ? 'match' : 'pass'} failed: $e');
      if (mounted && before != null) state = AsyncData(before);
      return false;
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
    StateNotifierProvider<LikedYouNotifier, AsyncValue<List<LikedYouUser>>>((
      ref,
    ) {
      return LikedYouNotifier(
        ref.watch(likedYouRepositoryProvider),
        ref.watch(swipeRepositoryProvider),
      );
    });
