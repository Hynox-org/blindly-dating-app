import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/onboarding_provider.dart';
import 'base_onboarding_step_screen.dart';

class SelfieInstructionsScreen extends ConsumerWidget {
  const SelfieInstructionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BaseOnboardingStepScreen(
      title: 'Verify it\'s you',
      child: const Center(child: Text('Selfie Verification Instructions')),
      nextLabel: 'I\'m Ready',
      onNext: () {
        ref
            .read(onboardingProvider.notifier)
            .completeStep('selfie_instructions');
      },
      showSkipButton: true,
      onSkip: () {
        // Skipping verification moves to next section
        ref.read(onboardingProvider.notifier).skipStep('selfie_instructions');
      },
    );
  }
}
