import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../auth/providers/auth_providers.dart';
import '../../onboarding/presentation/screens/onboarding_shell.dart';
import '../../onboarding/data/repositories/onboarding_repository.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _mainController;

  // Scene 1: Bokeh/Background Animations
  late Animation<double> _bokehOpacity;
  late Animation<Color?> _backgroundColor;

  // Scene 3: Text Animations
  late Animation<double> _textBlur;
  late Animation<double> _textOpacity;
  late Animation<double> _textScale;

  @override
  void initState() {
    super.initState();
    // Total Duration: 4.5 seconds (Reduced from 7.5)
    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4500),
    );

    _mainController.addStatusListener((status) async {
      if (status == AnimationStatus.completed) {
        // Check for existing session
        final user = ref.read(authRepositoryProvider).currentUser;

        if (user != null) {
          // Check onboarding status
          await _checkOnboardingAndNavigate(user.id);
        } else {
          if (mounted) {
            Navigator.pushReplacementNamed(context, '/welcome');
          }
        }
      }
    });
  }

  Future<void> _checkOnboardingAndNavigate(String userId) async {
    // We'll use a direct Supabase call for speed or reuse repo if possible.
    // Since we are in ConsumerStateful, we can use ref.
    // However, we need to import OnboardingRepository.
    // Let's assume we can fetch it.
    // Use the repository to validate and potentially fix the status
    try {
      final isComplete = await ref
          .read(onboardingRepositoryProvider)
          .validateAndFixOnboardingStatus(userId);

      if (!mounted) return;

      if (isComplete) {
        Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
      } else {
        // Navigate to Onboarding Shell
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const OnboardingShell()),
        );
      }
    } catch (e) {
      if (mounted) Navigator.pushReplacementNamed(context, '/welcome');
    }
  }

  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _initAnimations();
      _mainController.forward();
      _isInitialized = true;
    }
  }

  void _initAnimations() {
    // 0s - 1.5s: Display Bokeh (Scene 1)
    // 1.5s - 2.5s: Fade out Bokeh / Transition Background (Scene 2)
    _bokehOpacity = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _mainController,
        // Fade out between 1.5s (33%) and 2.5s (55%)
        curve: const Interval(0.33, 0.55, curve: Curves.easeOut),
      ),
    );

    // Background Color Transition
    _backgroundColor =
        ColorTween(
          begin: Theme.of(context).colorScheme.onPrimary, // Secondary Gold
          end: Theme.of(context).colorScheme.surface, // White
        ).animate(
          CurvedAnimation(
            parent: _mainController,
            curve: const Interval(0.33, 0.55, curve: Curves.easeIn),
          ),
        );

    // 2.5s - 4.5s: Text Reveal (Scene 3)
    // Blur: 20 -> 0
    _textBlur = Tween<double>(begin: 20.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _mainController,
        // 2.5s (55%) to 4s (90%)
        curve: const Interval(0.55, 0.90, curve: Curves.easeOut),
      ),
    );

    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.55, 0.80, curve: Curves.easeIn),
      ),
    );

    // Subtle scale up for text
    _textScale = Tween<double>(begin: 0.95, end: 1.0).animate(
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

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _mainController,
      builder: (context, child) {
        return Scaffold(
          backgroundColor: _backgroundColor.value,
          body: Stack(
            fit: StackFit.expand,
            children: [
              // Scene 1: Abstract Bokeh Background
              Opacity(
                opacity: _bokehOpacity.value,
                child: const _BokehBackground(),
              ),

              // Main Content
              Center(
                child: Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    // Text Logo
                    Opacity(
                      opacity: _textOpacity.value,
                      child: Transform.scale(
                        scale: _textScale.value,
                        child: ImageFiltered(
                          imageFilter: ui.ImageFilter.blur(
                            sigmaX: _textBlur.value,
                            sigmaY: _textBlur.value,
                          ),
                          child: Image.asset(
                            'assests/images/blindly-text-logo.png',
                            width: 280, // Slightly larger
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

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
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);
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
      builder: (context, child) {
        return Stack(
          children: [
            // Moving Blobs
            _buildBlob(
              Alignment(math.sin(_controller.value * 2 * math.pi) * 0.5, -0.2),
              const Color(0xFF4A5D4F).withOpacity(0.2),
              150,
            ),
            _buildBlob(
              Alignment(-0.3, math.cos(_controller.value * 2 * math.pi) * 0.5),
              const Color(0xFFFFFFFF).withOpacity(0.3),
              200,
            ),
            _buildBlob(
              const Alignment(0.4, 0.4),
              const Color(0xFF4A5D4F).withOpacity(0.1),
              180,
            ),
          ],
        );
      },
    );
  }

  Widget _buildBlob(Alignment alignment, Color color, double size) {
    return Align(
      alignment: alignment,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 30, sigmaY: 30),
          child: Container(color: Colors.transparent),
        ),
      ),
    );
  }
}
