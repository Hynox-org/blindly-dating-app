import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/onboarding_provider.dart';
import 'base_onboarding_step_screen.dart';
import 'selfie_processing_screen.dart';

class SelfieCaptureScreen extends ConsumerWidget {
  const SelfieCaptureScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BaseOnboardingStepScreen(
      title: 'Smile!',
      child: const Center(child: Text('Camera Viewfinder')),
      nextLabel: 'Capture',
      onNext: () async {
        // 1. Show processing screen (visual only)
        // We use Navigator to push it on top.
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const SelfieProcessingScreen()),
        );

        // 2. Simulate upload delay (if real, wait for result)
        await Future.delayed(const Duration(seconds: 2));

        // 3. Mark THIS step as complete
        // The processing screen should probably listen to state changes or we pop it?
        // Better: The processing screen is just a splash.
        // When we call completeStep below, the OnboardingShell will detect the change (to Gov ID)
        // and rebuild the body. IF the shell rebuilds, it replaces the body.
        // BUT we pushed a new route. So we must POP the processing screen.

        if (context.mounted) {
          // 1. Pop the Processing Screen
          Navigator.of(context).pop();

          // 2. Pop the Capture Screen (returns to Instructions which is the Shell body? No, Instructions pushed Capture)
          Navigator.of(context).pop();

          // 3. Mark step as complete
          // This will trigger the Shell (underneath) to update to the next step (Gov ID)
          ref.read(onboardingProvider.notifier).completeStep('selfie_capture');
        }
      },
      showSkipButton: true,
      onSkip: () {
        // If user skips from inside camera, pop back
        Navigator.of(context).pop();
        ref.read(onboardingProvider.notifier).skipStep('selfie_capture');
      },
    );
  }
}
