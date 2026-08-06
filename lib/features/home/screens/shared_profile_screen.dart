import 'package:flutter/material.dart';
import 'package:blindly_dating_app/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/widgets/app_loader.dart';
import '../../home/component/ProfileSwipeCard.dart';
import '../../discovery/domain/models/discovery_user_model.dart';
import '../../discovery/repository/discovery_repository.dart';
import '../../discovery/povider/swipe_provider.dart';

class SharedProfileScreen extends ConsumerStatefulWidget {
  final String profileId;
  const SharedProfileScreen({super.key, required this.profileId});

  @override
  ConsumerState<SharedProfileScreen> createState() =>
      _SharedProfileScreenState();
}

class _SharedProfileScreenState extends ConsumerState<SharedProfileScreen> {
  AppLocalizations get l10n => AppLocalizations.of(context);


  bool _isLoading = true;
  DiscoveryUser? _user;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    try {
      final repo = ref.read(discoveryRepositoryProvider);
      final user = await repo.getProfileWithRelationship(widget.profileId);

      if (user == null) {
        setState(() {
          _errorMessage = l10n.profileUnavailable;
          _isLoading = false;
        });
        return;
      }

      if (mounted) {
        setState(() {
          _user = user;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = l10n.profileLoadFailed;
          _isLoading = false;
        });
      }
    }
  }

  void _onDismiss() {
    Navigator.pop(context);
  }

  void _handleAction(String type) async {
    if (_user == null) return;
    
    // Optimistically pop and handle action, OR show success message
    // The requirement says: "When the user closes or swipes... automatically return to normal Discovery page"
    
    try {
      if (type == 'like') {
        await ref.read(swipeProvider.notifier).swipe(
              targetProfileId: _user!.profileId,
              action: 'like',
            );
      } else if (type == 'pass') {
        await ref.read(swipeProvider.notifier).swipe(
              targetProfileId: _user!.profileId,
              action: 'pass',
            );
      }
      
      if (mounted) {
        Navigator.pop(context); // Return to Discovery
      }
    } catch (e) {
       debugPrint("Error handling deep link action: $e");
    }
  }

  Widget _buildRelationshipOverlay() {
    if (_user == null) return const SizedBox.shrink();
    
    String? message;
    IconData? icon;
    Color? color;

    switch (_user!.relationship) {
      case RelationshipState.likedByMe:
        message = l10n.alreadyLikedProfile;
        icon = Icons.favorite;
        color = Colors.redAccent;
        break;
      case RelationshipState.likedMe:
        message = l10n.personAlreadyLikedYou;
        icon = Icons.star;
        color = Colors.amber;
        break;
      case RelationshipState.matched:
        message = l10n.youAreMatched;
        icon = Icons.auto_awesome;
        color = Colors.pinkAccent;
        break;
      case RelationshipState.chatStarted:
        message = l10n.alreadyChatting;
        icon = Icons.chat;
        color = Colors.blueAccent;
        break;
      case RelationshipState.skippedByMe:
        message = l10n.profileAlreadySkipped;
        icon = Icons.block;
        color = Colors.grey;
        break;
      default:
        return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: _onDismiss,
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: AppLoader()));
    }

    if (_errorMessage != null || _user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Profile")),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                _errorMessage ?? l10n.profileNotFound,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Go Back"),
              ),
            ],
          ),
        ),
      );
    }

    // Convert DiscoveryUser to UserProfile for the card
    final profile = UserProfile(
        id: _user!.profileId,
        name: _user!.displayName,
        age: _user!.age,
        distance: _user!.distanceKm,
        bio: _user!.bio,
        subTitle: _user!.workTitle,
        imageUrls: _user!.imageUrls,
        height: _user!.height?.toString() ?? '',
        activityLevel: _user!.exercise ?? '',
        education: _user!.education ?? '',
        school: _user!.school ?? '',
        gender: _user!.gender,
        religion: _user!.religion ?? '',
        zodiac: _user!.zodiac ?? '',
        drinking: _user!.drinking ?? '',
        smoking: _user!.smoking ?? '',
        politics: _user!.politics ?? '',
        kids: _user!.kids ?? '',
        hometown: _user!.hometown ?? '',
        workCompany: _user!.workCompany ?? '',
        hobbies: _user!.interests,
        summary: '', // discovery user doesn't have summary field but bio
        lookingForModes: _user!.lookingForModes,
        quickestWay: '',
        causes: _user!.causes,
        lifestyleItems: [], // could map lifestyle if needed
        prompts: _user!.prompts,
        simplePleasure: '',
        languages: _user!.languages,
        location: '',
        spotifyArtists: _user!.spotifyArtists,
        isVerified: _user!.isVerified,
        verificationLevel: _user!.verificationLevel,
        voiceIntroUrl: _user!.voiceIntroUrl,
        voiceIntroDuration: _user!.voiceIntroDuration,
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black, size: 28),
          onPressed: _onDismiss,
        ),
        title: Text(
            l10n.profilePreview,
            style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)
        ),
      ),
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ProfileSwipeCard(
                profile: profile,
                horizontalThreshold: 0,
                verticalThreshold: 0,
                mode: _user!.relationship == RelationshipState.none 
                    ? ProfileCardMode.swipe // Show buttons if no relationship
                    : ProfileCardMode.preview, // Hide defaults if relationship exists
                onLike: () => _handleAction('like'),
                onBlock: () => _handleAction('pass'),
              ),
            ),
          ),
          // Status Overlay
          if (_user!.relationship != RelationshipState.none)
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: _buildRelationshipOverlay(),
            ),
        ],
      ),
    );
  }
}
