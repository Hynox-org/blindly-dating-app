import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/onboarding_provider.dart';
import '../../../../auth/providers/auth_providers.dart';
import '../../../data/repositories/onboarding_repository.dart';
import 'base_onboarding_step_screen.dart';

class BirthDateScreen extends ConsumerStatefulWidget {
  const BirthDateScreen({super.key});

  @override
  ConsumerState<BirthDateScreen> createState() => _BirthDateScreenState();
}

class _BirthDateScreenState extends ConsumerState<BirthDateScreen> {
  DateTime? _selectedDate;
  bool _isSaving = false;
  final TextEditingController _dateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchExistingDate();
  }

  Future<void> _fetchExistingDate() async {
    final user = ref.read(authRepositoryProvider).currentUser;
    if (user != null) {
      final repo = ref.read(onboardingRepositoryProvider);
      final profile = await repo.getProfileRaw(user.id);
      if (profile != null && profile['birth_date'] != null) {
        final dateStr = profile['birth_date'] as String;
        // Postgres format YYYY-MM-DD
        final parts = dateStr.split('-');
        if (parts.length == 3) {
          final year = int.tryParse(parts[0]);
          final month = int.tryParse(parts[1]);
          final day = int.tryParse(parts[2]);

          if (year != null && month != null && day != null) {
            final date = DateTime(year, month, day);
            if (mounted) {
              setState(() {
                _selectedDate = date;
                _dateController.text =
                    "${day.toString().padLeft(2, '0')}-${month.toString().padLeft(2, '0')}-$year";
              });
            }
          }
        }
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(
        const Duration(days: 365 * 18),
      ), // Default to 18 years ago
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        // Format: DD-MM-YYYY
        _dateController.text =
            "${picked.day.toString().padLeft(2, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.year}";
      });
    }
  }

  Future<void> _handleNext() async {
    if (_selectedDate == null) return;

    setState(() => _isSaving = true);

    try {
      final user = ref.read(authRepositoryProvider).currentUser;
      if (user != null) {
        // Save birth_date to profile
        // Postgres DATE type expects YYYY-MM-DD string
        final dateString =
            "${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}";

        await ref.read(onboardingRepositoryProvider).updateProfileData(
          user.id,
          {'birth_date': dateString},
        );
      }

      await ref.read(onboardingProvider.notifier).completeStep('birth_date');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save birth date: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseOnboardingStepScreen(
      title: "Let's introduce you!",
      showBackButton: true,
      nextLabel: 'Continue',
      isNextEnabled: _selectedDate != null && !_isSaving,
      isLoading: _isSaving,
      onNext: _handleNext,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'We need your DOB to create your profile',
            style: TextStyle(fontSize: 14, color: Colors.black54),
          ),
          const SizedBox(height: 32),
          const Text(
            'Date of birth',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),

          InkWell(
            onTap: () => _selectDate(context),
            borderRadius: BorderRadius.circular(12),
            child: IgnorePointer(
              // Ignore pointer on TextField to use InkWell tap
              child: TextField(
                controller: _dateController,
                readOnly: true,
                decoration: InputDecoration(
                  hintText: 'DD-MM-YYYY',
                  hintStyle: TextStyle(color: Colors.grey.shade400),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),
          const Text(
            // Matches the text in the image provided
            'Your birthday is used to calculate your age and will be shown your profile. Your full name will not be public',
            style: TextStyle(fontSize: 12, color: Colors.black54, height: 1.5),
          ),
        ],
      ),
    );
  }
}
