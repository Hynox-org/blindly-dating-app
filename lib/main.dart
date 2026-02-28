import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/security/security_config.dart';
import 'core/config/environment_config.dart';

// Import your existing screens
import 'features/splash/screens/splash_screen.dart';
import 'features/onboarding/screens/welcome_screen.dart';
import 'features/onboarding/screens/location_access_screen.dart';
import 'features/auth/screens/authentication_screen.dart';
import 'features/home/screens/home_screen.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/logging_navigator_observer.dart';
import 'core/utils/nav_key.dart';
import 'features/auth/providers/auth_state_listener.dart';

import 'core/config/jiobase_proxy_client.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Load connection strings and credentials based on environment
  await EnvironmentConfig.load();

  // Prepare secure HTTP client
  final secureClient = await SecurityConfig.getSSLPinnedClient();

  // Extract the project ref from the anon key.
  // The anon key payload format is Base64 JWT. The easiest way to bypass Jiobase
  // is just providing the direct SUPABASE_PROJECT_URL if we have it in dotenv.
  String? directUrl = dotenv.env['SUPABASE_DIRECT_URL'];
  // The true .supabase.co URL
  String fallbackUrl = dotenv.env['SUPABASE_URL']!;
  String trueSupabaseUrl = directUrl != null && directUrl.isNotEmpty
      ? directUrl
      : fallbackUrl;

  // Use the native client for REST but route through JiobaseProxyClient
  // which will send all HTTP to fallbackUrl (Jiobase proxy)
  final proxiedHttpClient = JiobaseProxyClient(secureClient, fallbackUrl);

  await Future.wait([
    Firebase.initializeApp().then((_) => SecurityConfig.initializeAppCheck()),
    Supabase.initialize(
      url: trueSupabaseUrl,
      anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
      httpClient: proxiedHttpClient,
      realtimeClientOptions: const RealtimeClientOptions(eventsPerSecond: 10),
    ),
  ]);

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Blindly',
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      initialRoute: '/', // start at splash
      navigatorObservers: [LoggingNavigatorObserver()],
      builder: (context, child) {
        return AuthStateListenerWrapper(child: child!);
      },
      routes: {
        '/': (context) => const SplashScreen(),
        '/location_access': (context) => const LocationAccessScreen(),
        '/welcome': (context) => const WelcomeScreen(),
        '/auth': (context) => const AuthenticationScreen(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}
