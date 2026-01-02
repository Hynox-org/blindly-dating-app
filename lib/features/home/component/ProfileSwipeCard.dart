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
  final VoidCallback? onBlock;
  final VoidCallback? onReport;
  final VoidCallback? onLike;

  const ProfileSwipeCard({
    super.key,
    required this.profile,
    required this.horizontalThreshold,
    required this.verticalThreshold,
    this.onBlock,
    this.onReport,
    this.onLike,
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
  @override
Widget build(BuildContext context) {
  return Transform(
    // ⭐ Anchor point at BOTTOM - makes top move first
    alignment: Alignment.bottomCenter,
    transform: Matrix4.identity()
      ..setEntry(3, 2, 0.001) // perspective
      ..rotateZ(widget.horizontalThreshold * 0.001),// Gentle rotation, top moves first
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
              // ... rest of your content (keep everything else the same)
              _buildImageSection(0),
          // ============ CONTENT SECTION 1 ============
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Self Summary
                  const Text(
                    'My self Summary',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                      color: Color.fromRGBO(0, 0, 0, 1),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.profile.summary,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      fontFamily: 'Poppins',
                      color: Color.fromRGBO(0, 0, 0, 1),
                    ),
                  ),
                  const SizedBox(height: 20),

                  _buildKudosBadge(),
                  const SizedBox(height: 15),

                  // Relationship Great
                  const Text(
                    'What makes a relationship great is',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Poppins',
                      color: Color.fromRGBO(0, 0, 0, 1),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.profile.lookingFor,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      fontFamily: 'Poppins',
                      color: Color.fromRGBO(0, 0, 0, 1),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // My View
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

            // ============ IMAGE 2 ============
            _buildImageSection(1),

            // ============ CONTENT SECTION 2 ============
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // I'm Chasing For
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
                  const SizedBox(height: 20),

                  _buildKudosBadge(),
                  const SizedBox(height: 15),

                  // Quickest Way
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'The quickest way to my heart is',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Poppins',
                            color: Color.fromRGBO(0, 0, 0, 1),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.profile.quickestWay,
                          style: const TextStyle(
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                            fontFamily: 'Poppins',
                            color: Color.fromRGBO(0, 0, 0, 1),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  _buildKudosBadge(),
                  const SizedBox(height: 15),

                  // My Hobbies
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

            // ============ IMAGE 3 ============
            _buildImageSection(2),

            // ============ CONTENT SECTION 3 ============
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // My Causes
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
                  const SizedBox(height: 25),

                  _buildKudosBadge(),
                  const SizedBox(height: 15),

                  // Simple Pleasures
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'My simple and pleasure are',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Poppins',
                            color: Color.fromRGBO(0, 0, 0, 1),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.profile.simplePleasure,
                          style: const TextStyle(
                            fontSize: 14,
                            fontFamily: 'Poppins',
                            color: Color.fromRGBO(0, 0, 0, 1),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  _buildKudosBadge(),
                  const SizedBox(height: 15),

                  // Languages
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
                              color: Color.fromRGBO(0, 0, 0, 1),
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              lang,
                              style: const TextStyle(
                                fontSize: 13,
                                fontFamily: 'Poppins',
                                color: Color.fromRGBO(0, 0, 0, 1),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  // Location
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
                  const SizedBox(height: 20),

                  // Spotify Artists
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
                  const SizedBox(height: 30),

                  // ============ ACTION BUTTONS ============
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left side: Pass/Nope button (X mark)
                      GestureDetector(
                        onTap: widget.onBlock ?? () {
                          _showBlockDialog();
                        },
                        child: Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            color: const Color.fromRGBO(65, 72, 51, 1),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 8,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Color(0xFFD4AF37),
                            size: 44,
                          ),
                        ),
                      ),

                      // Center: Super Like button (Star)
                      GestureDetector(
                        onTap: widget.onReport ?? () {
                          _showReportDialog();
                        },
                        child: Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            color: const Color.fromRGBO(65, 72, 51, 1),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 8,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.star,
                            color: Color(0xFFD4AF37),
                            size: 44,
                          ),
                        ),
                      ),

                      // Right side: Like button (Heart)
                      GestureDetector(
                        onTap: widget.onLike ?? () {},
                        child: Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            color: const Color.fromRGBO(65, 72, 51, 1),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color.fromRGBO(65, 72, 51, 0.4),
                                blurRadius: 12,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.favorite,
                            color: Color(0xFFD4AF37),
                            size: 44,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // ============ TEXT LABELS ============
                  Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: const [
                        Text(
                          'Block',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Poppins',
                            color: Color.fromRGBO(0, 0, 0, 1),
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Report',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Poppins',
                            color: Color.fromRGBO(0, 0, 0, 1),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  )
  );
}

  // Helper method to build image sections
  Widget _buildImageSection(int index) {
    if (index >= widget.profile.imageUrls.length)
      return const SizedBox.shrink();

    return Stack(
      children: [
        // Image
        Image.network(
          widget.profile.imageUrls[index],
          width: double.infinity,
          height: 400,
          fit: BoxFit.cover,
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
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.emoji_emotions_outlined,
            size: 20,
            color: Color.fromRGBO(0, 0, 0, 1),
          ),
        ),
        const SizedBox(width: 10),
        const Text(
          'Kudos',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            fontFamily: 'Poppins',
            color: Color.fromRGBO(0, 0, 0, 1),
          ),
        ),
      ],
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
