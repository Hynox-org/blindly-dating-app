import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../chat/domain/models/recent_matches_model.dart';
import '../repository/recent_matches_repository.dart';
import '../../../../main.dart'; // Import customRealtimeClient

// ======================================================
// Recent Matches Notifier - FIXED ✅
// ======================================================
class RecentMatchesNotifier
    extends StateNotifier<AsyncValue<List<RecentMatch>>> {
  final RecentMatchesRepository _repository;

  // Keep track of the realtime channel to close it later
  RealtimeChannel? _matchesChannel;
  String? _myProfileId; // Cache profile ID

  RecentMatchesNotifier(this._repository) : super(const AsyncLoading()) {
    _init();
  }

  Future<void> _init() async {
    await _load(forceLoading: true);
    _subscribeToMatches();
  }

  // --------------------------------------------------
  // 🔄 LOAD MATCHES
  // --------------------------------------------------
  Future<void> _load({bool forceLoading = true}) async {
    try {
      final client = Supabase.instance.client;
      final myUserId = client.auth.currentUser?.id;

      if (myUserId == null) {
        if (mounted) {
          state = const AsyncData([]);
        }
        return;
      }

      // ✅ Get PROFILE ID from USER ID
      final profileRes = await client
          .from('profiles')
          .select('id')
          .eq('user_id', myUserId)
          .maybeSingle();

      final profileId = profileRes?['id'] as String?;

      if (profileId == null) {
        debugPrint('❌ No profile found for user: $myUserId');
        if (mounted) {
          state = const AsyncData([]);
        }
        return;
      }

      _myProfileId = profileId; // Cache it

      // Only set loading state if forced
      if (forceLoading) {
        state = const AsyncLoading();
      }

      debugPrint('💬 Loading matches for profile: $profileId');
      final matchMaps = await _repository.getRecentMatches(profileId);
      // final matches = matchMaps.map((map) => RecentMatch.fromJson(map)).toList();
      final matches = matchMaps
          .map(
            (map) =>
                RecentMatch.fromJson({...map, 'current_profile_id': profileId}),
          )
          .toList();
      if (mounted) {
        state = AsyncData(matches);
      }

      debugPrint('✅ Loaded ${matches.length} matches for profile: $profileId');
    } catch (e, st) {
      debugPrint('🛑 Failed to load matches: $e');
      debugPrint(st.toString());
      if (mounted) {
        state = AsyncError(e, st);
      }
    }
  }

  // --------------------------------------------------
  // 📡 REALTIME SUBSCRIPTION - FIXED ✅
  // --------------------------------------------------
  void _subscribeToMatches() {
    if (_myProfileId == null) {
      debugPrint('⚠️ No profile ID for subscription - will retry after load');
      return;
    }

    final client = Supabase.instance.client;

    // ✅ FIXED: Use safe generic channel name + filter in callback
    final safeChannelName = 'public:matches';

    debugPrint(
      '📡 Subscribing to matches for profile: $_myProfileId on channel: $safeChannelName',
    );

    // ✅ FIXED: Use the custom RealtimeClient (bypassing Jiobase) if available, otherwise fallback
    final realtimeTarget = customRealtimeClient ?? client.realtime;

    _matchesChannel = realtimeTarget
        .channel(safeChannelName)
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'matches',
          callback: (payload) {
            final newRecord = payload.newRecord;
            debugPrint(
              '🔔 New match payload: ${newRecord['id']} - A: ${newRecord['user_a_id']} B: ${newRecord['user_b_id']}',
            );

            // ✅ FIXED: Use correct column names from schema (profile_a_id, profile_b_id)
            if (newRecord['user_a_id'] == _myProfileId ||
                newRecord['user_b_id'] == _myProfileId) {
              debugPrint(
                '🔔 🎉 New Match for ME! ID: ${newRecord['id']} - Reloading...',
              );
              _load(forceLoading: false); // Refresh without spinner
            }
          },
        )
        .subscribe((status, [error]) {
          debugPrint(
            '📡 Matches subscription: $status${error != null ? ' | Error: $error' : ''}',
          );
        });
  }

  // --------------------------------------------------
  // 🔁 REFRESH
  // --------------------------------------------------
  Future<void> refresh() async {
    await _load(forceLoading: true);
  }

  // --------------------------------------------------
  // 🗑️ DISPOSE
  // --------------------------------------------------
  @override
  void dispose() {
    if (_matchesChannel != null) {
      if (customRealtimeClient != null) {
        customRealtimeClient!.removeChannel(_matchesChannel!);
      } else {
        Supabase.instance.client.removeChannel(_matchesChannel!);
      }
      debugPrint('🗑️ Matches subscription channel closed');
    }
    super.dispose();
  }
}

// ======================================================
// Provider - REMOVE DUPLICATE FROM HERE (use chat_providers.dart)
// ======================================================
// This provider definition should ONLY be in chat_providers.dart
// final recentMatchesProvider = StateNotifierProvider.autoDispose<RecentMatchesNotifier, AsyncValue<List<RecentMatch>>>(
//   (ref) {
//     final repo = ref.watch(recentMatchesRepositoryProvider);
//     return RecentMatchesNotifier(repo);
//   },
// );
