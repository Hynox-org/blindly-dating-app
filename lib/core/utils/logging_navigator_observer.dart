import 'package:flutter/material.dart';
import 'app_logger.dart';

class LoggingNavigatorObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _logRoute(route);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    if (previousRoute != null) {
      _logRoute(previousRoute);
    }
  }

  void _logRoute(Route<dynamic> route) {
    if (route is PageRoute) {
      final String? screenName = route.settings.name;
      if (screenName != null && screenName.isNotEmpty) {
        // Special mapping for routes if needed, or just log the name
        String displayLabel = screenName;

        // If route name is '/', it's SplashScreen
        if (displayLabel == '/') displayLabel = 'SplashScreen';

        AppLogger.logScreenRender(displayLabel);
      } else {
        // Fallback for cases where route name is not set (e.g. MaterialPageRoute without settings)
        // We can try to extract the widget type if it's a MaterialPageRoute
        // But for now, we rely on route names from our router map
        AppLogger.info('Navigated to unnamed route: ${route.runtimeType}');
      }
    }
  }
}
