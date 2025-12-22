import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/security/security_config.dart';

// Import your existing screens
import 'features/splash/screens/splash_screen.dart';
import 'features/onboarding/screens/welcome_screen.dart';
import 'features/auth/screens/authentication_screen.dart';
import 'features/onboarding/screens/terms_and_conditions_screen.dart';
import 'features/home/screens/home_screen.dart';
import 'features/onboarding/screens/age_selection_screen.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/logging_navigator_observer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load connection strings and credentials
  await dotenv.load(fileName: ".env");

  // Initialize Firebase (requires google-services.json on Android)
  await Firebase.initializeApp();

  // Initialize App Check and Security
  await SecurityConfig.initializeAppCheck();

  // Initialize Supabase with SSL Pinning
  final secureClient = await SecurityConfig.getSSLPinnedClient();
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
    httpClient: secureClient,
  );

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Blindly',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      initialRoute: '/', // start at splash
      navigatorObservers: [LoggingNavigatorObserver()],
      routes: {
        '/': (context) => const SplashScreen(),
        '/welcome': (context) => const WelcomeScreen(),
        '/auth': (context) => const AuthenticationScreen(),
        '/terms': (context) => const TermsScreen(),
        '/age-selector': (context) => const AgeSelectorScreen(),
        '/home': (context) => const HomeScreen(),
      },
      // Alternative: If you want to use go_router later, uncomment this:
      // routerConfig: router,
    );
  }
}
