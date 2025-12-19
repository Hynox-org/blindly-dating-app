import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// REPOSITORY
import '../../features/auth/repositories/auth_repository.dart';

// SCREENS
import '../../features/auth/screens/dummy_login_screen.dart'; 
import '../../Screens/home_screen.dart'; 

final goRouterProvider = Provider<GoRouter>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);

  return GoRouter(
    initialLocation: '/login',
    debugLogDiagnostics: true,
    
    // The Watchdog: Re-evaluates redirects when auth state changes
    refreshListenable: GoRouterRefreshStream(authRepository.authStateChanges),

    routes: [
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const DummyLoginScreen(),
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
    ],

    redirect: (context, state) {
      final session = authRepository.currentSession;
      final isLoggedIn = session != null;
      final isLoggingIn = state.uri.toString() == '/login';

      if (!isLoggedIn && !isLoggingIn) return '/login';
      if (isLoggedIn && isLoggingIn) return '/home';

      return null;
    },
  );
});

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
      (dynamic _) => notifyListeners(),
    );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}