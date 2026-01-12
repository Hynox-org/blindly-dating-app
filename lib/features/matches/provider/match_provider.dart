import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../repository/match_repository.dart';
import '../domain/models/match_model.dart';

// -------------------------------
// Repository Provider
// -------------------------------
final matchRepositoryProvider = Provider<MatchRepository>(
  (ref) => MatchRepository(Supabase.instance.client),
);

// -------------------------------
// Matches State Provider
// -------------------------------
final myMatchesProvider =
    StateNotifierProvider<MatchNotifier, AsyncValue<List<MatchModel>>>(
  (ref) => MatchNotifier(ref.read(matchRepositoryProvider)),
);

class MatchNotifier extends StateNotifier<AsyncValue<List<MatchModel>>> {
  final MatchRepository _repository;

  MatchNotifier(this._repository) : super(const AsyncLoading()) {
    loadMatches();
  }

  // --------------------------------------------------
  // LOAD MATCHES
  // --------------------------------------------------
  Future<void> loadMatches() async {
    try {
      final matches = await _repository.getMyMatches();
      state = AsyncData(matches);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  // --------------------------------------------------
  // EXTEND MATCH (PREMIUM)
  // --------------------------------------------------
  Future<void> extendMatch(String matchId) async {
    try {
      await _repository.extendMatch(matchId);

      // 🔁 Refresh matches so UI + popup update instantly
      await loadMatches();
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }
}

// -------------------------------
// 🔥 REALTIME MATCH LISTENER
// -------------------------------
final matchRealtimeProvider = Provider<void>((ref) {
  final supabase = Supabase.instance.client;

  final channel = supabase.channel('matches-realtime')
    ..onPostgresChanges(
      event: PostgresChangeEvent.insert,
      schema: 'public',
      table: 'matches',
      callback: (_) {
        ref.read(myMatchesProvider.notifier).loadMatches();
      },
    )
    ..subscribe();

  ref.onDispose(() {
    supabase.removeChannel(channel);
  });
});
