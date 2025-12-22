import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/onboarding_provider.dart';
import 'base_onboarding_step_screen.dart';

class VoiceIntroScreen extends ConsumerWidget {
  const VoiceIntroScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BaseOnboardingStepScreen(
      title: 'Record a Voice Intro',
      child: const Center(child: Text('Microphone Button Placeholder')),
      onNext: () {
        ref.read(onboardingProvider.notifier).completeStep('voice_intro');
      },
      showSkipButton: true,
      onSkip: () {
        ref.read(onboardingProvider.notifier).skipStep('voice_intro');
      },
    );
  }
}
