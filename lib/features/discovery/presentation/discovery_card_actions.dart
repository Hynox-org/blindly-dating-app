import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:blindly_dating_app/l10n/app_localizations.dart';
import 'package:blindly_dating_app/core/utils/navigation_utils.dart';
import 'package:blindly_dating_app/features/discovery/presentation/screens/discovery_profile_detail_screen.dart';
import 'package:blindly_dating_app/features/matching/domain/models/match_profile.dart';
import 'package:blindly_dating_app/features/matching/provider/swipe_provider.dart';

/// What a [DiscoveryProfileCard] can do, shared by the carousels and the
/// "See all" grid. Both screens hold the same three pieces of state, so they
/// hold them here instead of twice.
mixin DiscoveryCardActions<T extends ConsumerStatefulWidget>
    on ConsumerState<T> {
  /// Actions taken in this session, layered over the server's `swipeAction`
  /// so a like drawn here survives until the next refresh.
  /// Not final: the "See all" grid points this at the carousel's own map, so
  /// a like made in either place is visible in both without any plumbing.
  Map<String, String> userInteractions = {};

  final AudioPlayer audioPlayer = AudioPlayer();
  String? playingProfileId;

  AppLocalizations get l10n => AppLocalizations.of(context);

  void initCardActions() {
    audioPlayer.onPlayerComplete.listen((_) {
      if (mounted) setState(() => playingProfileId = null);
    });
  }

  void disposeCardActions() => audioPlayer.dispose();

  String interactionFor(MatchProfile user) =>
      userInteractions[user.profileId] ?? user.swipeAction ?? 'none';

  bool isPlaying(MatchProfile user) => playingProfileId == user.profileId;

  Future<void> stopVoice() async {
    if (playingProfileId == null) return;
    await audioPlayer.stop();
    if (mounted) setState(() => playingProfileId = null);
  }

  Future<void> toggleVoice(MatchProfile user) async {
    if (playingProfileId == user.profileId) return stopVoice();
    if (user.voiceIntroUrl == null) return;

    await audioPlayer.stop();
    await audioPlayer.play(UrlSource(user.voiceIntroUrl!));
    if (mounted) setState(() => playingProfileId = user.profileId);
  }

  Future<void> openProfile(MatchProfile user) async {
    await stopVoice(); // audio used to keep playing behind the profile

    if (!mounted) return;
    final result = await NavigationUtils.navigateToWithSlide<String>(
      context,
      DiscoveryProfileDetailScreen(
        user: user,
        initialState: interactionFor(user),
      ),
    );

    if (result != null && mounted) {
      setState(() => userInteractions[user.profileId] = result);
    }
  }

  Future<void> undo(MatchProfile user) async {
    try {
      // Naming the profile matters: without it the backend reverts whatever
      // this user swiped most recently, anywhere in the app.
      final ok = await ref
          .read(swipeProvider.notifier)
          .undo(targetProfileId: user.profileId);

      if (!mounted) return;
      if (ok) {
        setState(() => userInteractions[user.profileId] = 'none');
      } else {
        toast(l10n.somethingWentWrong);
      }
    } catch (e) {
      debugPrint('Undo error: $e');
      if (mounted) toast(l10n.somethingWentWrong);
    }
  }

  void toast(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
