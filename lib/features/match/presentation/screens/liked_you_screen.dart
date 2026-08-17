import 'package:blindly_dating_app/l10n/app_localizations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/connection_mode_provider.dart';
import '../../../../core/utils/navigation_utils.dart';
import '../../../../core/widgets/app_layout.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../../../core/widgets/marquee_text.dart';
import '../../../../core/widgets/match_dialog.dart';
import '../../../discovery/domain/models/discovery_user_model.dart'
    show RelationshipState;
import '../../../discovery/presentation/screens/discovery_profile_detail_screen.dart';
import '../../../discovery/repository/discovery_repository.dart';
import '../../../home/screens/connection_type_screen.dart';
import '../../../home/screens/home_screen.dart';
import '../../../profile/profile.dart';
import '../../domain/models/liked_you_user_model.dart';
import '../../provider/liked_you_provider.dart';

/// Who liked or super liked you. Super likes come first — the RPC orders,
/// this screen just renders. Match and Pass are ordinary swipes recorded
/// through the same path the deck uses.
class LikedYouScreen extends ConsumerStatefulWidget {
  const LikedYouScreen({super.key});

  @override
  ConsumerState<LikedYouScreen> createState() => _LikedYouScreenState();
}

class _LikedYouScreenState extends ConsumerState<LikedYouScreen> {
  AppLocalizations get l10n => AppLocalizations.of(context);

  /// Guards against a second tap while a profile is being fetched.
  bool _opening = false;

  @override
  void initState() {
    super.initState();
    // Fresh data every time the screen opens, without a spinner.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(likedYouProvider.notifier).refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      showFooter: true,
      selectedIndex: 3,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.more_vert,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          onPressed: () => NavigationUtils.navigateToWithSlide(
            context,
            const ConnectionTypeScreen(),
          ),
        ),
        title: Text(
          l10n.likedYou,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
      ),
      child: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: ref.watch(likedYouProvider).when(
              skipLoadingOnReload: true,
              loading: () => const AppLoader(),
              error: (_, __) => Center(child: Text(l10n.failedToLoadLikes)),
              data: (users) =>
                  users.isEmpty ? _buildEmptyState() : _buildGrid(users),
            ),
      ),
    );
  }

  // --------------------------------------------------
  // GRID
  // --------------------------------------------------
  Widget _buildGrid(List<LikedYouUser> users) {
    return Column(
      children: [
        _buildHeader(users.length),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.75,
            ),
            itemCount: users.length,
            itemBuilder: (context, index) => _buildProfileCard(users[index]),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(int likeCount) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.seeWhosInterested,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.matchInstantly('$likeCount'),
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------
  // CARD
  // --------------------------------------------------
  Widget _buildProfileCard(LikedYouUser user) {
    return GestureDetector(
      onTap: () => _openProfile(user),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          fit: StackFit.expand,
          children: [
            user.hasImage
                ? CachedNetworkImage(
                    imageUrl: user.imageUrl!,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => _imageFallback(),
                    errorWidget: (_, __, ___) => _imageFallback(),
                  )
                : _imageFallback(),

            // Gradient so the name and buttons stay readable on any photo.
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.9),
                  ],
                ),
              ),
            ),

            if (user.isSuperLike)
              Positioned(top: 10, left: 10, child: _superLikeBadge()),

            Positioned(
              left: 12,
              right: 12,
              bottom: 48,
              child: MarqueeText(
                text: '${user.displayName}, ${user.age}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            Positioned(
              left: 10,
              right: 10,
              bottom: 10,
              // Expanded, not intrinsic width: translated labels are longer
              // than "Match"/"Pass" and used to overflow the card.
              child: Row(
                children: [
                  Expanded(
                    child: _actionButton(
                      l10n.matchLabel,
                      () => _respond(user, match: true),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _actionButton(
                      l10n.passLabel,
                      () => _respond(user, match: false),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Answering someone who liked you always makes a match when you match
  /// back — worth saying so.
  Future<void> _respond(LikedYouUser user, {required bool match}) async {
    final matched =
        await ref.read(likedYouProvider.notifier).respond(user, match: match);
    if (matched && mounted) showMatchDialog(context, user.displayName);
  }

  Widget _superLikeBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.blue.shade600,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star, color: Colors.white, size: 14),
          const SizedBox(width: 4),
          Text(
            l10n.superLiked,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton(String label, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          // scaleDown keeps a long label readable instead of clipping it.
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              maxLines: 1,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
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
  // OPEN PROFILE
  // --------------------------------------------------
  /// Opens the same profile detail the rest of the app uses. Its Match/Pass
  /// buttons record the swipe themselves — the trigger turns a like-back into
  /// the match — so afterwards the list only needs a refresh.
  ///
  /// A loading barrier goes up on the first frame of the tap: the fetch is one
  /// RPC now, but the tap must land visibly either way.
  Future<void> _openProfile(LikedYouUser user) async {
    if (_opening) return;
    _opening = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: AppLoader()),
    );

    try {
      final repo = ref.read(discoveryRepositoryProvider);
      final mode = ref.read(connectionModeProvider);

      // The liker might only be active in the other mode, so fall back once
      // before giving up.
      var full = await repo.getDiscoveryUser(user.profileId, mode: mode);
      full ??= await repo.getDiscoveryUser(
        user.profileId,
        mode: mode.toLowerCase() == 'date' ? 'bff' : 'date',
      );

      if (!mounted) return;
      Navigator.pop(context); // drop the loading barrier
      if (full == null) return;

      final result = await NavigationUtils.navigateToWithSlide<String>(
        context,
        DiscoveryProfileDetailScreen(
          user: full.copyWith(relationship: RelationshipState.likedMe),
        ),
      );
      if (result == 'liked' || result == 'passed') {
        ref.read(likedYouProvider.notifier).refresh();
      }
    } catch (e) {
      debugPrint('❌ Failed to open liked-you profile: $e');
      if (mounted) Navigator.pop(context);
    } finally {
      _opening = false;
    }
  }

  // --------------------------------------------------
  // EMPTY
  // --------------------------------------------------
  Widget _buildEmptyState() {
    // Scrollable and flexible: the illustration plus two buttons overflowed a
    // short screen when it was a plain centred Column.
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
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
                  TextSpan(text: l10n.noLikesYet),
                  TextSpan(text: l10n.buzzOff),
                ],
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                  height: 1.3,
                ),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              l10n.keepSwipingBody,
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
                onPressed: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const HomeScreen()),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  l10n.startSwiping,
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
              onPressed: () => NavigationUtils.navigateToWithSlide(
                context,
                const ProfileScreen(),
              ),
              child: Text(
                l10n.improveProfile,
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
}
