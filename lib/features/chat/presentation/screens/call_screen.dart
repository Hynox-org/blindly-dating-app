import 'dart:async';
import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CallScreen extends StatefulWidget {
  final String callId;
  final String channelName;
  final bool isVideo;
  final bool isCaller;
  final String otherUserName;
  final String otherUserImage;

  const CallScreen({
    super.key,
    required this.callId,
    required this.channelName,
    required this.isVideo,
    required this.isCaller,
    required this.otherUserName,
    required this.otherUserImage,
  });

  @override
  State<CallScreen> createState() => _CallScreenState();
}
enum CallUIState {
  incoming,
  calling,
  ongoing,
  ended,
}
class _CallScreenState extends State<CallScreen> {
  CallUIState _uiState = CallUIState.calling;
bool _isMuted = false;
bool _isSpeakerOn = true;
bool _isVideoEnabled = true;

void _toggleMute() {
  _isMuted = !_isMuted;
  _engine?.muteLocalAudioStream(_isMuted);
  setState(() {});
}

void _toggleSpeaker() {
  _isSpeakerOn = !_isSpeakerOn;
  _engine?.setEnableSpeakerphone(_isSpeakerOn);
  setState(() {});
}

void _toggleVideo() {
  _isVideoEnabled = !_isVideoEnabled;
  _engine?.muteLocalVideoStream(!_isVideoEnabled);
  setState(() {});
}

void _switchCamera() {
  _engine?.switchCamera();
}
  static const String agoraAppId = "26a4269bedb846619f05292c85c74dba";

  RtcEngine? _engine;
  StreamSubscription<List<Map<String, dynamic>>>? _callSub;

  String? _token;
  int? _myUid;
  int? _remoteUid;

  bool _localJoined = false;
  bool _isConnected = false;
  bool _isIncoming = false;
  bool _isJoining = false;

  Timer? _timer;
  int _seconds = 0;

  // ================= INIT =================

  @override
  void initState() {
    super.initState();
    _isIncoming = !widget.isCaller;
    _uiState = _isIncoming
      ? CallUIState.incoming
      : CallUIState.calling;
    _listenCall();
  }

  @override
  void dispose() {
    _callSub?.cancel();
    _timer?.cancel();
    _leaveAgora();
    super.dispose();
  }

  // ================= SUPABASE CALL LISTENER =================

  void _listenCall() {
  debugPrint("🔍 Listening to call ID: ${widget.callId}");

  _callSub = Supabase.instance.client
      .from('calls')
      .stream(primaryKey: ['id'])
      .eq('id', widget.callId)
      .listen((data) async {
    debugPrint('🔔 Call data: $data');

    if (!mounted || data.isEmpty) return;

    final call = data.first;
    final status = call['status'];

    debugPrint("📞 Call status: $status");

    // --------------------------------------------------
    // 1️⃣ Update UI state based on DB status
    // --------------------------------------------------

    if (mounted) {
      setState(() {
        switch (status) {
          case 'ringing':
            _uiState = widget.isCaller
                ? CallUIState.calling
                : CallUIState.incoming;
            break;

          case 'ongoing':
            _uiState = CallUIState.ongoing;
            break;

          case 'ended':
            _uiState = CallUIState.ended;
            break;
        }
      });
    }

    // --------------------------------------------------
    // 2️⃣ Load / Generate Token Once
    // --------------------------------------------------

    if (_token == null) {
      if (widget.isCaller) {
        _token = call['agora_token'];
        _myUid ??= call['caller_uid'];
        debugPrint("✅ Caller loaded token: $_token | UID: $_myUid");
      } else {
        await _generateReceiverToken();
      }
    }

    debugPrint("✅ Token ready: ${_token != null}");

    // --------------------------------------------------
    // 3️⃣ Join Agora ONLY when call is ongoing
    // --------------------------------------------------

    if (_token != null &&
        !_localJoined &&
        !_isJoining &&
        status == 'ongoing') {
      debugPrint("🚪 Joining Agora channel: ${widget.channelName}");
      await _joinAgora();
    }

    // --------------------------------------------------
    // 4️⃣ DO NOT auto-exit on ended
    // --------------------------------------------------
    if (status == 'ended') {
      debugPrint("📴 Call ended - showing End UI");
      _timer?.cancel();
      await _leaveAgora();
      // No Navigator.pop here
    }
  });
}

  // ================= RECEIVER TOKEN GENERATION =================
  
