import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/discovery_user_model.dart';
import '../../../home/component/ProfileSwipeCard.dart';
import '../../povider/swipe_provider.dart';

class DiscoveryProfileDetailScreen extends ConsumerStatefulWidget {
  final DiscoveryUser user;
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
  // Local state to track the interaction on this specific card
  late String _swipeState;

  @override
  void initState() {
    super.initState();
    _swipeState = widget.initialState;
  }

  UserProfile _mapToUserProfile(DiscoveryUser user) {
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

    return UserProfile(
      id: user.profileId,
      name: user.displayName,
      age: user.age,
      distance: double.parse((user.distanceKm / 1000).toStringAsFixed(1)),
      location: user.hometown ?? 'Nearby',
      gender: genderStr,
      imageUrls: profileImages,
      bio: user.bio,
      subTitle: user.workTitle ?? '',
      height: user.height != null ? '${user.height} cm' : '',
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
      summary: user.bio.isNotEmpty ? user.bio : 'Swipe right to know more!',
      lookingFor: user.relationshipType ?? 'Connection',
      lookingForTags: [],
      quickestWay: '',
      hobbies: user.interests,
      causes: user.causes,
      simplePleasure: '',
      languages: user.languages,
      spotifyArtists: user.spotifyArtists,
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
      backgroundColor: Colors.black, // Dark background for focus
      body: Stack(
        children: [
          // The Card
          Positioned.fill(
            child: ProfileSwipeCard(
              profile: uiProfile,
              mode: ProfileCardMode.discovery,
              swipeState: _swipeState, // ✅ Pass down the state
              horizontalThreshold: 0,
              verticalThreshold: 0,
              onLike: () => _handleAction('like'),
              onBlock: () => _handleAction('pass'),
              onUndo: _handleUndo, // ✅ Pass down the undo handler
              onReport: () {
                // Report Logic (Placeholder)
                Navigator.pop(context);
              },
            ),
          ),

          // Close Button (Top RIGHT now)
          Positioned(
            top: 50,
            right: 20,
            child: GestureDetector(
              onTap: () => Navigator.pop(
                context,
                null,
              ), // Return whatever the state was initially basically without change
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 30),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
