import 'package:flutter/material.dart';
import 'SplashScreen.dart';
import 'Welcomescreen.dart';          // your existing file
// import 'guidelines_screen.dart';
// import 'age_screen.dart';
import 'AuthenticationScreen.dart';
import 'TeamsAndConditions.dart';
import 'HomeScreen.dart';
import 'AgeSelectionScreen.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Blindly',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF4A5D4F),
      ),
      initialRoute: '/',         // start at splash
      routes: {
        '/': (context) => const SplashScreen(),
        '/welcome': (context) => const WelcomeScreen(),          // Create / I have account
        // '/guidelines': (context) => const GuidelinesScreen(),    // new user only
        // '/age': (context) => const AgeScreen(),                  // new user only
        '/auth': (context) => const AuthenticationScreen(),      // sign-in options + flows
        '/terms': (context) => const TermsScreen(),    
        '/age-selector': (context) => const AgeSelectorScreen(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}