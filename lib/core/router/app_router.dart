import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:blindly_dating_app/features/splash/screens/splash_screen.dart';
import 'package:blindly_dating_app/features/onboarding/screens/welcome_screen.dart';
import 'package:blindly_dating_app/features/onboarding/screens/location_access_screen.dart';
import 'package:blindly_dating_app/features/auth/screens/authentication_screen.dart';
import 'package:blindly_dating_app/features/people/people_screen.dart';

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
        path: '/location_access',
        builder: (context, state) => const LocationAccessScreen(),
      ),
      GoRoute(
        path: '/auth',
        builder: (context, state) => const AuthenticationScreen(),
      ),
      GoRoute(path: '/home', builder: (context, state) => const PeopleScreen()),
    ],
  );
});
