import 'package:flutter/material.dart';
import 'package:blindly_dating_app/l10n/app_localizations.dart';
import 'package:blindly_dating_app/core/utils/vocab.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:blindly_dating_app/features/matching/domain/models/match_profile.dart';
import 'package:blindly_dating_app/features/matching/presentation/widgets/profile_swipe_card.dart';
import 'package:blindly_dating_app/features/matching/provider/swipe_provider.dart';

class DiscoveryProfileDetailScreen extends ConsumerStatefulWidget {
  final MatchProfile user;
  final String initialState; // 'none', 'liked', or 'passed'

  const DiscoveryProfileDetailScreen({
    super.key,
    required this.user,
    this.initialState = 'none',
  });

  @override
  ConsumerState<DiscoveryProfileDetailScreen> createState() =>
      _DiscoveryProfileDetailScreenState();
}

class _DiscoveryProfileDetailScreenState
    extends ConsumerState<DiscoveryProfileDetailScreen> {
  AppLocalizations get l10n => AppLocalizations.of(context);


  // Local state to track the interaction on this specific card
  late String _swipeState;

  @override
  void initState() {
    super.initState();
    _swipeState = widget.initialState;
  }

  UserProfile _mapToUserProfile(MatchProfile user) {
    List<String> profileImages = List.from(user.imageUrls);
    if (profileImages.isEmpty) {
      profileImages.add(
        'https://ui-avatars.com/api/?name=${Uri.encodeComponent(user.displayName)}&background=random&size=500&bold=true',
      );
    }

    final genderStr = user.gender.isNotEmpty
        ? (user.gender.startsWith('M')
              ? 'Male'
              : (user.gender.startsWith('F') ? 'Female' : 'Male'))
        : 'Male';
    final genderLabel = vocabLabel(l10n, genderStr);

    return UserProfile(
      id: user.profileId,
      name: user.displayName,
      age: user.age,
      distance: double.parse((user.distanceKm / 1000).toStringAsFixed(1)),
      location: user.hometown ?? l10n.nearby,
      gender: genderLabel,
      imageUrls: profileImages,
      bio: user.bio,
      subTitle: user.workTitle ?? '',
      height: user.height != null ? l10n.heightCm('${user.height}') : '',
      activityLevel: user.exercise ?? '',
      education: user.education ?? '',
      school: user.school ?? '',
      religion: user.religion ?? '',
      zodiac: user.zodiac ?? '',
      drinking: user.drinking ?? '',
      smoking: user.smoking ?? '',
      politics: user.politics ?? '',
      kids: user.kids ?? '',
      hometown: user.hometown ?? '',
      workCompany: user.workCompany ?? '',
      summary: user.bio.isNotEmpty ? user.bio : l10n.swipeRightHint,
      lookingForModes: user.lookingForModes,
      quickestWay: '',
      prompts: user.prompts, // ✅ Pass fetched Prompts here
      hobbies: user.interests,
      causes: user.causes,
      simplePleasure: '',
      languages: user.languages,
      spotifyArtists: user.spotifyArtists,
      isVerified: user.isVerified,
      verificationLevel: user.verificationLevel,
      trustScore: user.trustScore, // ✅ Pass Trust Score
      voiceIntroUrl: user.voiceIntroUrl,
      voiceIntroDuration: user.voiceIntroDuration,
    );
  }

  void _handleAction(String action) {
    // 1. Trigger the backend API call asynchronously
    ref
        .read(swipeProvider.notifier)
        .swipe(targetProfileId: widget.user.profileId, action: action)
        .then((_) => debugPrint('✅ Action $action successful'))
        .catchError((e) => debugPrint('❌ Swipe action $action failed: $e'));

    // 2. Optimistic UI update - return state back to grid immediately
    Navigator.pop(context, action == 'like' ? 'liked' : 'passed');
  }

  void _handleUndo() {
    // 1. Trigger the backend undo API
    ref
        .read(swipeProvider.notifier)
        .undo()
        .then(
          (success) =>
              debugPrint(success ? '✅ Undo complete' : '❌ Undo failed'),
        )
        .catchError((e) => debugPrint('❌ Undo err: $e'));

    // 2. Return state back to grid
    Navigator.pop(context, 'none');
  }

  @override
  Widget build(BuildContext context) {
    final uiProfile = _mapToUserProfile(widget.user);

    return Scaffold(
      backgroundColor: Colors.transparent, // ✅ Allow backdrop to show
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white, // ✅ The white background he asked for
            borderRadius: BorderRadius.circular(
              20,
            ), // ✅ The curved edges he asked for
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  top: 60, // Matching profile.dart exactly
                  bottom: 80,
                  left: 20,
                  right: 20,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: ProfileSwipeCard(
                    profile: uiProfile,
                    mode: ProfileCardMode
                        .discovery, // Preserve discovery mode for action buttons
                    // Someone who already liked you isn't being rated, they're
                    // being answered — so the buttons say Match / Pass.
                    likeText:
                        widget.user.relationship == RelationshipState.likedMe
                            ? l10n.matchLabel
                            : null,
                    passText:
                        widget.user.relationship == RelationshipState.likedMe
                            ? l10n.passLabel
                            : null,
                    swipeState: _swipeState, // ✅ Pass down the state
                    onLike: () => _handleAction('like'),
                    onBlock: () => _handleAction('pass'),
                    onUndo: _handleUndo, // ✅ Pass down the undo handler
                    onReport: () {
                      // Report Logic (Placeholder)
                      Navigator.pop(context);
                    },
                  ),
                ),
              ),

              Positioned(
                top: 10, // ✅ Restored back to 10
                right: 10,
                child: GestureDetector(
                  onTap: () => Navigator.pop(
                    context,
                    null,
                  ), // Return whatever the state was initially basically without change
                  child: CircleAvatar(
                    backgroundColor: Colors.black,
                    radius: 20,
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),

              Positioned(
                bottom: 10,
                left: 0,
                right: 0,
                child: const SizedBox.shrink(), // Button moved inside card
              ),
            ],
          ),
        ),
      ),
    );
  }
}
