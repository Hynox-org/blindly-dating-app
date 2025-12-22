import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/utils/app_logger.dart';
import '../../../core/utils/nav_key.dart';

/// A provider that listens to Supabase auth state changes and redirects accordingly.
final authStateListenerProvider = Provider<void>((ref) {
  // This provider is just a placeholder if we wanted to put logic here,
  // but for navigation we prefer the widget wrapper or using the global key here.
  // We'll keep the logic in the wrapper for lifecycle management or move it here.
  // Moving logic here is cleaner if we use the global key.
});

// We'll create a wrapper widget to handle the navigation with context
class AuthStateListenerWrapper extends ConsumerStatefulWidget {
  final Widget child;
  const AuthStateListenerWrapper({super.key, required this.child});

  @override
  ConsumerState<AuthStateListenerWrapper> createState() =>
      _AuthStateListenerWrapperState();
}

class _AuthStateListenerWrapperState
    extends ConsumerState<AuthStateListenerWrapper> {
  @override
  void initState() {
    super.initState();

    // Listen to manual sign outs or expiries
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      if (!mounted) return;

      final event = data.event;
      if (event == AuthChangeEvent.signedOut) {
        AppLogger.info(
          'AUTH_STATE_LISTENER: User signed out. Redirecting to /welcome',
        );

        // Use global navigator key to ensure we can navigate even if this widget
        // is placed above the Navigator (e.g. in MaterialApp.builder)
        navigatorKey.currentState?.pushNamedAndRemoveUntil(
          '/welcome',
          (route) => false,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
