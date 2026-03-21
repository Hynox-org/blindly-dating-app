import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../features/discovery/repository/discovery_repository.dart';
import '../domain/models/discovery_user_model.dart';

import '../../../core/providers/connection_mode_provider.dart';
import 'filter_provider.dart';

// ======================================================
// 1. THE STATE
// ======================================================
class DiscoveryState {
  final List<DiscoveryUser> mainDeck; // The cards currently in the stack
  final List<DiscoveryUser> historyDeck; // The cards swiped (for undo)
  final Set<String> seenIds; // Deduplication Set (Memory Cache)
  final bool isLoading; // Initial load state
  final bool isFetchingMore; // Pagination background load state
  final bool isDeckExhausted; // True when server returns 0 items

  DiscoveryState({
    required this.mainDeck,
    this.historyDeck = const [],
    this.seenIds = const {},
    this.isLoading = false,
    this.isFetchingMore = false,
    this.isDeckExhausted = false,
  });

  DiscoveryState copyWith({
    List<DiscoveryUser>? mainDeck,
    List<DiscoveryUser>? historyDeck,
    Set<String>? seenIds,
    bool? isLoading,
    bool? isFetchingMore,
    bool? isDeckExhausted,
  }) {
    return DiscoveryState(
      mainDeck: mainDeck ?? this.mainDeck,
      historyDeck: historyDeck ?? this.historyDeck,
      seenIds: seenIds ?? this.seenIds,
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

  // ⚙️ CONFIG
  static const int _batchSize = 20; // ✅ Production Grade: Fetch 20 at a time
  static const int _prefetchThreshold = 3; // Fetch more when 3 cards left
  String _currentMode; // Current mode (e.g. 'date', 'bff')

  DiscoveryFeedNotifier({
    required DiscoveryRepository repository,
    required String mode,
    required FilterState filters,
  }) : _repository = repository,
       _currentMode = mode.toLowerCase(),
       super(DiscoveryState(mainDeck: [])) {
    debugPrint("🧬 DISCOVERY_NOTIFIER: Initialized for mode: $_currentMode");
    // Initial Load
    refreshFeed();
  }

  // --------------------------------------------------
  // 🔄 REFRESH (Start Fresh / Pull-to-Refresh)
  // --------------------------------------------------
  Future<void> refreshFeed({String? mode}) async {
    if (mode != null) _currentMode = mode.toLowerCase();

    try {
      state = state.copyWith(
        isLoading: true,
        mainDeck: [],
        historyDeck: [],
        seenIds: {},
        isDeckExhausted: false,
      );

      // This takes time...
      await _loadBatch();

      // 🛑 CRITICAL FIX: Check mounted again before turning off loading
      if (!mounted) return;

      state = state.copyWith(isLoading: false);
    } catch (e) {
      // 🛑 Safety check here too
      if (mounted) {
        state = state.copyWith(isLoading: false);
      }
      debugPrint("❌ Error refreshing feed: $e");
    }
  }

  // --------------------------------------------------
  // ⏩ ACTION: SWIPE (Remove from Deck -> Add to History)
  // --------------------------------------------------
  /// [currentIndex] is the index of the card *being swiped* in the UI stack.
  /// Usually, in libraries like AppinioSwiper, this is effectively consuming the top card.
  void onSwipe(DiscoveryUser user) {
    // 1. Add to History (Limit to last 50 to save memory)
    final newHistory = List<DiscoveryUser>.from(state.historyDeck)..add(user);
    if (newHistory.length > 50) newHistory.removeAt(0);

    // 2. Remove from Main Deck (So it doesn't reappear if we redraw)
    // Note: Some UI libraries handle the "visual" removal, but our state must reflect reality.
    final newMainDeck = List<DiscoveryUser>.from(state.mainDeck)
      ..removeWhere((u) => u.profileId == user.profileId);

    // 3. Update State
    state = state.copyWith(historyDeck: newHistory, mainDeck: newMainDeck);

    // 4. Check if we need more cards
    if (newMainDeck.length <= _prefetchThreshold) {
      _loadBatch(); // Background fetch
    }
  }

  // --------------------------------------------------
  // ⏪ ACTION: UNDO (Remove from History -> Add to Deck)
  // --------------------------------------------------

  // --------------------------------------------------
  // ⏪ ACTION: UNDO (OPTIMISTIC & INSTANT)
  // --------------------------------------------------
  void undoLastSwipe() {
    // 1. Safety Check: Do we have history?
    if (state.historyDeck.isEmpty) return;

    // 2. LOGIC: Pop from History -> Push to Main Deck
    // We do this purely in memory first.
    final newHistory = List<DiscoveryUser>.from(state.historyDeck);
    final lastUser = newHistory.removeLast(); // Take the last swiped person

    final newMainDeck = List<DiscoveryUser>.from(state.mainDeck)
      ..insert(0, lastUser); // Put them back at the VERY TOP

    // 3. UPDATE STATE INSTANTLY
    state = state.copyWith(
      historyDeck: newHistory,
      mainDeck: newMainDeck,
      isDeckExhausted: false, // Important: We have cards again!
    );

    // 4. SYNC DB (Fire & Forget)
    // We call the repo to clean up the DB, but we don't wait for it
    // to update the UI. This makes it feel instant.
    _repository.undoLastSwipe();
  }

  // --------------------------------------------------
  // 📥 INTERNAL: FETCH BATCH
  // --------------------------------------------------
  Future<void> _loadBatch() async {
    // Guard: Don't fetch if already loading or if server said "Empty"
    if (state.isFetchingMore || state.isDeckExhausted) return;

    state = state.copyWith(isFetchingMore: true);

    try {
      // 1. Fetch from Repo
      // We pass 'offset' as 0 because the SQL function intelligently filters
      // out users we've already swiped. So we always ask for the "Next 10".
      final newCandidates = await _repository.getDiscoveryFeed(
        currentMode: _currentMode,
        limit: _batchSize,
        radiusKm: 50,
      );

      // 🛑 OPTIMIZATION: Check if disposed IMMEDIATELY after async,
      // before trying to access 'state' (which throws if disposed).
      if (!mounted) return;

      final validUsers = <DiscoveryUser>[];
      final newSeenIds = Set<String>.from(state.seenIds);

      for (var user in newCandidates) {
        if (!newSeenIds.contains(user.profileId)) {
          validUsers.add(user);
          newSeenIds.add(user.profileId);
        }
      }

      // 3. Update State
      if (validUsers.isEmpty) {
        // If we got users from DB but they were all duplicates, we might need to fetch MORE immediately
        // BUT, if the DB returned 0 items, then we are truly exhausted.
        if (newCandidates.isEmpty) {
          state = state.copyWith(
            isFetchingMore: false,
            isDeckExhausted: true, // Show "No More Profiles" UI
          );
        } else {
          // Recursive fetch? Or just stop for now to avoid infinite loops?
          // For safety, we stop, but you could trigger another load here.
          state = state.copyWith(isFetchingMore: false);
        }
      } else {
        state = state.copyWith(
          isFetchingMore: false,
          mainDeck: [...state.mainDeck, ...validUsers],
          seenIds: newSeenIds,
          isDeckExhausted: false,
        );
      }
    } catch (e) {
      debugPrint("❌ Discovery Fetch Error: $e");
      if (mounted) {
        state = state.copyWith(isFetchingMore: false);
      }
      // Optional: Set an error state if you have one
    }
  }
}

// ======================================================
// 3. THE PROVIDER
// ======================================================
final discoveryFeedProvider =
    StateNotifierProvider<DiscoveryFeedNotifier, DiscoveryState>((ref) {
      final repository = ref.watch(discoveryRepositoryProvider);
      final mode = ref.watch(connectionModeProvider);
      final filters = ref.watch(filterProvider);
      return DiscoveryFeedNotifier(
        repository: repository,
        mode: mode,
        filters: filters,
      );
    });
