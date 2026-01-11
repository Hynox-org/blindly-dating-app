import 'package:flutter/material.dart';

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
              color: Colors.black.withValues(alpha: 0.15),
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

                // ============ CONTENT SECTION 1 ============
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ✅ KUDOS SECTION 1: My Self Summary (Only on Home Screen)
                      if (widget.isHomeScreen) ...[
                        _buildKudosSection(
                          title: 'My self Summary',
                          content: widget.profile.summary,
                        ),
                        const SizedBox(height: 20),
                      ],

                      // ✅ KUDOS SECTION 2: What makes a relationship great (Only on Home Screen)
                      if (widget.isHomeScreen) ...[
                        _buildKudosSection(
                          title: 'What makes a relationship great is',
                          content: widget.profile.lookingFor,
                        ),
                        const SizedBox(height: 20),
                      ],

                      // My View (Always shown)
                      _buildSection(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'My view',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Poppins',
                                color: Color.fromRGBO(0, 0, 0, 1),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: [
                                _buildInfoChip('📏 ${widget.profile.height}', Colors.blue),
                                _buildInfoChip('⚡ ${widget.profile.activityLevel}', Colors.purple),
                                _buildInfoChip('🎓 ${widget.profile.education}', Colors.orange),
                                _buildInfoChip('👤 ${widget.profile.gender}', Colors.blue),
                                _buildInfoChip('🕉️ ${widget.profile.religion}', Colors.orange),
                                _buildInfoChip('♉ ${widget.profile.zodiac}', Colors.brown),
                                _buildInfoChip('🍺 ${widget.profile.drinking}', Colors.green),
                                _buildInfoChip('🚭 ${widget.profile.smoking}', Colors.red),
                              ],
                            ),
                          ],
                        ),
                      ),
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
                      // I'm Chasing For (Always shown)
                      _buildSection(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'I\'m Chasing for',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Poppins',
                                color: Color.fromRGBO(0, 0, 0, 1),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: widget.profile.lookingForTags.map((tag) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: Colors.grey[300]!),
                                  ),
                                  child: Text(
                                    tag,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontFamily: 'Poppins',
                                      color: Color.fromRGBO(0, 0, 0, 1),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // ✅ KUDOS SECTION 3: The quickest way to my heart (Only on Home Screen)
                      if (widget.isHomeScreen) ...[
                        _buildKudosSection(
                          title: 'The quickest way to my heart is',
                          content: widget.profile.quickestWay,
                          isItalic: true,
                        ),
                        const SizedBox(height: 20),
                      ],

                      // My Hobbies (Always shown)
                      _buildSection(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'My Hobbies',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Poppins',
                                color: Color.fromRGBO(0, 0, 0, 1),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: widget.profile.hobbies.map((hobby) {
                                return _buildHobbyChip(hobby);
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
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
                      // My Causes (Always shown)
                      _buildSection(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'My causes and communities',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Poppins',
                                color: Color.fromRGBO(0, 0, 0, 1),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: widget.profile.causes.map((cause) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: Colors.grey[300]!),
                                  ),
                                  child: Text(
                                    cause,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontFamily: 'Poppins',
                                      color: Color.fromRGBO(0, 0, 0, 1),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 25),

                      // ✅ KUDOS SECTION 4: My simple and pleasure (Only on Home Screen)
                      if (widget.isHomeScreen) ...[
                        _buildKudosSection(
                          title: 'My simple and pleasure are',
                          content: widget.profile.simplePleasure,
                        ),
                        const SizedBox(height: 20),
                      ],

                      // Languages (Always shown)
                      _buildSection(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Languages',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Poppins',
                                color: Color.fromRGBO(0, 0, 0, 1),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: widget.profile.languages.map((lang) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: Colors.blue[50],
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: Colors.blue[200]!),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.language,
                                        color: Colors.blue,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        lang,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontFamily: 'Poppins',
                                          color: Colors.blue,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Location (Always shown)
                      _buildSection(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'My location',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Poppins',
                                color: Color.fromRGBO(0, 0, 0, 1),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Container(
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
                                    widget.profile.location,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      fontFamily: 'Poppins',
                                      color: Color.fromRGBO(0, 0, 0, 1),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Spotify Artists (Always shown)
                      _buildSection(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'My top artist on spotify',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Poppins',
                                color: Color.fromRGBO(0, 0, 0, 1),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: widget.profile.spotifyArtists.map((artist) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: Colors.grey[300]!),
                                  ),
                                  child: Text(
                                    artist,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontFamily: 'Poppins',
                                      color: Color.fromRGBO(0, 0, 0, 1),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),

                      // ============ CONDITIONAL ACTION BUTTONS ============
                      // Show action buttons only on home screen
                      if (widget.isHomeScreen) ...[
                        _buildHomeScreenButtons(),
                        const SizedBox(height: 20),
                      ],

                      // Show edit button only on profile screen
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
        ),
      ),
    );
  }

  // ✅ NEW: Section wrapper with light grey background
  Widget _buildSection({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50], // Lightest grey background
        borderRadius: BorderRadius.circular(12),
      ),
      child: child,
    );
  }

  // ✅ Kudos Section Builder with background
  Widget _buildKudosSection({
    required String title,
    required String content,
    bool isItalic = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50], // Lightest grey background
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
              fontFamily: 'Poppins',
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
              fontFamily: 'Poppins',
              color: const Color.fromRGBO(0, 0, 0, 1),
            ),
          ),
          const SizedBox(height: 12),
          // Divider line
          Container(
            height: 1,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 12),
          // Kudos badge
          _buildKudosBadge(),
        ],
      ),
    );
  }

  // Helper method to build image sections
  Widget _buildImageSection(int index) {
    if (index >= widget.profile.imageUrls.length) {
      return const SizedBox.shrink();
    }

    return Stack(
      children: [
        // Image
        Image.network(
          widget.profile.imageUrls[index],
          width: double.infinity,
          height: 400,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: double.infinity,
              height: 400,
              color: Colors.grey[300],
              child: const Center(
                child: Icon(Icons.person, size: 80, color: Colors.grey),
              ),
            );
          },
        ),

        // Gradient overlay (only on first image for name)
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
                    Colors.black.withValues(alpha: 0.7),
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
                      fontFamily: 'Poppins',
                      shadows: [Shadow(color: Colors.black45, blurRadius: 10)],
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (widget.profile.distance > 0)
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          color: Colors.white,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${widget.profile.distance} km away',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontFamily: 'Poppins',
                            shadows: [
                              Shadow(color: Colors.black45, blurRadius: 10),
                            ],
                          ),
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

  Widget _buildKudosBadge() {
    return Container(
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
              fontFamily: 'Poppins',
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontFamily: 'Poppins',
          color: Color.fromRGBO(0, 0, 0, 1),
        ),
      ),
    );
  }

  Widget _buildHobbyChip(String hobby) {
    IconData icon = Icons.interests;
    if (hobby.toLowerCase().contains('dance')) icon = Icons.music_note;
    if (hobby.toLowerCase().contains('cricket') ||
        hobby.toLowerCase().contains('football')) {
      icon = Icons.sports;
    }
    if (hobby.toLowerCase().contains('whiskey') ||
        hobby.toLowerCase().contains('bar')) {
      icon = Icons.local_bar;
    }
    if (hobby.toLowerCase().contains('beach')) icon = Icons.beach_access;
    if (hobby.toLowerCase().contains('fish')) icon = Icons.set_meal;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: const Color.fromRGBO(0, 0, 0, 1)),
          const SizedBox(width: 6),
          Text(
            hobby,
            style: const TextStyle(
              fontSize: 13,
              fontFamily: 'Poppins',
              color: Color.fromRGBO(0, 0, 0, 1),
            ),
          ),
        ],
      ),
    );
  }

  // Home screen action buttons (Pass, Report, Like)
  Widget _buildHomeScreenButtons() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Pass button (X mark)
            _buildActionButton(
              icon: Icons.close,
              color: const Color.fromRGBO(65, 72, 51, 1),
              onTap: widget.onBlock ?? () {
                _showBlockDialog();
              },
            ),

            // Report button (Flag)
            _buildActionButton(
              icon: Icons.flag,
              color: const Color.fromRGBO(65, 72, 51, 1),
              onTap: widget.onReport ?? () {
                _showReportDialog();
              },
            ),

            // Like button (Heart)
            _buildActionButton(
              icon: Icons.favorite,
              color: const Color.fromRGBO(65, 72, 51, 1),
              onTap: widget.onLike ?? () {},
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Text labels
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: const [
            SizedBox(
              width: 70,
              child: Text(
                'Block',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins',
                  color: Color.fromRGBO(0, 0, 0, 1),
                ),
              ),
            ),
            SizedBox(
              width: 70,
              child: Text(
                'Report',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins',
                  color: Color.fromRGBO(0, 0, 0, 1),
                ),
              ),
            ),
            SizedBox(
              width: 70,
              child: Text(
                'Like',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins',
                  color: Color.fromRGBO(0, 0, 0, 1),
                ),
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
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Icon(
          icon,
          color: const Color(0xFFD4AF37),
          size: 32,
        ),
      ),
    );
  }

  // Profile screen edit button
  Widget _buildProfileScreenEditButton() {
    return Center(
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: widget.onEdit ?? () {},
          icon: const Icon(Icons.edit, color: Colors.white),
          label: const Text(
            'Edit Profile',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              fontFamily: 'Poppins',
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
      ),
    );
  }

  void _showBlockDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Block User',
          style: TextStyle(fontFamily: 'Poppins'),
        ),
        content: Text(
          'Are you sure you want to block ${widget.profile.name}?',
          style: const TextStyle(fontFamily: 'Poppins'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(fontFamily: 'Poppins'),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Block', style: TextStyle(fontFamily: 'Poppins')),
          ),
        ],
      ),
    );
  }

  void _showReportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Report User',
          style: TextStyle(fontFamily: 'Poppins'),
        ),
        content: Text(
          'Why are you reporting ${widget.profile.name}?',
          style: const TextStyle(fontFamily: 'Poppins'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(fontFamily: 'Poppins'),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text(
              'Report',
              style: TextStyle(fontFamily: 'Poppins'),
            ),
          ),
        ],
      ),
    );
  }
}