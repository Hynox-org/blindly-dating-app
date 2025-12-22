import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/onboarding_provider.dart';
import 'base_onboarding_step_screen.dart';

class PhotoUploadScreen extends ConsumerWidget {
  const PhotoUploadScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BaseOnboardingStepScreen(
      title: 'Add your best photos',
      child: const Center(child: Text('Photo Picker Grid')),
      onNext: () {
        ref.read(onboardingProvider.notifier).completeStep('photo_upload');
      },
    );
  }
}
