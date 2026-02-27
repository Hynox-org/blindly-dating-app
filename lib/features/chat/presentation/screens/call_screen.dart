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

class _CallScreenState extends State<CallScreen> {
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

          // Load token once (for caller) or generate for receiver
          if (_token == null) {
            if (widget.isCaller) {
              _token = call['agora_token'];
              _myUid ??= call['caller_uid'];
              debugPrint("✅ Caller loaded token: $_token | UID: $_myUid");
            } else {
              // Receiver: Generate own token
              await _generateReceiverToken();
            }
          }

          debugPrint("✅ Token ready: ${_token != null}");

          // FIXED: Receiver can join on 'ringing' OR 'ongoing'
          if (_token != null &&
              !_localJoined &&
              !_isJoining &&
              (widget.isCaller || 
               status == 'ongoing' || 
               status == 'ringing')) {
            debugPrint("🚪 Joining Agora channel: ${widget.channelName}");
            debugPrint("✅ Status: $status | Caller: ${widget.isCaller}");
            await _joinAgora();
          }

          if (status == 'ended') {
            debugPrint("📴 Call ended, exiting... from db");
            _exit();
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

    // Permissions
    final micStatus = await Permission.microphone.request();
    debugPrint("🎤 Mic permission: $micStatus");
    
    if (widget.isVideo) {
      final camStatus = await Permission.camera.request();
      debugPrint("📷 Camera permission: $camStatus");
    }

    try {
      _engine = createAgoraRtcEngine();
      await _engine!.initialize(const RtcEngineContext(appId: agoraAppId));
      debugPrint("✅ Agora engine initialized");

      await _engine!.setAudioProfile(
        profile: AudioProfileType.audioProfileDefault,
        scenario: AudioScenarioType.audioScenarioChatroom,
      );

      await _engine!.enableAudio();
      debugPrint("✅ Audio enabled");
      
      if (widget.isVideo) {
        await _engine!.enableVideo();
        debugPrint("✅ Video enabled");
      }

      await _engine!.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
      debugPrint("👤 Set role as broadcaster");

      _engine!.registerEventHandler(
        RtcEngineEventHandler(
          onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
            debugPrint("✅ Joined channel successfully");
            debugPrint("🆔 Local UID: ${connection.localUid}");

            if (!mounted) return;

            setState(() {
              _localJoined = true;
              _myUid ??= connection.localUid;
            });
          },
          onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
            debugPrint("👤 Remote user joined: $remoteUid");
            if (!mounted) return;

            setState(() {
              _remoteUid = remoteUid;
              _isConnected = true;
            });

            _startTimer();
          },
          onFirstRemoteAudioFrame: (RtcConnection connection, int remoteUid, int elapsed) {
            debugPrint("🔊 First remote audio frame received");
            if (!mounted) return;
            setState(() => _isConnected = true);
          },
          onUserOffline: (RtcConnection connection, int remoteUid, UserOfflineReasonType reason) {
            debugPrint("👋 Remote user offline: $remoteUid | Reason: $reason");
            _endCall();
          },
          onError: (err, msg) {
            debugPrint("❌ AGORA ERROR: $err - $msg");
          },
        ),
      );

      debugPrint("📡 Joining channel: ${widget.channelName}");
      debugPrint("🔑 Using token: ${_token!.substring(0, 20)}...");
      debugPrint("🆔 UID: ${_myUid ?? (widget.isCaller ? 0 : 0)}"); // Caller uses stored UID, receiver auto

      await _engine!.joinChannel(
        token: _token!,
        channelId: widget.channelName,
        uid: widget.isCaller ? (_myUid ?? 0) : 0, // FIXED: Receiver uses uid: 0 (auto-assign)
        options: ChannelMediaOptions(
          clientRoleType: ClientRoleType.clientRoleBroadcaster,
          publishMicrophoneTrack: true,
          publishCameraTrack: widget.isVideo,
          autoSubscribeAudio: true,
          autoSubscribeVideo: widget.isVideo,
        ),
      );
      debugPrint("📡 joinChannel() called");
    } catch (e) {
      debugPrint("❌ Failed to join Agora: $e");
    }
    _isJoining = false;
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
    setState(() => _isIncoming = false);

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

    _exit();
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
            // FIXED: Local video preview (small corner)
            if (widget.isVideo && _localJoined && _engine != null && _remoteUid == null)
              Positioned(
                top: 40,
                right: 20,
                child: Container(
                  width: 100,
                  height: 140,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: AgoraVideoView(
                    controller: VideoViewController(
                      rtcEngine: _engine!,
                      canvas: const VideoCanvas(uid: 0), // Local preview
                    ),
                  ),
                ),
              ),
            
            // Remote video (full screen)
            if (widget.isVideo && _remoteUid != null && _engine != null)
              AgoraVideoView(
                controller: VideoViewController.remote(
                  rtcEngine: _engine!,
                  canvas: VideoCanvas(uid: _remoteUid!),
                  connection: RtcConnection(channelId: widget.channelName),
                ),
              ),

            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 60),
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
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                // FIXED: Better status text
                Text(
                  _isIncoming
                      ? "Incoming Call..."
                      : _localJoined
                          ? (_isConnected ? _duration() : "Ringing...")
                          : "Connecting...",
                  style: const TextStyle(color: Colors.white70, fontSize: 16),
                ),
              ],
            ),

            // FIXED: Hero tags for FABs
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 40),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    if (_isIncoming)
                      FloatingActionButton(
                        heroTag: 'callscreen_${widget.callId}_accept',
                        backgroundColor: Colors.green,
                        onPressed: _acceptCall,
                        child: const Icon(Icons.call),
                      ),
                    FloatingActionButton(
                      heroTag: 'callscreen_${widget.callId}_end',
                      backgroundColor: Colors.red,
                      onPressed: _endCall,
                      child: const Icon(Icons.call_end),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
