import 'package:flutter/material.dart';
import '../../profile/profile_edit_screen.dart';
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
      _isSectionEmpty(displayProfile.height) &&
      _isSectionEmpty(displayProfile.activityLevel) &&
      _isSectionEmpty(displayProfile.education) &&
      _isSectionEmpty(displayProfile.gender) &&
      _isSectionEmpty(displayProfile.religion) &&
      _isSectionEmpty(displayProfile.zodiac) &&
      _isSectionEmpty(displayProfile.drinking) &&
      _isSectionEmpty(displayProfile.smoking);

  bool _isLookingForEmpty() => _isListEmpty(displayProfile.lookingForTags);
  bool _isInterestsEmpty() => _isListEmpty(displayProfile.hobbies);
  bool _isCausesEmpty() => _isListEmpty(displayProfile.causes);
  bool _isLanguagesEmpty() => _isListEmpty(displayProfile.languages);
  bool _isSpotifyEmpty() => _isListEmpty(displayProfile.spotifyArtists);
  bool _isLocationEmpty() => _isSectionEmpty(displayProfile.location);

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // --- HARDCODED PROFILE GENERATOR ---
  // This combines real user data (Name, Photo) with static data for the client demo
  UserProfile get displayProfile {
    return UserProfile(
      // 1. KEEP REAL DATA
      id: widget.profile.id,
      name: widget.profile.name,
      age: widget.profile.age,
      distance: widget.profile.distance,
      imageUrls: widget.profile.imageUrls,

      // 2. HARDCODE THE REST (Static Data for Demo)
      bio: "Living life one adventure at a time! 🌍✈️ Love photography and spicy food.",
      height: "5'10\"",
      activityLevel: "Active",
      education: "Masters in Design",
      gender: "Male", 
      religion: "Spiritual",
      zodiac: "Libra",
      drinking: "Socially",
      smoking: "Never",
      hobbies: ["Photography", "Hiking", "Cooking", "Travel", "Gym"],
      summary: "I am a creative soul who loves to explore new places and meet new people. I believe in kindness and staying curious.",
      lookingFor: "A partner in crime to explore the world with.",
      lookingForTags: ["Commitment", "Travel Buddy", "Deep Chats"],
      quickestWay: "Buy me a dark chocolate mocha ☕️",
      causes: ["Climate Change", "Animal Rights"],
      simplePleasure: "Watching the sunset with a good playlist.",
      languages: ["English", "Spanish", "French"],
      location: "New York, USA",
      spotifyArtists: ["Coldplay", "The Weeknd", "Ed Sheeran", "Drake"],
    );
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
        child: LayoutBuilder(
          builder: (context, constraints) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: SingleChildScrollView(
                controller: _scrollController,
                physics: const ClampingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ============ IMAGE 1 ============
                    _buildImageSection(0, cardHeight: constraints.maxHeight),

                    // ============ CONTENT SECTION 1 ============
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // KUDOS SECTIONS (Only on Home Screen)
                          if (widget.isHomeScreen &&
                              displayProfile.summary.trim().isNotEmpty) ...[
                            _buildKudosSection(
                              title: 'My self Summary',
                              content: displayProfile.summary,
                            ),
                            const SizedBox(height: 20),
                          ],
                          if (widget.isHomeScreen &&
                              displayProfile.lookingFor.trim().isNotEmpty) ...[
                            _buildKudosSection(
                              title: 'What makes a relationship great is',
                              content: displayProfile.lookingFor,
                            ),
                            const SizedBox(height: 20),
                          ],

                          // About Me (Only if not empty)
                          if (!_isAboutMeEmpty()) ...[
                            _buildSection(
                              title: 'About me',
                              child: Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                children: [
                                  if (!_isSectionEmpty(displayProfile.height))
                                    _buildInfoChip(
                                      displayProfile.height,
                                      Colors.blue,
                                    ),
                                  if (!_isSectionEmpty(
                                    displayProfile.activityLevel,
                                  ))
                                    _buildInfoChip(
                                      displayProfile.activityLevel,
                                      Colors.purple,
                                    ),
                                  if (!_isSectionEmpty(
                                    displayProfile.education,
                                  ))
                                    _buildInfoChip(
                                      displayProfile.education,
                                      Colors.orange,
                                    ),
                                  if (!_isSectionEmpty(displayProfile.gender))
                                    _buildInfoChip(
                                      displayProfile.gender,
                                      Colors.blue,
                                    ),
                                  if (!_isSectionEmpty(displayProfile.religion))
                                    _buildInfoChip(
                                      displayProfile.religion,
                                      Colors.orange,
                                    ),
                                  if (!_isSectionEmpty(displayProfile.zodiac))
                                    _buildInfoChip(
                                      displayProfile.zodiac,
                                      Colors.brown,
                                    ),
                                  if (!_isSectionEmpty(displayProfile.drinking))
                                    _buildInfoChip(
                                      displayProfile.drinking,
                                      Colors.green,
                                    ),
                                  if (!_isSectionEmpty(displayProfile.smoking))
                                    _buildInfoChip(
                                      displayProfile.smoking,
                                      Colors.red,
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],
                        ],
                      ),
                    ),

                    // ============ IMAGE 2 ============
                    _buildImageSection(1),

                    // ============ CONTENT SECTION 2 ============
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // I'm looking for (Only if not empty)
                          if (!_isLookingForEmpty()) ...[
                            _buildSection(
                              title: 'I\'m looking for',
                              child: Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: displayProfile.lookingForTags
                                    .where((tag) => tag.trim().isNotEmpty)
                                    .map(
                                      (tag) => Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 14,
                                          vertical: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.grey[100],
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                          border: Border.all(
                                            color: Colors.grey[300]!,
                                          ),
                                        ),
                                        child: Text(
                                          tag.trim(),
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: Color.fromRGBO(0, 0, 0, 1),
                                          ),
                                        ),
                                      ),
                                    )
                                    .toList(),
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],

                          // KUDOS SECTION 3 (Only on Home Screen)
                          if (widget.isHomeScreen &&
                              displayProfile.quickestWay.trim().isNotEmpty) ...[
                            _buildKudosSection(
                              title: 'The quickest way to my heart is',
                              content: displayProfile.quickestWay,
                              isItalic: true,
                            ),
                            const SizedBox(height: 20),
                          ],

                          // My Interests (Only if not empty)
                          if (!_isInterestsEmpty()) ...[
                            _buildSection(
                              title: 'My interests',
                              child: Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                children: displayProfile.hobbies
                                    .where((hobby) => hobby.trim().isNotEmpty)
                                    .map(
                                      (hobby) => Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 14,
                                          vertical: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                          border: Border.all(
                                            color: Colors.grey[300]!,
                                          ),
                                        ),
                                        child: Text(
                                          hobby.trim(),
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: Color.fromRGBO(0, 0, 0, 1),
                                          ),
                                        ),
                                      ),
                                    )
                                    .toList(),
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],
                        ],
                      ),
                    ),

                    // ============ IMAGE 3 ============
                    _buildImageSection(2),

                    // ============ CONTENT SECTION 3 ============
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // My Causes (Only if not empty)
                          if (!_isCausesEmpty()) ...[
                            _buildSection(
                              title: 'My causes and communities',
                              child: Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: displayProfile.causes
                                    .where((cause) => cause.trim().isNotEmpty)
                                    .map(
                                      (cause) => Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 14,
                                          vertical: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                          border: Border.all(
                                            color: Colors.grey[300]!,
                                          ),
                                        ),
                                        child: Text(
                                          cause.trim(),
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: Color.fromRGBO(0, 0, 0, 1),
                                          ),
                                        ),
                                      ),
                                    )
                                    .toList(),
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],

                          // KUDOS SECTION 4 (Only on Home Screen)
                          if (widget.isHomeScreen &&
                              displayProfile.simplePleasure
                                  .trim()
                                  .isNotEmpty) ...[
                            _buildKudosSection(
                              title: 'My simple pleasures are',
                              content: displayProfile.simplePleasure,
                            ),
                            const SizedBox(height: 20),
                          ],

                          // Languages (Only if not empty)
                          if (!_isLanguagesEmpty()) ...[
                            _buildSection(
                              title: 'Languages',
                              child: Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: displayProfile.languages
                                    .where((lang) => lang.trim().isNotEmpty)
                                    .map(
                                      (lang) => Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 10,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.blue[50],
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                          border: Border.all(
                                            color: Colors.blue[200]!,
                                          ),
                                        ),
                                        child: Text(
                                          lang.trim(),
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: Colors.blue,
                                          ),
                                        ),
                                      ),
                                    )
                                    .toList(),
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],

                          // Location (Only if not empty)
                          if (!_isLocationEmpty()) ...[
                            _buildSection(
                              title: 'My location',
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: Colors.grey[300]!),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.location_on,
                                      color: Color.fromRGBO(0, 0, 0, 1),
                                      size: 20,
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      displayProfile.location.trim(),
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Color.fromRGBO(0, 0, 0, 1),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],

                          // Spotify Artists (Only if not empty)
                          if (!_isSpotifyEmpty()) ...[
                            _buildSection(
                              title: 'My top artist on spotify',
                              child: Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: displayProfile.spotifyArtists
                                    .where((artist) => artist.trim().isNotEmpty)
                                    .map(
                                      (artist) => Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 14,
                                          vertical: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                          border: Border.all(
                                            color: Colors.grey[300]!,
                                          ),
                                        ),
                                        child: Text(
                                          artist.trim(),
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: Color.fromRGBO(0, 0, 0, 1),
                                          ),
                                        ),
                                      ),
                                    )
                                    .toList(),
                              ),
                            ),
                            const SizedBox(height: 30),
                          ],

                          // ============ CONDITIONAL ACTION BUTTONS ============
                          if (widget.isHomeScreen) ...[
                            _buildHomeScreenButtons(),
                            const SizedBox(height: 20),
                          ],

                          if (widget.isProfileScreen) ...[
                            _buildProfileScreenEditButton(),
                            const SizedBox(height: 20),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // Updated Section wrapper with title inside
  Widget _buildSection({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color.fromRGBO(0, 0, 0, 1),
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  // Kudos Section Builder
  Widget _buildKudosSection({
    required String title,
    required String content,
    bool isItalic = false,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color.fromRGBO(0, 0, 0, 1),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
              color: const Color.fromRGBO(0, 0, 0, 1),
            ),
          ),
          const SizedBox(height: 12),
          Container(height: 1, color: Colors.grey[300]),
          const SizedBox(height: 12),
          _buildKudosBadge(),
        ],
      ),
    );
  }

  // ✅ UPDATED: Kudos badge is now a transparent clickable button
  Widget _buildKudosBadge() {
    return GestureDetector(
      onTap: () {
        // Add your Kudos functionality here
        print('Kudos tapped for ${displayProfile.name}!');
        // Example: _showKudosDialog(), increment score, etc.
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.emoji_emotions_outlined,
              size: 20,
              color: Colors.grey[700],
            ),
            const SizedBox(width: 8),
            Text(
              'Kudos',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Full viewport height first image
  Widget _buildImageSection(int index, {double? cardHeight}) {
    if (index >= 3 || index >= displayProfile.imageUrls.length) {
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
        displayProfile.imageUrls[index],
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
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.65),
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Icon(Icons.share, color: Colors.white, size: 18),
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
                  "${displayProfile.name}, ${displayProfile.age}",
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
                          "${displayProfile.distance.toStringAsFixed(1)} miles away",
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

  Widget _buildInfoChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text.trim(),
        style: const TextStyle(fontSize: 13, color: Color.fromRGBO(0, 0, 0, 1)),
      ),
    );
  }

  Widget _buildHomeScreenButtons() {
    return Column(
      children: [
        // Icons row - horizontally aligned
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildActionButton(
              icon: Icons.close,
              color: const Color.fromRGBO(65, 72, 51, 1),
              onTap: widget.onBlock ?? () => _showBlockDialog(),
            ),
            _buildActionButton(
              icon: Icons.flag,
              color: const Color.fromRGBO(65, 72, 51, 1),
              onTap: widget.onReport ?? () => _showReportDialog(),
            ),
            _buildActionButton(
              icon: Icons.favorite,
              color: const Color.fromRGBO(65, 72, 51, 1),
              onTap: widget.onLike ?? () {},
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Text row - horizontally aligned, vertically below icons
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const Text(
              'Block',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color.fromRGBO(0, 0, 0, 1),
              ),
            ),
            const Text(
              'Report',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color.fromRGBO(0, 0, 0, 1),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Icon(icon, color: const Color(0xFFD4AF37), size: 32),
      ),
    );
  }

  Widget _buildProfileScreenEditButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed:
            widget.onEdit ??
            () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const ProfileEditScreen(),
                ),
              );
            },
        icon: const Icon(Icons.edit, color: Colors.white),
        label: const Text(
          'Edit Profile',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromRGBO(65, 72, 51, 1),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          elevation: 4,
        ),
      ),
    );
  }

  void _showBlockDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Block User'),
        content: Text('Are you sure you want to block ${displayProfile.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Block'),
          ),
        ],
      ),
    );
  }

  void _showReportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report User'),
        content: Text('Why are you reporting ${displayProfile.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('Report'),
          ),
        ],
      ),
    );
  }
}
