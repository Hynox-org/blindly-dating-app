import 'package:flutter/material.dart';
import 'profile_edit_screen.dart';
import '../home/component/ProfileSwipeCard.dart';
// ============================================================
// PROFILE SCREEN (View Mode)
// ============================================================

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // About me data
  String _height = '170 cm';
  String _activityLevel = 'Active';
  String _education = 'Post graduate';
  String _gender = 'Men';
  String _religion = 'Hindu';
  String _zodiac = 'Taurus';
  String _drinking = 'Yes';
  String _smoking = 'Yes';

  // Looking for
  List<String> _selectedLookingFor = [
    'Fun, casual dates',
    'Ambition',
    'Confidence',
    'Emotional intelligence',
    'Long term relationship',
    'Loyalty',
    'Humility',
    'Humor',
  ];

  // Interests
  List<String> _selectedInterests = [
    'Dance',
    'Cricket',
    'Whiskey',
    'Bar',
    'KFC',
    'Football',
    'Beaches',
    'Arabic',
    'Fish',
  ];

  // Languages
  List<String> _selectedLanguages = ['Tamil', 'English', 'Malayalam'];

  // Location
  String _location = 'Coimbatore';

  // Causes and communities
  List<String> _causes = [
    'Reproductive rights',
    'LGBTQ',
    'Feminism',
    'Neurodiversity',
    'End religious hate',
    'Human rights',
    'Environmentalism'
  ];

  // Spotify artists
  List<String> _spotifyArtists = [
    'Mir kalima',
    'Harris jayaraj',
    'AR Rahman',
    'Benny dayal',
    'XXX tentacion',
    'Vedan',
    'Arijit singh',
    'Snoop dog',
    'Benny'
  ];

  // Create UserProfile from current data
  UserProfile _getCurrentProfile() {
    return UserProfile(
      id: 'current_user',
      name: 'Vignesh',
      age: 27,
      distance: 0.0,
      bio: 'UX/X designer',
      imageUrls: [
        'https://picsum.photos/400/600',
        'https://picsum.photos/401/600',
        'https://picsum.photos/402/600',
      ],
      height: _height,
      activityLevel: _activityLevel,
      education: _education,
      gender: _gender,
      religion: _religion,
      zodiac: _zodiac,
      drinking: _drinking,
      smoking: _smoking,
      summary:
          'Need Netflix recommendations? I\'m looking for someone who\'s down for deep conversations, spontaneous weekend plans, and cozy nights in.',
      lookingFor:
          'Mutual respect, peace and the feeling that you can be your true self',
      lookingForTags: _selectedLookingFor,
      quickestWay: '"Showing up with pure intentions - not just pretty words"',
      hobbies: _selectedInterests,
      causes: _causes,
      simplePleasure:
          '"Chai and chips, walks, drives (Not anybody! I know, but definitely something I enjoy)"',
      languages: _selectedLanguages,
      location: _location,
      spotifyArtists: _spotifyArtists,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'My profile view',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.black),
            onPressed: () {
              // TODO: Settings
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              ProfileSwipeCard(
                profile: _getCurrentProfile(),
                horizontalThreshold: 0,
                verticalThreshold: 0,
                isProfileScreen: true,
                onEdit: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProfileEditScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

