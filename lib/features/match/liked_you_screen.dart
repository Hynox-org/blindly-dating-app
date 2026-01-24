import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/app_layout.dart';
import '../../../core/utils/navigation_utils.dart';
import '../../features/home/screens/connection_type_screen.dart';

import '../../features/match/provider/liked_you_provider.dart';
import '../../features/match/domain/models/liked_you_user_model.dart';

class LikedYouScreen extends ConsumerStatefulWidget {
  const LikedYouScreen({super.key});

  @override
  ConsumerState<LikedYouScreen> createState() => _LikedYouScreenState();
}

class _LikedYouScreenState extends ConsumerState<LikedYouScreen> {
  @override
  void initState() {
    super.initState();

    // // // 🔄 Fetch fresh data every time screen opens
    // // Future.microtask(() {
    // //   ref.read(likedYouProvider.notifier).refresh();
    // });
  }

  @override
  Widget build(BuildContext context) {
    final likedYouState = ref.watch(likedYouProvider);

    return AppLayout(
      showFooter: true,
      selectedIndex: 3,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
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
          'Liked You',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      child: Container(
        color: const Color(0xFFF5F5F5),
        child: likedYouState.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => _buildErrorState(),
          data: (users) {
            final likeCount = users.length;

            return Column(
              children: [
                _buildHeader(likeCount),

                Expanded(
                  child: users.isEmpty
                      ? _buildEmptyState()
                      : GridView.builder(
                          padding: const EdgeInsets.all(16),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                                childAspectRatio: 0.75,
                              ),
                          itemCount: users.length,
                          itemBuilder: (context, index) {
                            return _buildProfileCard(users[index]);
                          },
                        ),
                ),

                _buildUnlockButton(),
              ],
            );
          },
        ),
      ),
    );
  }

  // --------------------------------------------------
  // HEADER
  // --------------------------------------------------
  Widget _buildHeader(int likeCount) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "See Who's Interested",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          RichText(
            text: TextSpan(
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.4,
              ),
              children: [
                const TextSpan(text: 'You have '),
                TextSpan(
                  text: '$likeCount likes',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const TextSpan(text: ' waiting for you.'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------
  // PROFILE CARD WITH MATCH / PASS BUTTONS
  // --------------------------------------------------
  Widget _buildProfileCard(LikedYouUser user) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Image
          user.hasImage
              ? Image.network(
                  user.imageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _imageFallback(),
                )
              : _imageFallback(),

          // Gradient overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black.withOpacity(0.65)],
              ),
            ),
          ),

          // Name + age
          Positioned(
            left: 12,
            right: 12,
            bottom: 64,
            child: Text(
              '${user.displayName}, ${user.age}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // 🔥 ACTION BUTTONS
          Positioned(
            left: 10,
            right: 10,
            bottom: 10,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _overlayActionButton(
                  label: 'Like',
                  // icon: Icons.favorite_border,
                  onTap: () async {
                    await ref
                        .read(likedYouProvider.notifier)
                        .matchUser(user.profileId);
                  },
                ),

                _overlayActionButton(
                  label: 'Pause',
                  // icon: Icons.pause,
                  onTap: () async {
                    await ref
                        .read(likedYouProvider.notifier)
                        .passUser(user.profileId);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _imageFallback() {
    return Container(
      color: Colors.grey[700],
      child: const Center(
        child: Icon(Icons.person, size: 80, color: Colors.white54),
      ),
    );
  }

  // --------------------------------------------------
  // EMPTY
  // --------------------------------------------------
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite_border, size: 100, color: Colors.grey[400]),
          const SizedBox(height: 20),
          Text(
            'No likes yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return const Center(
      child: Text(
        'Failed to load likes',
      ),
    );
  }

  // --------------------------------------------------
  // UNLOCK BUTTON (UNCHANGED)
  // --------------------------------------------------
  Widget _buildUnlockButton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: SafeArea(
        child: ElevatedButton(
          onPressed: null,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4A5A4A),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            'Unlock all likes',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

//--------------------------------------------------
//HELPER FUNCTION FOR ACTION BUTTONS
//--------------------------------------------------
Widget _overlayActionButton({
  required String label,
  // required IconData icon,
  required VoidCallback onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          // Icon(icon, size: 16, color: Colors.Black),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    ),
  );
}