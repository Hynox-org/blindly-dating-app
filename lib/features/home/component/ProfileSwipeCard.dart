import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart'; // ✅ Added
import 'dart:ui';

class UserProfile {
  final String id;
  final String name;
  final int age;
  final double distance;
  final String bio;
  final String? subTitle;
  final List<String> imageUrls;

  // Basic Info
  final String height;
  final String activityLevel;
  final String education;
  final String school;
  final String gender;
  final String religion;
  final String zodiac;
  final String drinking;
  final String smoking;
  final String politics;
  final String kids;
  final String hometown;
  final String workCompany;

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
    this.subTitle,
    required this.imageUrls,
    required this.height,
    required this.activityLevel,
    required this.education,
    required this.school,
    required this.gender,
    required this.religion,
    required this.zodiac,
    required this.drinking,
    required this.smoking,
    required this.politics,
    required this.kids,
    required this.hometown,
    required this.workCompany,
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
              child: SingleChildScrollView(
                controller: _scrollController,
                child: Column(
                  children: [
                    // ============ IMAGE 1 ============
                    _buildImageSection(0, cardHeight: constraints.maxHeight),
                    const SizedBox(height: 12),
                    // ============ ABOUT ME SECTION ============
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _buildAboutMeSection(),
                    ),
                    const SizedBox(height: 16),
                    // ============ BIO SECTION ============
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _buildBioSection(),
                    ),
                    const SizedBox(height: 16),
                    // ============ IMAGE 2 ============
                    _buildImageSection(1),
                    const SizedBox(height: 16),
                    // ============ RELATIONSHIP SECTION ============
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _buildRelationshipSection(),
                    ),
                    const SizedBox(height: 16),
                    // ============ LOOKING FOR SECTION ============
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _buildLookingForSection(),
                    ),
                    const SizedBox(height: 16),
                    // ============ HEART SECTION ============
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _buildHeartSection(),
                    ),
                    const SizedBox(height: 16),
                    // ============ INTERESTS SECTION ============
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _buildInterestsSection(),
                    ),
                    const SizedBox(height: 16),
                    // ============ IMAGE 3 ============
                    _buildImageSection(2),
                    const SizedBox(height: 16),
                    // ============ CAUSES SECTION ============
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _buildCausesSection(),
                    ),
                    const SizedBox(height: 16),
                    // ============ LANGUAGES SECTION ============
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _buildLanguagesSection(),
                    ),
                    const SizedBox(height: 16),
                    // ============ LOCATION SECTION ============
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _buildLocationSection(),
                    ),
                    const SizedBox(height: 16),
                    // ============ SPOTIFY SECTION ============
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _buildSpotifySection(),
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

  Widget _buildBioSection() {
    final colorScheme = Theme.of(context).colorScheme;
    if (widget.profile.bio.isEmpty) return const SizedBox.shrink();

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
            widget.profile.bio.isNotEmpty
                ? widget.profile.bio
                : "Ask me about my bio!", // ✅ Dynamic Bio
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

  Widget _buildRelationshipSection() {
    final colorScheme = Theme.of(context).colorScheme;
    // TODO: Add dynamic field check if needed, currently hardcoded text in fallback
    // For now we assume if lookingFor is empty we might strictly hide it?
    // But design seemed to have a quote. We'll leave it unless explicitly empty.

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
            widget.profile.lookingFor.isNotEmpty
                ? widget.profile.lookingFor
                : "Mutual respect, peace and the feeling that you can be your true self", // Verification fallback or hide?
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

    final double screenWidth = MediaQuery.of(context).size.width;
    final double scaleFactor =
        screenWidth / 400; // Base scale for a ~400px wide screen

    return [
      isAsset
          ? Image.asset(
              imageUrl,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
            )
          : CachedNetworkImage(
              // ✅ Optimized Image Loading
              imageUrl: imageUrl,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: Colors.grey[200],
                child: const Center(
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
              errorWidget: (context, url, error) => Image.asset(
                fallbackAsset,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
      if (isFirstImage) ...[
        // Share arrow (top right)
        Positioned(
          top: 16 * scaleFactor,
          right: 16 * scaleFactor,
          child: ClipOval(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                width: 48 * scaleFactor,
                height: 48 * scaleFactor,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.25),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withOpacity(0.15),
                    width: 1,
                  ),
                ),
                child: Icon(
                  Icons.share,
                  color: Colors.white,
                  size: 24 * scaleFactor,
                ),
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
            padding: EdgeInsets.all(20 * scaleFactor),
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
                    verifiedTag("Profile Verified", Colors.blue, scaleFactor),
                    SizedBox(height: 6 * scaleFactor),
                    verifiedTag("Photo Verified", Colors.black, scaleFactor),
                  ],
                ),
                SizedBox(height: 12 * scaleFactor),
                // Name
                Text(
                  "${widget.profile.name}, ${widget.profile.age}",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28 * scaleFactor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10 * scaleFactor),
                // Job + Distance
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.work_outline,
                          color: Colors.white,
                          size: 16 * scaleFactor,
                        ),
                        SizedBox(width: 6 * scaleFactor),
                        Text(
                          widget.profile.subTitle ??
                              "UI/UX Designer", // ✅ Use passed subtitle or fallback
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13 * scaleFactor,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 6 * scaleFactor),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          color: Colors.white,
                          size: 16 * scaleFactor,
                        ),
                        SizedBox(width: 6 * scaleFactor),
                        Text(
                          "${widget.profile.distance.toStringAsFixed(1)} miles away",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13 * scaleFactor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 22 * scaleFactor),
                // Gold buttons + scores
                Row(
                  children: [
                    goldButton(loveChatIcon(scaleFactor), scaleFactor),
                    const Spacer(),
                    scoreBox(scaleFactor),
                    const Spacer(),
                    goldButton(
                      Icon(
                        Icons.star,
                        color: const Color(0xFFD4AF37),
                        size: 28 * scaleFactor,
                      ),
                      scaleFactor,
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

  Widget verifiedTag(String text, Color bg, double scaleFactor) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 12 * scaleFactor,
        vertical: 6 * scaleFactor,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20 * scaleFactor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.verified_user,
            size: 18 * scaleFactor,
            color: Colors.white,
          ),
          SizedBox(width: 6 * scaleFactor),
          Text(
            text,
            style: TextStyle(
              color: Colors.white,
              fontSize: 12 * scaleFactor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget goldButton(Widget icon, double scaleFactor) {
    return Container(
      height: 58 * scaleFactor,
      width: 58 * scaleFactor,
      decoration: BoxDecoration(
        color: const Color(0xFF414833),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 8 * scaleFactor,
            offset: Offset(0, 4 * scaleFactor),
          ),
        ],
      ),
      child: Center(child: icon),
    );
  }

  Widget scoreBox(double scaleFactor) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 18 * scaleFactor,
        vertical: 10 * scaleFactor,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22 * scaleFactor),
      ),
      child: Column(
        children: [
          Text(
            "Compatibility Score: 70%",
            style: TextStyle(
              fontSize: 12 * scaleFactor,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 4 * scaleFactor),
          Text(
            "Trust Score: 70%",
            style: TextStyle(
              fontSize: 12 * scaleFactor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget loveChatIcon(double scaleFactor) {
    return Container(
      width: 52 * scaleFactor,
      height: 52 * scaleFactor,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color.fromRGBO(65, 72, 51, 1),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(
            Icons.circle_outlined,
            color: const Color(0xFFD4AF37),
            size: 44 * scaleFactor,
          ),
          Positioned(
            top: 18 * scaleFactor,
            child: Icon(
              Icons.favorite,
              color: const Color(0xFFD4AF37),
              size: 14 * scaleFactor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutMeSection() {
    final colorScheme = Theme.of(context).colorScheme;
    final profile = widget.profile;

    List<Widget> tags = [];

    // Helper to add tag if value exists
    void addTag(String? value, IconData icon) {
      if (value != null && value.isNotEmpty && value != 'Ask me') {
        tags.add(_buildTag(icon, value));
      }
    }

    addTag(profile.height, Icons.height);
    addTag(profile.activityLevel, FontAwesomeIcons.dumbbell);
    addTag(profile.education, Icons.school_outlined);
    addTag(profile.school, Icons.school);

    // Work
    if (profile.subTitle != null && profile.subTitle!.isNotEmpty) {
      addTag(profile.subTitle, Icons.work_outline);
    } else if (profile.workCompany.isNotEmpty) {
      addTag(profile.workCompany, Icons.work_outline);
    }

    addTag(profile.gender, Icons.face);
    addTag(profile.religion, FontAwesomeIcons.handsPraying);
    addTag(profile.zodiac, FontAwesomeIcons.solidSun);
    addTag(profile.smoking, Icons.smoking_rooms_outlined);
    addTag(profile.drinking, Icons.local_bar_outlined);
    addTag(profile.politics, Icons.account_balance);
    addTag(profile.kids, Icons.child_care);
    addTag(profile.hometown, Icons.home_outlined);

    // Languages
    if (profile.languages.isNotEmpty) {
      for (var lang in profile.languages) {
        if (lang != 'English') {
          // Optional filter
          addTag(lang, Icons.translate);
        }
      }
    }

    if (tags.isEmpty) return const SizedBox.shrink();

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
          Wrap(spacing: 8, runSpacing: 12, children: tags),
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

  Widget _buildLookingForSection() {
    final colorScheme = Theme.of(context).colorScheme;
    final profile = widget.profile;

    if (profile.lookingFor.isEmpty && profile.lookingForTags.isEmpty) {
      return const SizedBox.shrink();
    }

    List<Widget> tags = [];
    if (profile.lookingFor.isNotEmpty) {
      tags.add(_buildTag(null, profile.lookingFor));
    }
    for (var tag in profile.lookingForTags) {
      tags.add(_buildTag(null, tag));
    }

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
          Wrap(spacing: 8, runSpacing: 12, children: tags),
        ],
      ),
    );
  }

  Widget _buildHeartSection() {
    final colorScheme = Theme.of(context).colorScheme;
    final profile = widget.profile;

    if (profile.quickestWay.isEmpty) return const SizedBox.shrink();

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
            '“${profile.quickestWay}”',
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
        ],
      ),
    );
  }

  Widget _buildInterestsSection() {
    final colorScheme = Theme.of(context).colorScheme;
    final profile = widget.profile;

    if (profile.hobbies.isEmpty) return const SizedBox.shrink();

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
            children: profile.hobbies.map((interest) {
              // Map interest to icon if possible, else default
              return _buildTag(Icons.star_outline, interest);
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCausesSection() {
    final colorScheme = Theme.of(context).colorScheme;
    if (widget.profile.causes.isEmpty) return const SizedBox.shrink();

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
            children: widget.profile.causes.map((cause) {
              return _buildTag(null, cause);
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguagesSection() {
    final colorScheme = Theme.of(context).colorScheme;
    if (widget.profile.languages.isEmpty) return const SizedBox.shrink();

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
            children: widget.profile.languages.map((lang) {
              return _buildTag(Icons.translate, lang);
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationSection() {
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
                widget.profile.location.isNotEmpty
                    ? widget.profile.location
                    : 'Nearby',
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

  Widget _buildSpotifySection() {
    final colorScheme = Theme.of(context).colorScheme;
    if (widget.profile.spotifyArtists.isEmpty) return const SizedBox.shrink();

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
            children: widget.profile.spotifyArtists.map((artist) {
              return _buildTag(null, artist);
            }).toList(),
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
