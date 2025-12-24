import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'generated/l10n.dart';
import 'core/security/security_config.dart';

// NEW: Locale provider import
import 'core/providers/locale_provider.dart'; // Create this file

// Import your existing screens
import 'features/splash/screens/splash_screen.dart';
import 'features/onboarding/screens/welcome_screen.dart';
import 'features/auth/screens/authentication_screen.dart';
import 'features/onboarding/screens/terms_and_conditions_screen.dart';
import 'features/home/screens/home_screen.dart';
import 'features/onboarding/screens/age_selection_screen.dart';
import 'core/theme/app_theme.dart';
import 'core/providers/theme_provider.dart';
import 'core/utils/logging_navigator_observer.dart';
import 'shared/widgets/theme_switcher.dart';

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

  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  Widget build(BuildContext context) {
    // NEW: Watch locale from Riverpod provider
    final locale = ref.watch(localeProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: 'Blindly',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.getThemeData(themeMode),

      // --- UPDATED: Use Riverpod locale ---
      locale: locale, // Now from Riverpod (null = system default)
      localizationsDelegates: const [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: S.delegate.supportedLocales,
      // -------------------------------------

      initialRoute: '/',
      navigatorObservers: [LoggingNavigatorObserver()],
      routes: {
        '/': (context) => WelcomeScreen(
          onLocaleChanged: (locale) {
            // NEW: Update Riverpod state instead of local state
            ref.read(localeProvider.notifier).setLocale(locale);
          },
        ),
        '/welcome': (context) => WelcomeScreen(
          onLocaleChanged: (locale) {
            ref.read(localeProvider.notifier).setLocale(locale);
          },
        ),
        '/auth': (context) => const AuthenticationScreen(),
        '/terms': (context) => const TermsScreen(),
        '/age-selector': (context) => const AgeSelectorScreen(),
        '/home': (context) => const HomeScreen(),
      },
      builder: (context, child) {
        return Stack(
          children: [
            if (child != null) child,
            if (const bool.fromEnvironment('dart.vm.product') == false)
              const Positioned(
                right: 20,
                bottom: 20,
                child: ThemeSwitcher(),
              ),
          ],
        );
      },
    );
  }
}
