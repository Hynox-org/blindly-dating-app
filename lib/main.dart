import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// YOUR IMPORTS (Matching your file structure)
import 'core/security/security_config.dart';      // Your SSL/AppCheck config
import 'core/router/app_router.dart';             // The Router we built
import 'core/services/security_provider.dart';   // The Root Detection Provider

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 1. Load Secrets
  await dotenv.load(fileName: ".env");

  // 2. Initialize Firebase (Required for AppCheck if you use it)
  await Firebase.initializeApp();

  // 3. Initialize App Check (Your custom security config)
  await SecurityConfig.initializeAppCheck();

  // 4. Initialize Supabase (With SSL Pinning AND Auth Logic)
  final secureClient = await SecurityConfig.getSSLPinnedClient();
  
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
    httpClient: secureClient,
    
    // ⚡ VITAL ADDITION: This enables the 15-min Auto-Refresh logic
    authOptions: const FlutterAuthClientOptions(
      authFlowType: AuthFlowType.pkce, 
      autoRefreshToken: true, 
    ),
  );

  // 5. Run App (Wrapped in ProviderScope for Riverpod)
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch our Security Provider (Root Detection)
    final deviceSafety = ref.watch(deviceSafetyProvider);

    return deviceSafety.when(
      // A. LOADING: Show a spinner while checking root status
      loading: () => const MaterialApp(
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      ),
      
      // B. ERROR: If check fails, show error (or fail open)
      error: (err, stack) => MaterialApp(
        home: Scaffold(body: Center(child: Text("Security Error: $err"))),
      ),
      
      // C. DATA: Check if Safe or Not
      data: (isSafe) {
        // 1. If Device is Rooted -> BLOCK USER
        if (!isSafe) {
          return const MaterialApp(
            home: Scaffold(
              backgroundColor: Colors.red,
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.gpp_bad, size: 80, color: Colors.white),
                    SizedBox(height: 20),
                    Text(
                      "❌ Device Security Risk\nThis app cannot run on rooted devices.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        // 2. If Device is Safe -> LAUNCH APP (GoRouter)
        final router = ref.watch(goRouterProvider);
        
        return MaterialApp.router(
          title: 'Blindly',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.pink),
            useMaterial3: true,
          ),
          // Hook up the router (Login <-> Home)
          routerConfig: router, 
        );
      },
    );
  }
}