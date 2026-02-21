import 'package:flutter/material.dart';

class IcebreakersScreen extends StatefulWidget {
  final String name;
  final String imageUrl;

  const IcebreakersScreen({
    super.key,
    required this.name,
    required this.imageUrl,
  });

  @override
  State<IcebreakersScreen> createState() => _IcebreakersScreenState();
}

class _IcebreakersScreenState extends State<IcebreakersScreen> {
  int selectedCategory = 0;

  final categories = [
    "All",
    "Playful",
    "Deep",
    "Quirky",
    "Hypothesis",
  ];

  final icebreakers = [
    "What’s a small thing that made you smile recently?",
    "Two truths and a lie: Let’s go!",
    "If you could have any superpower, what would it be?",
    "What’s the most interesting thing you’ve learned lately?",
  ];

  // --------------------------------------------------
  // ICON PICKER
  // --------------------------------------------------

  IconData _getIcebreakerIcon(int index) {
    switch (index) {
      case 0:
        return Icons.emoji_emotions_outlined;
      case 1:
        return Icons.wb_sunny_outlined;
      case 2:
        return Icons.flash_on_outlined;
      case 3:
        return Icons.school_outlined;
      default:
        return Icons.lightbulb_outline;
    }
  }

  // --------------------------------------------------
  // HEADER BUTTON
  // --------------------------------------------------

  Widget _circleHeaderButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(50),
      child: Container(
        width: 34,
        height: 34,
        decoration: const BoxDecoration(
          color: Colors.black,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 18, color: Colors.white),
      ),
    );
  }

  // --------------------------------------------------
  // UI
  // --------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),

      body: SafeArea(
        child: Stack(
          children: [
            /// ---------------- TOP USER INFO ----------------

            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                CircleAvatar(
                  radius: 40,
                  backgroundImage: NetworkImage(widget.imageUrl),
                ),

                const SizedBox(height: 10),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(
                      Icons.verified,
                      size: 18,
                      color: Colors.blue,
                    ),
                  ],
                ),

                const SizedBox(height: 6),

                Text(
                  "12 hours left to message",
                  style: TextStyle(
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),

            /// ---------------- ICEBREAKERS POPUP ----------------

            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: MediaQuery.of(context).size.height * 0.58,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(28),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 12,
                      offset: Offset(0, -5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 12),

                    /// Drag Handle
                    Container(
                      height: 5,
                      width: 40,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),

                    const SizedBox(height: 14),

                    /// Title Row
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: SizedBox(
  width: double.infinity,
  height: 44,
  child: Stack(
    alignment: Alignment.center,
    children: [
      /// Center title
      const Text(
        "Icebreakers",
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),

      /// Extreme left refresh
      Positioned(
        left: 0,
        child: _circleHeaderButton(Icons.refresh, () {}),
      ),

      /// Extreme right close
      Positioned(
        right: 0,
        child: _circleHeaderButton(
          Icons.close,
          () => Navigator.pop(context),
        ),
      ),
    ],
  ),
),

                    ),

                    const SizedBox(height: 14),

                    /// Categories
                    SizedBox(
                      height: 38,
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        scrollDirection: Axis.horizontal,
                        itemCount: categories.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final selected = selectedCategory == index;

                          return ChoiceChip(
                            label: Text(categories[index]),
                            selected: selected,
                            showCheckmark: false,
                            selectedColor: Colors.black,
                            backgroundColor: Colors.grey.shade200,
                            labelStyle: TextStyle(
                              color:
                                  selected ? Colors.white : Colors.black,
                            ),
                            onSelected: (_) {
                              setState(() {
                                selectedCategory = index;
                              });
                            },
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 18),

                    /// Icebreaker List
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: icebreakers.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          return _IcebreakerTile(
                            text: icebreakers[index],
                            icon: _getIcebreakerIcon(index),
                            onSend: () {
                                Navigator.pop(context, icebreakers[index]);
                            },
                          );
                        },
                      ),
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

// --------------------------------------------------
// TILE
// --------------------------------------------------

class _IcebreakerTile extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onSend;

  const _IcebreakerTile({
    required this.text,
    required this.icon,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Icon(icon, size: 22),

          const SizedBox(width: 12),

          Expanded(
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          const SizedBox(width: 12),

          IconButton(
            icon: const Icon(Icons.send),
            onPressed: onSend,
          ),
        ],
      ),
    );
  }
}
