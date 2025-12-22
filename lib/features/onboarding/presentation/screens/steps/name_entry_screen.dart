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
  Widget build(BuildContext context) {
    return BaseOnboardingStepScreen(
      title: 'What is your name?',
      child: TextField(
        controller: _controller,
        decoration: const InputDecoration(
          labelText: 'Display Name',
          border: OutlineInputBorder(),
        ),
      ),
      onNext: () {
        if (_controller.text.isNotEmpty) {
          // Should update profile here too, but for flow test just step
          ref.read(onboardingProvider.notifier).completeStep('name_entry');
        }
      },
    );
  }
}
