import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';
// import 'package:agora_rtc_engine/agora_rtc_engine.dart';
// import 'package:permission_handler/permission_handler.dart';
import '../../../call/presentation/screens/call_screen.dart';
import 'dart:async';
import './../../../../core/utils/app_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/security/encryption_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/security/key_security.dart';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:image/image.dart' as img;

class ChatConversationScreen extends ConsumerStatefulWidget {
  final String matchId;
  final String otherUserName;
  final String otherUserImage;
  final String myProfileId;
  final String otherProfileId;
  final String name;
  final String imageUrl;

  const ChatConversationScreen({
    super.key,
    required this.matchId,
    required this.otherUserName,
    required this.otherUserImage,
    required this.myProfileId,
    required this.otherProfileId,
    required this.name,
    required this.imageUrl,
  });

  @override
  ConsumerState<ChatConversationScreen> createState() =>
      _ChatConversationScreenState();
}

class _ChatConversationScreenState
    extends ConsumerState<ChatConversationScreen> {
  final SupabaseClient _supabase = Supabase.instance.client;

  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  final ImagePicker _imagePicker = ImagePicker();
  String? _editingMessageId;
  bool get _isEditing => _editingMessageId != null;
  RealtimeChannel? _channel;
  final List<Message> _messages = [];
  Timer? timer;
  Message? _replyingTo;
  // List<Message> messages = [];   // Ensure this exists
  RealtimeChannel? channelRead; // Add this
  String? receiverPublicKeyPem;
  bool _isKeyReady = false;
  // Voice recording
  final AudioRecorder _audioRecorder = AudioRecorder();
  bool _isRecording = false;
  String? _recordingPath;
  Duration _recordingDuration = Duration.zero;

  String get _myProfileId => widget.myProfileId;
  final userId = Supabase.instance.client.auth.currentUser!.id;

  // ================== AGORA ==================
  @override
  void initState() {
    super.initState();
    AppState.isChatScreenOpen = true;
    AppState.currentChatProfileId = widget.otherProfileId;
    AppState.setCurrentChat(widget.otherProfileId);

    // Initialize keys FIRST, then load other data
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await KeyService.generateAndStoreKeys(userId);
      if (mounted) {
        await _loadReceiverKey();
        await _loadHistory();
        _listenRealtime();
        await diagnosePrivateKey(); // ADD THIS
      }
    });

    // Rest of your existing initState code (timer, etc.)
    timer = Timer.periodic(const Duration(seconds: 3), (timerInstance) {
      if (mounted) _markMessagesAsRead();
    });

    // Fix channelRead assignment (use consistent naming)
    channelRead = _supabase
        .channel('read-status-${widget.matchId}')
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'messages',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'match_id', // Note: match_id (snake_case) matches your DB
            value: widget.matchId,
          ),
          callback: (payload) {
            if (!mounted) return;
            final updated = Message.fromMap(payload.newRecord);
            if (updated.senderProfileId != widget.myProfileId &&
                updated.readAt != null &&
                _messages.any((m) => m.id == updated.id)) {
              final index = _messages.indexWhere((m) => m.id == updated.id);
              if (index != -1) {
                setState(() {
                  _messages[index] = updated;
                });
              }
            }
          },
        )
        .subscribe();

    _markMessagesAsDelivered();
    _markMessagesAsRead();
  }

  @override
  void dispose() {
    AppState.isChatScreenOpen = false;
    AppState.currentChatProfileId = null;
    AppState.setCurrentChat(null);

    if (_channel != null) {
      // Use your actual channel variable name
      _supabase.removeChannel(_channel!);
    }
    if (channelRead != null) {
      _supabase.removeChannel(channelRead!);
    }

    timer?.cancel(); // Cancel the timer

    _controller.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    _audioRecorder.dispose();
    super.dispose();
  }

  //===========================================
  // AGORA CALL SETUP
  //===========================================

  bool _isNavigatingToCall = false;

  Future<void> _startCall(bool isVideo) async {
    debugPrint("📞 Starting ${isVideo ? 'video' : 'audio'} call...");
    if (_isNavigatingToCall) {
      debugPrint("⚠️ Already navigating to a call, ignoring...");
      return;
    }
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      debugPrint("❌ User is null");
      return;
    }
    _isNavigatingToCall = true;

    try {
      final profile = await Supabase.instance.client
          .from('profiles')
          .select('id')
          .eq('user_id', user.id)
          .single();
      debugPrint("✅ Profile loaded: ${profile['id']}");
      final myProfileId = profile['id'];
      debugPrint("✅ My profile ID: $myProfileId");
      // ✅ Prevent multiple active calls
      final activeCall = await Supabase.instance.client
          .from('calls')
          .select('id')
          .or(
            'and(status.eq.ringing,caller_id.eq.$myProfileId),'
            'and(status.eq.ringing,receiver_id.eq.$myProfileId),'
            'and(status.eq.ongoing,caller_id.eq.$myProfileId),'
            'and(status.eq.ongoing,receiver_id.eq.$myProfileId)',
          );
      debugPrint("✅ Active calls query result: $activeCall");
      debugPrint(
        "✅ Active calls check: ${activeCall.length} active call(s) found",
      );
      if (activeCall.isNotEmpty) {
        _isNavigatingToCall = false;
        debugPrint("⚠️ Already have an active call, ignoring...");
        return;
      }

      // ✅ Better UID generation
      final myUid =
          (DateTime.now().millisecondsSinceEpoch ~/ 1000) % 1000000000;
      debugPrint("✅ Generated UID: $myUid");
      // ✅ Edge Function invoke (FIXED – no .error usage)
      late final FunctionResponse response;
      debugPrint("📡 Invoking Agora token function...");
      try {
        response = await Supabase.instance.client.functions.invoke(
          'agora-token',
          body: {
            'channelName': widget.matchId,
            'uid': myUid,
            'role': 'publisher',
          },
        );
        debugPrint("✅ Function response: ${response.data}");
      } catch (e) {
        debugPrint("❌ Token invoke failed: $e");
        _isNavigatingToCall = false;
        return;
      }

      if (response.data == null) {
        debugPrint("❌ Token response empty");
        _isNavigatingToCall = false;
        return;
      }

      final token = response.data['token'];
      if (token == null) {
        _isNavigatingToCall = false;
        debugPrint("❌ Token missing in response");
        return;
      }

      // ✅ Insert call record
      final res = await Supabase.instance.client
          .from('calls')
          .insert({
            'caller_id': myProfileId,
            'receiver_id': widget.otherProfileId,
            'channel_name': widget.matchId,
            'call_type': isVideo ? 'video' : 'audio',
            'status': 'ringing',
            'agora_token': token,
            'caller_uid': myUid,
          })
          .select()
          .maybeSingle();

      debugPrint("✅ Call insert result: $res");

      if (res == null) {
        debugPrint("❌ Call insert failed — RLS or DB error");
        _isNavigatingToCall = false;
        return;
      }

      final call = res;
      debugPrint("✅ Call ID: ${call['id']}");

      if (!mounted) return;

      AppState.isCallScreenOpen = true;

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CallScreen(
            callId: call['id'],
            channelName: widget.matchId,
            isVideo: isVideo,
            isCaller: true,
            otherUserName: widget.otherUserName,
            otherUserImage: widget.otherUserImage,
          ),
        ),
      );

      AppState.isCallScreenOpen = false;
    } catch (e) {
      debugPrint("❌ Start call error: $e");
    } finally {
      _isNavigatingToCall = false;
    }
  }

  // ==============================
  // MARK AS DELIVERED/READ
  // ==============================

  Future<void> _markMessagesAsDelivered() async {
    try {
      await _supabase
          .from('messages')
          .update({'delivered_at': DateTime.now().toUtc().toIso8601String()})
          .eq('match_id', widget.matchId)
          .eq('receiver_profile_id', _myProfileId)
          .isFilter('delivered_at', null);
    } catch (e) {
      debugPrint('Error marking messages as delivered: $e');
    }
  }

  Future<void> _markMessagesAsRead() async {
    try {
      await _supabase
          .from('messages')
          .update({'read_at': DateTime.now().toUtc().toIso8601String()})
          .eq('match_id', widget.matchId)
          .eq('receiver_profile_id', _myProfileId)
          .isFilter('read_at', null);
    } catch (e) {
      debugPrint('Error marking messages as read: $e');
    }
  }

  // ==============================
  // LOAD HISTORY
  // ==============================

  Future<void> _loadHistory() async {
    try {
      final res = await _supabase
          .from('messages')
          .select()
          .eq('match_id', widget.matchId)
          .order('created_at', ascending: true);

      final List data = res as List;

      print("📜 Loaded messages from DB: ${data.length}");

      final List<Message> loadedMessages = [];

      for (final raw in data) {
        final msg = Map<String, dynamic>.from(raw);

        String content = msg['content'] ?? '';
        if (msg['message_type'] == 'text') {
          print(
            "📜 Processing message ${msg['id']} with content length ${content.length}, message_type: ${msg['message_type']}",
          );

          print(
            "🔍 Decrypting message ${msg['id']} with content length ${content.length},message_type: ${msg['message_type']}",
          );
          try {
            // 🔐 Decrypt only encrypted TEXT messages
            if (msg['message_type'] == 'text' &&
                msg['encrypted_key'] != null &&
                msg['iv'] != null &&
                msg['content'] != null) {
              content = await EncryptionService.decryptMessage(
                cipherText: msg['content'],
                encryptedKey: msg['encrypted_key'],
                iv: msg['iv'],
              );
            }
          } catch (e) {
            content = "🔒 Encrypted message";
            print("❌ Decrypt failed for message ${msg['id']}: $e");
          }
        }

        msg['content'] = content;

        loadedMessages.add(Message.fromMap(msg));
      }

      if (!mounted) return;

      setState(() {
        _messages
          ..clear()
          ..addAll(loadedMessages);
      });

      _scrollToBottom();
    } catch (e) {
      debugPrint('❌ Error loading message history: $e');
    }
  }

  Future<void> diagnosePrivateKey() async {
    try {
      // ✅ Use EncryptionService's public method instead of private field
      final privateKeyPem = await EncryptionService.getPrivateKeyPem();
      print(
        "🔑 PRIVATE KEY EXISTS: ${privateKeyPem != null ? 'YES (${privateKeyPem.length} chars)' : 'NO'}",
      );

      if (privateKeyPem != null) {
        print("🔑 PRIVATE KEY SAMPLE: ${privateKeyPem}");
        print(
          "🔑 PRIVATE KEY TYPE: ${privateKeyPem.contains('PRIVATE KEY') ? 'VALID' : 'INVALID'}",
        );
        print("🔑 PRIVATE KEY START: ${privateKeyPem.substring(0, 50)}...");
        print(
          "🔑 PRIVATE KEY END: ...${privateKeyPem.substring(privateKeyPem.length - 50)}",
        );
        print(
          "🔑 PRIVATE KEY TYPE: ${privateKeyPem.contains('RSA PRIVATE KEY') ? 'RSA' : 'UNKNOWN'}",
        );
      }
    } catch (e) {
      print("❌ PRIVATE KEY ERROR: $e");
    }
  }

  Future<void> _handleRealtimeMessage(Map<String, dynamic> raw) async {
    print(raw);
    final data = Map<String, dynamic>.from(raw);
    print("📩 Realtime message data: $data");
    String content = data['content'] ?? '';

    try {
      if (data['message_type'] == 'text' &&
          data['encrypted_key'] != null &&
          data['iv'] != null &&
          data['content'] != null) {
        print("🔍 Realtime decrypting message ${data['id']}...");
        content = await EncryptionService.decryptMessage(
          cipherText: data['content'],
          encryptedKey: data['encrypted_key'],
          iv: data['iv'],
        );
        print("content: $content");
      }
    } catch (e) {
      content = "🔒 Encrypted message";
      print("❌ Realtime decrypt failed: $e");
    }

    data['content'] = content;

    final msg = Message.fromMap(data);

    final exists = _messages.any((m) => m.id == msg.id);

    if (!exists && mounted) {
      setState(() => _messages.add(msg));
      _scrollToBottom();
    }
  }

  Future<void> _handleRealtimeUpdate(Map<String, dynamic> raw) async {
    print(raw);
    final data = Map<String, dynamic>.from(raw);

    String content = data['content'] ?? '';

    try {
      if (data['message_type'] == 'text' &&
          data['encrypted_key'] != null &&
          data['iv'] != null &&
          data['content'] != null) {
        content = await EncryptionService.decryptMessage(
          cipherText: data['content'],
          encryptedKey: data['encrypted_key'],
          iv: data['iv'],
        );
        print("content: $content");
      }
    } catch (e) {
      content = "🔒 Encrypted message";
      print("❌ Update decrypt failed: $e");
    }

    data['content'] = content;

    final updated = Message.fromMap(data);

    final index = _messages.indexWhere((m) => m.id == updated.id);

    if (index != -1 && mounted) {
      setState(() => _messages[index] = updated);
    }
  }
  // ==============================
  // REALTIME
  // ==============================

  void _listenRealtime() {
    // ✅ FIX 1: Use stable channel name (NOT dynamic per match)
    _channel = _supabase.channel('messages');

    _channel!
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'messages',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'match_id',
            value: widget.matchId,
          ),
          callback: (payload) async {
            print("📩 Realtime INSERT received");

            final newMsg = payload.newRecord;

            if (newMsg == null) return;

            await _handleRealtimeMessage(newMsg);
          },
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'messages',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'match_id',
            value: widget.matchId,
          ),
          callback: (payload) async {
            print("✏️ Realtime UPDATE received");

            final updatedMsg = payload.newRecord;

            if (updatedMsg == null) return;

            await _handleRealtimeUpdate(updatedMsg);
          },
        )
        .subscribe((status, error) {
          print("📡 Realtime status: $status");

          if (error != null) {
            print("❌ Realtime error: $error");
          }
        });
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 200), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _loadReceiverKey() async {
    try {
      final res = await _supabase
          .from('profiles')
          .select('public_key')
          .eq('user_id', userId)
          .single();

      receiverPublicKeyPem = res['public_key'];

      if (receiverPublicKeyPem != null && receiverPublicKeyPem!.isNotEmpty) {
        _isKeyReady = true;
        print("✅ Receiver public key loaded");
      } else {
        _isKeyReady = false;
        print("❌ Receiver public key is EMPTY");
      }
    } catch (e) {
      _isKeyReady = false;
      print("❌ Failed to load receiver key: $e");
    }
  }
  // ==============================
  // SEND TEXT MESSAGE
  // ==============================

  Future<void> _send(String text) async {
    if (text.trim().isEmpty) return;

    final trimmedText = text.trim();
    if (trimmedText.length > 14000) {
      // UI warning
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Message too long. Keep under 14k chars.'),
        ),
      );
      return;
    }
    if (!_isKeyReady) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Encryption key not loaded. Please wait."),
        ),
      );
      return;
    }

    if (_myProfileId == null || widget.otherProfileId.isEmpty) return;

    try {
      // ==============================
      // 🔐 ENCRYPT MESSAGE
      // ==============================
      final encrypted = await EncryptionService.encryptMessage(
        message: trimmedText,
        receiverPublicKeyPem: receiverPublicKeyPem!,
      );

      if (_isEditing) {
        await _supabase
            .from('messages')
            .update({
              'content': encrypted.cipherText,
              'encrypted_key': encrypted.encryptedKey,
              'iv': encrypted.iv,
              'edited_at': DateTime.now().toIso8601String(),
            })
            .eq('id', _editingMessageId!);

        setState(() => _editingMessageId = null);
      } else {
        await _supabase.from('messages').insert({
          'match_id': widget.matchId,
          'sender_profile_id': _myProfileId,
          'receiver_profile_id': widget.otherProfileId,
          'content': encrypted.cipherText,
          'encrypted_key': encrypted.encryptedKey,
          'iv': encrypted.iv,
          'message_type': 'text',
          'reply_to_id': _replyingTo?.id,
        });

        setState(() => _replyingTo = null);
      }

      _controller.clear();
    } catch (e) {
      debugPrint('❌ Error sending encrypted message: $e');
    }
  }

  Future<void> _showIceBreakerSheet() async {
    final categories = ["All", "Playful", "Deep", "Quirky", "Hypothesis"];

    final icebreakers = [
      "What’s a small thing that made you smile recently?",
      "Two truths and a lie: Let’s go!",
      "If you could have any superpower, what would it be?",
      "What’s the most interesting thing you’ve learned lately?",
    ];

    int selectedCategory = 0;

    final selectedText = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.7,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 12),

                  Container(
                    height: 5,
                    width: 40,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),

                  const SizedBox(height: 16),

                  const Text(
                    "Icebreakers",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  ),

                  const SizedBox(height: 16),

                  /// Categories
                  SizedBox(
                    height: 38,
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      scrollDirection: Axis.horizontal,
                      itemCount: categories.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final selected = selectedCategory == index;

                        return ChoiceChip(
                          label: Text(categories[index]),
                          selected: selected,
                          showCheckmark: false,
                          selectedColor: Colors.black,
                          backgroundColor: Colors.grey.shade200,
                          labelStyle: TextStyle(
                            color: selected ? Colors.white : Colors.black,
                          ),
                          onSelected: (_) {
                            setModalState(() {
                              selectedCategory = index;
                            });
                          },
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 18),

                  /// Icebreaker list
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: icebreakers.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        return ListTile(
                          leading: const Icon(Icons.lightbulb_outline),
                          title: Text(icebreakers[index]),
                          trailing: IconButton(
                            icon: const Icon(Icons.send),
                            onPressed: () {
                              Navigator.pop(context, icebreakers[index]);
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    if (selectedText != null) {
      _send(selectedText);
    }
  }

  // ==============================
  // MULTI SELECT
  // ==============================

  final Set<String> _selectedMessageIds = {};
  bool _isSelectionMode = false;

  void _toggleSelection(Message message) {
    setState(() {
      if (_selectedMessageIds.contains(message.id)) {
        _selectedMessageIds.remove(message.id);
        if (_selectedMessageIds.isEmpty) {
          _isSelectionMode = false;
        }
      } else {
        _selectedMessageIds.add(message.id);
        _isSelectionMode = true;
      }
    });
  }

  void _clearSelection() {
    setState(() {
      _selectedMessageIds.clear();
      _isSelectionMode = false;
    });
  }

  //=============================
  //copy message
  //=============================
  void _copySelectedMessage() {
    if (_selectedMessageIds.length != 1) return;

    final msg = _messages.firstWhere((m) => m.id == _selectedMessageIds.first);

    if (msg.messageType != 'text') return;
    if (msg.deletedForEveryone == true) return;

    Clipboard.setData(ClipboardData(text: msg.text));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Message copied"),
        duration: Duration(seconds: 1),
      ),
    );

    _clearSelection();
  }

  //=============================
  // DELETE MESSAGES
  //=============================
  Future<void> _deleteSelectedMessages() async {
    if (_selectedMessageIds.isEmpty) return;

    showModalBottomSheet(
      context: context,
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.delete_outline),
                title: const Text("Delete for me"),
                onTap: () async {
                  Navigator.pop(context);
                  await _deleteForMe();
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text("Delete for everyone"),
                onTap: () async {
                  Navigator.pop(context);
                  await _deleteForEveryone();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _deleteForMe() async {
    try {
      for (final id in _selectedMessageIds) {
        final message = _messages.firstWhere((m) => m.id == id);

        final isSender = message.senderProfileId == _myProfileId;

        await _supabase
            .from('messages')
            .update({
              isSender ? 'deleted_for_sender' : 'deleted_for_receiver': true,
            })
            .eq('id', id);
      }

      _clearSelection();
    } catch (e) {
      debugPrint("Delete for me error: $e");
    }
  }

  Future<void> _deleteForEveryone() async {
    try {
      for (final id in _selectedMessageIds) {
        final message = _messages.firstWhere((m) => m.id == id);

        // Only sender can delete for everyone
        if (message.senderProfileId != _myProfileId) continue;

        await _supabase
            .from('messages')
            .update({'deleted_for_everyone': true})
            .eq('id', id);
      }

      _clearSelection();
    } catch (e) {
      debugPrint("Delete for everyone error: $e");
    }
  }

  // ==============================
  // VOICE RECORDING
  // ==============================

  Future<void> _startRecording() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        final directory = await getApplicationDocumentsDirectory();
        final path =
            '${directory.path}/voice_${DateTime.now().millisecondsSinceEpoch}.m4a';

        await _audioRecorder.start(
          const RecordConfig(encoder: AudioEncoder.aacLc),
          path: path,
        );

        setState(() {
          _isRecording = true;
          _recordingPath = path;
          _recordingDuration = Duration.zero;
        });

        _updateRecordingDuration();
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Microphone permission denied'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error starting recording: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to start recording: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _updateRecordingDuration() async {
    while (_isRecording) {
      await Future.delayed(const Duration(seconds: 1));
      if (_isRecording && mounted) {
        setState(() {
          _recordingDuration += const Duration(seconds: 1);
        });
      }
    }
  }

  Future<void> _stopRecording() async {
    try {
      final path = await _audioRecorder.stop();
      if (mounted) {
        setState(() {
          _isRecording = false;
          _recordingPath = path;
        });
      }
    } catch (e) {
      debugPrint('Error stopping recording: $e');
    }
  }

  Future<void> _cancelRecording() async {
    try {
      await _audioRecorder.stop();
      if (_recordingPath != null) {
        final file = File(_recordingPath!);
        if (await file.exists()) {
          await file.delete();
        }
      }
      if (mounted) {
        setState(() {
          _isRecording = false;
          _recordingPath = null;
          _recordingDuration = Duration.zero;
        });
      }
    } catch (e) {
      debugPrint('Error canceling recording: $e');
    }
  }

  Future<void> _sendVoiceMessage() async {
    if (_recordingPath == null) return;

    if (!mounted) return;

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: Color(0xFF3F472E)),
      ),
    );

    try {
      final file = File(_recordingPath!);

      // Check if file exists
      if (!await file.exists()) {
        throw Exception('Recording file not found');
      }

      final fileSize = await file.length();
      debugPrint('📦 Voice file size: $fileSize bytes');

      // Check file size (max 5MB)
      if (fileSize > 5 * 1024 * 1024) {
        throw Exception('Voice message is too large (max 5MB)');
      }

      if (fileSize == 0) {
        throw Exception('Recording file is empty');
      }

      final fileName = 'voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
      final filePath = '${widget.matchId}/$fileName';

      debugPrint('📤 Uploading to: $filePath');

      // Upload file using File object instead of bytes
      await _supabase.storage
          .from('voice_messages')
          .upload(
            filePath,
            file,
            fileOptions: const FileOptions(
              contentType: 'audio/m4a',
              upsert: false,
            ),
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw Exception('Upload timeout. Please check your connection.');
            },
          );

      debugPrint('✅ Upload successful');

      // Get public URL
      final publicUrl = _supabase.storage
          .from('voice_messages')
          .getPublicUrl(filePath);

      debugPrint('🔗 Public URL: $publicUrl');

      // Insert message into database
      await _supabase.from('messages').insert({
        'match_id': widget.matchId,
        'sender_profile_id': _myProfileId,
        'receiver_profile_id': widget.otherProfileId,
        'content': publicUrl,
        'message_type': 'voice',
        'voice_duration': _recordingDuration.inSeconds,
        'reply_to_id': _replyingTo?.id,
        'reaction': null,
      });

      debugPrint('✅ Message saved to database');

      // Clean up local file
      if (await file.exists()) {
        await file.delete();
      }

      // Reset state
      if (mounted) {
        setState(() {
          _recordingPath = null;
          _recordingDuration = Duration.zero;
          _replyingTo = null;
        });

        // Close loading dialog
        Navigator.of(context).pop();

        // Show success message
        // ScaffoldMessenger.of(context).showSnackBar(
        //   const SnackBar(
        //     content: Row(
        //       children: [
        //         Icon(Icons.check_circle, color: Colors.white),
        //         SizedBox(width: 8),
        //         Text('Voice message sent'),
        //       ],
        //     ),
        //     duration: Duration(seconds: 2),
        //     backgroundColor: Colors.green,
        //   ),
        // );
      }
    } catch (e) {
      debugPrint('❌ Error sending voice message: $e');

      // Close loading dialog
      if (mounted) {
        Navigator.of(context).pop();

        // Show error dialog with retry option
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.error_outline, color: Colors.red),
                SizedBox(width: 8),
                Text('Upload Failed'),
              ],
            ),
            content: Text(
              e.toString().contains('connection') ||
                      e.toString().contains('timeout') ||
                      e.toString().contains('abort')
                  ? 'Network error. Please check your internet connection and try again.'
                  : 'Failed to send voice message: ${e.toString()}',
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  // Delete the recording
                  if (_recordingPath != null) {
                    final file = File(_recordingPath!);
                    if (await file.exists()) {
                      await file.delete();
                    }
                  }
                  if (mounted) {
                    setState(() {
                      _recordingPath = null;
                      _recordingDuration = Duration.zero;
                    });
                  }
                },
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3F472E),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  _sendVoiceMessage(); // Retry
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        );
      }
    }
  }

  // ==============================
  // REPLY
  // ==============================

  void _replyTo(Message message) {
    setState(() => _replyingTo = message);
    _focusNode.requestFocus();
  }

  void _cancelReply() {
    setState(() => _replyingTo = null);
  }

  // ==============================
  // REACTION
  // ==============================

  Future<void> _reactToMessage(Message msg, String reaction) async {
    try {
      final index = _messages.indexWhere((m) => m.id == msg.id);
      if (index == -1) return;

      final updatedMessage = _messages[index].copyWith(reaction: reaction);

      setState(() {
        _messages[index] = updatedMessage;
      });

      await _supabase
          .from('messages')
          .update({'reaction': reaction})
          .eq('id', msg.id);
    } catch (e) {
      debugPrint('Error reacting to message: $e');
    }
  }

  //===============================
  // EDIT MESSAGE
  //===============================
  void _editSelectedMessage() {
    if (_selectedMessageIds.length != 1) return;

    final messageId = _selectedMessageIds.first;
    final message = _messages.firstWhere((m) => m.id == messageId);

    // Allow only sender to edit
    if (message.senderProfileId != _myProfileId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You can only edit your own messages")),
      );
      return;
    }
    if (message.messageType != 'text') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Only text messages can be edited")),
      );
      return;
    }
    setState(() {
      _editingMessageId = message.id;
      _controller.text = message.text;
      _clearSelection();
    });

    // Show keyboard automatically
    FocusScope.of(context).requestFocus(_focusNode);
  }

  // ==============================
  // FORWARD MESSAGES
  // ==============================
  // void _forwardSelectedMessages() {
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     SnackBar(
  //       content: Text(
  //         "${_selectedMessageIds.length} message(s) selected to forward",
  //       ),
  //     ),
  //   );

  //   _clearSelection();
  // }

  // ==============================
  // MESSAGE STATUS BUILDER
  // ==============================

  Widget _buildMessageStatus(Message message) {
    if (message.senderProfileId != _myProfileId) {
      return const SizedBox.shrink();
    }

    if (message.readAt != null) {
      return const Icon(Icons.done_all, size: 14, color: Colors.blue);
    }

    if (message.deliveredAt != null) {
      return Icon(Icons.done_all, size: 14, color: Colors.grey.shade400);
    }

    return Icon(Icons.done, size: 14, color: Colors.grey.shade400);
  }

  // ==============================

  void _scrollBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _formatTime(DateTime dt) => DateFormat('h:mm a').format(dt);

  String _formatDayLabel(DateTime dt) {
    final today = DateTime.now();
    final date = DateTime(dt.year, dt.month, dt.day);

    final diff = DateTime(
      today.year,
      today.month,
      today.day,
    ).difference(date).inDays;

    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    if (diff < 7) return DateFormat('EEEE').format(dt);

    return DateFormat('dd/MM/yyyy').format(dt);
  }

  // ==============================
  // GROUP MESSAGES BY DAY
  // ==============================

  List<MessageGroup> _groupMessagesByDay() {
    final groups = <MessageGroup>[];
    String? currentDay;

    for (final msg in _messages) {
      final dayLabel = _formatDayLabel(msg.createdAt);

      if (currentDay != dayLabel) {
        currentDay = dayLabel;
        groups.add(MessageGroup(dayLabel: dayLabel, messages: []));
      }

      groups.last.messages.add(msg);
    }

    return groups;
  }

  Widget _buildEncryptionMessage() {
    return Center(
      child: Container(
        margin: const EdgeInsets.only(top: 8, bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        width: MediaQuery.of(context).size.width * 0.85,
        decoration: BoxDecoration(
          color: const Color(0xFFFFF9C4).withOpacity(0.3), // Very light yellow tint
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFE6C97A).withOpacity(0.4),
            width: 0.5,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.lock_outline,
                  size: 14,
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
                ),
                const SizedBox(width: 6),
                Text(
                  "End-to-end encrypted",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.8),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.black.withOpacity(0.6),
                  fontFamily: 'Poppins', // Match theme
                  height: 1.4,
                ),
                children: [
                  const TextSpan(
                    text:
                        "Messages and calls are end-to-end encrypted. No one outside of this chat, not even Blindly, can read or listen to them. ",
                  ),
                  TextSpan(
                    text: "Tap to learn more.",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==============================
  // UI
  // ==============================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      /// 🔹 FLOATING ICE BREAKER BUTTON
      floatingActionButton: !_isSelectionMode
          ? AnimatedPadding(
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsets.only(
                bottom:
                    MediaQuery.of(context).viewInsets.bottom +
                    (_replyingTo != null ? 110 : 70),
              ),
              child: FloatingActionButton(
                backgroundColor: const Color(0xFF3F472E),
                onPressed: _showIceBreakerSheet,
                child: const Icon(Icons.flash_on, color: Colors.white),
              ),
            )
          : null,

      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

      appBar: _isSelectionMode
          ? AppBar(
              backgroundColor: Colors.white,
              elevation: 0.5,
              leading: IconButton(
                icon: const Icon(Icons.close, color: Colors.black),
                onPressed: _clearSelection,
              ),
              title: Text(
                "${_selectedMessageIds.length} selected",
                style: const TextStyle(color: Colors.black),
              ),
              actions: [
                /// Edit (only if single message selected)
                if (_selectedMessageIds.length == 1)
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.black),
                    onPressed: _editSelectedMessage,
                  ),

                /// Forward
                // IconButton(
                //   icon: const Icon(Icons.forward, color: Colors.black),
                //   onPressed: _forwardSelectedMessages,
                // ),
                /// COPY (only if 1 text message selected & not deleted)
                if (_selectedMessageIds.length == 1 &&
                    _messages
                            .firstWhere(
                              (m) => m.id == _selectedMessageIds.first,
                            )
                            .messageType ==
                        'text' &&
                    _messages
                            .firstWhere(
                              (m) => m.id == _selectedMessageIds.first,
                            )
                            .deletedForEveryone !=
                        true)
                  IconButton(
                    icon: const Icon(Icons.copy, color: Colors.black),
                    onPressed: _copySelectedMessage,
                  ),

                /// DELETE
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.black),
                  onPressed: _deleteSelectedMessages,
                ),
              ],
            )
          : AppBar(
              elevation: 0.5,
              backgroundColor: Colors.white,
              leading: const BackButton(color: Colors.black),
              titleSpacing: 0,
              title: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundImage: NetworkImage(widget.otherUserImage),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          widget.otherUserName,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              actions: [
                /// Phone
                IconButton(
                  icon: const Icon(Icons.call, color: Colors.black),
                  onPressed: () => _startCall(false),
                ),

                /// Video
                IconButton(
                  icon: const Icon(Icons.videocam, color: Colors.black),
                  onPressed: () => _startCall(true),
                ),

                /// 3-dot menu
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: Colors.black),
                  onSelected: (value) {
                    // if (value == "view_profile") {
                    // } else if (value == "clear_chat") {
                    // }
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(
                      value: "view_profile",
                      child: Text("View Profile"),
                    ),
                    PopupMenuItem(
                      value: "clear_chat",
                      child: Text("Clear Chat"),
                    ),
                    PopupMenuItem(
                      value: "mute_notifications",
                      child: Text("Mute Notifications"),
                    ),
                    PopupMenuItem(
                      value: "block_user",
                      child: Text("Block User"),
                    ),
                    PopupMenuItem(
                      value: "report_user",
                      child: Text("Report and Spam"),
                    ),
                    PopupMenuItem(
                      value: "archive_chat",
                      child: Text("Archive Chat"),
                    ),
                    PopupMenuItem(
                      value: "Ice Breaker",
                      child: Text("Ice Breaker"),
                    ),
                    PopupMenuItem(
                      value: "opening Move",
                      child: Text("Opening Move"),
                    ),
                  ],
                ),
              ],
            ),

      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                Expanded(child: _messageList()),

                /// Reply preview
                if (_replyingTo != null) _buildReplyPreview(),

                /// Editing preview
                if (_isEditing)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    color: Colors.grey[200],
                    child: Row(
                      children: [
                        const Icon(Icons.edit, size: 18, color: Colors.black54),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            "Editing message",
                            style: TextStyle(
                              color: Colors.black54,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, size: 18),
                          onPressed: () {
                            setState(() {
                              _editingMessageId = null;
                            });
                            _controller.clear();
                          },
                        ),
                      ],
                    ),
                  ),

                /// Input bar
                _inputBar(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _messageList() {
    final groupedMessages = _groupMessagesByDay();

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(12),
      itemCount: groupedMessages.length + 1,
      itemBuilder: (_, index) {
        if (index == 0) {
          return _buildEncryptionMessage();
        }

        final groupIndex = index - 1;
        final group = groupedMessages[groupIndex];

        return Column(
          children: [
            // Day label
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  group.dayLabel,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),

            // Messages for this day
            ...group.messages.map((msg) {
              // 🔴 Handle deletion visibility
              if (msg.deletedForEveryone == true) {
                return SwipeableMessage(
                  key: ValueKey(msg.id),
                  message: msg.copyWith(text: "This message was deleted"),
                  replyMessage: null,
                  isMe: msg.senderProfileId == _myProfileId,
                  onReply: () {},
                  onReact: (_) {},
                  formatTime: _formatTime,
                  buildStatus: _buildMessageStatus,
                );
              }

              if (msg.senderProfileId == _myProfileId &&
                  msg.deletedForSender == true) {
                return const SizedBox.shrink();
              }

              if (msg.receiverProfileId == _myProfileId &&
                  msg.deletedForReceiver == true) {
                return const SizedBox.shrink();
              }
              Message? repliedMessage;
              if (msg.replyToId != null) {
                try {
                  repliedMessage = _messages.firstWhere(
                    (m) => m.id == msg.replyToId,
                  );
                } catch (e) {
                  repliedMessage = null;
                }
              }

              final isSelected = _selectedMessageIds.contains(msg.id);

              return GestureDetector(
                onLongPress: () {
                  _toggleSelection(msg);
                },
                onTap: () {
                  if (_isSelectionMode) {
                    _toggleSelection(msg);
                  }
                },
                child: Container(
                  color: isSelected ? Colors.grey.shade300 : Colors.transparent,
                  child: SwipeableMessage(
                    key: ValueKey(msg.id),
                    message: msg,
                    replyMessage: repliedMessage,
                    isMe: msg.senderProfileId == _myProfileId,
                    onReply: () => _replyTo(msg),
                    onReact: (emoji) => _reactToMessage(msg, emoji),
                    formatTime: _formatTime,
                    buildStatus: _buildMessageStatus,
                  ),
                ),
              );
            }),
          ],
        );
      },
    );
  }

  Widget _buildReplyPreview() {
    return Container(
      color: Colors.grey.shade300,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // const Icon(Icons.reply),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _replyingTo!.messageType == 'image'
                  ? ' Image message'
                  : _replyingTo!.messageType == 'voice'
                  ? ' Voice message'
                  : _replyingTo!.text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(icon: const Icon(Icons.close), onPressed: _cancelReply),
        ],
      ),
    );
  }

  Widget _inputBar() {
    // Recording UI
    if (_isRecording) {
      return Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            GestureDetector(
              onTap: _cancelRecording,
              child: const Icon(Icons.delete, color: Colors.red, size: 26),
            ),
            const SizedBox(width: 16),
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              _formatDuration(_recordingDuration),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () async {
                await _stopRecording();
                await _sendVoiceMessage();
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: Color(0xFF3F472E),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.send, color: Colors.white, size: 24),
              ),
            ),
          ],
        ),
      );
    }

    // Normal input UI - Updated to match the image
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 10),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            children: [
              // Camera icon with green background on the left
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  margin: const EdgeInsets.all(4),
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    color: Color(0xFF3F472E),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Text input field
              Expanded(
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  maxLines: null,
                  textInputAction: TextInputAction.newline,
                  decoration: const InputDecoration(
                    hintText: "Type a message",
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 10),
                  ),
                  onChanged: (_) => setState(() {}),
                  onSubmitted: _controller.text.trim().isNotEmpty
                      ? (_) => _send(_controller.text)
                      : null,
                ),
              ),
              // Right side icons
              if (_controller.text.trim().isEmpty) ...[
                GestureDetector(
                  onTap: () {
                    // Handle sticker picker
                    _showStickerPicker();
                  },
                  child: Icon(
                    Icons.tag_faces, // Sticker icon
                    color: Colors.grey.shade600,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () {
                    // Handle attachment
                    _pickAttachment();
                  },
                  child: Icon(
                    Icons.image, // Image icon
                    color: Colors.grey.shade600,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _startRecording,
                  child: Container(
                    margin: const EdgeInsets.all(4),
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      color: Color(0xFF3F472E),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.mic, color: Colors.white, size: 20),
                  ),
                ),
              ],
              if (_controller.text.trim().isNotEmpty) ...[
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: !_isKeyReady ? null : () => _send(_controller.text),
                  child: Container(
                    margin: const EdgeInsets.all(4),
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      color: Color(0xFF3F472E),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.send,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
  // Add import at the top
  // Add this property to your state class

  // ==============================
  // IMAGE PICKER
  // ==============================

  Future<void> _pickImage() async {
    try {
      // Show bottom sheet to choose between camera and gallery
      final source = await showModalBottomSheet<ImageSource>(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) => Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Color(0xFF3F472E)),
                title: const Text('Take Photo'),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(
                  Icons.photo_library,
                  color: Color(0xFF3F472E),
                ),
                title: const Text('Choose from Gallery'),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
            ],
          ),
        ),
      );

      if (source == null) return;

      final XFile? image = await _imagePicker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 1920,
      );

      if (image != null) {
        await _sendImageMessage(image);
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _sendImageMessage(XFile image) async {
    if (!mounted) return;

    final currentUser = _supabase.auth.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please login first')));
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: Color(0xFF3F472E)),
      ),
    );

    try {
      final file = File(image.path);
      final fileSize = await file.length();

      debugPrint('📦 Image size: $fileSize bytes');
      debugPrint('📂 Match ID: ${widget.matchId}');
      debugPrint('👤 User ID: ${currentUser.id}');

      if (fileSize > 5 * 1024 * 1024) {
        throw Exception('Image too large (max 5MB)');
      }

      final fileName = 'image_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final filePath = '${widget.matchId}/$fileName';

      debugPrint('📤 Uploading to: chat_images/$filePath');

      // Upload with proper error handling
      final uploadResponse = await _supabase.storage
          .from('chat_images')
          .upload(
            filePath,
            file,
            fileOptions: const FileOptions(
              contentType: 'image/jpeg',
              upsert: false,
            ),
          )
          .timeout(const Duration(seconds: 30));

      debugPrint('✅ Upload response: $uploadResponse');

      final publicUrl = _supabase.storage
          .from('chat_images')
          .getPublicUrl(filePath);

      debugPrint('🔗 Public URL: $publicUrl');

      // Insert message
      await _supabase.from('messages').insert({
        'match_id': widget.matchId,
        'sender_profile_id': _myProfileId,
        'receiver_profile_id': widget.otherProfileId,
        'content': publicUrl,
        'message_type': 'image',
        'reply_to_id': _replyingTo?.id,
        'reaction': null,
      });

      if (mounted) {
        setState(() => _replyingTo = null);
        Navigator.of(context).pop();

        // ScaffoldMessenger.of(context).showSnackBar(
        //   const SnackBar(
        //     content: Row(
        //       children: [
        //         Icon(Icons.check_circle, color: Colors.white),
        //         SizedBox(width: 8),
        //         Text('Image sent!'),
        //       ],
        //     ),
        //     backgroundColor: Colors.green,
        //   ),
        // );
      }
    } catch (e) {
      debugPrint('❌ Detailed error: $e');

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Upload failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Placeholder methods for sticker and attachment
  void _showStickerPicker() {
    // TODO: Implement sticker picker
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Sticker picker coming soon')));
  }

  void _pickAttachment() {
    // TODO: Implement file attachment picker
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Attachment picker coming soon')),
    );
  }
}

