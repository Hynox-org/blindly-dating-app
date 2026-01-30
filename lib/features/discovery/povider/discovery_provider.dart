import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../features/discovery/repository/discovery_repository.dart';
import '../domain/models/discovery_user_model.dart';
import '../../../core/providers/connection_mode_provider.dart';

// ======================================================
// 1. THE STATE
// ======================================================
class DiscoveryState {
  final List<DiscoveryUser> mainDeck; // All fetched profiles (Cumulative)
  final List<DiscoveryUser> historyDeck; // Track swiped profiles for DB Undo
  final bool isLoading;
  final bool isFetchingMore;
  // ✅ NEW: Tracks if the DB has run out of profiles completely
  final bool isDeckExhausted;

  DiscoveryState({
    required this.mainDeck,
    this.historyDeck = const [],
    this.isLoading = false,
    this.isFetchingMore = false,
    this.isDeckExhausted = false, // Default false
  });

  DiscoveryState copyWith({
    List<DiscoveryUser>? mainDeck,
    List<DiscoveryUser>? historyDeck,
    bool? isLoading,
    bool? isFetchingMore,
    bool? isDeckExhausted,
  }) {
    return DiscoveryState(
      mainDeck: mainDeck ?? this.mainDeck,
      historyDeck: historyDeck ?? this.historyDeck,
      isLoading: isLoading ?? this.isLoading,
      isFetchingMore: isFetchingMore ?? this.isFetchingMore,
      isDeckExhausted: isDeckExhausted ?? this.isDeckExhausted,
    );
  }
}

// ======================================================
// 2. THE NOTIFIER
// ======================================================
class DiscoveryFeedNotifier extends StateNotifier<DiscoveryState> {
  final DiscoveryRepository _repository;
  final String _currentMode;

  static const int _pageSize = 20;
  static const int _prefetchThreshold = 5;

  DiscoveryFeedNotifier(this._repository, this._currentMode)
    : super(DiscoveryState(mainDeck: [])) {
    refreshFeed();
  }

  // --------------------------------------------------
  // 🔄 REFRESH (Start Fresh)
  // --------------------------------------------------
  Future<void> refreshFeed() async {
    // Reset exhaustion flag on refresh
    state = state.copyWith(
      isLoading: true,
      mainDeck: [],
      historyDeck: [],
      isDeckExhausted: false,
    );

    await _loadBatch();
    state = state.copyWith(isLoading: false);
  }

  // --------------------------------------------------
  // ⏩ ACTION: CONSUME CARD (Swipe Right/Left)
  // --------------------------------------------------
  void consumeCard(DiscoveryUser user, int currentIndex) {
    final newHistoryDeck = List<DiscoveryUser>.from(state.historyDeck);
    newHistoryDeck.add(user);
    if (newHistoryDeck.length > 50) newHistoryDeck.removeAt(0);

    // Check Threshold & Fetch
    final itemsRemaining = state.mainDeck.length - currentIndex;
    if (itemsRemaining <= _prefetchThreshold && !state.isDeckExhausted) {
      _loadBatch();
    }

    state = state.copyWith(historyDeck: newHistoryDeck);
  }

  // --------------------------------------------------
  // ⏩ ACTION: ADD TO HISTORY ONLY (For Undo Support)
  // --------------------------------------------------
  // This helper function is cleaner for the UI to call
  void addToHistory(DiscoveryUser user) {
    final newHistoryDeck = List<DiscoveryUser>.from(state.historyDeck);
    newHistoryDeck.add(user);
    if (newHistoryDeck.length > 50) newHistoryDeck.removeAt(0);
    state = state.copyWith(historyDeck: newHistoryDeck);
  }

  // --------------------------------------------------
  // ⏪ ACTION: UNDO
  // --------------------------------------------------
  void undoSwipe() {
    if (state.historyDeck.isEmpty) return;

    final newHistoryDeck = List<DiscoveryUser>.from(state.historyDeck);
    newHistoryDeck.removeLast();

    state = state.copyWith(historyDeck: newHistoryDeck);
  }

  // --------------------------------------------------
  // 👍 ACTION: LIKE
  // --------------------------------------------------
  Future<void> likeUser(DiscoveryUser user, int currentIndex) async {
    // 1. Optimistic UI update
    consumeCard(user, currentIndex);
    // 2. Fire & Forget DB update
    _repository
        .swipeUser(targetUserId: user.profileId, isLike: true)
        .catchError((e) {
          // If critical, we could undo, but usually we just log
          debugPrint("Background Like Failed: $e");
        });
  }

  // --------------------------------------------------
  // 👎 ACTION: PASS
  // --------------------------------------------------
  Future<void> passUser(DiscoveryUser user, int currentIndex) async {
    // 1. Optimistic UI update
    consumeCard(user, currentIndex);
    // 2. Fire & Forget DB update
    _repository
        .swipeUser(targetUserId: user.profileId, isLike: false)
        .catchError((e) {
          debugPrint("Background Pass Failed: $e");
        });
  }

  // --------------------------------------------------
  // 📥 INTERNAL: FETCH & DEDUPLICATE
  // --------------------------------------------------
  Future<bool> _loadBatch() async {
    if (state.isFetchingMore || state.isDeckExhausted) return false;

    state = state.copyWith(isFetchingMore: true);

    try {
      final newCandidates = await _repository.getDiscoveryFeed(
        mode: _currentMode,
        limit: _pageSize,
        offset: 0,
      );

      // Deduplicate against existing decks
      final currentIds = {
        ...state.mainDeck.map((u) => u.profileId),
        ...state.historyDeck.map((u) => u.profileId),
      };

      final uniqueUsers = newCandidates
          .where((u) => !currentIds.contains(u.profileId))
          .toList();

      if (uniqueUsers.isNotEmpty) {
        state = state.copyWith(
          mainDeck: [...state.mainDeck, ...uniqueUsers],
          isFetchingMore: false,
        );
        debugPrint(
          "✅ Added ${uniqueUsers.length} profiles. Total: ${state.mainDeck.length}",
        );
        return true;
      } else {
        // ✅ EMPTY BATCH: Mark deck as exhausted so UI knows to show "No More Profiles"
        debugPrint("🏁 No more profiles found in DB.");
        state = state.copyWith(isFetchingMore: false, isDeckExhausted: true);
        return false;
      }
    } catch (e) {
      debugPrint("❌ Fetch Error: $e");
      state = state.copyWith(isFetchingMore: false);
      return false;
    }
  }
}

final discoveryFeedProvider =
    StateNotifierProvider<DiscoveryFeedNotifier, DiscoveryState>((ref) {
      final repository = ref.watch(discoveryRepositoryProvider);
      // Import missing provider if needed, assuming it is available in context or needs import
      // But wait, connection_mode_provider might not be imported here.
      // I need to add the import. But replace_file_content replaces a block.
      // I will check imports first.
      final currentMode = ref.watch(connectionModeProvider);
      return DiscoveryFeedNotifier(repository, currentMode);
    });
