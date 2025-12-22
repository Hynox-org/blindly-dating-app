import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/onboarding_provider.dart';
import 'base_onboarding_step_screen.dart';

class GovIdScreen extends ConsumerWidget {
  const GovIdScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BaseOnboardingStepScreen(
      title: 'Government ID',
      child: const Center(child: Text('Upload ID Card')),
      nextLabel: 'Upload',
      onNext: () {
        ref.read(onboardingProvider.notifier).completeStep('gov_id_optional');
      },
      showSkipButton: true,
      onSkip: () {
        ref.read(onboardingProvider.notifier).skipStep('gov_id_optional');
      },
    );
  }
}
