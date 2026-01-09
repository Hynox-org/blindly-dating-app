import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// =======================
/// USER PROFILE MODEL
/// =======================
class UserProfile {
  final String id;
  final String name;
  final int age;
  final double distance;
  final String bio;
  final List<String> imageUrls;

  final String height;
  final String activityLevel;
  final String education;
  final String gender;
  final String religion;
  final String zodiac;
  final String drinking;
  final String smoking;

  final List<String> hobbies;
  final String summary;
  final String lookingFor;
  final List<String> lookingForTags;
  final String quickestWay;
  final List<String> causes;

  final String simplePleasure;
  final List<String> languages;
  final String location;
  final List<String> spotifyArtists;

  UserProfile({
    required this.id,
    required this.name,
    required this.age,
    required this.distance,
    required this.bio,
    required this.imageUrls,
    required this.height,
    required this.activityLevel,
    required this.education,
    required this.gender,
    required this.religion,
    required this.zodiac,
    required this.drinking,
    required this.smoking,
    required this.hobbies,
    required this.summary,
    required this.lookingFor,
    required this.lookingForTags,
    required this.quickestWay,
    required this.causes,
    required this.simplePleasure,
    required this.languages,
    required this.location,
    required this.spotifyArtists,
  });
}

/// =======================
/// PROFILE SWIPE CARD
/// =======================
class ProfileSwipeCard extends StatefulWidget {
  final UserProfile profile;
  final double horizontalThreshold;
  final double verticalThreshold;

  /// Swipe actions
  final VoidCallback? onPass;
  final VoidCallback? onLike;
  final VoidCallback? onSuperLike;

  /// Non-swipe actions
  final VoidCallback? onBlock;
  final VoidCallback? onReport;

  const ProfileSwipeCard({
    super.key,
    required this.profile,
    required this.horizontalThreshold,
    required this.verticalThreshold,
    this.onPass,
    this.onLike,
    this.onSuperLike,
    this.onBlock,
    this.onReport,
  });

  @override
  State<ProfileSwipeCard> createState() => _ProfileSwipeCardState();
}

class _ProfileSwipeCardState extends State<ProfileSwipeCard> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Transform(
      alignment: Alignment.bottomCenter,
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.001)
        ..rotateZ(widget.horizontalThreshold * 0.001),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: SingleChildScrollView(
            controller: _scrollController,
            physics: const ClampingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildImageSection(0),
                _buildBasicInfo(),
                _buildImageSection(1),
                _buildExtraInfo(),
                _buildImageSection(2),
                _buildMoreInfo(),
                _buildActionButtons(),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// =======================
  /// IMAGE SECTION
  /// =======================
  Widget _buildImageSection(int index) {
    if (index >= widget.profile.imageUrls.length) {
      return const SizedBox.shrink();
    }

    return Stack(
      children: [
        CachedNetworkImage(
          imageUrl: widget.profile.imageUrls[index],
          width: double.infinity,
          height: 420,
          fit: BoxFit.cover,
          placeholder: (_, __) => Container(
            height: 420,
            color: Colors.grey[200],
            child: const Center(
              child: CircularProgressIndicator(color: Color(0xFFD4AF37)),
            ),
          ),
          errorWidget: (_, __, ___) => Container(
            height: 420,
            color: Colors.grey[300],
            child: const Icon(Icons.broken_image, size: 50),
          ),
        ),

        if (index == 0)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${widget.profile.name}, ${widget.profile.age}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.white, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        '${widget.profile.distance} km away',
                        style: const TextStyle(color: Colors.white, fontSize: 13),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  /// =======================
  /// CONTENT SECTIONS
  /// =======================
  Widget _buildBasicInfo() {
    return _section(
      title: 'My self summary',
      content: widget.profile.summary,
    );
  }

  Widget _buildExtraInfo() {
    return _section(
      title: 'The quickest way to my heart is',
      content: widget.profile.quickestWay,
    );
  }

  Widget _buildMoreInfo() {
    return _section(
      title: 'My location',
      content: widget.profile.location,
    );
  }

  Widget _section({required String title, required String content}) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Text(content, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  /// =======================
  /// ACTION BUTTONS
  /// =======================
  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _actionButton(
            icon: Icons.close,
            color: Colors.redAccent,
            onTap: widget.onPass,
          ),
          _actionButton(
            icon: Icons.star,
            color: const Color(0xFFD4AF37),
            onTap: widget.onSuperLike,
          ),
          _actionButton(
            icon: Icons.favorite,
            color: Colors.green,
            onTap: widget.onLike,
          ),
        ],
      ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required Color color,
    required VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          color: const Color.fromRGBO(65, 72, 51, 1),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
            ),
          ],
        ),
        child: Icon(icon, color: color, size: 44),
      ),
    );
  }
}
