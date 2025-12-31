import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/onboarding_provider.dart';
import 'base_onboarding_step_screen.dart';

enum SelfieStep { instructions, capture, processing }

class SelfieVerificationScreen extends ConsumerStatefulWidget {
  const SelfieVerificationScreen({super.key});

  @override
  ConsumerState<SelfieVerificationScreen> createState() =>
      _SelfieVerificationScreenState();
}

class _SelfieVerificationScreenState
    extends ConsumerState<SelfieVerificationScreen> {
  SelfieStep _currentStep = SelfieStep.instructions;
  // String? _capturedImagePath; // To store result if needed later

  void _startCapture() {
    setState(() {
      _currentStep = SelfieStep.capture;
    });
  }

  void _captureAndProcess() async {
    // 1. Transition to processing
    setState(() {
      _currentStep = SelfieStep.processing;
    });

    // 2. Simulate upload/verification delay
    // In a real app, you'd capture the image here and upload it
    await Future.delayed(const Duration(seconds: 2));

    // 3. Mark step as complete
    if (mounted) {
      ref.read(onboardingProvider.notifier).completeStep('selfie_capture');
    }
  }

  void _onSkip() {
    // If in capture mode, user might want to go back to instructions, but "Skip"
    // usually means skip the onboarding step entirely.
    ref.read(onboardingProvider.notifier).skipStep('selfie_capture');
  }

  void _onBack() {
    // If in Capture mode, go back to Instructions
    if (_currentStep == SelfieStep.capture) {
      setState(() {
        _currentStep = SelfieStep.instructions;
      });
    } else {
      // If in Instructions mode, go back to previous onboarding step
      ref.read(onboardingProvider.notifier).goToPreviousStep();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Processing View
    if (_currentStep == SelfieStep.processing) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Verifying your selfie...'),
            ],
          ),
        ),
      );
    }

    // Capture View
    if (_currentStep == SelfieStep.capture) {
      return BaseOnboardingStepScreen(
        title: 'Smile!',
        nextLabel: 'Capture',
        showBackButton: true,
        // Back in capture mode returns to instructions
        onBack: _onBack,
        onNext: _captureAndProcess,
        showSkipButton: true,
        onSkip: _onSkip,
        child: const Center(child: Text('Camera Viewfinder')),
      );
    }

    // Instructions View (Default)
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // Instructions View (Default)
    return BaseOnboardingStepScreen(
      title: 'Selfie Verification',
      showBackButton: true,
      onBack: _onBack,
      showNextButton: false, // Custom buttons in body
      showSkipButton: false, // Custom buttons in body
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 16),

                  // Visual Header
                  Container(
                    height: 220,
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest.withOpacity(
                        0.5,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: colorScheme.outlineVariant.withOpacity(0.5),
                      ),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Icon(
                          Icons.face_retouching_natural_rounded,
                          size: 100,
                          color: colorScheme.primary.withOpacity(0.8),
                        ),
                        Positioned(
                          right: 40,
                          top: 40,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: colorScheme.surface,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.verified_rounded,
                              size: 28,
                              color: colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Title
                  Text(
                    "Prove You're the\nReal Deal",
                    textAlign: TextAlign.center,
                    style: textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Subtitle
                  Text(
                    "This quick step helps keep our community safe and authentic.",
                    textAlign: TextAlign.center,
                    style: textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Benefits List with Icons
                  _buildBenefitItem(
                    context,
                    icon: Icons.verified_rounded,
                    title: "Get a verified badge",
                    subtitle:
                        "Build trust with other users and show you're real.",
                    iconColor: colorScheme.primary,
                  ),
                  const SizedBox(height: 24),
                  _buildBenefitItem(
                    context,
                    icon: Icons.shield_rounded,
                    title: "Keep the community safe",
                    subtitle: "Help us weed out fake profiles and bots.",
                    iconColor: colorScheme.tertiary,
                  ),
                  const SizedBox(height: 24),
                  _buildBenefitItem(
                    context,
                    icon: Icons.camera_front_rounded,
                    title: "Copy a simple pose",
                    subtitle: "Takes 1 minute to confirm your identity.",
                    iconColor: colorScheme.secondary,
                  ),

                  const SizedBox(height: 32),

                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest.withOpacity(
                        0.3,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          size: 16,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "Privacy Note: Your selfie is never shared on your profile. It is strictly used for verification purposes only.",
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Custom Buttons
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _startCapture,
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(vertical: 18),
              elevation: 2,
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text(
              "Get verified",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: _onSkip,
            style: TextButton.styleFrom(
              foregroundColor: colorScheme.secondary,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: const Text("Maybe later", style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    Color? iconColor,
  }) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: (iconColor ?? colorScheme.primary).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 24, color: iconColor ?? colorScheme.primary),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
