import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/security/security_config.dart';
import 'core/config/environment_config.dart';
import 'core/config/jiobase_proxy_client.dart';

// Screens
import 'features/splash/screens/splash_screen.dart';
import 'features/onboarding/screens/welcome_screen.dart';
import 'features/onboarding/screens/location_access_screen.dart';
import 'features/auth/screens/authentication_screen.dart';
import 'features/home/screens/home_screen.dart';
// Core
import 'core/theme/app_theme.dart';
import 'core/utils/logging_navigator_observer.dart';
import 'core/utils/nav_key.dart';
import 'features/auth/providers/auth_state_listener.dart';
import 'features/notifications/services/push_notification_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

//CALL SYSTEM
// import 'features/call/provider/global_call_listener.dart';
import 'features/call/presentation/widgets/incoming_call_overlay.dart';
import 'features/call/global_call_initializer.dart';
import 'core/services/deep_link_service.dart'
    as import_deep_links; // deep link setup
import 'core/services/translation_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('chat_cache');
  await Hive.openBox('match_keys');
  await Hive.openBox(TranslationService.boxName);
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

  final proxiedHttpClient = JiobaseProxyClient(secureClient, fallbackUrl);

  await Future.wait([
    Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    ).then((_) async {
      SecurityConfig.initializeAppCheck();
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
      
      // 🔥 Capture intent before the rest of the app boots
      await PushNotificationService.instance.captureLaunchNotification();
      
      PushNotificationService.instance.initPushNotifications();
    }),
    Supabase.initialize(
      url: trueSupabaseUrl,
      anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
      httpClient: directUrl != null && directUrl.isNotEmpty 
          ? secureClient 
          : proxiedHttpClient,
      realtimeClientOptions: const RealtimeClientOptions(eventsPerSecond: 10),
    ),
  ]);

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  void initState() {
    super.initState();
    // Initialize deep linking listeners when the app starts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      import_deep_links.DeepLinkService.instance.initDeepLinks();
    });
  }

  @override
  Widget build(BuildContext context) {
    // 🔥 START GLOBAL CALL LISTENER ONCE
    // ref.read(incomingCallProvider.notifier).start();

    return MaterialApp(
      title: 'Blindly',
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      initialRoute: '/',
      navigatorObservers: [LoggingNavigatorObserver()],

      builder: (context, child) {
        return Stack(
          children: [
            // AuthStateListenerWrapper(
            //   child: child!,
            // ),
            GlobalCallInitializer(
              child: AuthStateListenerWrapper(child: child!),
            ),
            // 🔔 GLOBAL INCOMING CALL UI
            const IncomingCallOverlay(),
          ],
        );
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
