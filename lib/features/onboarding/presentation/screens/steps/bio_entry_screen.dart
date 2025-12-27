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
  void dispose() {
    _controller.dispose(); // Always clean up controllers
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BaseOnboardingStepScreen(
      title: 'Describe yourself',
      showSkipButton: true,
      onSkip: () {
        // Just skip this step without saving data
        ref.read(onboardingProvider.notifier).skipStep('bio_entry');
      },
      onNext: () async {
        final bioText = _controller.text.trim();

        // 1. Validation: If empty, tell them to use Skip instead
        if (bioText.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please enter a bio or tap Skip.')),
          );
          return;
        }

        try {
          // 2. Save Data using specific function
          await ref.read(onboardingProvider.notifier).saveBio(bioText);

          // 3. Complete Step
          ref.read(onboardingProvider.notifier).completeStep('bio_entry');

        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error saving bio: $e')),
          );
        }
      },
      child: TextField(
        controller: _controller,
        maxLines: 5,
        maxLength: 500, // Optional: Limit bio length visually
        decoration: const InputDecoration(
          hintText: 'I love long walks on the beach...',
          border: OutlineInputBorder(),
        ),
        textCapitalization: TextCapitalization.sentences,
      ),
    );
  }
}