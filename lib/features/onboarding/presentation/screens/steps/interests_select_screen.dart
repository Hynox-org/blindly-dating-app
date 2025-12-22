import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/onboarding_provider.dart';
import 'base_onboarding_step_screen.dart';

class InterestsSelectScreen extends ConsumerWidget {
  const InterestsSelectScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BaseOnboardingStepScreen(
      title: 'Your Interests',
      child: const Center(child: Text('Interests Selection Chips')),
      onNext: () {
        ref.read(onboardingProvider.notifier).completeStep('interests_select');
      },
      showSkipButton: true,
      onSkip: () {
        ref.read(onboardingProvider.notifier).skipStep('interests_select');
      },
    );
  }
}
