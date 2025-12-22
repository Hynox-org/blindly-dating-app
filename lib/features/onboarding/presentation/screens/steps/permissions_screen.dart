import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/onboarding_provider.dart';
import 'base_onboarding_step_screen.dart';

class PermissionsScreen extends ConsumerWidget {
  const PermissionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BaseOnboardingStepScreen(
      title: 'App Permissions',
      child: const Center(child: Text('We need permissions for...')),
      nextLabel: 'Grant Permissions',
      onNext: () {
        // In real app, request permissions here
        ref.read(onboardingProvider.notifier).completeStep('permissions');
      },
    );
  }
}