// ======================================================
// MESSAGE GROUP
// ======================================================

class MessageGroup {
  final String dayLabel;
  final List<Message> messages;

  MessageGroup({required this.dayLabel, required this.messages});
}

// ======================================================
// MESSAGE WIDGET
// ======================================================

class SwipeableMessage extends StatefulWidget {
  final Message message;
  final Message? replyMessage;
  final bool isMe;
  final VoidCallback onReply;
  final Function(String) onReact;
  final String Function(DateTime) formatTime;
  final Widget Function(Message) buildStatus;

  const SwipeableMessage({
    super.key,
    required this.message,
    required this.replyMessage,
    required this.isMe,
    required this.onReply,
    required this.onReact,
    required this.formatTime,
    required this.buildStatus,
  });

  @override
  State<SwipeableMessage> createState() => _SwipeableMessageState();
}

class _SwipeableMessageState extends State<SwipeableMessage> {
  double _dragX = 0;

  OverlayEntry? _reactionOverlay;

  // Voice playback
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;

  @override
  void initState() {
    super.initState();
    if (widget.message.messageType == 'voice') {
      _audioPlayer.onPlayerStateChanged.listen((state) {
        if (mounted) {
          setState(() {
            _isPlaying = state == PlayerState.playing;
          });
        }
      });

      _audioPlayer.onPositionChanged.listen((position) {
        if (mounted) {
          setState(() {
            _currentPosition = position;
          });
        }
      });

      _audioPlayer.onDurationChanged.listen((duration) {
        if (mounted) {
          setState(() {
            _totalDuration = duration;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _removeReactionOverlay();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _showReactionPicker() {
    _removeReactionOverlay();

    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);

    _reactionOverlay = OverlayEntry(
      builder: (context) {
        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: _removeReactionOverlay,
              ),
            ),

            Positioned(
              left: widget.isMe ? offset.dx + size.width - 200 : offset.dx,
              top: offset.dy - 60,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: ['❤️', '😂', '😮', '😢', '👍']
                        .map(
                          (e) => GestureDetector(
                            onTap: () {
                              _removeReactionOverlay();
                              widget.onReact(e);
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                              ),
                              child: Text(
                                e,
                                style: const TextStyle(fontSize: 22),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );

    Overlay.of(context).insert(_reactionOverlay!);
  }

  void _removeReactionOverlay() {
    _reactionOverlay?.remove();
    _reactionOverlay = null;
  }

  Future<void> _togglePlayPause() async {
    try {
      if (_isPlaying) {
        await _audioPlayer.pause();
      } else {
        await _audioPlayer.play(UrlSource(widget.message.text));
      }
    } catch (e) {
      debugPrint('Error playing audio: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to play voice message'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragUpdate: (d) {
        if (d.delta.dx > 0) {
          setState(() => _dragX += d.delta.dx * .9);
        }
      },
      onHorizontalDragEnd: (_) {
        if (_dragX > 85) widget.onReply();
        setState(() => _dragX = 0);
      },
      onLongPress: _showReactionPicker,
      onTap: _removeReactionOverlay,
      child: Transform.translate(offset: Offset(_dragX, 0), child: _bubble()),
    );
  }

  Widget _bubble() {
    final textColor = widget.isMe ? Colors.white : Colors.black;
    final hasReaction = widget.message.reaction != null;

    return Align(
      alignment: widget.isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
        ),
        child: Container(
          margin: const EdgeInsets.only(bottom: 22),
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
          decoration: BoxDecoration(
            color: widget.isMe
                ? const Color(0xFF3F472E)
                : const Color(0xFFEBC163),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.replyMessage != null) _replyPreview(),

                  // Handle all message types: voice, image, or text
                  if (widget.message.messageType == 'voice')
                    _buildVoiceMessage(textColor)
                  else if (widget.message.messageType == 'image')
                    _buildImageMessage(textColor)
                  else
                    _buildTextMessage(textColor),
                ],
              ),

              if (hasReaction)
                Positioned(
                  bottom: -25,
                  left: widget.isMe ? null : -8,
                  right: widget.isMe ? -8 : null,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: const [
                        BoxShadow(blurRadius: 6, color: Colors.black12),
                      ],
                    ),
                    child: Text(
                      widget.message.reaction!,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextMessage(Color textColor) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Flexible(
          child: Text(
            widget.message.text,
            style: TextStyle(color: textColor, fontSize: 15),
          ),
        ),
        const SizedBox(width: 6),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.formatTime(widget.message.createdAt),
              style: TextStyle(fontSize: 10, color: textColor.withOpacity(.7)),
            ),
            const SizedBox(width: 4),
            widget.buildStatus(widget.message),
          ],
        ),
      ],
    );
  }

  Widget _buildImageMessage(Color textColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            // Optional: Open full-screen image viewer
            _showFullScreenImage();
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              widget.message.text,
              width: 200,
              height: 200,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  width: 200,
                  height: 200,
                  color: textColor.withOpacity(0.1),
                  child: Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                          : null,
                      color: textColor,
                    ),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 200,
                  height: 200,
                  color: textColor.withOpacity(0.1),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.broken_image,
                        color: textColor.withValues(alpha: 0.5),
                        size: 40,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Failed to load',
                        style: TextStyle(
                          color: textColor.withValues(alpha: 0.5),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.formatTime(widget.message.createdAt),
              style: TextStyle(fontSize: 10, color: textColor.withOpacity(.7)),
            ),
            const SizedBox(width: 4),
            widget.buildStatus(widget.message),
          ],
        ),
      ],
    );
  }

