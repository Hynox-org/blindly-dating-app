import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/onboarding_provider.dart';
import 'base_onboarding_step_screen.dart';

class PhotoReorderScreen extends ConsumerWidget {
  const PhotoReorderScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BaseOnboardingStepScreen(
      title: 'Arranging photos',
      showBackButton: true,
      onNext: () {
        ref.read(onboardingProvider.notifier).completeStep('photo_reorder');
      },
      showSkipButton: true,
      onSkip: () {
        ref.read(onboardingProvider.notifier).skipStep('photo_reorder');
      },
      child: const Center(child: Text('Drag and Drop Photos')),
    );
  }
}
