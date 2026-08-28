import 'package:blindly_dating_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

import 'package:blindly_dating_app/core/utils/navigation_utils.dart';
import 'package:blindly_dating_app/features/chat/presentation/screens/chat_screen.dart';

/// Shown the moment a swipe turns into a match, from the deck or the likes
/// screen. Both call this rather than each growing their own celebration.
Future<void> showMatchDialog(BuildContext context, String name) {
  final l10n = AppLocalizations.of(context);
  final scheme = Theme.of(context).colorScheme;

  return showDialog(
    context: context,
    builder: (dialogContext) => Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/static/match_illustration.png',
              height: 180,
              errorBuilder: (_, _, _) => const SizedBox(height: 180),
            ),
            const SizedBox(height: 20),
            Text(
              l10n.itsAMatch,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: scheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.youAndThemLiked(name),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: scheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                  NavigationUtils.navigateToWithSlide(
                    context,
                    const ChatScreen(),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: scheme.primary,
                  foregroundColor: scheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  l10n.sendMessage,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                l10n.keepSwiping,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: scheme.onSurface,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
