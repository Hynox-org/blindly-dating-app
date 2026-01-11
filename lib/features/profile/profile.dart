import 'package:flutter/material.dart';
import '../../core/widgets/app_layout.dart';
import '../../core/utils/navigation_utils.dart';
import '../home/screens/connection_type_screen.dart';
import '../home/component/ProfileSwipeCard.dart'; // Import for ProfileSwipeCard and UserProfile (local definition)

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return AppLayout(
      showFooter: true,
      selectedIndex: 0,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.more_vert, color: Colors.black),
          onPressed: () {
            NavigationUtils.navigateToWithSlide(
              context,
              const ConnectionTypeScreen(),
            );
          },
        ),
        title: const Text(
          'Profile',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.verified_outlined, color: Colors.black),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.black),
            onPressed: () {
              // TODO: Settings
            },
          ),
        ],
      ),
      child: Container(
        color: Colors.white,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      _buildHeader(),
                      const SizedBox(height: 24),
                      _buildPremiumBanner(),
                      const SizedBox(height: 24),
                      _buildActionButtons(),
                      const SizedBox(height: 24),
                      _buildScoreBreakdown(),
                      const SizedBox(height: 24),
                      _buildWaysToImprove(),
                      const SizedBox(height: 24),
                      _buildFooterNote(),
                      const SizedBox(height: 100), // Space for floating button
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Sticky-like button at the bottom (implemented via Stack or overlay in a real scaffold,
  // but here we can just put it in the scroll view or use a bottom sheet.
  // The UI shows it at the bottom. The requirement says "Use the app layout with the footer".
  // The AppLayout footer is the navigation bar. The "Improve your Profile" button is likely
  // part of the scrollable content or fixed above the nav bar.
  // Given the long scroll, I'll add it as a float or at the end of scroll.
  // The design shows it at the bottom, likely fixed.
  // I will append it to the scroll view for now, but to match "sticky" feel it might need a Stack.
  // However, AppLayout has a BottomNavigationBar.
  // Let's verify if 'Improve your Profile' should be pinned.
  // Usually such buttons are pinned.
  // But for now, let's put it at the end of the scroll view as per standard flow.

  Widget _buildHeader() {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 100,
              height: 100,
              child: CircularProgressIndicator(
                value: 0.35,
                strokeWidth: 4,
                backgroundColor: Colors.grey.shade200,
                color: const Color(0xFF4B5320), // Olive/Dark Green
              ),
            ),
            GestureDetector(
              onTap: _showProfilePopup,
              child: Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: const DecorationImage(
                    image: NetworkImage(
                      'https://picsum.photos/400/600',
                    ), // Placeholder
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF4B5320),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  '35%',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Vignesh, 27',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.verified, color: Colors.blue, size: 20),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            'Complete profile',
            style: TextStyle(fontSize: 12, color: Colors.black87),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'A higher score helps you get more\nauthentic matches',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: Colors.black87),
        ),
      ],
    );
  }

  void _showProfilePopup() {
    // Static dummy data matches ProfileSwipeCard's UserProfile definition
    final dummyProfile = UserProfile(
      id: '1',
      name: 'Vignesh',
      age: 27,
      distance: 0,
      bio: 'Lover of sunsets and coffee.',
      imageUrls: [
        'https://picsum.photos/400/600',
        'https://picsum.photos/400/601',
        'https://picsum.photos/400/602',
      ],
      height: '175 cm',
      activityLevel: 'Active',
      education: 'B.Tech',
      gender: 'Male',
      religion: 'Hindu',
      zodiac: 'Taurus',
      drinking: 'Socially',
      smoking: 'Never',
      hobbies: ['Photography', 'Travel', 'Coding'],
      summary:
          'I am a software engineer who loves to travel and explore new places.',
      lookingFor: 'A serious relationship',
      lookingForTags: ['Long-term', 'Partner'],
      quickestWay: 'Cook me a good meal',
      causes: ['Environment', 'Animal Welfare'],
      simplePleasure: 'Morning coffee',
      languages: ['English', 'Tamil'],
      location: 'Chennai, India',
      spotifyArtists: ['A.R. Rahman', 'Anirudh'],
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: const Color.fromARGB(255, 255, 255, 255),
          insetPadding: EdgeInsets.zero,
          child: SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Profile Card with Padding for Buttons
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
                      profile: dummyProfile,
                      horizontalThreshold: 0,
                      verticalThreshold: 0,
                      isHomeScreen: false,
                      isProfileScreen: false,
                    ),
                  ),
                ),

                // Close Button (Fixed at Top Right)
                Positioned(
                  top: 10,
                  right: 10,
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: CircleAvatar(
                      backgroundColor: const Color.fromARGB(255, 0, 0, 0),
                      radius: 20,
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),

                // Edit Button (Fixed at Bottom Center)
                Positioned(
                  bottom: 10,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.6,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).pop();
                          // TODO: Navigate to Edit Profile
                        },
                        icon: const Icon(Icons.edit, color: Colors.white),
                        label: const Text(
                          'Edit Profile',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromRGBO(65, 72, 51, 1),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 5,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPremiumBanner() {
    return Container(
      width: double.infinity,
      height: 180,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(16),
        image: const DecorationImage(
          image: NetworkImage(
            'https://picsum.photos/800/400',
          ), // Placeholder for couple image
          fit: BoxFit.cover,
          opacity: 0.6,
        ),
      ),
      child: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'PREMIUM',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Get noticed sooner and\ngo on 3x as many dates',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE4C687), // Goldish
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 12,
                    ),
                  ),
                  child: const Text(
                    'Upgrade',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: _buildActionCard(
            icon: Icons.cyclone, // Placeholder for Spotlight
            title: 'Spot light',
            subtitle: 'Stand out',
            color: const Color(0xFFF5F5F5),
            iconColor: const Color(0xFF6B5E3C), // Dark Gold
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildActionCard(
            icon: Icons.star,
            title: 'Super swipe',
            subtitle: 'Get noticed',
            color: const Color(0xFFF5F5F5),
            iconColor: const Color(0xFF4B5320), // Dark Green
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.2), // Lighter shade background
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.black,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScoreBreakdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Score breakdown',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 12),
        _buildScoreItem(
          icon: Icons.person_outline,
          title: 'Profile photo verified',
          status: 'Completed',
          isCompleted: true,
        ),
        const SizedBox(height: 8),
        _buildScoreItem(
          icon: Icons.person_outline,
          title: 'Profile details',
          status: 'Completed',
          isCompleted: true,
        ),
        const SizedBox(height: 8),
        _buildScoreItem(
          icon: Icons.link,
          title: 'Connect social accounts',
          status: 'Incomplete',
          isCompleted: false,
        ),
      ],
    );
  }

  Widget _buildScoreItem({
    required IconData icon,
    required String title,
    required String status,
    required bool isCompleted,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.black87),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        trailing: Text(
          status,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isCompleted ? Colors.green : Colors.orange,
          ),
        ),
      ),
    );
  }

  Widget _buildWaysToImprove() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ways to improve',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 12),
        _buildImproveItem(
          icon: Icons.camera_alt_outlined,
          title: 'Verify your photos',
          subtitle: 'Prove you\'re real to other members',
        ),
        const SizedBox(height: 8),
        _buildImproveItem(
          icon: Icons.check_circle_outline,
          title: 'Complete your profile',
          subtitle: 'Add prompts, interests and other details',
        ),
      ],
    );
  }

  Widget _buildImproveItem({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.black87),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontSize: 12, color: Colors.black54),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.black54,
        ),
      ),
    );
  }

  Widget _buildFooterNote() {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text.rich(
            TextSpan(
              text:
                  'You\'re verification data is handled secured and is not shared on your public profile. ',
              style: TextStyle(color: Colors.black54, fontSize: 12),
              children: [
                TextSpan(
                  text: 'Learn more',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4B5320), // Dark Green/Olive
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Improve your Profile',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }
}
