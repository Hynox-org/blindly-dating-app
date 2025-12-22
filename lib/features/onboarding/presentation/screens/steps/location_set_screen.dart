import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/onboarding_provider.dart';
import 'base_onboarding_step_screen.dart';

class LocationSetScreen extends ConsumerWidget {
  const LocationSetScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BaseOnboardingStepScreen(
      title: 'Set your Location',
      child: const Center(child: Text('Location Permission Request')),
      nextLabel: 'Enable Location',
      onNext: () {
        ref.read(onboardingProvider.notifier).completeStep('location_set');
      },
    );
  }
}
