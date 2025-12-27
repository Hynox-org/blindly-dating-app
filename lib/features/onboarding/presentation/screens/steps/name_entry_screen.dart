import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/onboarding_provider.dart';
import 'base_onboarding_step_screen.dart';

class NameEntryScreen extends ConsumerStatefulWidget {
  const NameEntryScreen({super.key});

  @override
  ConsumerState<NameEntryScreen> createState() => _NameEntryScreenState();
}

class _NameEntryScreenState extends ConsumerState<NameEntryScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose(); // Always dispose controllers to prevent memory leaks
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BaseOnboardingStepScreen(
      title: 'What is your name?',
      child: Center(
        child: TextField(
          controller: _controller,
          decoration: const InputDecoration(
            labelText: 'Display Name',
            border: OutlineInputBorder(),
            hintText: 'Enter your name',
          ),
          // UX Improvement: Auto-capitalize the first letter of each word
          textCapitalization: TextCapitalization.words,
        ),
      ),
      onNext: () async {
        final name = _controller.text.trim();

        // 1. VALIDATION: Check if name is empty
        if (name.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please enter your name.')),
          );
          return;
        }

        try {
          // 2. SAVE DATA: Call the specific endpoint
          // The repository will automatically truncate it if it's over 100 chars
          await ref.read(onboardingProvider.notifier).saveDisplayName(name);

          // 3. COMPLETE STEP
          ref.read(onboardingProvider.notifier).completeStep('name_entry');

        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error saving name: $e')),
          );
        }
      },
    );
  }
}