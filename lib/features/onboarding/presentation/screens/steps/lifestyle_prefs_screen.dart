import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/onboarding_provider.dart';
import 'base_onboarding_step_screen.dart';


class LifestylePrefsScreen extends ConsumerStatefulWidget {
  const LifestylePrefsScreen({super.key});


  @override
  ConsumerState<LifestylePrefsScreen> createState() => _LifestylePrefsScreenState();
}


class _LifestylePrefsScreenState extends ConsumerState<LifestylePrefsScreen> {
  // Selected values for each category
  String? _selectedFitness;
  String? _selectedEating;
  String? _selectedDrinking;
  String? _selectedSmoking;
  String? _selectedSocial;
  String? _selectedTravel;

  // Category options
  final Map<String, List<Map<String, String>>> _lifestyleOptions = {
    'Fitness': [
      {'name': 'Active', 'icon': 'assests/images/hire.png'},
      {'name': 'Sometimes', 'icon': 'assests/images/chronometer.png'},
      {'name': 'Out door', 'icon': 'assests/images/logout.png'},
      {'name': 'Gym enthusiast', 'icon': 'assests/images/weightlifting.png'},
    ],
    'Eating habits': [
      {'name': 'Vegan', 'icon': 'assests/images/vegetarian.png'},
      {'name': 'Non-vegetarian', 'icon': 'assests/images/fried-chicken.png'},
      {'name': 'Omnivore', 'icon': 'assests/images/omnivore.png'},
      {'name': 'Foodie', 'icon': 'assests/images/food.png'},
    ],
    'Drinking': [
      {'name': 'Never', 'icon': 'assests/images/close.png'},
      {'name': 'Occasionally', 'icon': 'assests/images/car.png'},
      {'name': 'Frequently', 'icon': 'assests/images/continuous-improvement.png'},
    ],
    'Smoking': [
      {'name': 'Never', 'icon': 'assests/images/close.png'},
      {'name': 'Occasionally', 'icon': 'assests/images/car.png'},
      {'name': 'Frequently', 'icon': 'assests/images/continuous-improvement.png'},
    ],
    'Social preference': [
      {'name': 'Introvert', 'icon': 'assests/images/introvert.png'},
      {'name': 'Extrovert', 'icon': 'assests/images/extrovert.png'},
      {'name': 'Home body', 'icon': 'assests/images/house.png'},
      {'name': 'Night owl', 'icon': 'assests/images/owl.png'},
    ],
    'Travel style': [
      {'name': 'Relaxer', 'icon': 'assests/images/relax.png'},
      {'name': 'Planner', 'icon': 'assests/images/event-planner.png'},
      {'name': 'Adventurer', 'icon': 'assests/images/adventurer.png'},
      {'name': 'Spontaneous', 'icon': 'assests/images/idea.png'},
    ],
  };

  void _selectOption(String category, String option) {
    setState(() {
      switch (category) {
        case 'Fitness':
          _selectedFitness = option;
          break;
        case 'Eating habits':
          _selectedEating = option;
          break;
        case 'Drinking':
          _selectedDrinking = option;
          break;
        case 'Smoking':
          _selectedSmoking = option;
          break;
        case 'Social preference':
          _selectedSocial = option;
          break;
        case 'Travel style':
          _selectedTravel = option;
          break;
      }
    });
  }

  String? _getSelectedValue(String category) {
    switch (category) {
      case 'Fitness':
        return _selectedFitness;
      case 'Eating habits':
        return _selectedEating;
      case 'Drinking':
        return _selectedDrinking;
      case 'Smoking':
        return _selectedSmoking;
      case 'Social preference':
        return _selectedSocial;
      case 'Travel style':
        return _selectedTravel;
      default:
        return null;
    }
  }

  Widget _buildCategorySection(String category, List<Map<String, String>> options) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.only(bottom: 12.0, top: 16.0),
        child: Text(
          category,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ),
      Wrap(
        spacing: 8.0,
        runSpacing: 8.0,
        children: options.map((option) {
          final isSelected = _getSelectedValue(category) == option['name'];
          return ChoiceChip(
            label: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Change this line - use Image.asset instead of Text
                Image.asset(
                  option['icon'] ?? '',
                  width: 20,
                  height: 20,
                  errorBuilder: (context, error, stackTrace) {
                    // Fallback if image not found
                    return Icon(
                      Icons.image_not_supported,
                      size: 20,
                      color: isSelected ? Colors.white : Colors.grey,
                    );
                  },
                ),
                const SizedBox(width: 6),
                Text(
                  option['name'] ?? '',
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            selected: isSelected,
            onSelected: (selected) {
              if (selected) {
                _selectOption(category, option['name']!);
              }
            },
            backgroundColor: Colors.white,
            selectedColor: const Color(0xFF4A5A3E),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: isSelected ? const Color(0xFF4A5A3E) : Colors.grey[300]!,
                width: 1,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            showCheckmark: false,
          );
        }).toList(),
      ),
    ],
  );
}

  @override
  Widget build(BuildContext context) {
    return BaseOnboardingStepScreen(
      title: 'Life Style',
      showBackButton: true,
      nextLabel: 'Continue',
      onNext: () {
        // Validation: Check if all categories have selections
        final List<String> missingCategories = [];
        
        if (_selectedFitness == null) missingCategories.add('Fitness');
        if (_selectedEating == null) missingCategories.add('Eating habits');
        if (_selectedDrinking == null) missingCategories.add('Drinking');
        if (_selectedSmoking == null) missingCategories.add('Smoking');
        if (_selectedSocial == null) missingCategories.add('Social preference');
        if (_selectedTravel == null) missingCategories.add('Travel style');

        if (missingCategories.isNotEmpty) {
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
                      'Incomplete Selection',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                content: Text(
                  'Please select an option for the following categories:\n\n${missingCategories.map((cat) => '• $cat').join('\n')}',
                  style: const TextStyle(
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
        ref.read(onboardingProvider.notifier).completeStep('lifestyle_prefs');
      },
      // showSkipButton: true,
      // onSkip: () {
      //   ref.read(onboardingProvider.notifier).skipStep('lifestyle_prefs');
      // },
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Helper text
            Text(
              'Tell us more about your habits. Pick what fits you best.',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),

            // Build all category sections
            ..._lifestyleOptions.entries.map(
              (entry) => _buildCategorySection(entry.key, entry.value),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
