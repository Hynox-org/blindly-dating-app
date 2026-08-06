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
import '../../domain/models/message_model.dart';
import '../../../../core/services/chat_cache_service.dart';
import '../../../../core/security/encryption_service.dart';
import '../../../../core/security/key_security.dart';
import '../../../../core/utils/app_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:blindly_dating_app/features/chat/presentation/widgets/media_picker.dart';
import 'dart:convert';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:uuid/uuid.dart';
import '../../data/icebreaker_service.dart';
import '../../../../core/services/translation_service.dart';
import '../../../../core/services/text_moderation_service.dart';

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
  final Uuid _uuid = const Uuid();
  final FocusNode _focusNode = FocusNode();
  final ImagePicker _imagePicker = ImagePicker();
  String? _editingMessageId;
  bool get _isEditing => _editingMessageId != null;
  RealtimeChannel? _channel;
  final List<Message> _messages = [];
  Timer? timer;
  Message? _replyingTo;
  // List<Message> messages = [];   // Ensure this exists
  RealtimeChannel? _channelRead;
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
      await ChatCacheService().clearAllMessages();
      await ChatCacheService().clearAllMatchKeys();

      if (mounted) {
        await _loadReceiverKey();
        _loadCachedHistory();
        await _loadHistory();
        _listenRealtime();
        _markMessagesAsDelivered();
        _markMessagesAsRead();
      }
    });

    timer = Timer.periodic(const Duration(seconds: 3), (timerInstance) {
      if (mounted) _markMessagesAsRead();
    });
  }

  @override
  void dispose() {
    AppState.isChatScreenOpen = false;
    AppState.currentChatProfileId = null;
    AppState.setCurrentChat(null);

    if (_channel != null) {
      _supabase.removeChannel(_channel!);
    }
    if (_channelRead != null) {
      _supabase.removeChannel(_channelRead!);
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
          .update({
            'delivered_at': DateTime.now().toUtc().toIso8601String(),
            'read_at': DateTime.now().toUtc().toIso8601String(),
            'is_read': true,
          })
          .eq('match_id', widget.matchId)
          .eq('receiver_profile_id', _myProfileId)
          .isFilter('read_at', null);
    } catch (e) {
      debugPrint('Error marking messages as read: $e');
    }
  }

  // ==============================
  // CACHE LOAD
  // ==============================

  void _loadCachedHistory() {
    final cachedMaps = ChatCacheService().getMessages(widget.matchId);
    if (cachedMaps.isEmpty) return;

    final List<Message> cachedMessages = cachedMaps.map((map) => Message.fromMap(map)).toList();

    if (mounted) {
      setState(() {
        _messages.addAll(cachedMessages);
      });
      _scrollToBottom(force: true);
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
      print("📜 Loaded ${data.length} messages from DB");

      final List<Message> loadedMessages = [];
      String? symmetricKey = ChatCacheService().getMatchKey(widget.matchId);

      for (final raw in data) {
        final msgMap = Map<String, dynamic>.from(raw);
        String decryptedContent = await _decryptMessageItem(msgMap, symmetricKey: symmetricKey);
        
        // Update symmetric key cache if it changed during decryption
        if (symmetricKey == null && msgMap['message_type'] != 'system') {
           // We might want to re-fetch/update symmetricKey here if _decryptMessageItem updated it, 
           // but for simplicity, we rely on ChatCacheService being updated within _decryptMessageItem.
           symmetricKey = ChatCacheService().getMatchKey(widget.matchId);
        }

        loadedMessages.add(Message.fromMap(msgMap, decryptedText: decryptedContent));
      }

      if (!mounted) return;

      setState(() {
        _messages
          ..clear()
          ..addAll(loadedMessages);
      });

      // Update Cache with Decrypted content
      final List<Map<String, dynamic>> cacheData = loadedMessages.map((m) => m.toMap()).toList();
      ChatCacheService().saveMessages(widget.matchId, cacheData);

      _scrollToBottom(force: true);
    } catch (e) {
      debugPrint('❌ Error loading message history: $e');
    }
  }

  Future<String> _decryptMessageItem(Map<String, dynamic> msgMap, {String? symmetricKey}) async {
    final type = msgMap['message_type'];
    final content = msgMap['content'];
    final iv = msgMap['iv'];

    if (type == 'system' || iv == null || content == null) {
      return content ?? '';
    }

    try {
      final isMe = msgMap['sender_profile_id'] == _myProfileId;
      final encryptedKey = isMe
          ? msgMap['encrypted_key_sender']
          : msgMap['encrypted_key_receiver'];

      if (encryptedKey != null) {
        final cacheKey = symmetricKey ?? ChatCacheService().getMatchKey(widget.matchId);
        
        final result = await EncryptionService.decryptMessage(
          cipherText: content,
          encryptedKey: cacheKey ?? encryptedKey,
          iv: iv,
          symmetricKeyBase64: cacheKey,
        );

        if (cacheKey != result.decryptedSymmetricKey && result.decryptedSymmetricKey != null) {
          await ChatCacheService().saveMatchKey(widget.matchId, result.decryptedSymmetricKey!);
        }

        return result.text;
      }
      return content;
    } catch (e) {
      debugPrint("❌ Decrypt failed for ${msgMap['id']}: $e");
      return "🔒 Encrypted message";
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
        print("🔑 PRIVATE KEY SAMPLE: $privateKeyPem");
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
      print("❌ Error diagnosing private key: $e");
    }
  }

  Future<void> _handleRealtimeMessage(Map<String, dynamic> raw) async {
    final data = Map<String, dynamic>.from(raw);
    final messageId = data['id'].toString();
    final index = _messages.indexWhere((m) => m.id == messageId);

    String decryptedContent = "⏳ Decrypting...";

    // 🚀 OPTIMIZATION: If we already have the message decrypted (i.e. status update), preserve it
    if (index != -1 && _messages[index].text != "⏳ Decrypting..." && _messages[index].text != "🔒 Encrypted message") {
      decryptedContent = _messages[index].text;
    } else {
      decryptedContent = await _decryptMessageItem(data);
    }

    final msg = Message.fromMap(data, decryptedText: decryptedContent);

    if (mounted) {
      setState(() {
        if (index != -1) {
          _messages[index] = msg;
        } else {
          _messages.add(msg);
        }
      });
      _scrollToBottom();
      ChatCacheService().updateSingleMessage(widget.matchId, msg.toMap());
      
      if (msg.senderProfileId != _myProfileId && msg.readAt == null) {
        _markMessageAsDeliveredAndRead(msg.id);
      }
      
      // Force a UI refresh if it's a known message but something changed (like ticks)
      if (index != -1 && mounted) {
         setState(() {}); 
      }
    }
  }

  Future<void> _markMessageAsDeliveredAndRead(String messageId) async {
    try {
      final now = DateTime.now().toUtc().toIso8601String();
      await _supabase.from('messages').update({
        'delivered_at': now,
        'read_at': now,
      }).eq('id', messageId);
    } catch (e) {
      debugPrint('❌ Error marking message as read: $e');
    }
  }

  void _listenRealtime() {
    // Single channel for all message-related updates to ensure order and reliability
    _channel = _supabase.channel('messages:${widget.matchId}');

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
          callback: (payload) => _handleRealtimeMessage(payload.newRecord),
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
          callback: (payload) => _handleRealtimeMessage(payload.newRecord),
        )
        .subscribe((status, error) {
          debugPrint("📡 Message channel status (${widget.matchId}): $status");
          if (error != null) {
            debugPrint("❌ Message channel error: $error");
          }
          if (status == RealtimeSubscribeStatus.channelError) {
             debugPrint("⚠️ Realtime Channel Error: MatchId might be invalid or permissions restricted.");
          }
        });
  }

  void _scrollToBottom({bool force = false}) {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_scrollController.hasClients) {
        final pos = _scrollController.position.pixels;
        final max = _scrollController.position.maxScrollExtent;
        final isNearBottom = pos > max - 200;

        if (force || isNearBottom) {
          _scrollController.animateTo(
            max,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      }
    });
  }

  Future<void> _loadReceiverKey() async {
    try {
      final res = await _supabase
          .from('profiles')
          .select('public_key')
          .eq('id', widget.otherProfileId)
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

    if (!_isKeyReady) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Encryption key not loaded. Please wait.")));
      return;
    }

    // Moderation runs before encryption — once encrypted, nothing downstream
    // can inspect it. Covers new messages and edits alike.
    if (TextModerationService().check(trimmedText) != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "This message may violate our community guidelines and wasn't sent.",
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    // 🚀 OPTIMISTIC UPDATE
    Message? optimisticMsg;
    if (_isEditing) {
      setState(() {
        final idx = _messages.indexWhere((m) => m.id == _editingMessageId);
        if (idx != -1) {
          _messages[idx] = _messages[idx].copyWith(
            text: trimmedText,
            isSending: true,
          );
        }
        _controller.clear();
      });
    } else {
      final String messageId = _uuid.v4();
      optimisticMsg = Message(
        id: messageId,
        matchId: widget.matchId,
        senderProfileId: _myProfileId,
        receiverProfileId: widget.otherProfileId,
        text: trimmedText,
        createdAt: DateTime.now(),
        isSending: true,
        messageType: 'text',
        replyToId: _replyingTo?.id,
      );

      setState(() {
        _messages.add(optimisticMsg!);
        _controller.clear();
        _replyingTo = null;
      });
      _scrollToBottom(force: true);
    }

    try {
      final matchKey = ChatCacheService().getMatchKey(widget.matchId);
      final encrypted = await EncryptionService.encryptMessage(
        message: trimmedText,
        receiverPublicKeyPem: receiverPublicKeyPem!,
        symmetricKeyBase64: matchKey,
      );

      if (_isEditing) {
        final String editId = _editingMessageId!;
        await _supabase.from('messages').update({
          'content': encrypted.cipherText,
          'encrypted_key_sender': encrypted.encryptedKeyForSender,
          'encrypted_key_receiver': encrypted.encryptedKeyForReceiver,
          'iv': encrypted.iv,
          'is_encrypted': true,
          'edited_at': DateTime.now().toIso8601String(),
        }).eq('id', editId);
        
        setState(() => _editingMessageId = null);
        
        // Update local state and cache
        final updatedMsg = _messages.firstWhere((m) => m.id == editId);
        ChatCacheService().updateSingleMessage(widget.matchId, updatedMsg.copyWith(isSending: false).toMap());
      } else {
        final String messageId = _messages.last.id; 
        await _supabase.from('messages').insert({
          'id': messageId,
          'match_id': widget.matchId,
          'sender_profile_id': _myProfileId,
          'receiver_profile_id': widget.otherProfileId,
          'content': encrypted.cipherText,
          'encrypted_key_sender': encrypted.encryptedKeyForSender,
          'encrypted_key_receiver': encrypted.encryptedKeyForReceiver,
          'iv': encrypted.iv,
          'message_type': 'text',
          'is_encrypted': true,
          'reply_to_id': optimisticMsg?.replyToId,
        });
        
        if (mounted) {
          setState(() {
            final idx = _messages.indexWhere((m) => m.id == messageId);
            if (idx != -1) {
              _messages[idx] = _messages[idx].copyWith(isSending: false);
            }
          });
        }
      }
    } catch (e) {
      debugPrint('❌ Error sending message: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to send: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _sendMediaMessage(String url, String previewUrl, int width, int height, String type) async {
    if (!_isKeyReady) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Encryption key not loaded. Please wait.")));
      return;
    }

    // Prepare JSON metadata for media
    final mediaData = jsonEncode({
      'url': url,
      'previewUrl': previewUrl,
      'width': width,
      'height': height,
      'type': type,
    });

    final String messageId = _uuid.v4();
    final optimisticMsg = Message(
      id: messageId,
      matchId: widget.matchId,
      senderProfileId: _myProfileId,
      receiverProfileId: widget.otherProfileId,
      text: mediaData, 
      createdAt: DateTime.now(),
      isSending: true,
      messageType: type, // 'gif' or 'sticker'
      replyToId: _replyingTo?.id,
    );

    setState(() {
      _messages.add(optimisticMsg);
      _replyingTo = null;
    });
    _scrollToBottom(force: true);

    try {
      final matchKey = ChatCacheService().getMatchKey(widget.matchId);
      final encrypted = await EncryptionService.encryptMessage(
        message: mediaData,
        receiverPublicKeyPem: receiverPublicKeyPem!,
        symmetricKeyBase64: matchKey,
      );

      await _supabase.from('messages').insert({
        'id': messageId,
        'match_id': widget.matchId,
        'sender_profile_id': _myProfileId,
        'receiver_profile_id': widget.otherProfileId,
        'content': encrypted.cipherText,
        'encrypted_key_sender': encrypted.encryptedKeyForSender,
        'encrypted_key_receiver': encrypted.encryptedKeyForReceiver,
        'iv': encrypted.iv,
        'message_type': type,
        'is_encrypted': true,
        'reply_to_id': optimisticMsg.replyToId,
      });

      if (mounted) {
        setState(() {
          final idx = _messages.indexWhere((m) => m.id == messageId);
          if (idx != -1) _messages[idx] = optimisticMsg.copyWith(isSending: false);
        });
      }
    } catch (e) {
      debugPrint('❌ Error sending media message: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to send $type: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  // ==============================
  // DELETE LOGIC
  // ==============================

  Future<void> _deleteMessageForMe(Message message) async {
    final isMe = message.senderProfileId == _myProfileId;
    final column = isMe ? 'deleted_for_sender' : 'deleted_for_receiver';

    try {
      await _supabase.from('messages').update({
        column: true,
      }).eq('id', message.id);

      setState(() {
        _messages.removeWhere((m) => m.id == message.id);
      });
      
      // Update cache
      ChatCacheService().deleteSingleMessage(widget.matchId, message.id);
    } catch (e) {
      debugPrint('❌ Error deleting message for me: $e');
    }
  }

  Future<void> _deleteMessageForEveryone(Message message) async {
    if (message.senderProfileId != _myProfileId) return;

    try {
      await _supabase.from('messages').update({
        'deleted_for_everyone': true,
      }).eq('id', message.id);

      setState(() {
        final idx = _messages.indexWhere((m) => m.id == message.id);
        if (idx != -1) {
          _messages[idx] = _messages[idx].copyWith(deletedForEveryone: true);
        }
      });
      
      // Update cache
      ChatCacheService().updateSingleMessage(widget.matchId, _messages.firstWhere((m) => m.id == message.id).toMap());
    } catch (e) {
      debugPrint('❌ Error deleting message for everyone: $e');
    }
  }

  Future<void> _showIceBreakerSheet() async {
    final categories = ["All", "AI ✨", "Playful", "Deep", "Quirky", "Hypothesis"];
    int selectedCategory = 0;
    bool isAiLoading = false;
    bool aiFailed = false;
    IcebreakerResponse? aiResults;
    int selectedAiMode = 0; // 0: Both, 1: Recipient Only

    final icebreakers = [
      "What’s a small thing that made you smile recently?",
      "Two truths and a lie: Let’s go!",
      "If you could have any superpower, what would it be?",
      "What’s the most interesting thing you’ve learned lately?",
    ];

    final selectedText = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            Future<void> loadAi({bool refresh = false}) async {
              setModalState(() {
                isAiLoading = true;
                aiFailed = false;
              });
              final res = await IcebreakerService.fetchAiIcebreakers(
                matchId: widget.matchId,
                refresh: refresh,
              );
              setModalState(() {
                if (res != null) aiResults = res;
                aiFailed = res == null;
                isAiLoading = false;
              });
            }

            return Container(
              height: MediaQuery.of(context).size.height * 0.75,
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
                          selectedColor: index == 1 ? const Color(0xFF3F472E) : Colors.black,
                          backgroundColor: Colors.grey.shade200,
                          labelStyle: TextStyle(
                            color: selected ? Colors.white : Colors.black,
                            fontWeight: index == 1 ? FontWeight.bold : FontWeight.normal,
                          ),
                          onSelected: (_) async {
                            setModalState(() {
                              selectedCategory = index;
                            });
                            if (index == 1 && aiResults == null && !isAiLoading) {
                              await loadAi();
                            }
                          },
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 18),

                  /// Content Area
                  Expanded(
                    child: selectedCategory == 1 
                      ? _buildAiIcebreakerSection(
                          isLoading: isAiLoading,
                          failed: aiFailed,
                          results: aiResults,
                          selectedMode: selectedAiMode,
                          onModeChanged: (mode) => setModalState(() => selectedAiMode = mode),
                          onRefresh: () => loadAi(refresh: true),
                          onRetry: () => loadAi(),
                          onSelect: (text) => Navigator.pop(context, text),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: icebreakers.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            return ListTile(
                              leading: const Icon(Icons.lightbulb_outline),
                              title: Text(icebreakers[index]),
                              trailing: IconButton(
                                icon: const Icon(Icons.send),
                                onPressed: () => Navigator.pop(context, icebreakers[index]),
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

  Widget _buildAiIcebreakerSection({
    required bool isLoading,
    required bool failed,
    required IcebreakerResponse? results,
    required int selectedMode,
    required Function(int) onModeChanged,
    required VoidCallback onRefresh,
    required VoidCallback onRetry,
    required Function(String) onSelect,
  }) {
    if (isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Color(0xFF3F472E)),
            SizedBox(height: 16),
            Text("AI is analyzing your profiles...", style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    if (results == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF3F472E).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.cloud_off_rounded,
                  size: 44,
                  color: Color(0xFF3F472E),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "Couldn't load icebreakers",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                failed
                    ? "Something went wrong on our side. Give it another go."
                    : "Tap below to generate openers from your profiles.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh, size: 18),
                label: Text(failed ? "Try again" : "Generate"),
                style: TextButton.styleFrom(foregroundColor: const Color(0xFF3F472E)),
              ),
            ],
          ),
        ),
      );
    }

    final data = selectedMode == 0 ? results.bothProfiles : results.recipientOnly;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              _aiModeChip("Personalized", selectedMode == 0, () => onModeChanged(0)),
              const SizedBox(width: 8),
              _aiModeChip("Them only", selectedMode == 1, () => onModeChanged(1)),
              const Spacer(),
              IconButton(
                tooltip: "Regenerate",
                onPressed: onRefresh,
                icon: const Icon(Icons.refresh, size: 20, color: Color(0xFF3F472E)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              _aiIcebreakerCard("Question", data['question'] ?? "", Icons.question_answer_outlined, onSelect),
              _aiIcebreakerCard("Observation", data['observation'] ?? "", Icons.remove_red_eye_outlined, onSelect),
              _aiIcebreakerCard("Fun Fact", data['fun_fact'] ?? "", Icons.celebration_outlined, onSelect),
            ],
          ),
        ),
      ],
    );
  }

  Widget _aiModeChip(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF3F472E).withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? const Color(0xFF3F472E) : Colors.grey.shade300),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? const Color(0xFF3F472E) : Colors.grey.shade600,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _aiIcebreakerCard(String title, String content, IconData icon, Function(String) onSelect) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 4)),
        ],
      ),
      child: InkWell(
        onTap: () => onSelect(content),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, size: 18, color: const Color(0xFF3F472E)),
                  const SizedBox(width: 8),
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey)),
                  const Spacer(),
                  const Icon(Icons.arrow_forward_ios, size: 12, color: Colors.grey),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                content,
                style: const TextStyle(fontSize: 15, height: 1.4),
              ),
            ],
          ),
        ),
      ),
    );
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

    final selectedMessages = _messages.where((m) => _selectedMessageIds.contains(m.id)).toList();
    final allMine = selectedMessages.every((m) => m.senderProfileId == _myProfileId);
    final allRecent = selectedMessages.every((m) => 
        DateTime.now().difference(m.createdAt).inHours < 24);
    
    // Check if any are already deleted for everyone (placeholders)
    final anyDeletedForEveryone = selectedMessages.any((m) => m.deletedForEveryone);

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
              if (allMine && allRecent && !anyDeletedForEveryone)
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
        final column = isSender ? 'deleted_for_sender' : 'deleted_for_receiver';

        await _supabase
            .from('messages')
            .update({column: true})
            .eq('id', id);
        
        // Update local cache for zero-latency consistency
        final updatedData = message.toMap();
        updatedData[column] = true;
        ChatCacheService().updateSingleMessage(widget.matchId, updatedData);
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
        
        // Update local cache
        final updatedData = message.toMap();
        updatedData['deleted_for_everyone'] = true;
        // Also change message type to text for placeholder
        updatedData['message_type'] = 'text';
        ChatCacheService().updateSingleMessage(widget.matchId, updatedData);
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
        'is_encrypted': true,
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
  //   );

  //   _clearSelection();
  // }

  Widget _buildMessageStatus(Message message) {
    Color statusColor = (message.senderProfileId == _myProfileId ? Colors.white : Colors.black).withOpacity(0.5);
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (message.editedAt != null)
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: Text(
              '(Edited)',
              style: TextStyle(
                fontSize: 10,
                color: statusColor,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        if (message.senderProfileId == _myProfileId) ...[
          if (message.isSending)
            Padding(
              padding: const EdgeInsets.only(left: 4.0),
              child: Icon(Icons.access_time, size: 12, color: statusColor),
            )
          else if (message.readAt != null)
            const Padding(
              padding: EdgeInsets.only(left: 4.0),
              child: Icon(Icons.done_all, size: 14, color: Colors.blueAccent),
            )
          else
            Padding(
              padding: const EdgeInsets.only(left: 4.0),
              child: Icon(Icons.done, size: 14, color: statusColor),
            ),
        ],
      ],
    );
  }

  // ==============================


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

    final visibleMessages = _messages.where((msg) {
      if (msg.senderProfileId == _myProfileId && msg.deletedForSender == true) return false;
      if (msg.receiverProfileId == _myProfileId && msg.deletedForReceiver == true) return false;
      return true;
    }).toList();

    for (final msg in visibleMessages) {
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
              // No viewInsets here: the Scaffold already shrinks its body for the
              // keyboard, so adding it again lifts the FAB by a second keyboard.
              padding: EdgeInsets.only(bottom: _replyingTo != null ? 110 : 70),
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
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              actions: [
                /// REACTIONS (only if single message selected)
                if (_selectedMessageIds.length == 1)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: ['❤️', '😂', '😮', '😢', '👍'].map((emoji) {
                      final msg = _messages.firstWhere((m) => m.id == _selectedMessageIds.first);
                      return GestureDetector(
                        onTap: () {
                          _reactToMessage(msg, emoji);
                          _clearSelection();
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Text(emoji, style: const TextStyle(fontSize: 22)),
                        ),
                      );
                    }).toList(),
                  ),

                const SizedBox(width: 8),

                /// Edit (only if single message selected)
                if (_selectedMessageIds.length == 1)
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, color: Colors.black),
                    onPressed: _editSelectedMessage,
                  ),

                /// DELETE
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: _deleteSelectedMessages,
                ),
                
                const SizedBox(width: 8),
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
                    child: ClipOval(
                      child: CachedNetworkImage(
                        imageUrl: widget.otherUserImage,
                        fit: BoxFit.cover,
                        width: 40,
                        height: 40,
                        placeholder: (context, url) => const CircularProgressIndicator(strokeWidth: 2),
                        errorWidget: (context, url, error) => const Icon(Icons.person),
                      ),
                    ),
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
              final isSender = msg.senderProfileId == _myProfileId;
              
              // 1. Handle "Delete for Me" FIRST (Highest priority - completely vanish)
              if ((isSender && msg.deletedForSender == true) || 
                  (!isSender && msg.deletedForReceiver == true)) {
                return const SizedBox.shrink();
              }

              // 2. Handle "Delete for Everyone" (Placeholder)
              if (msg.deletedForEveryone == true) {
                return SwipeableMessage(
                  key: ValueKey(msg.id),
                  message: msg.copyWith(
                    text: "This message was deleted",
                    messageType: "text",
                  ),
                  replyMessage: null,
                  isMe: msg.senderProfileId == _myProfileId,
                  onReply: () {},
                  onReact: (_) {},
                  formatTime: _formatTime,
                  buildStatus: _buildMessageStatus,
                  onEdit: () {},
                  onDeleteForMe: () => _deleteMessageForMe(msg),
                  onDeleteForEveryone: () {},
                  isSelected: _selectedMessageIds.contains(msg.id),
                  selectionMode: _isSelectionMode,
                  onToggleSelection: (m) => _toggleSelection(m),
                );
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

              return SwipeableMessage(
                key: ValueKey(msg.id),
                message: msg,
                replyMessage: repliedMessage,
                isMe: msg.senderProfileId == _myProfileId,
                onReply: () => _replyTo(msg),
                onReact: (emoji) => _reactToMessage(msg, emoji),
                formatTime: _formatTime,
                buildStatus: _buildMessageStatus,
                onEdit: () {
                  _editingMessageId = msg.id;
                  _controller.text = msg.text;
                  _focusNode.requestFocus();
                  setState(() {});
                },
                onDeleteForMe: () => _deleteMessageForMe(msg),
                onDeleteForEveryone: () => _deleteMessageForEveryone(msg),
                isSelected: isSelected,
                selectionMode: _isSelectionMode,
                onToggleSelection: (m) => _toggleSelection(m),
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
                    // Handle media picker (GIFs and Stickers)
                    _showMediaPicker();
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
        'is_encrypted': true,
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
  void _showMediaPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Crucial for keyboard resizing
      backgroundColor: Colors.transparent,
      builder: (context) => MediaPicker(
        onSelect: (url, previewUrl, width, height, type) {
          Navigator.pop(context);
          _sendMediaMessage(url, previewUrl, width, height, type);
        },
      ),
    );
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
  final VoidCallback onEdit;
  final VoidCallback onDeleteForMe;
  final VoidCallback onDeleteForEveryone;
  final bool isSelected;
  final bool selectionMode;
  final Function(Message) onToggleSelection;

  const SwipeableMessage({
    super.key,
    required this.message,
    required this.replyMessage,
    required this.isMe,
    required this.onReply,
    required this.onReact,
    required this.formatTime,
    required this.buildStatus,
    required this.onEdit,
    required this.onDeleteForMe,
    required this.onDeleteForEveryone,
    this.isSelected = false,
    this.selectionMode = false,
    required this.onToggleSelection,
  });

  @override
  State<SwipeableMessage> createState() => _SwipeableMessageState();
}

