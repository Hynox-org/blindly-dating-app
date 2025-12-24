import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/onboarding_provider.dart';
import 'base_onboarding_step_screen.dart';

class BioEntryScreen extends ConsumerStatefulWidget {
  const BioEntryScreen({super.key});

  @override
  ConsumerState<BioEntryScreen> createState() => _BioEntryScreenState();
}

class _BioEntryScreenState extends ConsumerState<BioEntryScreen> {
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BaseOnboardingStepScreen(
      title: 'Describe yourself',
      onNext: () {
        ref.read(onboardingProvider.notifier).completeStep('bio_entry');
      },
      showSkipButton: true,
      onSkip: () {
        ref.read(onboardingProvider.notifier).skipStep('bio_entry');
      },
      child: TextField(
        controller: _controller,
        maxLines: 5,
        decoration: const InputDecoration(
          hintText: 'I love long walks on the beach...',
          border: OutlineInputBorder(),
        ),
      ),
    );
  }
}
