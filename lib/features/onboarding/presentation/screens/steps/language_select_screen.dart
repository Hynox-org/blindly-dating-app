import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/onboarding_provider.dart';
import 'base_onboarding_step_screen.dart';

class LanguageSelectScreen extends ConsumerWidget {
  const LanguageSelectScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BaseOnboardingStepScreen(
      title: 'Choose Language',
      child: const Center(child: Text('Language Selection Placeholder')),
      onNext: () {
        ref.read(onboardingProvider.notifier).completeStep('language_select');
      },
    );
  }
}
