import 'dart:ui' as ui;
import 'dart:math' as math;

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

  // Scene 1: Background
  late Animation<double> _bokehOpacity;
  late Animation<Color?> _backgroundColor;

  // Scene 3: Text
  late Animation<double> _textBlur;
  late Animation<double> _textOpacity;
  late Animation<double> _textScale;

  bool _isInitialized = false;

  // --------------------------------------------------
  // INIT
  // --------------------------------------------------
  @override
  void initState() {
    super.initState();

    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4500),
    );

    _mainController.addStatusListener((status) async {
      if (status != AnimationStatus.completed) return;

      final user = ref.read(authRepositoryProvider).currentUser;

      if (user != null) {
        await _checkOnboardingAndNavigate(user.id);
      } else {
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/welcome');
        }
      }
    });
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
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/home',
          (route) => false,
        );
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

  // --------------------------------------------------
  // ANIMATIONS
  // --------------------------------------------------
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInitialized) return;

    _initAnimations();
    _mainController.forward();
    _isInitialized = true;
  }

  void _initAnimations() {
    _bokehOpacity = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.33, 0.55, curve: Curves.easeOut),
      ),
    );

    _backgroundColor = ColorTween(
      begin: Theme.of(context).colorScheme.onPrimary,
      end: Theme.of(context).colorScheme.surface,
    ).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.33, 0.55),
      ),
    );

    _textBlur = Tween<double>(begin: 20, end: 0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.55, 0.90, curve: Curves.easeOut),
      ),
    );

    _textOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.55, 0.80),
      ),
    );

    _textScale = Tween<double>(begin: 0.95, end: 1).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.55, 0.90, curve: Curves.easeOutQuad),
      ),
    );
  }

  @override
  void dispose() {
    _mainController.dispose();
    super.dispose();
  }

  // --------------------------------------------------
  // UI
  // --------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _mainController,
      builder: (_, __) {
        return Scaffold(
          backgroundColor: _backgroundColor.value,
          body: Stack(
            fit: StackFit.expand,
            children: [
              Opacity(
                opacity: _bokehOpacity.value,
                child: const _BokehBackground(),
              ),
              Center(
                child: Opacity(
                  opacity: _textOpacity.value,
                  child: Transform.scale(
                    scale: _textScale.value,
                    child: ImageFiltered(
                      imageFilter: ui.ImageFilter.blur(
                        sigmaX: _textBlur.value,
                        sigmaY: _textBlur.value,
                      ),
                      child: Image.asset(
                        'assets/images/blindly-text-logo.png',
                        width: 280,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// --------------------------------------------------
// BACKGROUND
// --------------------------------------------------
class _BokehBackground extends StatefulWidget {
  const _BokehBackground();

  @override
  State<_BokehBackground> createState() => _BokehBackgroundState();
}

class _BokehBackgroundState extends State<_BokehBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 10))
          ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        return Stack(
          children: [
            _blob(
              Alignment(math.sin(_controller.value * 2 * math.pi) * 0.5, -0.2),
              Theme.of(context).colorScheme.primary.withOpacity(0.2),
              150,
            ),
            _blob(
              Alignment(-0.3,
                  math.cos(_controller.value * 2 * math.pi) * 0.5),
              Theme.of(context).colorScheme.secondary.withOpacity(0.3),
              200,
            ),
            _blob(
              const Alignment(0.4, 0.4),
              Theme.of(context).colorScheme.primary.withOpacity(0.1),
              180,
            ),
          ],
        );
      },
    );
  }

  Widget _blob(Alignment alignment, Color color, double size) {
    return Align(
      alignment: alignment,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 30, sigmaY: 30),
          child: const SizedBox(),
        ),
      ),
    );
  }
}
