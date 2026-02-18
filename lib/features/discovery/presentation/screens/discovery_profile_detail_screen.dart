import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/discovery_user_model.dart';
import '../../../home/component/ProfileSwipeCard.dart';
import '../../povider/discovery_landing_provider.dart';
import '../../povider/swipe_provider.dart';
// Reuse the mapper logic (Should ideally be in a shared helper, but duplicating for now to be safe)
// Or better: import from home screen if it was static? No it's private.
// I'll implement a local mapper here to keep it independent.

class DiscoveryProfileDetailScreen extends ConsumerWidget {
  final DiscoveryUser user;

  const DiscoveryProfileDetailScreen({super.key, required this.user});

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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uiProfile = _mapToUserProfile(user);

    Future<void> handleAction(String action) async {
      // 1. Close Screen Immediately
      Navigator.pop(context);

      // 2. Remove from Feed (Optimistic Update)
      // We use profileId as the key
      ref.read(discoveryLandingProvider.notifier).removeUser(user.profileId);

      // 3. Trigger Backend Call
      try {
        await ref
            .read(swipeProvider.notifier)
            .swipe(targetProfileId: user.profileId, action: action);
      } catch (e) {
        // Silently fail or minimal feedback, action is already "done" for user
        debugPrint('Swipe action $action failed: $e');
      }
    }

    return Scaffold(
      backgroundColor: Colors.black, // Dark background for focus
      body: Stack(
        children: [
          // The Card
          Positioned.fill(
            child: ProfileSwipeCard(
              profile: uiProfile,
              isHomeScreen: false,
              horizontalThreshold: 0,
              verticalThreshold: 0,
              onLike: () => handleAction('like'),
              onBlock: () => handleAction('pass'),
              onReport: () {
                // Report Logic (Placeholder)
                Navigator.pop(context);
              },
            ),
          ),

          // Close Button (Top LEFT now)
          Positioned(
            top: 50,
            left: 20,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
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
