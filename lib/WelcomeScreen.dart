import 'package:flutter/material.dart';
import 'authenticationScreen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            children: [
              // Top section with logo and title
              Column(
                children: [
                  const SizedBox(height: 40),
                  Image.asset(
                    'assests/images/logo.png',
                    width: 60,
                    height: 60,
                  ),
                  const SizedBox(height: 8),
                  // Replaced Text widget with Image
                  Image.asset(
                    'assests/images/blindly-text-logo.png',
                    width: 120, // Adjust width as needed
                    height: 28, // Adjust height as needed
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'The joyful journey',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
              
              const Spacer(),
              
              // Center text
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                child: Text(
                  'Real connections start here!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    height: 1.3,
                    color: Colors.black,
                  ),
                ),
              ),
              
              const Spacer(),
              
              // Bottom buttons section
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const AuthenticationScreen(isNewUser: true),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4A5D4F),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 0,
                      shadowColor: Colors.black.withOpacity(0.05),
                    ).copyWith(
                      backgroundColor: MaterialStateProperty.all(const Color(0xFF4A5D4F)),
                      foregroundColor: MaterialStateProperty.all(Colors.white),
                      overlayColor: MaterialStateProperty.resolveWith<Color?>(
                        (Set<MaterialState> states) {
                          if (states.contains(MaterialState.pressed)) {
                            return Colors.white.withOpacity(0.1);
                          }
                          return null;
                        },
                      ),
                    ),
                    child: const Text(
                      'Create an account',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Color.fromRGBO(230, 201, 122, 1),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const AuthenticationScreen(isNewUser: false),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      side: const BorderSide(color: Color(0xFFE0E0E0), width: 1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      backgroundColor: Colors.white,
                    ).copyWith(
                      foregroundColor: MaterialStateProperty.all(Colors.black),
                      backgroundColor: MaterialStateProperty.all(Colors.white),
                      overlayColor: MaterialStateProperty.resolveWith<Color?>(
                        (Set<MaterialState> states) {
                          if (states.contains(MaterialState.pressed)) {
                            return Colors.black.withOpacity(0.03);
                          }
                          return null;
                        },
                      ),
                    ),
                    child: const Text(
                      'I have an account',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 11,
                          color: Colors.grey[600],
                          height: 1.4,
                        ),
                        children: const [
                          TextSpan(text: 'By signing up, you agree to our '),
                          TextSpan(
                            text: 'terms',
                            style: TextStyle(
                              color: Color(0xFF4A5D4F),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          TextSpan(text: '. See how we use your data in our '),
                          TextSpan(
                            text: 'privacy policy',
                            style: TextStyle(
                              color: Color(0xFF4A5D4F),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          TextSpan(text: '.'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
