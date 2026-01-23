import 'package:flutter/material.dart';
import './../onboarding/presentation/screens/steps/photo_upload_screen.dart';
import './../profile/presentation/screens/setup_steps/profile_prompts_screen.dart';
import './../onboarding/presentation/screens/steps/name_birth_entry_screen.dart';
import './../onboarding/presentation/screens/steps/gender_select_screen.dart';
import './../profile/presentation/screens/setup_steps/language_select_screen.dart';
import './../profile/presentation/screens/setup_steps/location_set_screen.dart';
import './../profile/presentation/screens/setup_steps/interests_select_screen.dart';
import './../profile/presentation/screens/setup_steps/lifestyle_prefs_screen.dart';
// ============================================================
// PROFILE EDIT SCREEN (Complete Redesign)
// ============================================================

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  // Profile data
  final int _age = 27;
  final String _work = 'Designer';
  final String _education = 'PG graduate';
  final String _gender = 'Male';
  final String _location = 'Coimbatore';
  final String _hometown = 'Coimbatore';

  // More about you
  final String _height = '5.8';
  final String _exercise = 'Daily';
  final String _drinking = 'Yes';
  final String _smoking = 'Yes';
  final String _kids = 'No';
  final String _haveKids = 'No';
  final String _zodiac = 'Taurus';
  final String _politics = 'Not interested';
  final String _religion = 'Hindu';

  // Interests
  final List<String> _selectedInterests = [
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

  final List<String> _allInterests = [
    'Dance',
    'Cricket',
    'Whiskey',
    'Bar',
    'KFC',
    'Football',
    'Beaches',
    'Arabic',
    'Fish',
    'Music',
    'Reading',
    'Gaming',
  ];

  // Qualities
  final List<String> _selectedQualities = [
    'Empathy',
    'Emotional intelligence',
    'Gratitude',
    'Ambition',
  ];

  final List<String> _allQualities = [
    'Empathy',
    'Emotional intelligence',
    'Gratitude',
    'Ambition',
    'Honesty',
    'Kindness',
  ];

  // Languages
  final List<String> _selectedLanguages = ['Tamil', 'English'];
  final List<String> _allLanguages = [
    'Tamil',
    'English',
    'Malayalam',
    'Hindi',
    'Telugu',
    'Kannada',
  ];

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
          'Edit profile',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildProfileStrength(),
            const SizedBox(height: 16),
            _buildPhotosSection(),
            const SizedBox(height: 16),
            _buildInterestsSection(),
            const SizedBox(height: 16),
            _buildCausesSection(),
            const SizedBox(height: 16),
            _buildQualitiesSection(),
            const SizedBox(height: 16),
            _buildPromptsSection(),
            const SizedBox(height: 16),
            _buildOpeningMovesSection(),
            const SizedBox(height: 16),
            _buildBioSection(),
            const SizedBox(height: 16),
            _buildAboutYouSection(),
            const SizedBox(height: 16),
            _buildMoreAboutYouSection(),
            const SizedBox(height: 16),
            _buildPronounsSection(),
            const SizedBox(height: 16),
            _buildLanguagesSection(),
            const SizedBox(height: 16),
            _buildConnectedAccountsSection(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileStrength() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Profile strength',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  '40% complete',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                    color: Colors.black,
                  ),
                ),
                Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotosSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Photos and videos',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Pick some that show the true you.',
            style: TextStyle(
              fontSize: 12,
              color: Colors.black,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 3,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            children: List.generate(6, (index) {
              return GestureDetector(
                onTap: () async {
                  // Navigate to PhotoUploadScreen
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PhotoUploadScreen(),
                    ),
                  );
                  // Refresh UI after returning
                  setState(() {});
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.add, size: 32, color: Colors.grey),
                ),
              );
            }),
          ),
          const SizedBox(height: 12),
          const Text(
            'Hold and drag media to reorder',
            style: TextStyle(
              fontSize: 11,
              color: Colors.black,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 16),
          // Best photo row in white bg
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: const [
                Icon(
                  Icons.verified, // blue tick
                  size: 20,
                  color: Colors.blue,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Best photo',
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: 'Poppins',
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  'On',
                  style: TextStyle(
                    fontSize: 13,
                    fontFamily: 'Poppins',
                    color: Colors.black,
                  ),
                ),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Verification row in white bg
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: const [
                Icon(Icons.verified_user, size: 20, color: Colors.black),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Verification',
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: 'Poppins',
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  'Not Verified',
                  style: TextStyle(
                    fontSize: 13,
                    fontFamily: 'Poppins',
                    color: Colors.black,
                  ),
                ),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInterestsSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Interests',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Get specific about the things you love.',
            style: TextStyle(
              fontSize: 12,
              color: Colors.black,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: _showInterestsDialog,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        'Add your favorite interests',
                        style: TextStyle(
                          fontSize: 14,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      Icon(Icons.add, color: Colors.black, size: 20),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                const Divider(color: Colors.black, thickness: 1, height: 1),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _selectedInterests.map((interest) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(10), // less curve
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(_getInterestEmoji(interest)),
                          const SizedBox(width: 6),
                          Text(
                            interest,
                            style: const TextStyle(
                              fontSize: 12,
                              fontFamily: 'Poppins',
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getInterestEmoji(String interest) {
    final Map<String, String> emojis = {
      'Dance': '💃',
      'Cricket': '🏏',
      'Whiskey': '🥃',
      'Bar': '🍻',
      'KFC': '🍗',
      'Football': '⚽',
      'Beaches': '🏖️',
      'Arabic': '🎵',
      'Fish': '🐟',
    };
    return emojis[interest] ?? '🎯';
  }

  Widget _buildCausesSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'My causes and communities',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Add up to 3 causes close to your heart.',
            style: TextStyle(
              fontSize: 12,
              color: Colors.black,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: GestureDetector(
              onTap: () {},
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Expanded(
                    child: Text(
                      'Add your causes and communities',
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQualitiesSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Qualities I value',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Choose up to 3 qualities you value in a person',
            style: TextStyle(
              fontSize: 12,
              color: Colors.black,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _selectedQualities.map((quality) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Text(
                          quality,
                          style: const TextStyle(
                            fontSize: 13,
                            fontFamily: 'Poppins',
                            color: Colors.black,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () {},
                  child: const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromptsSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Prompts',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Let people know what it\'s like to date you.',
            style: TextStyle(
              fontSize: 12,
              color: Colors.black,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: GestureDetector(
              onTap: () async {
                // Navigate to ProfilePromptsScreen
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfilePromptsScreen(),
                  ),
                );
                // Refresh UI after returning
                setState(() {});
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Expanded(
                    child: Text(
                      'Add a prompt',
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOpeningMovesSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Opening moves',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Add 3 first messages your new matches can reply to.',
            style: TextStyle(
              fontSize: 12,
              color: Colors.black,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: GestureDetector(
              onTap: () {},
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Expanded(
                    child: Text(
                      'Whats your ideal first date?',
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBioSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Bio',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Write a fun intro.',
            style: TextStyle(
              fontSize: 12,
              color: Colors.black,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'About you..',
                hintStyle: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  fontFamily: 'Poppins',
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              style: const TextStyle(
                fontFamily: 'Poppins',
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutYouSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'About you',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          _buildListTile(
            Icons.cake,
            'Age',
            '$_age',
            true,
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NameBirthEntryScreen(),
                ),
              );
              setState(() {});
            },
          ),
          _buildListTile(
            Icons.work,
            'Work',
            _work,
            true,
            onTap: () {},
            // async {
            // await Navigator.push(
            //   context
            // MaterialPageRoute(builder: (context) => const WorkEditScreen()),
            // );
            // setState(() {});
            // },
          ),
          _buildListTile(
            Icons.school,
            'Education',
            _education,
            true,
            onTap: () {},
            // async {
            //   await Navigator.push(
            //     context,
            //     MaterialPageRoute(builder: (context) => const EducationEditScreen()),
            //   );
            //   setState(() {});
            // },
          ),
          _buildListTile(
            Icons.person,
            'Gender',
            _gender,
            true,
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const GenderSelectScreen(),
                ),
              );
              setState(() {});
            },
          ),
          _buildListTile(
            Icons.location_on,
            'Location',
            _location,
            true,
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const LocationSetScreen(),
                ),
              );
              setState(() {});
            },
          ),
          _buildListTile(
            Icons.home,
            'Hometown',
            _hometown,
            true,
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const LocationSetScreen(),
                ),
              );
              setState(() {});
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMoreAboutYouSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'More about you',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          _buildListTile(
            Icons.height,
            'Height',
            _height,
            true,
            onTap: () {} 
            //async {
            //   await Navigator.push(
            //     context,
            //     MaterialPageRoute(
            //       builder: (context) => const HeightEditScreen(),
            //     ),
            //   );
            //   setState(() {});
            // },
          ),
          _buildListTile(
            Icons.fitness_center,
            'Exercise',
            _exercise,
            true,
            onTap: () {}
            // async {
            //   await Navigator.push(
            //     context,
            //     MaterialPageRoute(
            //       builder: (context) => const ExerciseEditScreen(),
            //     ),
            //   );
            //   setState(() {});
            // },
          ),
          _buildListTile(
            Icons.school,
            'Education level',
            _education,
            true,
            onTap: () {}
            // async {
            //   await Navigator.push(
            //     context,
            //     MaterialPageRoute(
            //       builder: (context) => const EducationLevelEditScreen(),
            //     ),
            //   );
            //   setState(() {});
            // },
          ),
          _buildListTile(
            Icons.local_drink,
            'Drinking',
            _drinking,
            true,
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const LifestylePrefsScreen(),
                ),
              );
              setState(() {});
            },
          ),
          _buildListTile(
            Icons.smoking_rooms,
            'Smoking',
            _smoking,
            true,
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const LifestylePrefsScreen(),
                ),
              );
              setState(() {});
            },
          ),
          _buildListTile(
            Icons.child_care,
            'Kids',
            _kids,
            true,
            onTap: () {}
            // async {
            //   await Navigator.push(
            //     context,
            //     MaterialPageRoute(builder: (context) => const KidsEditScreen()),
            //   );
            //   setState(() {});
            // },
          ),
          _buildListTile(
            Icons.family_restroom,
            'Have kids',
            _haveKids,
            true,
            onTap: () {}
            // async {
            //   await Navigator.push(
            //     context,
            //     MaterialPageRoute(
            //       builder: (context) => const HaveKidsEditScreen(),
            //     ),
            //   );
            //   setState(() {});
            // },
          ),
          _buildListTile(
            Icons.stars,
            'Zodiac',
            _zodiac,
            true,
            onTap: () {}
            // async {
            //   await Navigator.push(
            //     context,
            //     MaterialPageRoute(
            //       builder: (context) => const ZodiacEditScreen(),
            //     ),
            //   );
            //   setState(() {});
            // },
          ),
          _buildListTile(
            Icons.how_to_vote,
            'Politics',
            _politics,
            true,
            onTap: () {}
            // async {
            //   await Navigator.push(
            //     context,
            //     MaterialPageRoute(
            //       builder: (context) => const PoliticsEditScreen(),
            //     ),
            //   );
            //   setState(() {});
            // },
          ),
          _buildListTile(
            Icons.temple_hindu,
            'Religion',
            _religion,
            true,
            onTap: () {}
            // async {
            //   await Navigator.push(
            //     context,
            //     MaterialPageRoute(
            //       builder: (context) => const ReligionEditScreen(),
            //     ),
            //   );
            //   setState(() {});
            // },
          ),
        ],
      ),
    );
  }

  Widget _buildPronounsSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Pronouns',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Pick your pronouns',
            style: TextStyle(
              fontSize: 12,
              color: Colors.black,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: GestureDetector(
              onTap: () {},
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Expanded(
                    child: Text(
                      'Add your pronouns',
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

Widget _buildLanguagesSection() {
  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Languages',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: () async {
            // Navigate to LanguageSelectScreen
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const LanguageSelectScreen(),
              ),
            );
            // Refresh UI after returning
            setState(() {});
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                ..._selectedLanguages.map((lang) {
                  return Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.language,
                          size: 14,
                          color: Colors.blue,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          lang,
                          style: const TextStyle(
                            fontSize: 12,
                            fontFamily: 'Poppins',
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                const Spacer(),
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.black,
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

  Widget _buildConnectedAccountsSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Connected accounts',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Show your favorite music',
            style: TextStyle(
              fontSize: 12,
              color: Colors.black,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(Icons.music_note, color: Colors.green, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Connect my spotify',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Poppins',
                          color: Colors.black,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Colors.black,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Show your top spotify artists on your profile and allow blindly to highlight who have in common with others',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.black,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 60,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: 6,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: const EdgeInsets.only(right: 8),
                        width: 60,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          shape: BoxShape.circle,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListTile(
    IconData icon,
    String title,
    String trailing,
    bool showArrow, {
    VoidCallback? onTap, // Add optional onTap parameter
  }) {
    return GestureDetector(
      onTap: onTap, // Trigger navigation when tapped
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(icon, size: 20, color: Colors.black),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontFamily: 'Poppins',
                  color: Colors.black,
                ),
              ),
            ),
            Text(
              trailing,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black,
                fontFamily: 'Poppins',
              ),
            ),
            if (showArrow) ...[
              const SizedBox(width: 8),
              const Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: Colors.black,
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showInterestsDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(16),
              height: MediaQuery.of(context).size.height * 0.7,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Select Interests',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins',
                          color: Colors.black,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.black),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _allInterests.map((interest) {
                        final isSelected = _selectedInterests.contains(
                          interest,
                        );
                        return GestureDetector(
                          onTap: () {
                            setModalState(() {
                              if (isSelected) {
                                _selectedInterests.remove(interest);
                              } else {
                                _selectedInterests.add(interest);
                              }
                            });
                            setState(() {});
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color.fromRGBO(65, 72, 51, 1)
                                  : Colors.grey[100],
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected
                                    ? const Color.fromRGBO(65, 72, 51, 1)
                                    : Colors.grey[300]!,
                              ),
                            ),
                            child: Text(
                              interest,
                              style: TextStyle(
                                fontSize: 13,
                                fontFamily: 'Poppins',
                                color: isSelected ? Colors.white : Colors.black,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}