import 'package:flutter/material.dart';
import 'package:blindly_dating_app/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:blindly_dating_app/features/call/provider/global_call_listener.dart';
import 'package:blindly_dating_app/features/call/presentation/screens/call_screen.dart';
import 'package:blindly_dating_app/core/utils/nav_key.dart';
import 'package:blindly_dating_app/core/utils/app_state.dart';

class IncomingCallOverlay extends ConsumerStatefulWidget {
  const IncomingCallOverlay({super.key});

  @override
  ConsumerState<IncomingCallOverlay> createState() =>
      _IncomingCallOverlayState();
}

class _IncomingCallOverlayState extends ConsumerState<IncomingCallOverlay> {
  AppLocalizations get l10n => AppLocalizations.of(context);



  @override
  Widget build(BuildContext context) {
    final call = ref.watch(incomingCallProvider);

    // Prevent overlay if call screen already open
    if (AppState.isCallScreenOpen) {
      return const SizedBox.shrink();
    }

    if (call == null || call['status'] != 'ringing') {
      return const SizedBox.shrink();
    }

    final callerName = call['caller_name']?.toString() ?? 'Unknown';
    final callerImage = call['caller_image']?.toString() ?? '';
    final isVideo = call['call_type'] == 'video';

    debugPrint("🔔 Incoming call overlay from: $callerName");

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: GestureDetector(
          onTap: () {
            _navigateToCallScreen(
              callId: call['id'],
              channelName: call['channel_name'],
              isVideo: isVideo,
              callerName: callerName,
              callerImage: callerImage,
            );
          },
          child: Material(
            color: Colors.transparent,
            child: Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(14),
                boxShadow: const [
                  BoxShadow(
                    blurRadius: 12,
                    color: Colors.black38,
                  )
                ],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundImage: callerImage.isNotEmpty
                        ? NetworkImage(callerImage)
                        : null,
                    child: callerImage.isEmpty
                        ? const Icon(Icons.person, color: Colors.white)
                        : null,
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          callerName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          isVideo
                              ? l10n.incomingVideoCallTitle
                              : l10n.incomingVoiceCallTitle,
                          style: const TextStyle(
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // DECLINE
                  IconButton(
                    icon: const Icon(Icons.call_end, color: Colors.red),
                    onPressed: () => _declineCall(call['id']),
                  ),

                  // ACCEPT
                  IconButton(
                    icon: const Icon(Icons.call, color: Colors.green),
                    onPressed: () async {
                      await _acceptAndNavigate(
                        callId: call['id'],
                        channelName: call['channel_name'],
                        isVideo: isVideo,
                        callerName: callerName,
                        callerImage: callerImage,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // NAVIGATE TO CALL SCREEN
  void _navigateToCallScreen({
    required String callId,
    required String channelName,
    required bool isVideo,
    required String callerName,
    required String callerImage,
  }) {

    final nav = navigatorKey.currentState;

    if (nav == null) {
      debugPrint("❌ Navigator not ready");
      return;
    }

    // mark call screen open
    AppState.isCallScreenOpen = true;

    // clear overlay state
    ref.read(incomingCallProvider.notifier).clear();

    nav.push(
      MaterialPageRoute(
        builder: (_) => CallScreen(
          callId: callId,
          channelName: channelName,
          isVideo: isVideo,
          isCaller: false,
          otherUserName: callerName,
          otherUserImage: callerImage,
        ),
      ),
    ).then((_) {
      // reset when call screen closed
      AppState.isCallScreenOpen = false;
    });

    debugPrint("✅ Navigated to CallScreen");
  }

  // ACCEPT CALL
  Future<void> _acceptAndNavigate({
    required String callId,
    required String channelName,
    required bool isVideo,
    required String callerName,
    required String callerImage,
  }) async {
    try {
      await Supabase.instance.client
          .from('calls')
          .update({'status': 'ongoing'})
          .eq('id', callId);

      _navigateToCallScreen(
        callId: callId,
        channelName: channelName,
        isVideo: isVideo,
        callerName: callerName,
        callerImage: callerImage,
      );
    } catch (e) {
      debugPrint("❌ Accept failed: $e");
    }
  }

  // DECLINE CALL
  Future<void> _declineCall(String callId) async {
    try {
      await Supabase.instance.client
          .from('calls')
          .update({'status': 'ended'})
          .eq('id', callId);

      ref.read(incomingCallProvider.notifier).clear();

      debugPrint("❌ Call declined");
    } catch (e) {
      debugPrint("❌ Decline failed: $e");
    }
  }
}