import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:blindly_dating_app/core/utils/nav_key.dart';
import 'package:blindly_dating_app/features/matching/presentation/screens/shared_profile_screen.dart';

class DeepLinkService {
  DeepLinkService._();
  static final DeepLinkService instance = DeepLinkService._();

  late AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;

  // Track if we've already handled the initial link to avoid double-handling
  bool _initialUriIsHandled = false;

  void initDeepLinks() {
    _appLinks = AppLinks();

    // 1. Handle Active Links (App is in background and user clicks a link)
    _linkSubscription = _appLinks.uriLinkStream.listen(
      (uri) {
        debugPrint('DeepLinkService: Received active link: $uri');
        _handleDeepLink(uri);
      },
      onError: (err) {
        debugPrint('DeepLinkService: Error listening to links: $err');
      },
    );

    // 2. Handle Initial Link (App was dead/closed and user clicks a link to launch it)
    _checkInitialLink();
  }

  Future<void> _checkInitialLink() async {
    try {
      if (!_initialUriIsHandled) {
        final initialUri = await _appLinks.getInitialLink();
        _initialUriIsHandled = true;
        if (initialUri != null) {
          debugPrint('DeepLinkService: Received initial link: $initialUri');
          _handleDeepLink(initialUri);
        }
      }
    } catch (e) {
      debugPrint('DeepLinkService: Error grabbing initial link: $e');
    }
  }

  void _handleDeepLink(Uri uri) {
    if ((uri.scheme == 'https' || uri.scheme == 'http') &&
        uri.host == 'app.blindly.com') {
      // the path will be /profile/[id], so segments are ['profile', '[id]']
      if (uri.pathSegments.isNotEmpty && uri.pathSegments.first == 'profile') {
        final String profileId = uri.pathSegments.length > 1
            ? uri.pathSegments[1]
            : '';
        if (profileId.isNotEmpty) {
          debugPrint("DeepLinkService: Routing to profile ID: $profileId");

          if (navigatorKey.currentState != null) {
            navigatorKey.currentState!.push(
              MaterialPageRoute(
                builder: (context) => SharedProfileScreen(profileId: profileId),
              ),
            );
          } else {
            debugPrint(
              "DeepLinkService: navigatorKey state is null. Can't route.",
            );
          }
        }
      }
    }
  }

  void dispose() {
    _linkSubscription?.cancel();
  }
}
