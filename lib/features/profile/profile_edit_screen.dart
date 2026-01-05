import 'package:flutter/material.dart';

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
  int _age = 27;
  String _work = 'Designer';
  String _education = 'PG graduate';
  String _gender = 'Male';
  String _location = 'Coimbatore';
  String _hometown = 'Coimbatore';

  // More about you
  String _height = '5.8';
  String _exercise = 'Daily';
  String _drinking = 'Yes';
  String _smoking = 'Yes';
  String _kids = 'No';
  String _haveKids = 'No';
  String _zodiac = 'Taurus';
  String _politics = 'Not interested';
  String _religion = 'Hindu';

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
  List<String> _selectedQualities = [
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
  List<String> _selectedLanguages = ['Tamil', 'English'];
  final List<String> _allLanguages = [
    'Tamil',
    'English',
    'Malayalam',
    'Hindi',
    'Telugu',
    'Kannada'
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Profile strength',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                ),
              ),
              SizedBox(height: 4),
              Text(
                '40% complete',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  fontFamily: 'Poppins',
                ),
              ),
            ],
          ),
          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _buildPhotosSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Photos and videos',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Pick some that show the true you.',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
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
              return Container(
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.add,
                  size: 32,
                  color: Colors.grey,
                ),
              );
            }),
          ),
          const SizedBox(height: 12),
          const Text(
            'Hold and drag media to reorder',
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 16),
          _buildListTile(Icons.star, 'Best photo', '', false),
          _buildListTile(Icons.verified_user, 'Verification', '', false),
        ],
      ),
    );
  }

  Widget _buildInterestsSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Interests',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Get specific about the things you love.',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () {
              _showInterestsDialog();
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  'Add your favorite interests',
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: 'Poppins',
                  ),
                ),
                Icon(Icons.add, color: Colors.black),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _selectedInterests.map((interest) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(16),
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
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'My causes and communities',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Add up to 3 causes close to your heart.',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () {},
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  'Add your causes and communities',
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: 'Poppins',
                  ),
                ),
                Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQualitiesSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Qualities I value',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Choose up to 3 qualities you value in a person',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _selectedQualities.map((quality) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: () {},
              child: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromptsSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Prompts',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Let people know what it\'s like to date you.',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () {},
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  'Add a prompt',
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: 'Poppins',
                  ),
                ),
                Icon(Icons.add, color: Colors.black),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOpeningMovesSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Opening moves',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Add 3 first messages your new matches can reply to.',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () {},
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  'Whats your ideal first date?',
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: 'Poppins',
                  ),
                ),
                Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBioSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Bio',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Write a fun intro.',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 16),
          TextField(
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
            style: const TextStyle(fontFamily: 'Poppins'),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutYouSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'About you',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 16),
          _buildListTile(Icons.cake, 'Age', '$_age', true),
          _buildListTile(Icons.work, 'Work', _work, true),
          _buildListTile(Icons.school, 'Education', _education, true),
          _buildListTile(Icons.person, 'Gender', _gender, true),
          _buildListTile(Icons.location_on, 'Location', _location, true),
          _buildListTile(Icons.home, 'Hometown', _hometown, true),
        ],
      ),
    );
  }

  Widget _buildMoreAboutYouSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'More about you',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 16),
          _buildListTile(Icons.height, 'Height', _height, true),
          _buildListTile(Icons.fitness_center, 'Exercise', _exercise, true),
          _buildListTile(Icons.school, 'Education level', _education, true),
          _buildListTile(Icons.local_drink, 'Drinking', _drinking, true),
          _buildListTile(Icons.smoking_rooms, 'Smoking', _smoking, true),
          _buildListTile(Icons.child_care, 'Kids', _kids, true),
          _buildListTile(Icons.family_restroom, 'Have kids', _haveKids, true),
          _buildListTile(Icons.stars, 'Zodiac', _zodiac, true),
          _buildListTile(Icons.how_to_vote, 'Politics', _politics, true),
          _buildListTile(Icons.temple_hindu, 'Religion', _religion, true),
        ],
      ),
    );
  }

  Widget _buildPronounsSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Pronouns',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Pick your pronouns',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () {},
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  'Add your pronouns',
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: 'Poppins',
                  ),
                ),
                Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguagesSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Languages',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              ..._selectedLanguages.map((lang) {
                return Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.language, size: 14, color: Colors.blue),
                      const SizedBox(width: 4),
                      Text(
                        lang,
                        style: const TextStyle(
                          fontSize: 12,
                          fontFamily: 'Poppins',
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildConnectedAccountsSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Connected accounts',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Show your favorite music',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.music_note, color: Colors.green, size: 20),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Connect my spotify',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Show your top spotify artists on your profile and allow blindly to highlight who have in common with others',
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey,
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
    );
  }

  Widget _buildListTile(IconData icon, String title, String trailing, bool showArrow) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontFamily: 'Poppins',
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
            const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
          ],
        ],
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
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
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
                        final isSelected = _selectedInterests.contains(interest);
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
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
