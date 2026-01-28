import 'package:flutter/material.dart';
import './chat_conversation_screen.dart';

/// ===============================================================
/// CHAT DETAIL SCREEN
/// ===============================================================

class ChatDetailScreen extends StatefulWidget {
  final String name;
  final String imageUrl;

  const ChatDetailScreen({
    super.key,
    required this.name,
    required this.imageUrl,
  });

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  String? selectedOption;

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

    if (result != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ChatConversationScreen(
            name: widget.name,
            imageUrl: widget.imageUrl,
            firstMessage: result,
          ),
        ),
      );
    }
  }

  /// -------------------------------------------------------------

  void _openConversation(String text) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ChatConversationScreen(
          name: widget.name,
          imageUrl: widget.imageUrl,
          firstMessage: text,
        ),
      ),
    );
  }

  /// -------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios,
              color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
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
                Text(widget.name,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600)),
                const Text('Online now',
                    style:
                        TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ],
        ),
        actions: const [
          Icon(Icons.call_outlined),
          SizedBox(width: 10),
          Icon(Icons.videocam_outlined),
          SizedBox(width: 10),
          Icon(Icons.more_vert),
          SizedBox(width: 10),
        ],
      ),

      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  /// PROFILE IMAGE
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

                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Choose an option',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),

                  const SizedBox(height: 12),

                  _buildOptionButton(
                    'Me and the cushions I made.\nWhat do you think?',
                  ),

                  const SizedBox(height: 10),

                  _buildOptionButton(
                    'I bet you can\'t beat my 90s look',
                  ),

                  const SizedBox(height: 10),

                  _buildOptionButton(
                    'Guess my pet\'s name?',
                  ),

                  const SizedBox(height: 25),

                  /// MORE OPENING MOVES BUTTON
                  ElevatedButton(
                    onPressed: _openMovePopup,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          const Color.fromRGBO(65, 72, 51, 1),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      'More opening moves',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------

  Widget _buildOptionButton(String text) {
    return InkWell(
      onTap: () => _openConversation(text),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(child: Text(text)),

            const SizedBox(width: 10),

            const Text(
              'Use',
              style: TextStyle(
                color: Colors.orange,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//////////////////////////////////////////////////////////////
/// OPEN MOVE POPUP (UNCHANGED)
//////////////////////////////////////////////////////////////
class OpenMovePopup extends StatefulWidget {
  final String name;

  const OpenMovePopup({super.key, required this.name});

  @override
  State<OpenMovePopup> createState() => _OpenMovePopupState();
}

class _OpenMovePopupState extends State<OpenMovePopup> {
  final categories = [
    'For you',
    'Funny',
    'Deep',
    'Playful',
    'Story time',
  ];

  int selectedCategory = 0;

  final suggestions = [
    'I saw you like hiking. What\'s the best trail you\'ve been on?',
    'Your dog is so cute! What\'s their name?',
    'What\'s the most spontaneous thing you\'ve done?',
    'If you could have any superpower, what would it be?',
    'I loved your Paris photo! What was your favorite part?',
  ];

  final TextEditingController _controller = TextEditingController();

  bool showComposer = false;

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return SafeArea(
  child: Padding(
    padding: EdgeInsets.only(
      bottom: MediaQuery.of(context).viewInsets.bottom,
    ),
    child: Container(
      height: height * .82,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),

          /// HANDLE
          Container(
            height: 4,
            width: 40,
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(20),
            ),
          ),

          const SizedBox(height: 14),

          /// HEADER
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              height: 44,
              child: Row(
                children: [
                  _circleBtn(Icons.refresh),

                  const Expanded(
                    child: Center(
                      child: Text(
                        'Opening moves',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  _circleBtn(
                    Icons.close,
                    onTap: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 6),

          const Text(
            'Choose a suggestion or write your own message.',
            style: TextStyle(color: Colors.grey),
          ),

          const SizedBox(height: 16),

          /// CATEGORIES
          SizedBox(
            height: 36,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: categories.length,
              itemBuilder: (_, i) {
                final selected = selectedCategory == i;

                return GestureDetector(
                  onTap: () => setState(() => selectedCategory = i),
                  child: Container(
                    margin: const EdgeInsets.only(right: 10),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: selected
                          ? const Color(0xFF4A503D)
                          : Colors.grey[200],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      categories[i],
                      style: TextStyle(
                        color:
                            selected ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 14),

          /// SUGGESTIONS LIST
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              itemCount: suggestions.length,
              itemBuilder: (_, i) {
                return _suggestionTile(suggestions[i]);
              },
            ),
          ),

          /// WRITE YOUR OWN BUTTON
          if (!showComposer)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 18),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      const Color(0xFF4A503D),
                  minimumSize:
                      const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(30),
                  ),
                ),
                onPressed: () {
                  setState(() => showComposer = true);
                },
                child: const Text(
                  'Write your own',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),

          /// CUSTOM TEXT INPUT
          if (showComposer)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  16, 6, 16, 20),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius:
                            BorderRadius.circular(24),
                      ),
                      child: TextField(
                        controller: _controller,
                        autofocus: true,
                        decoration: const InputDecoration(
                          hintText:
                              "Type your opening move...",
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  Container(
                    height: 42,
                    width: 42,
                    decoration: BoxDecoration(
                      color:
                          const Color(0xFF4A503D),
                      borderRadius:
                          BorderRadius.circular(21),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.send,
                          color: Colors.white,
                          size: 18),
                      onPressed: () {
                        if (_controller.text
                            .trim()
                            .isEmpty) return;

                        Navigator.pop(
                          context,
                          _controller.text,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    ),
  ),
);

  }

  /// -------------------------------------------------------------

  Widget _circleBtn(IconData icon, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 34,
        width: 34,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.black,
        ),
        child: Icon(icon, size: 18, color: Colors.white),
      ),
    );
  }

  Widget _suggestionTile(String text) {
    return InkWell(
      onTap: () => Navigator.pop(context, text),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Expanded(child: Text(text)),
            const SizedBox(width: 12),
            const Text(
              'Use',
              style: TextStyle(
                color: Colors.orange,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
