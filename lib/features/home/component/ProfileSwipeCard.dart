import 'package:flutter/material.dart';
import 'package:blindly_dating_app/l10n/app_localizations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../core/widgets/voice_playback_widget.dart';
import '../../onboarding/domain/models/lifestyle_chip_model.dart';
import '../../onboarding/domain/models/profile_prompt_model.dart'; // ✅ Added Prompts
import 'package:cached_network_image/cached_network_image.dart'; // ✅ Added
import 'dart:ui';
import '../../../../core/utils/share_utils.dart'; // Add ShareUtils
import '../../discovery/presentation/screens/compatibility_explanation_screen.dart';

class UserProfile {
  final String id;
  final String name;
  final int age;
  final double distance;
  final String bio;
  final String? subTitle;
  final List<String> imageUrls;
  final String? voiceIntroUrl;
  final int? voiceIntroDuration;

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
  final List<String> lookingForModes;
  final String quickestWay;
  final List<LifestyleChip> lifestyleItems; // ✅ Added lifestyle items
  final List<ProfilePrompt> prompts; // ✅ Added Prompts
  final List<String> causes;

  // Additional Details
  final String simplePleasure;
  final List<String> languages;
  final String location;
  final List<String> spotifyArtists;
  final bool isVerified;
  final String verificationLevel;
  final int trustScore; // ✅ Added Trust Score

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
    required this.lookingForModes,
    required this.quickestWay,
    this.prompts = const [], // Default to empty
    this.lifestyleItems = const [], // ✅ Optional, default empty list
    required this.causes,
    required this.simplePleasure,
    required this.languages,
    required this.location,
    required this.spotifyArtists,
    this.voiceIntroUrl,
    this.voiceIntroDuration,
    this.isVerified = false,
    this.verificationLevel = 'unverified',
    this.trustScore = 0, // ✅ Default to 0
  });
}

enum ProfileCardMode { swipe, discovery, preview }

class ProfileSwipeCard extends StatefulWidget {
  final UserProfile profile;
  final double horizontalThreshold;
  final double verticalThreshold;

  // ✅ Mode determines button layout & interactions
  final ProfileCardMode mode;

  // Callbacks
  final VoidCallback? onBlock; // Used for "Pass" or "Not for me"
  final VoidCallback? onReport;
  final VoidCallback? onLike;
  final VoidCallback? onSuperLike;
  final VoidCallback? onPause;
  final VoidCallback? onEdit;
  final VoidCallback? onUndo;

  // Track the result of an action ('none', 'liked', 'passed')
  final String swipeState;

  const ProfileSwipeCard({
    super.key,
    required this.profile,
    required this.horizontalThreshold,
    required this.verticalThreshold,
    this.mode = ProfileCardMode.swipe, // Default to Swipe
    this.swipeState = 'none',
    this.onBlock,
    this.onReport,
    this.onLike,
    this.onSuperLike,
    this.onPause,
    this.onEdit,
    this.onUndo,
  });

  @override
  State<ProfileSwipeCard> createState() => _ProfileSwipeCardState();
}

class _ProfileSwipeCardState extends State<ProfileSwipeCard> {
  AppLocalizations get l10n => AppLocalizations.of(context);


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

