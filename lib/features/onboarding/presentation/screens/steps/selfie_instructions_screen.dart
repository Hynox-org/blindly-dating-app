import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/onboarding_provider.dart';
import 'selfie_capture_screen.dart';
import 'base_onboarding_step_screen.dart';

class SelfieInstructionsScreen extends ConsumerWidget {
  const SelfieInstructionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BaseOnboardingStepScreen(
      title: 'Verify it\'s you',
      nextLabel: 'I\'m Ready',
      showBackButton: true,
      onNext: () {
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const SelfieCaptureScreen()));
      },
      showSkipButton: true,
      onSkip: () {
        ref.read(onboardingProvider.notifier).skipStep('selfie_capture');
      },
      child: const Center(child: Text('Selfie Verification Instructions')),
    );
  }
}
