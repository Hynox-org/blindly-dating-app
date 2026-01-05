import 'package:flutter/material.dart';
import 'profile_edit_screen.dart';
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
        child: Column(
          children: [
            _buildProfilePhotoSection(),
            const SizedBox(height: 20),
            _buildAboutMeSection(),
            const SizedBox(height: 16),
            _buildLookingForSection(),
            const SizedBox(height: 16),
            _buildInterestsSection(),
            const SizedBox(height: 16),
            _buildLanguagesSection(),
            const SizedBox(height: 16),
            _buildLocationSection(),
            const SizedBox(height: 20),
            _buildEditProfileButton(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildProfilePhotoSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      height: 560,
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2C),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.image, color: Colors.white54, size: 48),
                SizedBox(height: 8),
                Text(
                  'Photo',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 16,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 16,
            left: 16,
            child: const Text(
              'Vignesh, 27',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutMeSection() {
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
            'About me',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildAboutChip('📏 $_height', Colors.blue),
              const SizedBox(width: 8),
              _buildAboutChip('⚡ $_activityLevel', Colors.purple),
              const SizedBox(width: 8),
              _buildAboutChip('🎓 $_education', Colors.orange),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildAboutChip('👤 $_gender', Colors.blue),
              const SizedBox(width: 8),
              _buildAboutChip('🕉️ $_religion', Colors.orange),
              const SizedBox(width: 8),
              _buildAboutChip('♉ $_zodiac', Colors.brown),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildAboutChip('🍺 $_drinking', Colors.green),
              const SizedBox(width: 8),
              _buildAboutChip('🚭 $_smoking', Colors.red),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAboutChip(String text, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            fontFamily: 'Poppins',
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildLookingForSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'I\'m looking for',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _selectedLookingFor.map((item) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Text(
                    item,
                    style: const TextStyle(
                      fontSize: 12,
                      fontFamily: 'Poppins',
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInterestsSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'My interests',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _selectedInterests.map((item) {
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
                      _getInterestIcon(item),
                      const SizedBox(width: 6),
                      Text(
                        item,
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
          ),
        ],
      ),
    );
  }

  Widget _getInterestIcon(String interest) {
    final Map<String, String> icons = {
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
    return Text(icons[interest] ?? '🎯', style: const TextStyle(fontSize: 16));
  }

  Widget _buildLanguagesSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      width: double.infinity,
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
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _selectedLanguages.map((lang) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.language, size: 16, color: Colors.blue),
                      const SizedBox(width: 6),
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
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationSection() {
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
            'My location',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.location_on, size: 20, color: Colors.black),
              const SizedBox(width: 8),
              Text(
                _location,
                style: const TextStyle(
                  fontSize: 14,
                  fontFamily: 'Poppins',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEditProfileButton() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ProfileEditScreen(),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromRGBO(65, 72, 51, 1),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: const Text(
          'Edit profile',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

