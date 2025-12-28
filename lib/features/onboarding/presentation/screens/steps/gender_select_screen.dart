import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../providers/onboarding_provider.dart';
import '../../../../auth/providers/auth_providers.dart';
import '../../../data/repositories/onboarding_repository.dart';
import 'base_onboarding_step_screen.dart';

class GenderSelectScreen extends ConsumerStatefulWidget {
  const GenderSelectScreen({super.key});

  @override
  ConsumerState<GenderSelectScreen> createState() => _GenderSelectScreenState();
}

class _GenderSelectScreenState extends ConsumerState<GenderSelectScreen> {
  String? _selectedGender; // 'male', 'female', 'non_binary'
  bool _showOnProfile = false;
  bool _isSaving = false;

  final List<Map<String, String>> _genderOptions = [
    {'value': 'male', 'label': 'Male'},
    {'value': 'female', 'label': 'Female'},
    {'value': 'non_binary', 'label': 'Non-Binary'},
  ];

  Future<void> _handleNext() async {
    if (_selectedGender == null) return;

    setState(() => _isSaving = true);

    try {
      final user = ref.read(authRepositoryProvider).currentUser;
      if (user != null) {
        // Map internal values to Database Enum values: M, F, NB, Prefer Not
        String dbGender;
        switch (_selectedGender) {
          case 'male':
            dbGender = 'M';
            break;
          case 'female':
            dbGender = 'F';
            break;
          case 'non_binary':
            dbGender = 'NB';
            break;
          default:
            dbGender = 'Prefer Not';
        }

        final Map<String, dynamic> updates = {'gender': dbGender};

        await ref
            .read(onboardingRepositoryProvider)
            .updateProfileData(user.id, updates);
      }

      await ref.read(onboardingProvider.notifier).completeStep('gender_select');
    } catch (e) {
      debugPrint('Error saving gender: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to save gender: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseOnboardingStepScreen(
      title: "What's your Gender?",
      showBackButton: true,
      nextLabel: 'Continue',
      isNextEnabled: _selectedGender != null && !_isSaving,
      isLoading: _isSaving,
      onNext: _handleNext,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'This help us show you relevant profiles and find your matches',
            style: TextStyle(fontSize: 14, color: Colors.black54),
          ),
          const SizedBox(height: 32),

          ..._genderOptions.map((option) {
            final isSelected = _selectedGender == option['value'];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: InkWell(
                onTap: () {
                  setState(() => _selectedGender = option['value']);
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 20,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF4A4E3D) // Dark olive/brown from image
                        : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: isSelected
                        ? Border.all(color: Colors.transparent)
                        : Border.all(
                            color: Colors.transparent,
                          ), // Image shows white cards with shadow? or just white. Text is black.
                    boxShadow: [
                      if (!isSelected)
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        option['label']!,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? const Color(0xFFCDB38B)
                              : Colors
                                    .black87, // Gold text when selected, Black when not
                        ),
                      ),
                      if (isSelected)
                        const Icon(
                          FontAwesomeIcons.circleCheck,
                          color: Color(0xFFCDB38B), // Gold check
                          size: 24,
                        )
                      else
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey.shade300,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
