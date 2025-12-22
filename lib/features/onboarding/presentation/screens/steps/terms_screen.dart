import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/onboarding_provider.dart';
import 'base_onboarding_step_screen.dart';

class TermsScreen extends ConsumerWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BaseOnboardingStepScreen(
      title: 'Terms of Service',
      child: const Center(
        child: Text('Terms and Conditions Content Placeholder'),
      ),
      nextLabel: 'I Accept',
      onNext: () {
        ref.read(onboardingProvider.notifier).completeStep('terms_accept');
      },
    );
  }
}
