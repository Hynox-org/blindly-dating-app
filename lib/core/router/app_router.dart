import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/splash/screens/splash_screen.dart';
import '../../features/onboarding/screens/welcome_screen.dart';
import '../../features/auth/screens/authentication_screen.dart';
import '../../features/onboarding/screens/terms_and_conditions_screen.dart';
import '../../features/onboarding/screens/age_selection_screen.dart';
import '../../features/home/screens/home_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/welcome',
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: '/auth',
        builder: (context, state) => const AuthenticationScreen(),
      ),
      GoRoute(path: '/terms', builder: (context, state) => const TermsScreen()),
      GoRoute(
        path: '/age-selector',
        builder: (context, state) => const AgeSelectorScreen(),
      ),
      GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
    ],
  );
});
