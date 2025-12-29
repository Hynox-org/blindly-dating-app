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
  String? _selectedGender;
  bool _showGenderOnProfile = false;
  bool _showError = false; // Error indicator flag
  final List<String> _genderOptions = ['Male', 'Female', 'Non-Binary'];

  @override
  Widget build(BuildContext context) {
    return BaseOnboardingStepScreen(
      title: "What's your Gender?",
      showBackButton: true,
      nextLabel: 'Continue',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Helper text
          Text(
            'This help us show you relevant profiles and find your matches',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 24),

          // Gender options list
          ..._genderOptions.map((gender) {
            final isSelected = _selectedGender == gender;
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: isSelected 
                    ? const Color(0xFF4A5A3E) 
                    : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _showError && !isSelected
                      ? Colors.red // Red border when error and not selected
                      : isSelected 
                          ? const Color(0xFF4A5A3E) 
                          : Colors.grey[300]!,
                  width: _showError && !isSelected ? 2 : 1,
                ),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                title: Text(
                  gender,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: isSelected ? Colors.white : Colors.black,
                  ),
                ),
                trailing: isSelected
                    ? const Icon(
                        Icons.check_circle,
                        color: Color(0xFFD4AF37),
                        size: 24,
                      )
                    : Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _showError 
                                ? Colors.red 
                                : Colors.grey[400]!,
                            width: 2,
                          ),
                        ),
                      ),
                onTap: () {
                  setState(() {
                    _selectedGender = gender;
                    // Clear error when user selects
                    _showError = false;
                  });
                },
              ),
            );
          }).toList(),

          // Error message
          if (_showError)
            Padding(
              padding: const EdgeInsets.only(top: 8, left: 4),
              child: Text(
                'Please select your gender',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.red[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

          const Spacer(),

          // Show gender on profile toggle
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Show my gender on my profile',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Switch(
                value: _showGenderOnProfile,
                onChanged: (value) {
                  setState(() {
                    _showGenderOnProfile = value;
                  });
                },
                activeColor: const Color(0xFF4A5A3E),
              ),
            ],
          ),
        ],
      ),
      onNext: () {
        // Validation: Check if gender is selected
        if (_selectedGender == null) {
          // Show error indicator
          setState(() {
            _showError = true;
          });
          
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                title: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: Colors.red[700],
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Gender Required',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                content: const Text(
                  'Please select your gender to continue',
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    child: const Text(
                      'OK',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              );
            },
          );
          return;
        }
        
        // All validations passed - proceed to next step
        setState(() {
          _showError = false;
        });
        
        // TODO: Save gender and showGenderOnProfile values
        debugPrint('Selected Gender: $_selectedGender');
        debugPrint('Show on Profile: $_showGenderOnProfile');
        
        ref.read(onboardingProvider.notifier).completeStep('gender_select');
      },
    );
  }
}
