import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
              child: SingleChildScrollView(
                controller: _scrollController,
                child: Column(
                  children: [
                    // ============ IMAGE 1 ============
                    _buildImageSection(0, cardHeight: constraints.maxHeight),
                    const SizedBox(height: 12),
                    // ============ STATIC ABOUT ME SECTION ============
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _buildHardcodedAboutMeSection(),
                    ),
                    const SizedBox(height: 16),
                    // ============ STATIC BIO SECTION ============
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _buildHardcodedBioSection(),
                    ),
                    const SizedBox(height: 16),
                    // ============ IMAGE 2 ============
                    _buildImageSection(1),
                    const SizedBox(height: 16),
                    // ============ STATIC RELATIONSHIP SECTION ============
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _buildHardcodedRelationshipSection(),
                    ),
                    const SizedBox(height: 16),
                    // ============ STATIC LOOKING FOR SECTION ============
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _buildHardcodedLookingForSection(),
                    ),
                    const SizedBox(height: 16),
                    // ============ STATIC HEART SECTION ============
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _buildHardcodedHeartSection(),
                    ),
                    const SizedBox(height: 16),
                    // ============ STATIC INTERESTS SECTION ============
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _buildHardcodedInterestsSection(),
                    ),
                    const SizedBox(height: 16),
                    // ============ IMAGE 3 ============
                    _buildImageSection(2),
                    const SizedBox(height: 16),
                    // ============ STATIC CAUSES SECTION ============
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _buildHardcodedCausesSection(),
                    ),
                    const SizedBox(height: 16),
                    // ============ STATIC LANGUAGES SECTION ============
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _buildHardcodedLanguagesSection(),
                    ),
                    const SizedBox(height: 16),
                    // ============ STATIC LOCATION SECTION ============
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _buildHardcodedLocationSection(),
                    ),
                    const SizedBox(height: 16),
                    // ============ STATIC SPOTIFY SECTION ============
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _buildHardcodedSpotifySection(),
                    ),
                    const SizedBox(height: 32),
                    // ============ ACTION BUTTONS ============
                    _buildActionButtons(),
                    const SizedBox(height: 32),
                    // ============ BLOCK / REPORT ============
                    _buildBlockReportButtons(),
                    const SizedBox(height: 48),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHardcodedBioSection() {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 2), // Small shim for shadow
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bio',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "Need Netflix recommendations? I'm looking for someone who's down for deep conversations, spontaneous weekend plans, and cozy nights in.",
            style: TextStyle(
              fontSize: 14,
              color: colorScheme.onSurfaceVariant,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Divider(
            color: colorScheme.outlineVariant.withOpacity(0.5),
            thickness: 1,
            height: 1,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Image.asset(
                'assets/icons/speech-bubble-icon.png',
                width: 24,
                height: 24,
                color: colorScheme.onSurface,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.chat_bubble_outline,
                    size: 24,
                    color: colorScheme.onSurface,
                  );
                },
              ),
              const SizedBox(width: 12),
              Text(
                'Kudos',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHardcodedRelationshipSection() {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 2), // Small shim for shadow
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What makes a relationship great is',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "“Mutual respect, peace and the feeling that you can be your true self”",
            style: TextStyle(
              fontSize: 14,
              color: colorScheme.onSurfaceVariant,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Divider(
            color: colorScheme.outlineVariant.withOpacity(0.5),
            thickness: 1,
            height: 1,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Image.asset(
                'assets/icons/speech-bubble-icon.png',
                width: 24,
                height: 24,
                color: colorScheme.onSurface,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.chat_bubble_outline,
                    size: 24,
                    color: colorScheme.onSurface,
                  );
                },
              ),
              const SizedBox(width: 12),
              Text(
                'Kudos',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ],
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
    final String imageUrl = widget.profile.imageUrls[index];
    final bool isAsset = imageUrl.startsWith('assets/');

    // Fallback asset based on gender
    String fallbackAsset = 'assets/defaults/men1.jpeg';
    if (widget.profile.gender == 'Female') {
      fallbackAsset = 'assets/defaults/women1.jpeg';
    }

    return [
      isAsset
          ? Image.asset(
              imageUrl,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
            )
          : Image.network(
              imageUrl,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Image.asset(
                  fallbackAsset,
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
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

  Widget _buildHardcodedAboutMeSection() {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'About Me',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 12,
            children: [
              _buildTag(Icons.height, "170 cm"),
              _buildTag(FontAwesomeIcons.dumbbell, "Active"),
              _buildTag(Icons.school_outlined, "Post graduate"),
              _buildTag(Icons.face, "Men"),
              _buildTag(FontAwesomeIcons.om, "Hindu"),
              _buildTag(FontAwesomeIcons.solidSun, "Taurus"),
              _buildTag(Icons.smoking_rooms_outlined, "Yes"),
              _buildTag(Icons.local_bar_outlined, "Yes"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTag(IconData? icon, String text) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.02),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: colorScheme.onSurface),
            const SizedBox(width: 8),
          ],
          Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHardcodedLookingForSection() {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "I'm Looking for",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 12,
            children: [
              _buildTag(null, "Fun, casual dates"),
              _buildTag(null, "Ambition"),
              _buildTag(null, "Confidence"),
              _buildTag(null, "Emotional intelligence"),
              _buildTag(null, "Long term relationship"),
              _buildTag(null, "Loyalty"),
              _buildTag(null, "Humility"),
              _buildTag(null, "Humor"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHardcodedHeartSection() {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 2), // Small shim for shadow
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'The quickest way to my heart is',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "“Showing up with pure intentions - not just pretty words”",
            style: TextStyle(
              fontSize: 14,
              color: colorScheme.onSurfaceVariant,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Divider(
            color: colorScheme.outlineVariant.withOpacity(0.5),
            thickness: 1,
            height: 1,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Image.asset(
                'assets/icons/speech-bubble-icon.png',
                width: 24,
                height: 24,
                color: colorScheme.onSurface,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.chat_bubble_outline,
                    size: 24,
                    color: colorScheme.onSurface,
                  );
                },
              ),
              const SizedBox(width: 12),
              Text(
                'Kudos',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHardcodedInterestsSection() {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'My Interests',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 12,
            children: [
              _buildTag(Icons.accessibility_new, "Dance"),
              _buildTag(Icons.sports_cricket, "Cricket"),
              _buildTag(Icons.local_bar, "Whiskey"),
              _buildTag(Icons.restaurant_menu, "Bar"),
              _buildTag(Icons.fastfood, "KFC"),
              _buildTag(Icons.sports_soccer, "Football"),
              _buildTag(Icons.beach_access, "Beaches"),
              _buildTag(Icons.music_note, "Arabic"),
              _buildTag(Icons.set_meal, "Fish"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHardcodedCausesSection() {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'My causes and communites',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 12,
            children: [
              _buildTag(null, "Reproductive rights"),
              _buildTag(null, "LGBTQ"),
              _buildTag(null, "Feminism"),
              _buildTag(null, "Neurodiversity"),
              _buildTag(null, "End religious hate"),
              _buildTag(null, "Human rights"),
              _buildTag(null, "Environmentalism"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHardcodedLanguagesSection() {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Languages',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 12,
            children: [
              _buildTag(Icons.translate, "Tamil"),
              _buildTag(Icons.translate, "English"),
              _buildTag(Icons.translate, "Malayalam"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHardcodedLocationSection() {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'My location',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                size: 24,
                color: colorScheme.onSurface,
              ),
              const SizedBox(width: 12),
              Text(
                'Coimbatore',
                style: TextStyle(
                  fontSize: 16,
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHardcodedSpotifySection() {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'My top artist on spotify',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 12,
            children: [
              _buildTag(null, "Wiz kalifha"),
              _buildTag(null, "Harris jayaraj"),
              _buildTag(null, "AR Rahman"),
              _buildTag(null, "Benny dayal"),
              _buildTag(null, "XXX tentaction"),
              _buildTag(null, "Vedan"),
              _buildTag(null, "Arijit singh"),
              _buildTag(null, "Snoop dog"),
              _buildTag(null, "Benny"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 40),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(40),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildCircleButton(
            icon: Icons.close,
            color: const Color(0xFF414833),
            iconColor: const Color(0xFFD4AF37),
          ),
          _buildCircleButton(
            icon: Icons.star,
            color: const Color(0xFF414833),
            iconColor: const Color(0xFFD4AF37),
          ),
          _buildCircleButton(
            icon: Icons.favorite,
            color: const Color(0xFF414833),
            iconColor: const Color(0xFFD4AF37),
          ),
        ],
      ),
    );
  }

  Widget _buildCircleButton({
    required IconData icon,
    required Color color,
    required Color iconColor,
  }) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: Icon(icon, color: iconColor, size: 28),
    );
  }

  Widget _buildBlockReportButtons() {
    return Column(
      children: [
        TextButton(
          onPressed: () {},
          child: const Text(
            'Block',
            style: TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: () {},
          child: const Text(
            'Report',
            style: TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
