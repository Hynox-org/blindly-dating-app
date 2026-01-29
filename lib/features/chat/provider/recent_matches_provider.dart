import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../chat/domain/models/recent_matches_model.dart';
import '../repository/recent_matches_repository.dart';

// ======================================================
// Recent Matches Notifier
// ======================================================
class RecentMatchesNotifier extends StateNotifier<AsyncValue<List<RecentMatch>>> {
  final RecentMatchesRepository _repository;
  
  // Keep track of the realtime channel to close it later
  RealtimeChannel? _matchesChannel;

  RecentMatchesNotifier(this._repository) : super(const AsyncLoading()) {
    // Initial load (show spinner)
    _load(forceLoading: true);
    // Start listening for new matches in the background
    _subscribeToMatches();
  }

  // --------------------------------------------------
  // 🔄 LOAD MATCHES
  // --------------------------------------------------
  // ✅ UPDATED: Added 'forceLoading' to support silent background updates
  Future<void> _load({bool forceLoading = true}) async {
    try {
      // Only set loading state if forced (e.g., initial screen load)
      // We skip this for realtime updates to avoid UI flickering
      if (forceLoading) {
        state = const AsyncLoading();
      }

      final matches = await _repository.getRecentMatches();
      
      // Update state with new data
      if (mounted) {
        state = AsyncData(matches);
      }
    } catch (e, st) {
      if (mounted) {
        state = AsyncError(e, st);
      }
    }
  }

  // --------------------------------------------------
  // 📡 REALTIME SUBSCRIPTION (The Background Fix)
  // --------------------------------------------------
  void _subscribeToMatches() {
    final client = Supabase.instance.client;
    final myUserId = client.auth.currentUser?.id;

    if (myUserId == null) return;

    debugPrint('📡 Subscribing to matches realtime channel...');

    _matchesChannel = client.channel('public:matches')
      .onPostgresChanges(
        event: PostgresChangeEvent.insert,
        schema: 'public',
        table: 'matches',
        callback: (payload) {
          final newRecord = payload.newRecord;
          
          // ✅ CHECK: Only update if the new match involves ME
          if (newRecord['user1_id'] == myUserId || newRecord['user2_id'] == myUserId) {
             debugPrint('🔔 New Match Detected! Updating list silently...');
             
             // ✅ Call load with forceLoading: false (No Spinner)
             _load(forceLoading: false); 
          }
        },
      )
      .subscribe();
  }

  // --------------------------------------------------
  // 🔁 REFRESH (SCREEN OPEN / PULL)
  // --------------------------------------------------
  Future<void> refresh() async {
    await _load(forceLoading: true);
  }

  // --------------------------------------------------
  // 🗑️ DISPOSE
  // --------------------------------------------------
  @override
  void dispose() {
    // Clean up the channel to prevent memory leaks
    if (_matchesChannel != null) {
      Supabase.instance.client.removeChannel(_matchesChannel!);
    }
    super.dispose();
  }
}

// ======================================================
// Provider
// ======================================================
final recentMatchesProvider = StateNotifierProvider.autoDispose<RecentMatchesNotifier, AsyncValue<List<RecentMatch>>>(
  (ref) {
    final repo = ref.watch(recentMatchesRepositoryProvider);
    return RecentMatchesNotifier(repo);
  },
);