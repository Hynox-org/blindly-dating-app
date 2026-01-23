import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // ✅ Added Riverpod

import '../../core/widgets/app_layout.dart';
import '../../core/utils/navigation_utils.dart';
import '../home/screens/connection_type_screen.dart';
import '../home/component/ProfileSwipeCard.dart'; 
import '../discovery/domain/models/discovery_user_model.dart'; // Needed for UserProfile mapping
import './profile_edit_screen.dart';

// ✅ Import Provider & Model
import '../profile/domain/models/profile_user_model.dart.dart';
import '../profile/provider/profile_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget { // ✅ Changed to ConsumerStatefulWidget
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    // ✅ Watch the provider
    final userAsync = ref.watch(currentUserProfileProvider);

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
        child: userAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: Color(0xFF4B5320)),
          ),
          error: (err, stack) => Center(child: Text("Error loading profile")),
          data: (user) {
            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        children: [
                          const SizedBox(height: 20),
                          // ✅ Pass Real User Data
                          _buildHeader(user),
                          const SizedBox(height: 24),
                          _buildPremiumBanner(),
                          const SizedBox(height: 24),
                          _buildActionButtons(),
                          const SizedBox(height: 24),
                          _buildScoreBreakdown(user),
                          const SizedBox(height: 24),
                          _buildWaysToImprove(),
                          const SizedBox(height: 24),
                          _buildFooterNote(),
                          const SizedBox(height: 100), 
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // ✅ Updated to accept ProfileUser
  Widget _buildHeader(ProfileUser user) {
    // Calculate percentage integer (e.g., 0.35 -> 35)
    final int percentInt = (user.completionPercentage * 100).toInt();

    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 100,
              height: 100,
              child: CircularProgressIndicator(
                value: user.completionPercentage, // ✅ Real Value
                strokeWidth: 4,
                backgroundColor: Colors.grey.shade200,
                color: const Color(0xFF4B5320), 
              ),
            ),
            GestureDetector(
              onTap: () => _showProfilePopup(user),
              child: Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    // ✅ Real Primary Image
                    image: NetworkImage(
                      user.imageUrls.isNotEmpty 
                          ? user.imageUrls.first 
                          : 'https://picsum.photos/400/600'
                    ),
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
                child: Text(
                  '$percentInt%', // ✅ Real Text
                  style: const TextStyle(
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
            Text(
              '${user.name}, ${user.age}', // ✅ Real Name & Age
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(width: 4),
            // Only show verified check if verified (assuming logic exists, else static for now)
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
          child: Text(
            percentInt == 100 ? 'Profile Completed' : 'Complete profile',
            style: const TextStyle(fontSize: 12, color: Colors.black87),
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

  // ✅ Updated to map DB data to SwipeCard
  void _showProfilePopup(ProfileUser user) {
    
    // Mapping ProfileUser (DB) to UserProfile (UI Component)
    // We use Default Data for fields missing in your DB Schema
    final realProfile = UserProfile(
      id: user.id,
      name: user.name,
      age: user.age,
      distance: 0, 
      bio: user.bio.isNotEmpty ? user.bio : 'No bio added yet.',
      // ✅ IMAGE LOGIC: This list will have 2 or 3 images based on provider fetch
      imageUrls: user.imageUrls, 
      height: 'Ask me', // Default (Not in DB)
      activityLevel: 'Active', // Default
      education: 'Add Education', // Default (Not in DB)
      gender: user.gender,
      religion: 'Add Religion', // Default
      zodiac: 'Add Zodiac', // Default
      drinking: 'Socially', // Default
      smoking: 'Never', // Default
      hobbies: user.interests.isNotEmpty ? user.interests : ['Add Interests'],
      summary: user.bio,
      lookingFor: 'Connection', // Default
      lookingForTags: [],
      quickestWay: 'Ask me',
      causes: [],
      simplePleasure: 'Ask me',
      languages: ['English'], // Default
      location: user.city.isNotEmpty ? user.city : 'Unknown',
      spotifyArtists: [],
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
                      profile: realProfile, // ✅ Passing the real data
                      horizontalThreshold: 0,
                      verticalThreshold: 0,
                      isHomeScreen: false,
                      // isProfileScreen: true, // Uncomment if your card supports this flag
                    ),
                  ),
                ),

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

                Positioned(
                  bottom: 10,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.6,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context); // Close popup first
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ProfileEditScreen(),
                            ),
                          );
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
                            borderRadius: BorderRadius.circular(20),
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

  // ... (Rest of your UI widgets: _buildPremiumBanner, _buildActionButtons, etc. remain UNCHANGED)

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
          ), 
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
            icon: Icons.cyclone, 
            title: 'Spot light',
            subtitle: 'Stand out',
            color: const Color(0xFFF5F5F5),
            iconColor: const Color(0xFF6B5E3C), 
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildActionCard(
            icon: Icons.star,
            title: 'Super swipe',
            subtitle: 'Get noticed',
            color: const Color(0xFFF5F5F5),
            iconColor: const Color(0xFF4B5320), 
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
              color: iconColor.withOpacity(0.2), 
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

  Widget _buildScoreBreakdown(ProfileUser user) {
    // Determine status based on actual data
    bool detailsComplete = user.bio.isNotEmpty && user.interests.isNotEmpty;

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
          status: 'Completed', // Assuming verified for now
          isCompleted: true,
        ),
        const SizedBox(height: 8),
        _buildScoreItem(
          icon: Icons.person_outline,
          title: 'Profile details',
          status: detailsComplete ? 'Completed' : 'Incomplete',
          isCompleted: detailsComplete,
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
            onPressed: () {
               Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileEditScreen()),
              );
            },
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