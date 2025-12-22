import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/onboarding_provider.dart';
import 'base_onboarding_step_screen.dart';

class GenderSelectScreen extends ConsumerWidget {
  const GenderSelectScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BaseOnboardingStepScreen(
      title: 'Select your Gender',
      child: const Center(child: Text('Gender Selection Options')),
      onNext: () {
        ref.read(onboardingProvider.notifier).completeStep('gender_select');
      },
    );
  }
}
