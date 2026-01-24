import 'package:flutter/material.dart';
import '../../../../core/widgets/app_layout.dart';
import '../../../../core/utils/navigation_utils.dart';
import '../../../../features/home/screens/connection_type_screen.dart';

class DiscoverScreen extends StatelessWidget {
  const DiscoverScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      showFooter: true,
      selectedIndex: 1, // Discover tab index
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
          'Discover',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      child: Container(
        color: Colors.white,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSection(
                title: 'Similar Interest',
                profiles: _similarInterestProfiles,
              ),
              const SizedBox(height: 24),
              _buildSection(
                title: 'Same Dating Goals',
                profiles: _sameGoalsProfiles,
              ),
              const SizedBox(height: 24),
              _buildSection(
                title: 'Communities in Common',
                profiles: _communitiesProfiles,
              ),
              const SizedBox(height: 100), // Space for footer
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Map<String, dynamic>> profiles,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 220, // Height for the cards
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: profiles.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final profile = profiles[index];
              return _buildDiscoverCard(profile);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDiscoverCard(Map<String, dynamic> profile) {
    return Container(
      width: 160,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: const Color(0xFFF5F5F5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Section
          Expanded(
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  child: Image.network(
                    profile['image'],
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                // Overlay Gradient
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.6),
                        ],
                      ),
                    ),
                    child: Text(
                      profile['tag'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Info Section
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${profile['name']}, ${profile['age']}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const Icon(
                  Icons.favorite_border,
                  size: 20,
                  color: Colors.black54,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Static Data
  final List<Map<String, dynamic>> _similarInterestProfiles = const [
    {
      'name': 'V',
      'age': 27,
      'image': 'https://randomuser.me/api/portraits/women/44.jpg',
      'tag': 'Art, Draw...',
    },
    {
      'name': 'V',
      'age': 27,
      'image': 'https://randomuser.me/api/portraits/women/68.jpg',
      'tag': 'Art, Draw...',
    },
    {
      'name': 'V',
      'age': 27,
      'image': 'https://randomuser.me/api/portraits/men/32.jpg',
      'tag': 'Art, Draw...',
    },
  ];

  final List<Map<String, dynamic>> _sameGoalsProfiles = const [
    {
      'name': 'V',
      'age': 27,
      'image': 'https://randomuser.me/api/portraits/women/65.jpg',
      'tag': 'Art, Draw...',
    },
    {
      'name': 'V',
      'age': 27,
      'image': 'https://randomuser.me/api/portraits/women/90.jpg',
      'tag': 'Art, Draw...',
    },
    {
      'name': 'V',
      'age': 27,
      'image': 'https://randomuser.me/api/portraits/men/45.jpg',
      'tag': 'Art, Draw...',
    },
  ];

  final List<Map<String, dynamic>> _communitiesProfiles = const [
    {
      'name': 'V',
      'age': 27,
      'image': 'https://randomuser.me/api/portraits/women/22.jpg',
      'tag': 'Art, Draw...',
    },
    {
      'name': 'V',
      'age': 27,
      'image': 'https://randomuser.me/api/portraits/women/29.jpg',
      'tag': 'Art, Draw...',
    },
    {
      'name': 'V',
      'age': 27,
      'image': 'https://randomuser.me/api/portraits/men/11.jpg',
      'tag': 'Art, Draw...',
    },
  ];
}