import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repository/discovery_repository.dart';
import '../repository/swipe_repository.dart';
import '../domain/models/discovery_user_model.dart';
import '../../../core/providers/connection_mode_provider.dart';

/// like / pass / super_like, exactly as `record_swipe` expects them.
enum SwipeIntent {
  pass('pass'),
  like('like'),
  superLike('super_like');

  const SwipeIntent(this.value);
  final String value;
}

// ======================================================
// 1. THE STATE
// ======================================================
class DiscoveryState {
  final List<DiscoveryUser> deck; // cards still to be shown, top first
  final List<DiscoveryUser> history; // swiped, newest last (for undo)
  final Set<String> seenIds; // dedup across batches
  final bool isLoading; // first load, nothing to show yet
  final bool isFetchingMore; // background top-up
  final bool isDeckExhausted; // server has nothing left
  final bool hasLocationError; // RPC refused: no location on the profile
  final String? error; // last action failure, for a one-shot toast

  /// Name of the person a swipe just matched with, for a one-shot
  /// celebration. Null the rest of the time.
  final String? matchedWith;

  const DiscoveryState({
    this.deck = const [],
    this.history = const [],
    this.seenIds = const {},
    this.isLoading = false,
    this.isFetchingMore = false,
    this.isDeckExhausted = false,
    this.hasLocationError = false,
    this.error,
    this.matchedWith,
  });

  /// True only when there is genuinely nothing more coming — a deck that is
  /// empty while a batch is in flight is still a working deck.
  bool get isOutOfProfiles =>
      deck.isEmpty && !isLoading && !isFetchingMore && isDeckExhausted;

  DiscoveryState copyWith({
    List<DiscoveryUser>? deck,
    List<DiscoveryUser>? history,
    Set<String>? seenIds,
    bool? isLoading,
    bool? isFetchingMore,
    bool? isDeckExhausted,
    bool? hasLocationError,
    String? error,
    String? matchedWith,
  }) {
    return DiscoveryState(
      deck: deck ?? this.deck,
      history: history ?? this.history,
      seenIds: seenIds ?? this.seenIds,
      isLoading: isLoading ?? this.isLoading,
      isFetchingMore: isFetchingMore ?? this.isFetchingMore,
      isDeckExhausted: isDeckExhausted ?? this.isDeckExhausted,
      hasLocationError: hasLocationError ?? this.hasLocationError,
      error: error ?? this.error,
      matchedWith: matchedWith ?? this.matchedWith,
    );
  }

  /// Both one-shot fields are dropped together once the UI has shown them.
  DiscoveryState withoutNotices() => DiscoveryState(
        deck: deck,
        history: history,
        seenIds: seenIds,
        isLoading: isLoading,
        isFetchingMore: isFetchingMore,
        isDeckExhausted: isDeckExhausted,
        hasLocationError: hasLocationError,
      );
}

// ======================================================
// 2. THE NOTIFIER
// ======================================================
/// Owns the deck *and* the swipe actions on it. Keeping them together is what
/// stops the deck and the database from drifting apart: one undo path, one
/// place that decides which card the action belongs to.
class DiscoveryFeedNotifier extends StateNotifier<DiscoveryState> {
  DiscoveryFeedNotifier({
    required DiscoveryRepository repository,
    required SwipeRepository swipes,
    required String mode,
  })  : _repository = repository,
        _swipes = swipes,
        _currentMode = mode.toLowerCase(),
        super(const DiscoveryState(isLoading: true)) {
    refreshFeed();
  }

  final DiscoveryRepository _repository;
  final SwipeRepository _swipes;
  String _currentMode;

  static const int _batchSize = 20;
  static const int _prefetchThreshold = 5;

  // --------------------------------------------------
  // 🔄 REFRESH
  // --------------------------------------------------
  Future<void> refreshFeed({String? mode}) async {
    if (mode != null) _currentMode = mode.toLowerCase();

    state = const DiscoveryState(isLoading: true);

    // Cheap on a refresh, ruinous on every background top-up — which is where
    // it used to live.
    await _repository.ensureProfileMode(_currentMode);
    await _loadBatch();

    if (!mounted) return;
    state = state.copyWith(isLoading: false);
  }

