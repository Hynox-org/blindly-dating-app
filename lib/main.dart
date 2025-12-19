import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/security/security_config.dart';
import 'core/router/app_router.dart';

// Import your existing screens
import 'SplashScreen.dart';
import 'Welcomescreen.dart';
import 'AuthenticationScreen.dart';
import 'TeamsAndConditions.dart';
import 'HomeScreen.dart';
import 'AgeSelectionScreen.dart';

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
    // You can still use the router provider if needed
    // final router = ref.watch(routerProvider);

    return MaterialApp(
      title: 'Blindly',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF4A5D4F),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4A5D4F),
        ),
        useMaterial3: true,
      ),
      initialRoute: '/', // start at splash
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