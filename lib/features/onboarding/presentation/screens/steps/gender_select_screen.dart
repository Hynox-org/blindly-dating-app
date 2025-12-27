import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/onboarding_provider.dart';
import 'base_onboarding_step_screen.dart';

class GenderSelectScreen extends ConsumerStatefulWidget {
  const GenderSelectScreen({super.key});

  @override
  ConsumerState<GenderSelectScreen> createState() => _GenderSelectScreenState();
}

class _GenderSelectScreenState extends ConsumerState<GenderSelectScreen> {
  // Store the selection. 
  // NOTE: Your Repository will automatically convert this to lowercase 
  // to match your database Enum (e.g. 'Male' -> 'male').
  String? _selectedGender;

  @override
  Widget build(BuildContext context) {
    return BaseOnboardingStepScreen(
      title: 'Select your Gender',
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildGenderOption('Male'),
            const SizedBox(height: 16),
            _buildGenderOption('Female'),
            const SizedBox(height: 16),
            _buildGenderOption('Non-binary'),
            const SizedBox(height: 16),
            _buildGenderOption('Prefer not to say'),
          ],
        ),
      ),
      onNext: () async {
        // 1. VALIDATION: Check if selection is made
        if (_selectedGender == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please select an option.')),
          );
          return;
        }

        try {
          // 2. SAVE DATA: Call the specific endpoint
          // The repository handles the .toLowerCase() logic for your Enum
          await ref.read(onboardingProvider.notifier).saveGender(_selectedGender!);

          // 3. COMPLETE STEP
          ref.read(onboardingProvider.notifier).completeStep('gender_select');

        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error saving gender: $e')),
          );
        }
      },
    );
  }

  // Helper widget to build consistent selection buttons
  Widget _buildGenderOption(String label) {
    final isSelected = _selectedGender == label;

    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: isSelected ? Colors.blue.withOpacity(0.1) : null,
          side: BorderSide(
            color: isSelected ? Colors.blue : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: () {
          setState(() {
            _selectedGender = label;
          });
        },
        child: Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Colors.blue : Colors.black87,
          ),
        ),
      ),
    );
  }
}