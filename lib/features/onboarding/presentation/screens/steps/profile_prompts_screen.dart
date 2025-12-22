import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/onboarding_provider.dart';
import 'base_onboarding_step_screen.dart';

class ProfilePromptsScreen extends ConsumerWidget {
  const ProfilePromptsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BaseOnboardingStepScreen(
      title: 'Add some personality',
      nextLabel: 'Finish',
      onNext: () {
        ref.read(onboardingProvider.notifier).completeOnboarding();
      },
      showSkipButton: true,
      onSkip: () {
        ref
            .read(onboardingProvider.notifier)
            .completeOnboarding(skippedStepKey: 'profile_prompts');
      },
      child: const Center(child: Text('Profile Prompts List')),
    );
  }
}
