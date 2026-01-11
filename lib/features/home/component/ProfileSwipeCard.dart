import 'package:flutter/material.dart';

// -----------------------------------------------------------------------------
// 1. MODEL
// -----------------------------------------------------------------------------
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

// -----------------------------------------------------------------------------
// 2. SWIPE WRAPPER
// -----------------------------------------------------------------------------
class ProfileSwipeCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Transform(
      // Keep the bottom pivot for rotation style
      alignment: Alignment.bottomCenter,
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.001)
        ..rotateZ(horizontalThreshold * 0.001),
      child: ProfileCard(
        profile: profile,
        isSwipeMode: true,
        onBlock: onBlock,
        onReport: onReport,
        onLike: onLike,
        tags: const ['Home', 'Discovery'],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// 3. FULL SCREEN IMAGE PROFILE CARD
// -----------------------------------------------------------------------------
class ProfileCard extends StatelessWidget {
  final UserProfile profile;
  final bool isSwipeMode;
  final List<String> tags;
  final VoidCallback? onBlock;
  final VoidCallback? onReport;
  final VoidCallback? onLike;

  const ProfileCard({
    super.key,
    required this.profile,
    this.isSwipeMode = false,
    this.tags = const [],
    this.onBlock,
    this.onReport,
    this.onLike,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black, // Dark background
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // 1. FULL SCREEN IMAGE
            Positioned.fill(
              child: profile.imageUrls.isNotEmpty
                  ? Image.network(
                      profile.imageUrls[0],
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          Container(color: Colors.grey[800]),
                    )
                  : Container(
                      color: Colors.grey[800],
                      child: const Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 80,
                      ),
                    ),
            ),

            // 2. GRADIENT OVERLAY (Bottom)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                height: 300,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.9)],
                    stops: const [0.0, 0.8],
                  ),
                ),
              ),
            ),

            // 3. TEXT CONTENT (Bottom)
            Positioned(
              left: 20,
              right: 20,
              bottom: 20, // Bottom padding
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // NAME & AGE
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${profile.name}, ${profile.age}',
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(color: Colors.black45, blurRadius: 10),
                            ],
                          ),
                        ),
                      ),
                      // Optional "Verified" or indicator
                    ],
                  ),

                  const SizedBox(height: 8),

                  // WORK/EDUCATION & DISTANCE
                  _buildIconText(Icons.work_outline, profile.education),
                  const SizedBox(height: 4),
                  _buildIconText(
                    Icons.location_on_outlined,
                    '${profile.distance} km away',
                  ),
                  const SizedBox(height: 16),

                  // DOWN CHEVRON / HINT
                  Center(
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      color: Colors.white.withOpacity(0.6),
                      size: 30,
                    ),
                  ),
                ],
              ),
            ),

            // 4. ACTION BUTTONS OVERLAY (Optional - only if intended to be ON the card)
            // Bumble usually keeps actions separate or floating.
            // Since we restricted the card swipe, the existing separate buttons in UI might be handled by parent.
            // But if we want buttons ON the card like previous design:
            /*
            if (isSwipeMode) 
                 Positioned(bottom: 20, right: 20, ...)
            */
            // Keeping it clean as per "only the main profile image" request.
          ],
        ),
      ),
    );
  }

  Widget _buildIconText(IconData icon, String text) {
    if (text.isEmpty) return const SizedBox.shrink();

    return Row(
      children: [
        Icon(icon, color: Colors.white.withOpacity(0.9), size: 16),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: Colors.white.withOpacity(0.9),
            shadows: const [Shadow(color: Colors.black45, blurRadius: 4)],
          ),
        ),
      ],
    );
  }
}
