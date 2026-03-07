import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/utils/app_state.dart';

final incomingCallProvider =
    StateNotifierProvider<IncomingCallNotifier, Map<String, dynamic>?>(
        (ref) => IncomingCallNotifier());

class IncomingCallNotifier extends StateNotifier<Map<String, dynamic>?> {
  IncomingCallNotifier() : super(null);

  StreamSubscription<List<Map<String, dynamic>>>? _sub;
  String? _myProfileId;

  final Map<String, Map<String, dynamic>> _callerCache = {};

  Future<void> start() async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;
    if (user == null) return;

    await _sub?.cancel();

    try {
      final profile = await supabase
          .from('profiles')
          .select('id')
          .eq('user_id', user.id)
          .maybeSingle();

      if (profile == null) return;

      _myProfileId = profile['id'];

      print("✅ Global listener started for profile: $_myProfileId");

      _sub = supabase
          .from('calls')
          .stream(primaryKey: ['id'])
          .eq('receiver_id', _myProfileId!)
          .listen((calls) async {
        if (AppState.isCallScreenOpen) return;

        print("📞 Received ${calls.length} calls");

        final ringingCalls = calls.where((call) {
          return call['status'] == 'ringing' &&
              call['channel_name'] != null;
        }).toList();

        if (ringingCalls.isEmpty) {
          if (state != null) {
            print("📵 No ringing calls - clearing");
            state = null;
          }
          return;
        }

        final callData = ringingCalls.first;
        final callerId = callData['caller_id'];

        // If user already chatting with same caller skip overlay
        if (AppState.isChatScreenOpen &&
            AppState.currentChatProfileId == callerId) {
          print("💬 Caller is current chat user → skip overlay");
          // await _fetchAndSetCallerDetails(callData);
          // return;
        }

        // Prevent duplicate updates
        if (state != null && state!['id'] == callData['id']) {
          print("⚠️ Duplicate call event ignored");
          return;
        }

        print("📱 New ringing call: ${callData['id']}");

        // store call globally
        AppState.callerId = callerId;
        AppState.callId = callData['id'];

        await _fetchAndSetCallerDetails(callData);
      });
    } catch (e) {
      print("❌ Listener error: $e");
      Future.delayed(const Duration(seconds: 3), start);
    }
  }

  Future<void> _fetchAndSetCallerDetails(Map<String, dynamic> callData) async {
    try {
      final callerId = callData['caller_id'];

      // Use cache
      if (_callerCache.containsKey(callerId)) {
        final cached = _callerCache[callerId]!;

        AppState.callerName = cached['caller_name'];
        AppState.callerImage = cached['caller_image'];

        state = {...callData, ...cached};
        return;
      }

      print("🔍 Fetching caller profile: $callerId");

      final callerProfile = await Supabase.instance.client
          .from('profiles')
          .select('id, display_name, current_mode')
          .eq('id', callerId)
          .limit(1)
          .maybeSingle();

      if (callerProfile == null) {
        state = {
          ...callData,
          'caller_name': 'Unknown',
          'caller_image': '',
        };
        return;
      }

      String callerName = callerProfile['display_name'] ?? 'Unknown';
      String callerImage = '';

      final currentMode = callerProfile['current_mode'];

      if (currentMode != null) {
        final profileMode = await Supabase.instance.client
            .from('profile_modes')
            .select('id')
            .eq('profile_id', callerProfile['id'])
            .eq('mode', currentMode.toString().toLowerCase())
            .eq('is_active', true)
            .limit(1)
            .maybeSingle();

        if (profileMode != null) {
          final media = await Supabase.instance.client
              .from('profile_mode_media')
              .select('media_url')
              .eq('profile_mode_id', profileMode['id'])
              .eq('media_type', 'photo')
              .eq('is_deleted', false)
              .limit(1)
              .maybeSingle();

          if (media != null && media['media_url'] != null) {
            final mediaUrl = media['media_url'];

            final parts = mediaUrl.split('/');

            if (parts.length == 2) {
              final folder = parts[0];
              final file = parts[1];

              final signedUrl = await Supabase.instance.client.storage
                  .from('user_photos')
                  .createSignedUrl('$folder/$file', 3600);

              callerImage = signedUrl;
            }
          }
        }
      }

      // Cache caller info
      _callerCache[callerId] = {
        'caller_name': callerName,
        'caller_image': callerImage,
      };

      // Save globally
      AppState.callerId = callerId;
      AppState.callerName = callerName;
      AppState.callerImage = callerImage;
      AppState.callId = callData['id'];

      state = {
        ...callData,
        'caller_name': callerName,
        'caller_image': callerImage,
      };

      print("🎉 Caller loaded: $callerName");
    } catch (e) {
      print("❌ Caller fetch failed: $e");

      state = {
        ...callData,
        'caller_name': 'Unknown',
        'caller_image': '',
      };
    }
  }

  Future<void> decline() async {
    if (state == null) return;

    print("❌ Declining call ${state!['id']}");

    await Supabase.instance.client
        .from('calls')
        .update({'status': 'ended'})
        .eq('id', state!['id']);
  }

  void clear() {
    state = null;

    AppState.callerId = null;
    AppState.callerName = null;
    AppState.callerImage = null;
    AppState.callId = null;
  }

  void disposeListener() {
    print("🧹 Disposing listener");
    _sub?.cancel();
    _sub = null;
  }

  @override
  void dispose() {
    disposeListener();
    super.dispose();
  }
}