  bool _isLookingForEmpty() => _isListEmpty(widget.profile.lookingForModes);
  bool _isInterestsEmpty() => _isListEmpty(widget.profile.hobbies);
  bool _isLifestyleEmpty() => widget.profile.lifestyleItems.isEmpty; // ✅ Added
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
          color: Colors
              .transparent, // ✅ Allow parent container to define background color
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Container(
              color: Colors
                  .white, // ✅ Solid white background for the scrolling card content
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: SingleChildScrollView(
                  controller: _scrollController,
                  child: Column(
                    children: [
                      // ============ IMAGE 1 ============
                      _buildImageSection(0, cardHeight: constraints.maxHeight),
                      if (widget.profile.voiceIntroUrl != null) ...[
                        const SizedBox(height: 12),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: _buildVoiceIntroSection(),
                        ),
                      ],
                      const SizedBox(height: 12),
                      // ============ ABOUT ME SECTION ============
                      if (!_isAboutMeEmpty()) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: _buildAboutMeSection(),
                        ),
                        const SizedBox(height: 16),
                      ],
                      // ============ BIO SECTION ============
                      if (widget.profile.bio.isNotEmpty) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: _buildBioSection(),
                        ),
                        const SizedBox(height: 16),
                      ],
                      // ============ IMAGE 2 ============
                      if (widget.profile.imageUrls.length > 1) ...[
                        _buildImageSection(1),
                        const SizedBox(height: 16),
                      ],
                      // ============ KUDOS SECTION ============
                      if (widget.profile.prompts.any(
                        (p) => p.userResponse.isNotEmpty,
                      )) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: _buildKudosSection(),
                        ),
                        const SizedBox(height: 16),
                      ],
                      // ============ LOOKING FOR SECTION ============
                      if (!_isLookingForEmpty()) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: _buildLookingForSection(),
                        ),
                        const SizedBox(height: 16),
                      ],
                      // ============ HEART SECTION ============
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: _buildHeartSection(),
                      ),
                      const SizedBox(height: 16),
                      // ============ INTERESTS SECTION ============
                      if (!_isInterestsEmpty()) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: _buildInterestsSection(),
                        ),
                        const SizedBox(height: 16),
                      ],
                      // ============ LIFESTYLE SECTION ============
                      if (!_isLifestyleEmpty()) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: _buildLifestyleSection(),
                        ),
                        const SizedBox(height: 16),
                      ],
                      // ============ IMAGE 3 ============
                      if (widget.profile.imageUrls.length > 2) ...[
                        _buildImageSection(2),
                        const SizedBox(height: 16),
                      ],
                      // ============ CAUSES SECTION ============
                      if (!_isCausesEmpty()) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: _buildCausesSection(),
                        ),
                        const SizedBox(height: 16),
                      ],
                      // ============ LANGUAGES SECTION ============
                      if (!_isLanguagesEmpty()) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: _buildLanguagesSection(),
                        ),
                        const SizedBox(height: 16),
                      ],
                      // ============ LOCATION SECTION ============
                      if (!_isLocationEmpty()) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: _buildLocationSection(),
                        ),
                        const SizedBox(height: 16),
                      ],
                      // ============ SPOTIFY SECTION ============
                      if (!_isSpotifyEmpty()) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: _buildSpotifySection(),
                        ),
                        const SizedBox(height: 16),
                      ],
                      const SizedBox(height: 16),
                      // ============ COMPATIBILITY ============
                      // Scoring a pair costs an LLM call, so it sits behind a
                      // button rather than running for every profile shown.
                      if (widget.mode != ProfileCardMode.preview) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: compatibilityButton(),
                        ),
                        const SizedBox(height: 16),
                      ],
                      // ============ ACTION BUTTONS ============
                      _buildActionButtons(),
                      const SizedBox(height: 32),
                      // ============ BLOCK / REPORT ============
                      // Only show block/report in Swipe or Discovery modes, not Preview
                      if (widget.mode != ProfileCardMode.preview) ...[
                        _buildBlockReportButtons(),
                        const SizedBox(height: 48),
                      ] else
                        const SizedBox(height: 48),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildVoiceIntroSection() {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.08),
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
            l10n.voiceIntro,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          VoicePlaybackWidget(
            url: widget.profile.voiceIntroUrl!,
            durationSeconds: widget.profile.voiceIntroDuration ?? 0,
          ),
        ],
      ),
    );
  }

  // ... (Other build methods remain unchanged: _buildBioSection, _buildRelationshipSection, etc.)

  // ... (Keep existing helper methods like _buildImageSection, _buildTag, etc. UNCHANGED until _buildActionButtons)

  // ... (Re-inserting unmodified methods to maintain context if needed, but I will skip to _buildActionButtons for the replacement)

  // NOTE: I am relying on the tool to replace the block correctly.
  // I will just replace the build method and the _buildActionButtons method.
  // Wait, the tool requires me to replace a contiguous block.
  // The provided StartLine 78 covers the class definition.
  // I need to be careful not to delete the methods in between.
  // The 'replacement content' must match the target content logic.
  // Actually, rewriting the WHOLE class is safer given the StartLine/EndLine constraint if I want to change the constructor AND the build method AND the action buttons.
  // But that is huge.
  // Let's try to do it in chunks? No, tool says "Use this tool ONLY when you are making a SINGLE CONTIGUOUS block of edits".
  // The class fields + constructor are at the top.
  // The _buildActionButtons is at the bottom.
  // I'll use `multi_replace_file_content` instead to change multiple parts safely.
  // Changing tool to multi_replace_file_content.

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
            color: colorScheme.shadow.withValues(alpha: 0.08),
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
            l10n.bioTitle,
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
                : l10n.askAboutMyBio, // ✅ Dynamic Bio
            style: TextStyle(
              fontSize: 14,
              color: colorScheme.onSurfaceVariant,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Divider(
            color: colorScheme.outlineVariant.withValues(alpha: 0.5),
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
                l10n.kudos,
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

  Widget _buildKudosSection() {
    final colorScheme = Theme.of(context).colorScheme;
    final profile = widget.profile;

    if (profile.prompts.isEmpty) return const SizedBox.shrink();

    // Show up to 2 prompts
    final displayPrompts = profile.prompts.take(2).toList();

    // Build widgets for each prompt
    List<Widget> promptWidgets = [];
    for (int i = 0; i < displayPrompts.length; i++) {
      final prompt = displayPrompts[i];
      if (prompt.userResponse.isEmpty) continue; // Skip empty answers

      promptWidgets.add(
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              prompt.promptQuestion ?? l10n.aPrompt,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              prompt.userResponse,
              style: TextStyle(
                fontSize: 14,
                color: colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
            ),
            if (i < displayPrompts.length - 1) ...[
              const SizedBox(height: 16),
              Divider(
                color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                thickness: 1,
                height: 1,
              ),
              const SizedBox(height: 16),
            ],
          ],
        ),
      );
    }

    if (promptWidgets.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 2), // Small shim for shadow
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...promptWidgets,
          const SizedBox(height: 16),
          Divider(
            color: colorScheme.outlineVariant.withValues(alpha: 0.5),
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
                l10n.kudos,
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
            child: AspectRatio(
              aspectRatio: 3 / 4,
              child: Stack(
                fit: StackFit.expand,
                children: _buildImageStack(index),
              ),
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
        if (widget.mode == ProfileCardMode.swipe)
          Positioned(
            top: 16 * scaleFactor,
            right: 16 * scaleFactor,
            child: GestureDetector(
              onTap: () {
                ShareUtils.shareProfile(context, widget.profile);
              },
              child: ClipOval(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    width: 48 * scaleFactor,
                    height: 48 * scaleFactor,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.25),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.15),
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
          ),
        // Bottom overlay
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: 16 * scaleFactor,
              vertical: 12 * scaleFactor,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.9),
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.profile.isVerified &&
                        widget.profile.verificationLevel ==
                            'full_verified') ...[
                      verifiedTag(l10n.profileVerified, Colors.blue, scaleFactor),
                      SizedBox(height: 4 * scaleFactor),
                      // Verified "Photo Verified" is blue, as requested ("show the two badges in bluue colour profile verified and photo verified")
                      verifiedTag(l10n.photoVerified, Colors.blue, scaleFactor),
                    ] else ...[
                      // "if they are noot verified the show a black badge mentioning not verified"
                      verifiedTag(l10n.notVerified, Colors.black, scaleFactor),
                    ],
                    if (widget.profile.trustScore > 0) ...[
                      SizedBox(height: 4 * scaleFactor),
                      _buildTrustScoreBadge(scaleFactor),
                    ],
                  ],
                ),
                SizedBox(height: 8 * scaleFactor),
                // Name
                Text(
                  "${widget.profile.name}, ${widget.profile.age}",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22 * scaleFactor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 6 * scaleFactor),
                // Job + Distance
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.work_outline,
                          color: Colors.white,
                          size: 12 * scaleFactor,
                        ),
                        SizedBox(width: 4 * scaleFactor),
                        Text(
                          widget.profile.subTitle ??
                              "UI/UX Designer", // ✅ Use passed subtitle or fallback
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11 * scaleFactor,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4 * scaleFactor),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          color: Colors.white,
                          size: 12 * scaleFactor,
                        ),
                        SizedBox(width: 4 * scaleFactor),
                        Text(
                          l10n.milesAway(widget.profile.distance.toStringAsFixed(1)),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11 * scaleFactor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                if (widget.mode == ProfileCardMode.swipe) ...[
                  SizedBox(height: 16 * scaleFactor),
                  // Gold buttons + scores
                  Row(
                    children: [
                      GestureDetector(
                        onTap: widget.onLike,
                        child: goldButton(loveChatIcon(scaleFactor), scaleFactor),
                      ),
                      const Spacer(),
                      scoreBox(scaleFactor),
                      const Spacer(),
                      GestureDetector(
                        onTap: widget.onSuperLike,
                        child: goldButton(
                          Icon(
                            Icons.star,
                            color: const Color(0xFFD4AF37),
                            size: 20 * scaleFactor,
                          ),
                          scaleFactor,
                        ),
                      ),
                    ],
                  ),
                ],
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
        horizontal: 8 * scaleFactor,
        vertical: 4 * scaleFactor,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16 * scaleFactor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.verified_user,
            size: 14 * scaleFactor,
            color: Colors.white,
          ),
          SizedBox(width: 4 * scaleFactor),
          Text(
            text,
            style: TextStyle(
              color: Colors.white,
              fontSize: 10 * scaleFactor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrustScoreBadge(double scaleFactor) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 8 * scaleFactor,
        vertical: 4 * scaleFactor,
      ),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(16 * scaleFactor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.shield_outlined,
            size: 14 * scaleFactor,
            color: Colors.white,
          ),
          SizedBox(width: 4 * scaleFactor),
          Text(
            l10n.trustScore('${widget.profile.trustScore}'),
            style: TextStyle(
              color: Colors.white,
              fontSize: 10 * scaleFactor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget goldButton(Widget icon, double scaleFactor) {
    return Container(
      height: 44 * scaleFactor,
      width: 44 * scaleFactor,
      decoration: BoxDecoration(
        color: const Color(0xFF414833),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 6 * scaleFactor,
            offset: Offset(0, 2 * scaleFactor),
          ),
        ],
      ),
      child: Center(child: icon),
    );
  }

  Widget scoreBox(double scaleFactor) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 12 * scaleFactor,
        vertical: 6 * scaleFactor,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16 * scaleFactor),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Column(
          children: [
            // Compatibility used to be hardcoded to 70% here. It is a real
            // per-pair calculation now, so it lives behind the button below
            // the card rather than being asserted on every card.
            Text(
              l10n.trustScore('${widget.profile.trustScore}'),
              style: TextStyle(
                fontSize: 10 * scaleFactor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Entry point to the compatibility result. Tapping it is what triggers the
  /// scoring; nothing is computed for profiles the user never asks about.
  Widget compatibilityButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => CompatibilityExplanationScreen(
              targetProfileId: widget.profile.id,
              targetName: widget.profile.name,
            ),
          ),
        ),
        icon: const Icon(Icons.insights_outlined, size: 20),
        label: Text(
          l10n.seeHowYouMatch,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF414833),
          side: const BorderSide(color: Color(0xFF414833)),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      ),
    );
  }

  Widget loveChatIcon(double scaleFactor) {
    return Container(
      width: 38 * scaleFactor,
      height: 38 * scaleFactor,
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
            size: 32 * scaleFactor,
          ),
          Positioned(
            top: 13 * scaleFactor,
            child: Icon(
              Icons.favorite,
              color: const Color(0xFFD4AF37),
              size: 10 * scaleFactor,
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
    void addTag(String? value, IconData icon, {String? prefix}) {
      if (value != null && value.isNotEmpty && value != 'Ask me') {
        final displayText = prefix != null ? '$prefix $value' : value;
        tags.add(_buildTag(icon, displayText));
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

    // The following tags are removed as per instruction: smoking, drinking, kids, politics, hometown.
    // addTag(profile.smoking, FontAwesomeIcons.smoking);
    // addTag(profile.drinking, FontAwesomeIcons.wineGlass);
    // addTag(profile.kids, FontAwesomeIcons.child);
    // addTag(profile.politics, Icons.gavel);
    // addTag(profile.hometown, Icons.home);

    if (tags.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.08),
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
            l10n.aboutMe,
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
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.08),
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

    if (_isLookingForEmpty()) {
      return const SizedBox.shrink();
    }

    List<Widget> tags = [];
    for (var tag in profile.lookingForModes) {
      tags.add(_buildTag(null, tag));
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.08),
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
            l10n.imLookingFor,
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
            color: colorScheme.shadow.withValues(alpha: 0.08),
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
            l10n.quickestWayToHeart,
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
            color: colorScheme.outlineVariant.withValues(alpha: 0.5),
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
            color: colorScheme.shadow.withValues(alpha: 0.08),
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
            l10n.myInterests,
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

  IconData? _getLifestyleIcon(String label) {
    final l = label.toLowerCase();

    // Smoking
    if (l.contains('smoke') ||
        l == 'frequently' ||
        l == 'socially' ||
        l == 'never') {
      // It's hard to tell just from 'never' if it's smoking or drinking without category context.
      // But let's map known labels if possible, or fall back to a generic icon
    }

    // We will do a generic approach first. If it's a known string, map it.
    if (l == 'never' || l == 'socially' || l == 'frequently') {
      // Too ambiguous without category. We will just return a generic check or nothing
      return null; // Will just show label
    }

    if (l.contains('dog') || l.contains('cat') || l.contains('pet')) {
      return Icons.pets;
    }
    if (l.contains('vegan') || l.contains('vegetarian')) {
      return Icons.restaurant;
    }
    if (l.contains('gym') || l.contains('workout') || l.contains('fitness')) {
      return FontAwesomeIcons.dumbbell;
    }

    return Icons.loyalty; // default fallback
  }

  Widget _buildLifestyleSection() {
    final colorScheme = Theme.of(context).colorScheme;
    final profile = widget.profile;

    if (_isLifestyleEmpty()) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.08),
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
            l10n.myLifestyle,
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
            children: profile.lifestyleItems.map((chip) {
              IconData? icon;
              String displayText = chip.label;

              // Advanced matching based on our known chip labels and categories
              if (chip.categoryName != null) {
                final cName = chip.categoryName!.toLowerCase();
                if (cName.contains('smok')) {
                  icon = Icons.smoking_rooms_outlined;
                } else if (cName.contains('drink'))
                  icon = Icons.local_bar_outlined;
                else if (cName.contains('pet'))
                  icon = Icons.pets;
                else if (cName.contains('diet'))
                  icon = Icons.restaurant;
                else if (cName.contains('workout'))
                  icon = FontAwesomeIcons.dumbbell;

                // Prepend category if it's ambiguous like "Never" or "Sometimes"
                if (chip.label == 'Never' ||
                    chip.label == 'Sometimes' ||
                    chip.label == 'Socially') {
                  if (cName.contains('smok')) {
                    displayText = l10n.smokesLabel(chip.label);
                  }
                  if (cName.contains('drink')) {
                    displayText = l10n.drinksLabel(chip.label);
                  }
                  if (cName.contains('workout')) {
                    displayText = l10n.worksOutLabel(chip.label);
                  }
                }
              }

              // Fallback icon based on label text
              icon ??= _getLifestyleIcon(chip.label);

              return _buildTag(icon, displayText);
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
            color: colorScheme.shadow.withValues(alpha: 0.08),
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
            l10n.myCauses,
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
            color: colorScheme.shadow.withValues(alpha: 0.08),
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
            l10n.languagesTitle,
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
            color: colorScheme.shadow.withValues(alpha: 0.08),
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
            l10n.myLocation,
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
              Expanded(
                child: Text(
                  widget.profile.location.isNotEmpty
                      ? widget.profile.location
                      : l10n.nearby,
                  style: TextStyle(
                    fontSize: 16,
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
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
            color: colorScheme.shadow.withValues(alpha: 0.08),
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
            l10n.myTopArtist,
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
    // 1. PREVIEW MODE (Profile Screen) - Only "Edit" button
    if (widget.mode == ProfileCardMode.preview) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 40),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: widget.onEdit,
            icon: Icon(
              Icons.edit,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
            label: Text(
              l10n.editProfile,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              elevation: 5,
            ),
          ),
        ),
      );
    }

    // 2. DISCOVERY MODE - "Not for me" and "Like" OR State Overrides
    if (widget.mode == ProfileCardMode.discovery) {
      if (widget.swipeState == 'liked') {
        // State A: Liked - Render a large heart emoji badge in place of the buttons
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          height: 56, // Keep the same height as the buttons
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Theme.of(context).colorScheme.primary),
            boxShadow: [
              BoxShadow(
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('❤️', style: TextStyle(fontSize: 24)),
              const SizedBox(width: 8),
              Text(
                l10n.youLikedThem,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
            ],
          ),
        );
      } else if (widget.swipeState == 'passed') {
        // State B: Passed - Render a backtrack (undo) button
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          height: 56,
          child: ElevatedButton.icon(
            onPressed: widget.onUndo,
            icon: Icon(
              Icons.undo,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            label: Text(
              l10n.undoNotForMe,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.surface,
              side: BorderSide(color: Theme.of(context).colorScheme.outline),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              elevation: 0,
            ),
          ),
        );
      } else {
        // State C: None - Render normal buttons
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // NOT FOR ME (Pass)
              Expanded(
                child: _buildDiscoveryButton(
                  text: "Not for me",
                  textColor: Colors.black87,
                  backgroundColor: Colors.white,
                  borderColor: Colors.grey.shade300,
                  onTap: widget.onPause ?? widget.onBlock, // Use onPause if available
                ),
              ),
              const SizedBox(width: 16),
              // LIKE
              Expanded(
                child: _buildDiscoveryButton(
                  text: "Like",
                  textColor: Theme.of(context).colorScheme.onPrimary,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  borderColor: Colors.transparent,
                  onTap: widget.onLike,
                ),
              ),
            ],
          ),
        );
      }
    }

    // 3. SWIPE MODE (Home Screen) - Standard 3 Buttons (Cross, Star, Heart)
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 40),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(40),
        border: Border.all(
          color: Theme.of(
            context,
          ).colorScheme.outlineVariant.withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
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
            onTap: widget.onPause ?? widget.onBlock,
          ),
          _buildCircleButton(
            icon: Icons.star,
            color: const Color(0xFF414833),
            iconColor: const Color(0xFFD4AF37),
            onTap: widget.onSuperLike,
          ),
          _buildCircleButton(
            icon: Icons.favorite,
            color: const Color(0xFF414833),
            iconColor: const Color(0xFFD4AF37),
            onTap: widget.onLike,
          ),
        ],
      ),
    );
  }

  // Helper for Discovery Buttons
  Widget _buildDiscoveryButton({
    required String text,
    required Color textColor,
    required Color backgroundColor,
    required Color borderColor,
    required VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: borderColor),
          boxShadow: [
            if (backgroundColor != Colors.white)
              BoxShadow(
                color: backgroundColor.withValues(alpha: 0.4),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCircleButton({
    required IconData icon,
    required Color color,
    required Color iconColor,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        child: Icon(icon, color: iconColor, size: 28),
      ),
    );
  }

  Widget _buildBlockReportButtons() {
    return Column(
      children: [
        TextButton(
          onPressed: () {},
          child: Text(
            l10n.block,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: () {},
          child: Text(
            l10n.report,
            style: const TextStyle(
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