  Future<void> _generateReceiverToken() async {
    try {
      debugPrint("📲 Receiver generating own token...");
      final response = await Supabase.instance.client.functions.invoke('agora-token', 
        body: {
          'channelName': widget.channelName,
          'uid': 0,  // Auto-assign UID
          'role': 'publisher',
        }
      );
      
      if (response.data != null && response.data['token'] != null) {
        _token = response.data['token'];
        debugPrint("✅ Receiver token generated: ${_token!.substring(0, 20)}...");
      } else {
        debugPrint("❌ Invalid token response: ${response.data}");
      }
    } catch (e) {
      debugPrint("❌ Receiver token generation failed: $e");
      _exit(); // Exit if can't get token
    }
  }

  // ================= AGORA =================

  Future<void> _joinAgora() async {
  debugPrint("🚪 Attempting to join Agora..........");

  if (_token == null) {
    debugPrint("❌ Token is null");
    return;
  }

  if (_engine != null) {
    debugPrint("⚠️ Engine already exists");
    return;
  }

  if (_isJoining) {
    debugPrint("⚠️ Already joining");
    return;
  }

  _isJoining = true;

  try {
    // --------------------------------------------------
    // 1️⃣ Permissions (Strict Handling)
    // --------------------------------------------------

    final micStatus = await Permission.microphone.request();
    debugPrint("🎤 Mic permission: $micStatus");

    if (!micStatus.isGranted) {
      debugPrint("❌ Microphone permission denied");
      _isJoining = false;
      return;
    }

    if (widget.isVideo) {
      final camStatus = await Permission.camera.request();
      debugPrint("📷 Camera permission: $camStatus");

      if (!camStatus.isGranted) {
        debugPrint("❌ Camera permission denied");
        _isJoining = false;
        return;
      }
    }

    // --------------------------------------------------
    // 2️⃣ Create & Initialize Engine
    // --------------------------------------------------

    _engine = createAgoraRtcEngine();
    await _engine!.initialize(
      const RtcEngineContext(appId: agoraAppId),
    );

    debugPrint("✅ Agora engine initialized");

    await _engine!.setAudioProfile(
      profile: AudioProfileType.audioProfileDefault,
      scenario: AudioScenarioType.audioScenarioChatroom,
    );

    await _engine!.enableAudio();

    if (widget.isVideo) {
      await _engine!.enableVideo();
    }

    await _engine!.setClientRole(
      role: ClientRoleType.clientRoleBroadcaster,
    );

    debugPrint("👤 Role set to broadcaster");

    // --------------------------------------------------
    // 3️⃣ Register Events
    // --------------------------------------------------

    _engine!.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          debugPrint("✅ Joined channel");
          debugPrint("🆔 Local UID: ${connection.localUid}");

          if (!mounted) return;

          setState(() {
            _localJoined = true;
            _myUid ??= connection.localUid;
          });
        },

        onUserJoined:
            (RtcConnection connection, int remoteUid, int elapsed) {
          debugPrint("👤 Remote joined: $remoteUid");

          if (!mounted) return;

          setState(() {
            _remoteUid = remoteUid;
            _isConnected = true;
          });

          _startTimer();
        },

        onFirstRemoteAudioFrame:
            (RtcConnection connection, int remoteUid, int elapsed) {
          debugPrint("🔊 First remote audio frame");
          if (!mounted) return;
          setState(() => _isConnected = true);
        },

        // ⚠️ IMPORTANT CHANGE HERE
        onUserOffline:
            (RtcConnection connection, int remoteUid,
                UserOfflineReasonType reason) async {
          debugPrint("👋 Remote offline: $remoteUid | $reason");

          if (!mounted) return;

          // Only update UI — DO NOT call _endCall()
          setState(() {
            _uiState = CallUIState.ended;
          });

          _timer?.cancel();
          await _leaveAgora();
        },

        onError: (err, msg) {
          debugPrint("❌ AGORA ERROR: $err - $msg");
        },
      ),
    );

    // --------------------------------------------------
    // 4️⃣ Join Channel
    // --------------------------------------------------

    debugPrint("📡 Joining: ${widget.channelName}");

    await _engine!.joinChannel(
      token: _token!,
      channelId: widget.channelName,
      uid: widget.isCaller ? (_myUid ?? 0) : 0,
      options: ChannelMediaOptions(
        clientRoleType: ClientRoleType.clientRoleBroadcaster,
        publishMicrophoneTrack: true,
        publishCameraTrack: widget.isVideo,
        autoSubscribeAudio: true,
        autoSubscribeVideo: widget.isVideo,
      ),
    );

    debugPrint("📡 joinChannel() executed");
  } catch (e) {
    debugPrint("❌ Failed to join Agora: $e");
  } finally {
    _isJoining = false; // ✅ Always reset
  }
}
  Future<void> _leaveAgora() async {
    try {
      await _engine?.leaveChannel();
      await _engine?.release();
      _engine = null;
    } catch (_) {}
  }

  // ================= CALL ACTIONS =================

  Future<void> _acceptCall() async {
    // setState(() => _isIncoming = false);

    await Supabase.instance.client
        .from('calls')
        .update({'status': 'ongoing'})
        .eq('id', widget.callId);
  }

  Future<void> _endCall() async {
    await Supabase.instance.client
        .from('calls')
        .update({'status': 'ended'})
        .eq('id', widget.callId);
    _timer?.cancel();
    await _leaveAgora();
    // _exit();
  }

  void _exit() {
    _timer?.cancel();
    _leaveAgora();
    if (mounted) Navigator.pop(context);
  }

  // ================= TIMER =================

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _seconds++);
    });
  }

  String _duration() {
    final m = (_seconds ~/ 60).toString().padLeft(2, '0');
    final s = (_seconds % 60).toString().padLeft(2, '0');
    return "$m:$s";
  }

  // ================= UI =================

  @override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Colors.black,
    body: SafeArea(
      child: Stack(
        children: [

          /// ================= VIDEO BACKGROUND =================
          if (widget.isVideo &&
              _remoteUid != null &&
              _engine != null &&
              _uiState == CallUIState.ongoing)
            Positioned.fill(
              child: AgoraVideoView(
                controller: VideoViewController.remote(
                  rtcEngine: _engine!,
                  canvas: VideoCanvas(uid: _remoteUid!),
                  connection:
                      RtcConnection(channelId: widget.channelName),
                ),
              ),
            ),

          /// ================= UI CONTENT =================
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _buildUIByState(),
          ),
        ],
      ),
    ),
  );
}
Widget _buildUIByState() {
  switch (_uiState) {
    case CallUIState.incoming:
      return _incomingUI();

    case CallUIState.calling:
      return _callingUI();

    case CallUIState.ongoing:
      // 🔥 Choose UI based on call type
      return widget.isVideo
          ? _videoCallUI()
          : _ongoingUI();

    case CallUIState.ended:
      return _endedUI();
  }
}
Widget _incomingUI() {
  return Container(
    key: const ValueKey("incoming"),
    decoration: BoxDecoration(
      image: DecorationImage(
        image: NetworkImage(widget.otherUserImage),
        fit: BoxFit.cover,
      ),
    ),
    child: Container(
      color: Colors.black.withOpacity(0.6),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 60,
            backgroundImage: NetworkImage(widget.otherUserImage),
          ),
          const SizedBox(height: 20),
          Text(
            widget.otherUserName,
            style: const TextStyle(
                fontSize: 22,
                color: Colors.white,
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const Text(
            "Incoming video call",
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 60),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _circleButton(Icons.call_end, Colors.red, _endCall),
              _circleButton(Icons.call, Colors.green, _acceptCall),
            ],
          )
        ],
      ),
    ),
  );
}
Widget _callingUI() {
  return Container(
    key: const ValueKey("calling"),
    alignment: Alignment.center,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: 70,
          backgroundImage: NetworkImage(widget.otherUserImage),
        ),
        const SizedBox(height: 20),
        Text(
          widget.otherUserName,
          style: const TextStyle(
              fontSize: 22,
              color: Colors.white,
              fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 10),
        const Text(
          "Ringing...",
          style: TextStyle(color: Colors.white70),
        ),
        const SizedBox(height: 50),
        _circleButton(Icons.call_end, Colors.red, _endCall),
      ],
    ),
  );
}
Widget _ongoingUI() {
  return Container(
    key: const ValueKey("ongoing"),
    padding: const EdgeInsets.symmetric(horizontal: 24),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [

        const SizedBox(height: 40),

        Column(
          children: [
            CircleAvatar(
              radius: 60,
              backgroundImage: NetworkImage(widget.otherUserImage),
            ),
            const SizedBox(height: 20),
            Text(
              widget.otherUserName,
              style: const TextStyle(
                  fontSize: 22,
                  color: Colors.white,
                  fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              _duration(),
              style: const TextStyle(color: Colors.white70),
            ),
          ],
        ),

        Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _controlButton(Icons.volume_up, "Speaker"),
                  _controlButton(Icons.mic_off, "Mute"),
                  _controlButton(Icons.videocam_off, "Video"),
                ],
              ),
              const SizedBox(height: 25),
              _circleButton(Icons.call_end, Colors.red, _endCall),
            ],
          ),
        )
      ],
    ),
  );
}
Widget _endedUI() {
  return Container(
    key: const ValueKey("ended"),
    color: Colors.white,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: 60,
          backgroundImage: NetworkImage(widget.otherUserImage),
        ),
        const SizedBox(height: 20),
        Text(
          widget.otherUserName,
          style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 10),
        const Text(
          "Call Ended",
          style: TextStyle(fontSize: 18),
        ),
        const SizedBox(height: 30),
        const Text("How was the call quality?"),
        const SizedBox(height: 15),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            5,
            (index) => const Icon(Icons.star,
                color: Colors.amber, size: 30),
          ),
        ),

        const SizedBox(height: 40),

        ElevatedButton(
          // onPressed: _exit,
          onPressed: () async {
            // Final cleanup safety
            _timer?.cancel();
            await _leaveAgora();

            if (mounted) {
              Navigator.pop(context);
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green.shade800,
            minimumSize: const Size(200, 50),
          ),
          child: const Text("Done"),
        )
      ],
    ),
  );
}
Widget _videoCallUI() {
  return Stack(
    children: [

      /// 🔹 Remote Video (Background)
      Positioned.fill(
        child: _remoteUid != null
            ? AgoraVideoView(
                controller: VideoViewController.remote(
                  rtcEngine: _engine!,
                  canvas: VideoCanvas(uid: _remoteUid),
                  connection: RtcConnection(channelId: widget.channelName),
                ),
              )
            : Container(color: Colors.black),
      ),

      /// 🔹 Top Bar
      SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: _endCall,
              ),

              CircleAvatar(
                radius: 18,
                backgroundImage:
                    NetworkImage(widget.otherUserImage),
              ),

              const SizedBox(width: 10),

              Text(
                widget.otherUserName,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const Spacer(),

              Text(
                _duration(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),

      /// 🔹 Local Preview (Top Right)
      Positioned(
        top: 100,
        right: 16,
        child: Container(
          width: 110,
          height: 150,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.black,
          ),
          clipBehavior: Clip.hardEdge,
          child: _localJoined
              ? AgoraVideoView(
                  controller: VideoViewController(
                    rtcEngine: _engine!,
                    canvas: const VideoCanvas(uid: 0),
                  ),
                )
              : const SizedBox(),
        ),
      ),

      /// 🔹 Bottom Controls
      Align(
        alignment: Alignment.bottomCenter,
        child: SafeArea(
          child: Container(
            margin: const EdgeInsets.only(bottom: 20),
            padding: const EdgeInsets.symmetric(
                horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [

                _callControlButton(
                  icon: Icons.volume_up,
                  label: "Speaker",
                  onTap: _toggleSpeaker,
                ),

                const SizedBox(width: 25),

                _callControlButton(
                  icon: Icons.mic_off,
                  label: "Mute",
                  onTap: _toggleMute,
                ),

                const SizedBox(width: 25),

                _callControlButton(
                  icon: Icons.videocam,
                  label: "Video",
                  onTap: _toggleVideo,
                ),

                const SizedBox(width: 25),

                _callControlButton(
                  icon: Icons.cameraswitch,
                  label: "Flip",
                  onTap: _switchCamera,
                ),

                const SizedBox(width: 25),

                GestureDetector(
                  onTap: _endCall,
                  child: const CircleAvatar(
                    radius: 22,
                    backgroundColor: Colors.red,
                    child: Icon(Icons.call_end,
                        color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ],
  );
}
Widget _circleButton(
    IconData icon, Color color, VoidCallback onTap) {
  return GestureDetector(
    onTap: onTap,
    child: CircleAvatar(
      radius: 32,
      backgroundColor: color,
      child: Icon(icon, color: Colors.white),
    ),
  );
}

Widget _controlButton(IconData icon, String label) {
  return Column(
    children: [
      CircleAvatar(
        radius: 25,
        backgroundColor: Colors.white24,
        child: Icon(icon, color: Colors.white),
      ),
      const SizedBox(height: 6),
      Text(label,
          style: const TextStyle(
              color: Colors.white70, fontSize: 12))
    ],
  );
}
Widget _callControlButton({
  required IconData icon,
  required String label,
  required VoidCallback onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
          ),
        ),
      ],
    ),
  );
}
}
