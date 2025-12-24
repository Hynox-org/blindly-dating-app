import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/onboarding_provider.dart';
import 'base_onboarding_step_screen.dart';

class LifestylePrefsScreen extends ConsumerWidget {
  const LifestylePrefsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BaseOnboardingStepScreen(
      title: 'Lifestyle Preferences',
      onNext: () {
        ref.read(onboardingProvider.notifier).completeStep('lifestyle_prefs');
      },
      showSkipButton: true,
      onSkip: () {
        ref.read(onboardingProvider.notifier).skipStep('lifestyle_prefs');
      },
      child: const Center(child: Text('Smoking, Drinking, etc.')),
    );
  }
}
