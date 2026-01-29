import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/app_loader.dart';
import '../../../core/widgets/app_layout.dart';
import '../../../core/utils/navigation_utils.dart';
import '../../features/home/screens/connection_type_screen.dart';

import '../../features/match/provider/liked_you_provider.dart';
import '../../features/match/domain/models/liked_you_user_model.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/profile/profile.dart';

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
          icon: Icon(
            Icons.more_vert,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          onPressed: () {
            NavigationUtils.navigateToWithSlide(
              context,
              const ConnectionTypeScreen(),
            );
          },
        ),
        title: Text(
          'Liked You',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      child: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: likedYouState.when(
          loading: () => const AppLoader(),
          error: (e, _) => _buildErrorState(),
          data: (users) {
            final likeCount = users.length;

            // ✅ Empty State: Full Screen, White Background, No Header
            if (users.isEmpty) {
              return Container(
                color: Theme.of(context).scaffoldBackgroundColor,
                width: double.infinity,
                child: _buildEmptyState(),
              );
            }

            return Column(
              children: [
                _buildHeader(likeCount),

                Expanded(
                  child: GridView.builder(
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
      color: Theme.of(context).cardColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "See Who's Interested",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          RichText(
            text: TextSpan(
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
              children: [
                const TextSpan(text: 'You have '),
                TextSpan(
                  text: '$likeCount likes',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
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
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Center(
        child: Icon(
          Icons.person,
          size: 80,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  // --------------------------------------------------
  // EMPTY
  // --------------------------------------------------
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/static/liked_you_empty_state.png',
              height: 200,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 24),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: "No likes yet, but don't\n",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                      height: 1.2,
                      decorationColor: Theme.of(
                        context,
                      ).colorScheme.tertiary, // Adjust color to match reference
                      decorationThickness: 2,
                    ),
                  ),
                  TextSpan(
                    text: "buzz off!",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                      height: 1.5,
                      decorationColor: Theme.of(context).colorScheme.tertiary,
                      decorationThickness: 2,
                    ),
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              "Keep swiping to find your honey.\nSomeone is bound to like you soon!",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const HomeScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.primary, // Using primary
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Start Swiping',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                NavigationUtils.navigateToWithSlide(
                  context,
                  const ProfileScreen(),
                );
              },
              child: Text(
                'Improve Profile',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return const Center(child: Text('Failed to load likes'));
  }

  // --------------------------------------------------
  // UNLOCK BUTTON (UNCHANGED)
  // --------------------------------------------------
  Widget _buildUnlockButton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).scaffoldBackgroundColor,
      child: SafeArea(
        child: ElevatedButton(
          onPressed: null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            'Unlock all likes',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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
  return Builder(
    builder: (context) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              // Icon(icon, size: 16, color: Colors.Black),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
