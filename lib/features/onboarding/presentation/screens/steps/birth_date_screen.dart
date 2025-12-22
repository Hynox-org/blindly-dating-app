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
      onNext: () {
        // if (_selectedDate != null)
        ref.read(onboardingProvider.notifier).completeStep('birth_date');
      },
    );
  }
}
