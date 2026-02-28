import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/providers/auth_providers.dart';
import '../../onboarding/data/repositories/onboarding_repository.dart';
import '../../onboarding/presentation/screens/onboarding_shell.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _pulseController;

  // Animations
  late Animation<double> _logoOpacity;
  late Animation<double> _logoScale;
  late Animation<double> _logoPulse;

  bool _isNavigating = false;

  // --------------------------------------------------
  // INIT
  // --------------------------------------------------
  @override
  void initState() {
    super.initState();

    // Controls the initial entrance animation
    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    // Controls a continuous subtle breathing/pulse effect
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat(reverse: true);

    _initAnimations();

    _mainController.forward();

    // Wait for the entrance animation to finish, hold on screen for a moment, then navigate
    Future.delayed(const Duration(milliseconds: 3500), () {
      if (mounted && !_isNavigating) {
        _isNavigating = true;
        _proceedToNextScreen();
      }
    });
  }

  void _initAnimations() {
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _logoScale = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOutCubic),
      ),
    );

    _logoPulse = Tween<double>(begin: 1.0, end: 1.03).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOutSine),
    );
  }

  Future<void> _proceedToNextScreen() async {
    final user = ref.read(authRepositoryProvider).currentUser;

    if (user != null) {
      await _checkOnboardingAndNavigate(user.id);
    } else {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/welcome');
      }
    }
  }

  // --------------------------------------------------
  // ONBOARDING FLOW
  // --------------------------------------------------
  Future<void> _checkOnboardingAndNavigate(String userId) async {
    try {
      final isComplete = await ref
          .read(onboardingRepositoryProvider)
          .validateAndFixOnboardingStatus(userId);

      if (!mounted) return;

      if (isComplete) {
        Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const OnboardingShell()),
        );
      }
    } catch (_) {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/welcome');
      }
    }
  }

  @override
  void dispose() {
    _mainController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  // --------------------------------------------------
  // UI
  // --------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: AnimatedBuilder(
          animation: Listenable.merge([_mainController, _pulseController]),
          builder: (context, child) {
            return Opacity(
              opacity: _logoOpacity.value,
              child: Transform.scale(
                scale: _logoScale.value * _logoPulse.value,
                child: child,
              ),
            );
          },
          child: Image.asset('assets/images/blindly-text-logo.png', width: 250),
        ),
      ),
    );
  }
}
