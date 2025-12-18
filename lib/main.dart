import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Imports
import 'core/services/security_service.dart'; // Import Security Service
import 'features/auth/security_block_screen.dart'; // Import Block Screen
import 'features/auth/dummy_test_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 1. Load Env
  await dotenv.load(fileName: ".env");

  // 2. Initialize Supabase
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  // 3. SECURITY CHECK
  final securityService = SecurityService();
  final isSafe = await securityService.isDeviceSafe();

  runApp(MyApp(isDeviceSafe: isSafe));
}

class MyApp extends StatelessWidget {
  final bool isDeviceSafe;
  
  const MyApp({super.key, required this.isDeviceSafe});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Blindly',
      // 4. Decide which screen to show
      home: isDeviceSafe 
          ? const DummyTestScreen()  // Normal App
          : const SecurityBlockScreen(), // 🚨 BLOCKED!
    );
  }
}