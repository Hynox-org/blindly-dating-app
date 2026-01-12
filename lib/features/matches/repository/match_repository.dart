import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import '../domain/models/match_model.dart';

class MatchRepository {
  final SupabaseClient _supabase;

  MatchRepository(this._supabase);

  // ---------------------------------------------------------------------------
  // ✅ GET MY MATCHES
  // ---------------------------------------------------------------------------
  /// Returns active matches for the logged-in user
  Future<List<MatchModel>> getMyMatches() async {
    try {
      debugPrint('👉 FETCHING MATCHES');

      final response = await _supabase.rpc('get_my_matches');

      // Supabase RPC can return null or empty list
      if (response == null) {
        debugPrint('ℹ️ GET MATCHES: response is null');
        return [];
      }

      if (response is! List) {
        debugPrint('⚠️ GET MATCHES: unexpected response type');
        return [];
      }

      final List<Map<String, dynamic>> rows =
          List<Map<String, dynamic>>.from(response);

      final matches = rows
          .map((row) {
            try {
              return MatchModel.fromJson(row);
            } catch (e) {
              // 🔥 This prevents ONE bad row from crashing the whole app
              debugPrint('❌ MATCH PARSE ERROR: $e');
              debugPrint('❌ BAD ROW: $row');
              return null;
            }
          })
          .whereType<MatchModel>() // remove nulls safely
          .toList();

      debugPrint('✅ MATCHES LOADED: ${matches.length}');
      return matches;
    } catch (e, st) {
      debugPrint('❌ GET MATCHES ERROR: $e');
      debugPrint(st.toString());
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // ✅ UNMATCH
  // ---------------------------------------------------------------------------
  /// Soft unmatch (status → unmatched)
  Future<void> unmatch(String matchId) async {
    try {
      debugPrint('👉 UNMATCH: $matchId');

      await _supabase
          .from('matches')
          .update({
            'status': 'unmatched',
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', matchId);
    } catch (e, st) {
      debugPrint('❌ UNMATCH ERROR: $e');
      debugPrint(st.toString());
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // ✅ EXTEND MATCH (PREMIUM)
  // ---------------------------------------------------------------------------
  /// Extend match expiry by 24h (handled in DB)
  Future<void> extendMatch(String matchId) async {
    try {
      debugPrint('👉 EXTEND MATCH: $matchId');

      await _supabase.rpc(
        'extend_match_expiry',
        params: {
          'p_match_id': matchId,
        },
      );
    } catch (e, st) {
      debugPrint('❌ EXTEND MATCH ERROR: $e');
      debugPrint(st.toString());
      rethrow;
    }
  }
}
