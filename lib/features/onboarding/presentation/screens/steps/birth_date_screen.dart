import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/onboarding_provider.dart';
import 'base_onboarding_step_screen.dart';

class BirthDateScreen extends ConsumerStatefulWidget {
  const BirthDateScreen({super.key});

  @override
  ConsumerState<BirthDateScreen> createState() => _BirthDateScreenState();
}

class _BirthDateScreenState extends ConsumerState<BirthDateScreen> {
  DateTime? _selectedDate;

  @override
  Widget build(BuildContext context) {
    return BaseOnboardingStepScreen(
      title: 'When is your birthday?',
      child: Center(
        child: ElevatedButton(
          onPressed: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: DateTime(2000),
              firstDate: DateTime(1900),
              lastDate: DateTime.now(),
            );
            if (picked != null) {
              setState(() => _selectedDate = picked);
            }
          },
          child: Text(
            _selectedDate == null
                ? 'Select Date'
                : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
          ),
        ),
      ),
      onNext: () async {
        // 1. VALIDATION: Check if user picked a date
        if (_selectedDate == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please select your birth date first.')),
          );
          return;
        }

        try {
          // 2. SAVE DATA: Call the specific provider function
          // The Repository will handle the conversion to "YYYY-MM-DD" automatically.
          await ref.read(onboardingProvider.notifier).saveBirthDate(_selectedDate!);

          // 3. COMPLETE STEP: Move to the next screen
          ref.read(onboardingProvider.notifier).completeStep('birth_date');

        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error saving date: $e')),
          );
        }
      },
    );
  }
}