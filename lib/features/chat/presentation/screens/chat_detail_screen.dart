import 'package:flutter/material.dart';
import 'package:blindly_dating_app/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:blindly_dating_app/features/chat/providers/chat_providers.dart';
import 'package:blindly_dating_app/features/chat/presentation/screens/chat_conversation_screen.dart';
import 'package:blindly_dating_app/core/widgets/app_layout.dart';

/// ===============================================================
/// CHAT DETAIL SCREEN
/// ===============================================================

class ChatDetailScreen extends ConsumerStatefulWidget {
  final String name;
  final String imageUrl;

  final String matchId;
  final String myProfileId;
  final String otherProfileId;

  const ChatDetailScreen({
    super.key,
    required this.name,
    required this.imageUrl,
    required this.matchId,
    required this.myProfileId,
    required this.otherProfileId,
  });

  @override
  ConsumerState<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends ConsumerState<ChatDetailScreen> {
  AppLocalizations get l10n => AppLocalizations.of(context);


  bool _isLoading = false;

  /// -------------------------------------------------------------
  /// OPEN MOVE POPUP
  /// -------------------------------------------------------------
  Future<void> _openMovePopup() async {
    final result = await showModalBottomSheet<String?>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return OpenMovePopup(name: widget.name);
      },
    );

    if (!mounted || result == null) return;

    await _startChatAndNavigate(result);
  }

  /// -------------------------------------------------------------

  Future<void> _openConversation(String text) async {
    await _startChatAndNavigate(text);
  }

  /// -------------------------------------------------------------
  /// START CHAT AND SEND FIRST MESSAGE
  /// -------------------------------------------------------------

  Future<void> _startChatAndNavigate(String messageText) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });
 if (widget.matchId.isEmpty || widget.myProfileId.isEmpty || widget.otherProfileId.isEmpty) {
    print('❌ INVALID IDs: matchId="${widget.matchId}", my=${widget.myProfileId}, other=${widget.otherProfileId}');
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.invalidMatchData), backgroundColor: Colors.red),
      );
    }
    setState(() => _isLoading = false);
    return;
  }
    final repo = ref.read(matchRepositoryProvider);
    print('🚀 Starting chat with message: $messageText');
    print('📊 Match ID: ${widget.matchId}');
    print('👤 Sender Profile ID: ${widget.myProfileId}');
    print('👤 Receiver Profile ID: ${widget.otherProfileId}');
    final success = await repo.startChatAndSendMessage(
      matchId: widget.matchId,
      senderProfileId: widget.myProfileId,
      receiverProfileId: widget.otherProfileId,
      messageContent: messageText,
    );
    print('🔍 Start chat result: $success');
    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.matchHasExpired),
          backgroundColor: Colors.red,
        ),
      );
      Navigator.pop(context, true);
      return;
    }

    /// ✅ PASS myProfileId
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ChatConversationScreen(
          matchId: widget.matchId,
          otherUserName: widget.name,
          otherUserImage: widget.imageUrl,
          myProfileId: widget.myProfileId,
          otherProfileId: widget.otherProfileId,
          name:widget.name,
          imageUrl: widget.imageUrl,
        ),
      ),
    );
  }

  /// -------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      showFooter: true,
      child: Scaffold(
        backgroundColor: Colors.white,

        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0.5,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios,
              color: Colors.black,
              size: 20,
            ),
            onPressed: () => Navigator.pop(context, true),
          ),
          title: Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundImage: NetworkImage(widget.imageUrl),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    l10n.onlineNow,
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
        ),

        body: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  Container(
                    height: 280,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      image: DecorationImage(
                        image: NetworkImage(widget.imageUrl),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      l10n.chooseAnOption,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  _buildOptionButton(l10n.openingMoveCushions),

                  const SizedBox(height: 10),

                  _buildOptionButton(l10n.openingMove90s),

                  const SizedBox(height: 10),

                  _buildOptionButton(l10n.openingMovePetName),

                  const SizedBox(height: 25),

                  ElevatedButton(
                    onPressed: _isLoading ? null : _openMovePopup,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromRGBO(65, 72, 51, 1),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text(
                      l10n.moreOpeningMoves,
                      style: TextStyle(color: Colors.white),
                    ),
                  ),

                  const SizedBox(height: 100),
                ],
              ),
            ),

            /// ✅ Loading overlay (no deprecated API)
            if (_isLoading)
              Container(
                color: Colors.black.withValues(alpha: 0.3),
                child: const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------------

  Widget _buildOptionButton(String text) {
    return InkWell(
      onTap: _isLoading ? null : () => _openConversation(text),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _isLoading ? Colors.grey[200] : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(child: Text(text)),
            const SizedBox(width: 10),
            Text(
              l10n.use,
              style: TextStyle(
                color: _isLoading ? Colors.grey : Colors.orange,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ===============================================================
/// OPEN MOVE POPUP — LOCAL WIDGET
/// ===============================================================

class OpenMovePopup extends StatefulWidget {
  final String name;

  const OpenMovePopup({super.key, required this.name});

  @override
  State<OpenMovePopup> createState() => _OpenMovePopupState();
}

class _OpenMovePopupState extends State<OpenMovePopup> {
  AppLocalizations get l10n => AppLocalizations.of(context);


  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.55,
      minChildSize: 0.35,
      maxChildSize: 0.9,
      builder: (_, scrollController) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                Text(
                  l10n.sendPersonMessage(widget.name),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 16),

                TextField(
                  controller: _controller,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: l10n.typeOpeningMove,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      final text = _controller.text.trim();

                      if (text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(l10n.pleaseEnterMessage),
                          ),
                        );
                        return;
                      }

                      Navigator.pop(context, text);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromRGBO(65, 72, 51, 1),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(
                      l10n.sendMessage,
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