  // --------------------------------------------------
  // ⏩ SWIPE
  // --------------------------------------------------
  /// Drops the top card immediately and records it in the background — the
  /// animation must never wait on the network. A rejected write surfaces in
  /// [DiscoveryState.error]; the profile simply comes back in a later batch,
  /// because without a swipe row the server still counts them as unseen.
  Future<void> swipe(DiscoveryUser user, SwipeIntent intent) async {
    final history = [...state.history, user];
    state = state.copyWith(
      deck: [...state.deck]..removeWhere((u) => u.profileId == user.profileId),
      // 50 is plenty: only the newest is ever undoable.
      history: history.length > 50 ? history.sublist(history.length - 50) : history,
    );

    if (state.deck.length <= _prefetchThreshold) _loadBatch();

    try {
      final matched = await _swipes.recordSwipe(
        targetProfileId: user.profileId,
        action: intent.value,
      );
      if (matched && mounted) {
        state = state.copyWith(matchedWith: user.displayName);
      }
    } catch (e) {
      debugPrint('❌ Swipe not recorded: $e');
      if (mounted) {
        state = state.copyWith(error: "Couldn't save that swipe. Try again.");
      }
    }
  }

  // --------------------------------------------------
  // ⏪ UNDO
  // --------------------------------------------------
  /// Optimistic: the card comes back at once, and goes away again if the
  /// backend refuses (nothing to undo, or the pair is already chatting).
  Future<void> undo() async {
    if (state.history.isEmpty) return;

    final restored = state.history.last;
    state = state.copyWith(
      history: state.history.sublist(0, state.history.length - 1),
      deck: [restored, ...state.deck],
      isDeckExhausted: false,
    );

    bool ok = false;
    try {
      ok = await _swipes.undoLastSwipe(targetProfileId: restored.profileId);
    } catch (e) {
      debugPrint('❌ Undo failed: $e');
    }

    if (!mounted || ok) return;

    state = state.copyWith(
      deck: [...state.deck]..removeWhere((u) => u.profileId == restored.profileId),
      history: [...state.history, restored],
      error: "That one can't be undone.",
    );
  }

  /// Clears the one-shot error and match notice after the UI has shown them.
  void clearNotices() {
    if (state.error != null || state.matchedWith != null) {
      state = state.withoutNotices();
    }
  }

  // --------------------------------------------------
  // 📥 FETCH
  // --------------------------------------------------
  Future<void> _loadBatch() async {
    if (state.isFetchingMore || state.isDeckExhausted) return;

    state = state.copyWith(isFetchingMore: true);

    try {
      // A full batch that dedups down to nothing would otherwise strand the
      // deck as "empty but not exhausted", so keep asking — bounded.
      for (var attempt = 0; attempt < 3; attempt++) {
        final (candidates, serverHasNoMore) = await _repository.getDiscoveryFeed(
          currentMode: _currentMode,
          limit: _batchSize,
        );

        if (!mounted) return;

        final seen = {...state.seenIds};
        final fresh = [
          for (final user in candidates)
            if (seen.add(user.profileId)) user,
        ];

        state = state.copyWith(
          deck: [...state.deck, ...fresh],
          seenIds: seen,
          isDeckExhausted: serverHasNoMore,
          hasLocationError: false,
        );

        if (fresh.isNotEmpty || serverHasNoMore) break;
      }
    } catch (e) {
      debugPrint('❌ Discovery fetch failed: $e');
      if (mounted) {
        state = state.copyWith(
          hasLocationError:
              e.toString().toLowerCase().contains('no location set'),
        );
      }
    } finally {
      if (mounted) state = state.copyWith(isFetchingMore: false);
    }
  }
}

// ======================================================
// 3. THE PROVIDER
// ======================================================
/// Deliberately does not watch the filters: they are read server-side from
/// `profile_modes.filters`, and watching them rebuilt the whole deck on every
/// slider tick. The filter screen asks for a refresh when the user is done.
final discoveryFeedProvider =
    StateNotifierProvider<DiscoveryFeedNotifier, DiscoveryState>((ref) {
  return DiscoveryFeedNotifier(
    repository: ref.watch(discoveryRepositoryProvider),
    swipes: ref.watch(swipeRepositoryProvider),
    mode: ref.watch(connectionModeProvider),
  );
});
