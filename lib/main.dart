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

// Provide a globally accessible custom RealtimeClient to bypass Jiobase proxy limits
RealtimeClient? customRealtimeClient;

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

  // If no direct URL provided, fallback to the Jiobase one.
  // Note: For Realtime WebSocket to work perfectly, you need to add
  // SUPABASE_DIRECT_URL=https://<your-project-ref>.supabase.co to your .env files!

  await Future.wait([
    Firebase.initializeApp().then((_) => SecurityConfig.initializeAppCheck()),
    Supabase.initialize(
      url: dotenv.env['SUPABASE_URL']!,
      anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
      httpClient: secureClient,
      realtimeClientOptions: const RealtimeClientOptions(eventsPerSecond: 10),
    ),
  ]);

  // ✅ INITIALIZE CUSTOM REALTIME CLIENT TO BYPASS JIOBASE PROXY
  // The 'SUPABASE_URL' usually points to blindly.jiobase.com (which drops wss://)
  // We extract the actual project URL from .env, or fallback to the direct supabase.co URL via JWT
  if (directUrl != null && directUrl.isNotEmpty) {
    customRealtimeClient = RealtimeClient(
      '${directUrl
              .replaceAll('http', 'ws')
              .replaceAll('/rest/v1', '/realtime/v1')}/realtime/v1',
      params: {'apikey': dotenv.env['SUPABASE_ANON_KEY']!},
      headers: {'apikey': dotenv.env['SUPABASE_ANON_KEY']!},
    );
    // Explicitly set the auth token so the realtime socket has permission to subscribe
    final currentSession = Supabase.instance.client.auth.currentSession;
    if (currentSession != null) {
      customRealtimeClient?.setAuth(currentSession.accessToken);
    }
  }

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
