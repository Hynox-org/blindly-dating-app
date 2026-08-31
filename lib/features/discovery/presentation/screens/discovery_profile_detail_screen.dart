import 'package:flutter/material.dart';
import 'package:blindly_dating_app/l10n/app_localizations.dart';
import 'package:blindly_dating_app/core/utils/vocab.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:blindly_dating_app/features/matching/domain/models/match_profile.dart';
import 'package:blindly_dating_app/features/matching/presentation/widgets/profile_swipe_card.dart';
import 'package:blindly_dating_app/features/matching/provider/swipe_provider.dart';
import 'package:blindly_dating_app/core/widgets/match_dialog.dart';

class DiscoveryProfileDetailScreen extends ConsumerStatefulWidget {
  final MatchProfile user;

  /// 'none' | 'liked' | 'super_liked' | 'passed' — as resolved by
  /// [DiscoveryCardActions.interactionFor].
  final String initialState;

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

  /// The interaction this card is showing. A super like is still a like, and
  /// [ProfileSwipeCard] only knows 'liked' — left as 'super_liked' it fell
  /// through to the un-swiped branch and offered Like/Pass all over again.
  late String _swipeState;

  /// Blocks a second tap while a swipe or undo is in flight. This screen is a
  /// full-page sheet, not an animating card, so it can afford to wait for the
  /// write instead of guessing — the deck deliberately does the opposite.
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _swipeState = widget.initialState == 'super_liked'
        ? 'liked'
        : widget.initialState;
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
      distance: double.parse(user.distanceKm.toStringAsFixed(1)),
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
      prompts: user.prompts,
      hobbies: user.interests,
      causes: user.causes,
      simplePleasure: '',
      languages: user.languages,
      spotifyArtists: user.spotifyArtists,
      isVerified: user.isVerified,
      verificationLevel: user.verificationLevel,
      trustScore: user.trustScore,
      voiceIntroUrl: user.voiceIntroUrl,
      voiceIntroDuration: user.voiceIntroDuration,
      // Carried through so a spotlighted card keeps its badge when it is
      // opened from the deck, not just in the deck.
      isSpotlight: user.isSpotlight,
    );
  }

  void _toast(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  /// Waits for the write before popping, so the grid is never told about a
  /// like the server rejected. A match is celebrated here, while this route
  /// still has a context to show it in.
  Future<void> _handleAction(String action) async {
    if (_busy) return;
    setState(() => _busy = true);

    try {
      final matched = await ref
          .read(swipeProvider.notifier)
          .swipe(targetProfileId: widget.user.profileId, action: action);

      if (!mounted) return;
      if (matched) await showMatchDialog(context, widget.user.displayName);
      if (!mounted) return;
      Navigator.pop(context, action == 'like' ? 'liked' : 'passed');
    } catch (e) {
      debugPrint('Swipe action $action failed: $e');
      if (!mounted) return;
      setState(() => _busy = false);
      _toast(l10n.somethingWentWrong);
    }
  }

  Future<void> _handleUndo() async {
    if (_busy) return;
    setState(() => _busy = true);

    try {
      // Naming the profile matters: without it the backend reverts whatever
      // this user swiped most recently, anywhere in the app.
      final success = await ref
          .read(swipeProvider.notifier)
          .undo(targetProfileId: widget.user.profileId);

      if (!mounted) return;
      if (!success) {
        setState(() => _busy = false);
        _toast(l10n.somethingWentWrong);
        return;
      }
      Navigator.pop(context, 'none');
    } catch (e) {
      debugPrint('Undo failed: $e');
      if (!mounted) return;
      setState(() => _busy = false);
      _toast(l10n.somethingWentWrong);
    }
  }

  @override
  Widget build(BuildContext context) {
    final uiProfile = _mapToUserProfile(widget.user);

    return Scaffold(
      backgroundColor: Colors.transparent, // lets the backdrop show through
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  top: 60,
                  bottom: 80,
                  left: 20,
                  right: 20,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: ProfileSwipeCard(
                    profile: uiProfile,
                    // Discovery mode is what puts Like / Not for me on the
                    // card instead of the deck's swipe gestures.
                    mode: ProfileCardMode.discovery,
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
                    swipeState: _swipeState,
                    onLike: _busy ? null : () => _handleAction('like'),
                    onBlock: _busy ? null : () => _handleAction('pass'),
                    onUndo: _busy ? null : _handleUndo,
                    // ponytail: reporting just closes the sheet for now;
                    // wire it to the report flow when that screen exists.
                    onReport: () => Navigator.pop(context),
                  ),
                ),
              ),

              Positioned(
                top: 10,
                right: 10,
                child: GestureDetector(
                  // null means "nothing changed" — the caller keeps the
                  // interaction it already had for this profile.
                  onTap: () => Navigator.pop(context, null),
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
            ],
          ),
        ),
      ),
    );
  }
}