class _SwipeableMessageState extends State<SwipeableMessage> {
  double _dragX = 0;

  // Voice playback
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;

  // On-device translation
  String? _translated;
  bool _translating = false;
  bool _showOriginal = false;
  bool _translateFailed = false;

  @override
  void initState() {
    super.initState();

    // Already translated in an earlier session? Show it without a round trip.
    final target = TranslationService().deviceLanguage;
    if (target != null) {
      _translated = TranslationService().cached(widget.message.id, target);
    }

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
    _audioPlayer.dispose();
    super.dispose();
  }

  void _removeReactionOverlay() {
    // Overlays removed in favor of AppBar actions to fix overflow
  }

  Future<void> _togglePlayPause() async {
    try {
      if (_isPlaying) {
        await _audioPlayer.pause();
      } else {
        // Optimize: Use CacheManager to get local file
        final file = await DefaultCacheManager().getSingleFile(widget.message.text);
        await _audioPlayer.play(DeviceFileSource(file.path));
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
      onLongPress: () {
        widget.onToggleSelection(widget.message);
      },
      onTap: widget.selectionMode
          ? () => widget.onToggleSelection(widget.message)
          : null,
      child: Transform.translate(offset: Offset(_dragX, 0), child: _bubble()),
    );
  }

  Widget _bubble() {
    final textColor = widget.isMe ? Colors.white : Colors.black;
    final hasReaction = widget.message.reaction != null;

    return GestureDetector(
      onTap: widget.selectionMode
          ? () => widget.onToggleSelection(widget.message)
          : _removeReactionOverlay,
      child: Container(
        color: widget.isSelected ? Colors.blue.withOpacity(0.1) : Colors.transparent,
        child: Row(
          children: [
            if (widget.selectionMode)
              Padding(
                padding: const EdgeInsets.only(left: 12),
                child: Icon(
                  widget.isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                  color: widget.isSelected ? const Color(0xFF3F472E) : Colors.grey,
                  size: 22,
                ),
              ),
            Expanded(
              child: Align(
                alignment: widget.isMe ? Alignment.centerRight : Alignment.centerLeft,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.7,
                  ),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 22, left: 14, right: 14),
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

                            // Handle all message types
                            if (widget.message.messageType == 'voice')
                              _buildVoiceMessage(textColor)
                            else if (widget.message.messageType == 'image')
                              _buildImageMessage(textColor)
                            else if (widget.message.messageType == 'gif')
                              _buildGifMessage(textColor)
                            else if (widget.message.messageType == 'sticker')
                              _buildStickerMessage(textColor)
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
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Translates the message into the device language, on-device.
  Future<void> _translate() async {
    setState(() => _translating = true);
    try {
      final result = await TranslationService()
          .translate(widget.message.id, widget.message.text);
      if (!mounted) return;
      setState(() {
        _translating = false;
        _translated = result;
        _showOriginal = false;
        _translateFailed = result == null;
      });
    } catch (e) {
      debugPrint('Translation failed: $e');
      if (!mounted) return;
      setState(() {
        _translating = false;
        _translateFailed = true;
      });
    }
  }

  Widget _translateAction(Color textColor) {
    if (_translating) {
      return Padding(
        padding: const EdgeInsets.only(top: 4),
        child: SizedBox(
          height: 12,
          width: 12,
          child: CircularProgressIndicator(
            strokeWidth: 1.5,
            color: textColor.withOpacity(.6),
          ),
        ),
      );
    }

    final String label;
    if (_translateFailed) {
      label = 'Translation unavailable';
    } else if (_translated == null) {
      label = 'Translate';
    } else {
      label = _showOriginal ? 'Show translation' : 'Show original';
    }

    return GestureDetector(
      onTap: _translateFailed
          ? null
          : () {
              if (_translated == null) {
                _translate();
              } else {
                setState(() => _showOriginal = !_showOriginal);
              }
            },
      child: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: textColor.withOpacity(.6),
            decoration: _translateFailed ? null : TextDecoration.underline,
          ),
        ),
      ),
    );
  }

  Widget _buildTextMessage(Color textColor) {
    // Determine if deleted for everyone
    final isDeleted = widget.message.deletedForEveryone;
    final showTranslated = _translated != null && !_showOriginal;
    final messageText = isDeleted
        ? "This message was deleted"
        : (showTranslated ? _translated! : widget.message.text);
    final fontStyle = isDeleted ? FontStyle.italic : FontStyle.normal;
    final opacity = isDeleted ? 0.7 : 1.0;

    // Only incoming, non-deleted text is worth translating — you wrote your own.
    final canTranslate = !isDeleted &&
        !widget.isMe &&
        !widget.message.isSending &&
        widget.message.text.trim().isNotEmpty;

    return Wrap(
      alignment: WrapAlignment.end,
      crossAxisAlignment: WrapCrossAlignment.end,
      spacing: 8,
      runSpacing: 4,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              messageText,
              style: TextStyle(
                color: textColor.withOpacity(opacity),
                fontSize: 15,
                fontStyle: fontStyle,
              ),
            ),
            if (canTranslate) _translateAction(textColor),
          ],
        ),
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
            child: CachedNetworkImage(
              imageUrl: widget.message.text,
              width: 200,
              height: 200,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                width: 200,
                height: 200,
                color: textColor.withOpacity(0.1),
                child: Center(
                  child: CircularProgressIndicator(color: textColor),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                width: 200,
                height: 200,
                color: textColor.withOpacity(0.1),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.broken_image,
                      color: textColor.withOpacity(0.5),
                      size: 40,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Failed to load',
                      style: TextStyle(
                        color: textColor.withOpacity(0.5),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
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

  Widget _buildGifMessage(Color textColor) {
    Map<String, dynamic> data = {};
    try {
      data = jsonDecode(widget.message.text);
    } catch (e) {
      return Text('Error loading GIF', style: TextStyle(color: textColor));
    }

    final previewUrl = data['previewUrl'];
    final url = data['url'];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              _isGifPlaying = !_isGifPlaying;
            });
          },
          child: Stack(
            alignment: Alignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl: _isGifPlaying ? url : previewUrl,
                  placeholder: (context, url) => Container(
                    width: 200,
                    height: 150,
                    color: textColor.withOpacity(0.1),
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                ),
              ),
              if (!_isGifPlaying)
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black45,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Icon(Icons.play_arrow, color: Colors.white, size: 30),
                ),
              Positioned(
                bottom: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text('GIF', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
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

  Widget _buildStickerMessage(Color textColor) {
    Map<String, dynamic> data = {};
    try {
      data = jsonDecode(widget.message.text);
    } catch (e) {
      return Text('Error loading Sticker', style: TextStyle(color: textColor));
    }

    final url = data['url'];
    
    // Fallback logic for stickers (same set as in picker)
    final List<String> fallbackUrls = [
      'https://raw.githubusercontent.com/Tarikul-Islam-Anik/Animated-Fluent-Emojis/master/Emojis/Smilies/Beaming%20Face%20with%20Smiling%20Eyes.png',
      'https://raw.githubusercontent.com/Tarikul-Islam-Anik/Animated-Fluent-Emojis/master/Emojis/Smilies/Smiling%20Face%20with%20Heart-Eyes.png',
      'https://raw.githubusercontent.com/Tarikul-Islam-Anik/Animated-Fluent-Emojis/master/Emojis/Hand%20gestures/High%20Five.png',
      'https://raw.githubusercontent.com/Tarikul-Islam-Anik/Animated-Fluent-Emojis/master/Emojis/Activities/Party%20Popper.png',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CachedNetworkImage(
          imageUrl: url,
          width: 120,
          height: 120,
          fit: BoxFit.contain,
          placeholder: (context, url) => Container(
            width: 120,
            height: 120,
            color: textColor.withOpacity(0.05),
            child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
          ),
          errorWidget: (context, url, error) {
            // Check if we can find a matching index from the URL or just use a default
            int fallbackIndex = 0;
            if (url.contains('sticker_')) {
              try {
                final parts = url.split('sticker_');
                final last = parts.last.split('.').first;
                fallbackIndex = (int.parse(last) - 1).clamp(0, fallbackUrls.length - 1);
              } catch (_) {}
            }
            return CachedNetworkImage(
              imageUrl: fallbackUrls[fallbackIndex],
              width: 120,
              height: 120,
              fit: BoxFit.contain,
            );
          },
        ),
        const SizedBox(height: 4),
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

  bool _isGifPlaying = false;

  Widget _replyPreview() {
    final isVoice = widget.replyMessage?.messageType == 'voice';
    final isGif = widget.replyMessage?.messageType == 'gif';
    final isSticker = widget.replyMessage?.messageType == 'sticker';

    String previewText = widget.replyMessage?.text ?? '';
    if (isGif) previewText = 'GIF';
    if (isSticker) previewText = 'Sticker';
    if (isVoice) previewText = 'Voice message';

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
                  previewText,
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
  bool shouldRepaint(WaveformPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

// Message class moved to lib/features/chat/domain/models/message_model.dart
