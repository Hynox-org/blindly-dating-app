import 'package:flutter/material.dart';
import 'dart:ui';

class UserProfile {
  final String id;
  final String name;
  final int age;
  final double distance;
  final String bio;
  final List<String> imageUrls;

  // Basic Info
  final String height;
  final String activityLevel;
  final String education;
  final String gender;
  final String religion;
  final String zodiac;
  final String drinking;
  final String smoking;

  // Interests & Values
  final List<String> hobbies;
  final String summary;
  final String lookingFor;
  final List<String> lookingForTags;
  final String quickestWay;
  final List<String> causes;

  // Additional Details
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

class ProfileSwipeCard extends StatefulWidget {
  final UserProfile profile;
  final double horizontalThreshold;
  final double verticalThreshold;

  // Screen identification flags
  final bool isHomeScreen;
  final bool isProfileScreen;

  // Callbacks
  final VoidCallback? onBlock;
  final VoidCallback? onReport;
  final VoidCallback? onLike;
  final VoidCallback? onEdit;

  const ProfileSwipeCard({
    super.key,
    required this.profile,
    required this.horizontalThreshold,
    required this.verticalThreshold,
    this.isHomeScreen = false,
    this.isProfileScreen = false,
    this.onBlock,
    this.onReport,
    this.onLike,
    this.onEdit,
  });

  @override
  State<ProfileSwipeCard> createState() => _ProfileSwipeCardState();
}

class _ProfileSwipeCardState extends State<ProfileSwipeCard> {
  final ScrollController _scrollController = ScrollController();

  /// Check if section data is empty
  bool _isSectionEmpty(String data) => data.trim().isEmpty;
  bool _isListEmpty(List<String> items) => 
      items.isEmpty || items.every((item) => item.trim().isEmpty);
  
  bool _isAboutMeEmpty() => 
      _isSectionEmpty(widget.profile.height) &&
      _isSectionEmpty(widget.profile.activityLevel) &&
      _isSectionEmpty(widget.profile.education) &&
      _isSectionEmpty(widget.profile.gender) &&
      _isSectionEmpty(widget.profile.religion) &&
      _isSectionEmpty(widget.profile.zodiac) &&
      _isSectionEmpty(widget.profile.drinking) &&
      _isSectionEmpty(widget.profile.smoking);

  bool _isLookingForEmpty() => _isListEmpty(widget.profile.lookingForTags);
  bool _isInterestsEmpty() => _isListEmpty(widget.profile.hobbies);
  bool _isCausesEmpty() => _isListEmpty(widget.profile.causes);
  bool _isLanguagesEmpty() => _isListEmpty(widget.profile.languages);
  bool _isSpotifyEmpty() => _isListEmpty(widget.profile.spotifyArtists);
  bool _isLocationEmpty() => _isSectionEmpty(widget.profile.location);

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
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                children: [
                  // ============ IMAGE 1 ============
                  Positioned.fill(
                    child: _buildImageSection(
                      0,
                      cardHeight: constraints.maxHeight,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // Full viewport height first image
  Widget _buildImageSection(int index, {double? cardHeight}) {
    if (index >= 3 || index >= widget.profile.imageUrls.length) {
      return const SizedBox.shrink();
    }

    final bool isFirstImage = index == 0;

    return LayoutBuilder(
      builder: (context, constraints) {
        if (isFirstImage) {
          return SizedBox(
            width: double.infinity,
            height: cardHeight ?? MediaQuery.of(context).size.height,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16), // all 4 corners
              child: Stack(
                fit: StackFit.expand,
                children: _buildImageStack(index),
              ),
            ),
          );
        } else {
          return SizedBox(
            width: double.infinity,
            height: 400,
            child: Stack(
              fit: StackFit.expand,
              children: _buildImageStack(index),
            ),
          );
        }
      },
    );
  }

  List<Widget> _buildImageStack(int index) {
    final bool isFirstImage = index == 0;
    return [
      Image.network(
        widget.profile.imageUrls[index],
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.grey[300],
            child: const Center(
              child: Icon(Icons.person, size: 80, color: Colors.grey),
            ),
          );
        },
      ),
      if (isFirstImage) ...[
        // Share arrow (top right)
        Positioned(
          top: 16,
          right: 16,
          child: ClipOval(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.25),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withOpacity(0.15),
                    width: 1,
                  ),
                ),
                child: const Icon(Icons.share, color: Colors.white, size: 24),
              ),
            ),
          ),
        ),
        // Bottom overlay
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
                colors: [Colors.transparent, Colors.black.withOpacity(0.9)],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Verified tags
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    verifiedTag("Profile Verified", Colors.blue),
                    const SizedBox(height: 6),
                    verifiedTag("Photo Verified", Colors.black),
                  ],
                ),
                const SizedBox(height: 12),
                // Name
                Text(
                  "${widget.profile.name}, ${widget.profile.age}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                // Job + Distance
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.work_outline, color: Colors.white, size: 16),
                        SizedBox(width: 6),
                        Text(
                          "UI/UX Designer",
                          style: TextStyle(color: Colors.white, fontSize: 13),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          "${widget.profile.distance.toStringAsFixed(1)} miles away",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                // Gold buttons + scores
                Row(
                  children: [
                    goldButton(loveChatIcon()),
                    const Spacer(),
                    scoreBox(),
                    const Spacer(),
                    goldButton(
                      const Icon(
                        Icons.star,
                        color: Color(0xFFD4AF37),
                        size: 28,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    ];
  }

  Widget verifiedTag(String text, Color bg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.verified_user, size: 18, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget goldButton(Widget icon) {
    return Container(
      height: 58,
      width: 58,
      decoration: BoxDecoration(
        color: const Color(0xFF414833),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(child: icon),
    );
  }

  Widget scoreBox() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: const Column(
        children: [
          Text(
            "Compatibility Score: 70%",
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 4),
          Text(
            "Trust Score: 70%",
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget loveChatIcon() {
    return Container(
      width: 52,
      height: 52,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color.fromRGBO(65, 72, 51, 1),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: const [
          Icon(Icons.circle_outlined, color: Color(0xFFD4AF37), size: 44),
          // Icon(
          //   Icons.chat_bubble_outline,
          //   color: Color(0xFFD4AF37),
          //   size: 28,
          // ),
          Positioned(
            top: 18,
            child: Icon(Icons.favorite, color: Color(0xFFD4AF37), size: 14),
          ),
        ],
      ),
    );
  }
}
