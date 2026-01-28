import 'package:flutter/material.dart';
import './ice_breaker_screen.dart';

/// =======================================================
/// CHAT CONVERSATION SCREEN
/// =======================================================

class ChatConversationScreen extends StatefulWidget {
  final String name;
  final String imageUrl;
  final String firstMessage;

  const ChatConversationScreen({
    super.key,
    required this.name,
    required this.imageUrl,
    required this.firstMessage,
  });

  @override
  State<ChatConversationScreen> createState() =>
      _ChatConversationScreenState();
}

class _ChatConversationScreenState extends State<ChatConversationScreen> {
  final TextEditingController _controller = TextEditingController();

  final List<ChatMessage> messages = [];

  bool hasConversationStarted = false;

  @override
  void initState() {
    super.initState();

    if (widget.firstMessage.trim().isNotEmpty) {
      messages.add(
        ChatMessage(text: widget.firstMessage, isMe: true),
      );
      hasConversationStarted = true;
    }
  }

  /// ---------------- SEND MESSAGE ----------------

  void _send(String text) {
    if (text.trim().isEmpty) return;

    setState(() {
      messages.add(ChatMessage(text: text, isMe: true));
      hasConversationStarted = true;
    });

    _controller.clear();
  }

  /// ---------------- ICEBREAKER POPUP ----------------

  Future<void> _openIcebreakers() async {
    final icebreaker = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return IcebreakersScreen(
          name: widget.name,
          imageUrl: widget.imageUrl,
        );
      },
    );

    if (icebreaker != null && icebreaker.trim().isNotEmpty) {
      setState(() {
        messages.insert(
          0,
          ChatMessage(text: icebreaker, isMe: true),
        );
        hasConversationStarted = true;
      });
    }
  }

  /// =======================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      /// ---------------- APP BAR ----------------

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: .5,
        leading: const BackButton(color: Colors.black),

        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(widget.imageUrl),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.name),
                const Text(
                  "Online now",
                  style: TextStyle(fontSize: 12),
                ),
              ],
            )
          ],
        ),

        actions: const [
          Icon(Icons.call_outlined, color: Colors.black),
          SizedBox(width: 16),
          Icon(Icons.videocam_outlined, color: Colors.black),
          SizedBox(width: 16),
          Icon(Icons.more_vert, color: Colors.black),
          SizedBox(width: 8),
        ],
      ),

      /// ---------------- FLOATING ICEBREAKER BUTTON ----------------

      floatingActionButtonLocation:
          FloatingActionButtonLocation.endFloat,

      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 90),
        child: FloatingActionButton(
          backgroundColor: const Color(0xFF4A503D),
          onPressed: _openIcebreakers,
          child: const Icon(Icons.flash_on, color: Colors.white),
        ),
      ),

      /// ---------------- BODY ----------------

      body: Column(
        children: [
          /// PROFILE IMAGE ONLY WHEN NO CHAT

          if (!hasConversationStarted)
            Padding(
              padding: const EdgeInsets.all(16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: Image.network(
                  widget.imageUrl,
                  height: 240,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),

          if (!hasConversationStarted)
            const Divider(height: 1),

          /// CHAT LIST

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              itemCount: messages.length,
              itemBuilder: (_, i) => _bubble(messages[i]),
            ),
          ),

          _inputBar(),
        ],
      ),
    );
  }

  /// ---------------- CHAT BUBBLE ----------------

  Widget _bubble(ChatMessage msg) {
    final isMe = msg.isMe;

    return Align(
      alignment:
          isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isMe
              ? const Color(0xFF3F472E)
              : const Color(0xFFEBC163),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(
          msg.text,
          style: TextStyle(
            color: isMe ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }

  /// ---------------- INPUT BAR ----------------

  Widget _inputBar() {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
        child: Row(
          children: [
            /// CAMERA ICON
            Container(
              height: 38,
              width: 38,
              decoration: BoxDecoration(
                color: const Color(0xFFE6E6E6),
                borderRadius: BorderRadius.circular(20),
              ),
              child: IconButton(
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.camera_alt_outlined,
                    size: 20),
                onPressed: () {},
              ),
            ),

            const SizedBox(width: 10),

            /// INPUT FIELD
            Expanded(
              child: Container(
                height: 42,
                padding:
                    const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        decoration: const InputDecoration(
                          hintText: "Type a message",
                          border: InputBorder.none,
                        ),
                      ),
                    ),

                    const Icon(Icons.mic_none, size: 20),
                    const SizedBox(width: 10),
                    const Icon(
                        Icons.sentiment_satisfied_alt_outlined,
                        size: 20),
                    const SizedBox(width: 10),
                    const Icon(Icons.crop_original_outlined,
                        size: 20),
                  ],
                ),
              ),
            ),

            const SizedBox(width: 10),

            /// SEND BUTTON
            Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF4A503D),
                borderRadius: BorderRadius.circular(20),
              ),
              child: IconButton(
                icon: const Icon(Icons.send,
                    color: Colors.white, size: 18),
                onPressed: () => _send(_controller.text),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// =======================================================
/// CHAT MESSAGE MODEL
/// =======================================================

class ChatMessage {
  final String text;
  final bool isMe;

  ChatMessage({
    required this.text,
    required this.isMe,
  }); 
}
