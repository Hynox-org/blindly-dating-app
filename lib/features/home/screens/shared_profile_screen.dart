import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// Removed go_router import

import '../../../core/widgets/app_loader.dart';
import '../../home/component/ProfileSwipeCard.dart';

class SharedProfileScreen extends ConsumerStatefulWidget {
  final String profileId;
  const SharedProfileScreen({super.key, required this.profileId});

  @override
  ConsumerState<SharedProfileScreen> createState() =>
      _SharedProfileScreenState();
}

class _SharedProfileScreenState extends ConsumerState<SharedProfileScreen> {
  bool _isLoading = true;
  UserProfile? _profile;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    try {
      final supabase = Supabase.instance.client;

      final Map<String, dynamic>? data = await supabase
          .from('profiles')
          .select()
          .eq(
            'user_id',
            widget.profileId,
          ) // Using user_id for public linking or id if prefer
          .maybeSingle();

      if (data == null) {
        setState(() {
          _errorMessage = "Profile not found or no longer available.";
          _isLoading = false;
        });
        return;
      }

      final mappedProfile = UserProfile(
        id: data['id'],
        name: data['display_name'] ?? 'Unknown',
        age: data['age'] ?? 0,
        distance: (data['distance_miles'] ?? 0.0).toDouble(),
        bio: data['bio'] ?? '',
        subTitle: data['job_title'],
        imageUrls: List<String>.from(data['photos'] ?? []),
        height: data['height'] ?? '',
        activityLevel: data['workout'] ?? '',
        education: data['education_level'] ?? '',
        school: data['college'] ?? '',
        gender: data['gender'] ?? '',
        religion: data['religion'] ?? '',
        zodiac: data['zodiac_sign'] ?? '',
        drinking: data['drinking'] ?? '',
        smoking: data['smoking'] ?? '',
        politics: data['politics'] ?? '',
        kids: data['kids'] ?? '',
        hometown: data['hometown'] ?? '',
        workCompany: data['work_company'] ?? '',
        hobbies: List<String>.from(data['interests'] ?? []),
        summary: data['about_me'] ?? '',
        lookingForModes: List<String>.from(data['looking_for_modes'] ?? []),
        quickestWay: data['quickest_way'] ?? '',
        causes: List<String>.from(data['causes'] ?? []),
        simplePleasure: data['simple_pleasure'] ?? '',
        languages: List<String>.from(data['languages'] ?? []),
        location: data['location'] ?? '',
        spotifyArtists: List<String>.from(data['spotify_artists'] ?? []),
        isVerified: data['is_verified'] ?? false,
        verificationLevel: data['verification_level'] ?? 'unverified',
      );

      if (mounted) {
        setState(() {
          _profile = mappedProfile;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = "Failed to load profile. Please try again.";
          _isLoading = false;
        });
      }
    }
  }

  void _onDismiss() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: AppLoader()));
    }

    if (_errorMessage != null || _profile == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Profile")),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                _errorMessage ?? "Profile not found",
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

    return Scaffold(
      backgroundColor: Colors.black, // Typical card background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white, size: 28),
          onPressed: _onDismiss,
        ),
      ),
      extendBodyBehindAppBar: true,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ProfileSwipeCard(
            profile: _profile!,
            horizontalThreshold: 0,
            verticalThreshold: 0,
            mode: ProfileCardMode
                .preview, // Preview mode hides the swipe action buttons
          ),
        ),
      ),
    );
  }
}