  Widget _buildVoiceMessage(Color textColor) {
    final duration = _isPlaying && _totalDuration.inSeconds > 0
        ? _currentPosition
        : Duration(seconds: widget.message.voiceDuration ?? 0);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: _togglePlayPause,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: textColor.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _isPlaying ? Icons.pause : Icons.play_arrow,
                  color: textColor,
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 120,
              height: 30,
              decoration: BoxDecoration(
                color: textColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(15),
              ),
              child: CustomPaint(
                painter: WaveformPainter(
                  color: textColor,
                  progress: _totalDuration.inMilliseconds > 0
                      ? _currentPosition.inMilliseconds /
                            _totalDuration.inMilliseconds
                      : 0,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              _formatDuration(duration),
              style: TextStyle(fontSize: 11, color: textColor.withOpacity(.8)),
            ),
          ],
        ),

        const SizedBox(height: 4),

        /// Time + Status on new line (right aligned)
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              widget.formatTime(widget.message.createdAt),
              style: TextStyle(fontSize: 10, color: textColor.withOpacity(.7)),
            ),
            const SizedBox(width: 4),
            widget.buildStatus(widget.message),
          ],
        ),
      ],
    );
  }

  // Optional: Add full-screen image viewer
  void _showFullScreenImage() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                child: Image.network(widget.message.text, fit: BoxFit.contain),
              ),
            ),
            Positioned(
              top: 40,
              right: 20,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _replyPreview() {
    final isVoice = widget.replyMessage?.messageType == 'voice';

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(.18),
        borderRadius: BorderRadius.circular(10),
      ),
      child: IntrinsicWidth(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.5,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 3, height: 32, color: Colors.greenAccent),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  isVoice
                      ? '🎤 Voice message'
                      : widget.replyMessage?.text ?? '',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(.85),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ======================================================
// WAVEFORM PAINTER
// ======================================================

class WaveformPainter extends CustomPainter {
  final Color color;
  final double progress;

  WaveformPainter({required this.color, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.6)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final activePaint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final heights = [8.0, 14.0, 10.0, 16.0, 12.0, 18.0, 10.0, 14.0, 8.0, 12.0];
    final spacing = size.width / heights.length;

    for (int i = 0; i < heights.length; i++) {
      final x = i * spacing + spacing / 2;
      final height = heights[i];
      final y1 = (size.height - height) / 2;
      final y2 = y1 + height;

      final isActive = (i / heights.length) <= progress;

      canvas.drawLine(
        Offset(x, y1),
        Offset(x, y2),
        isActive ? activePaint : paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant WaveformPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

// ======================================================
// MODEL
// ======================================================

class Message {
  final String id;
  final String matchId;
  final String senderProfileId;
  final String receiverProfileId; // ✅ REQUIRED
  final String text;
  final DateTime createdAt;
  final String? replyToId;
  final String? reaction;
  final DateTime? deliveredAt;
  final DateTime? readAt;
  final DateTime? editedAt; // ✅ REQUIRED
  final String messageType;
  final int? voiceDuration;

  final bool deletedForSender;
  final bool deletedForReceiver;
  final bool deletedForEveryone;

  Message({
    required this.id,
    required this.matchId,
    required this.senderProfileId,
    required this.receiverProfileId,
    required this.text,
    required this.createdAt,
    this.replyToId,
    this.reaction,
    this.deliveredAt,
    this.readAt,
    this.editedAt,
    this.messageType = 'text',
    this.voiceDuration,
    this.deletedForSender = false,
    this.deletedForReceiver = false,
    this.deletedForEveryone = false,
  });
  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      id: map['id'].toString(),
      matchId: map['match_id'],
      senderProfileId: map['sender_profile_id'],
      receiverProfileId: map['receiver_profile_id'], // ✅ REQUIRED
      text: map['content'] ?? '',
      createdAt: DateTime.parse(map['created_at']).toLocal(),
      replyToId: map['reply_to_id'],
      reaction: map['reaction'],
      deliveredAt: map['delivered_at'] != null
          ? DateTime.parse(map['delivered_at']).toLocal()
          : null,
      readAt: map['read_at'] != null
          ? DateTime.parse(map['read_at']).toLocal()
          : null,
      editedAt: map['edited_at'] != null
          ? DateTime.parse(map['edited_at']).toLocal()
          : null,
      messageType: map['message_type'] ?? 'text',
      voiceDuration: map['voice_duration'],
      deletedForSender: map['deleted_for_sender'] ?? false,
      deletedForReceiver: map['deleted_for_receiver'] ?? false,
      deletedForEveryone: map['deleted_for_everyone'] ?? false,
    );
  }

  /// ✅ REQUIRED FOR EDIT + SOFT DELETE UI
  Message copyWith({
    String? text,
    String? reaction,
    DateTime? editedAt,
    DateTime? deliveredAt,
    DateTime? readAt,
    bool? deletedForSender,
    bool? deletedForReceiver,
    bool? deletedForEveryone,
  }) {
    return Message(
      id: id,
      matchId: matchId,
      senderProfileId: senderProfileId,
      receiverProfileId: receiverProfileId,
      text: text ?? this.text,
      createdAt: createdAt,
      replyToId: replyToId,
      reaction: reaction ?? this.reaction,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      readAt: readAt ?? this.readAt,
      editedAt: editedAt ?? this.editedAt,
      messageType: messageType,
      voiceDuration: voiceDuration,
      deletedForSender: deletedForSender ?? this.deletedForSender,
      deletedForReceiver: deletedForReceiver ?? this.deletedForReceiver,
      deletedForEveryone: deletedForEveryone ?? this.deletedForEveryone,
    );
  }
}
