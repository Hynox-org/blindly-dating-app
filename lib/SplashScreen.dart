import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _animate = false;

  @override
  void initState() {
    super.initState();
    _startAnimation();
  }

  Future<void> _startAnimation() async {
    await Future.delayed(const Duration(milliseconds: 3000));
    if (!mounted) return;
    setState(() => _animate = true);
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/welcome');
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 1200),
              curve: Curves.easeInOut,
              top: _animate ? 80 : h / 2 - 100,
              left: 0,
              right: 0,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    child: Image.asset(
                      'assets/images/logo.png',
                      width: 80,
                      height: 80,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Replaced Text widget with Image
                  Image.asset(
                    'assets/images/blindly.png',
                    width: 120, // Adjust width as needed
                    height: 30, // Adjust height as needed
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'The joyful journey',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
