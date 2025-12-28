import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/onboarding_provider.dart';
import 'base_onboarding_step_screen.dart';
import '../../../data/repositories/onboarding_repository.dart';
import '../../../domain/models/lifestyle_category_model.dart';
import '../../../../auth/providers/auth_providers.dart';
import '../../widgets/selection_chip.dart';

class LifestylePrefsScreen extends ConsumerStatefulWidget {
  const LifestylePrefsScreen({super.key});

  @override
  ConsumerState<LifestylePrefsScreen> createState() =>
      _LifestylePrefsScreenState();
}

class _LifestylePrefsScreenState extends ConsumerState<LifestylePrefsScreen> {
  bool _isLoading = true;
  List<LifestyleCategory> _categories = [];
  // Map of Category ID -> Selected Chip ID
  final Map<int, String> _selections = {};
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    try {
      final repo = ref.read(onboardingRepositoryProvider);
      final categories = await repo.getLifestyleCategoriesWithChips();
      setState(() {
        _categories = categories;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load lifestyle options. Please try again.';
        _isLoading = false;
      });
    }
  }

  void _selectChip(int categoryId, String chipId) {
    setState(() {
      // Single select per category: replace existing selection
      _selections[categoryId] = chipId;
    });
  }

  String _formatCategoryKey(String key) {
    if (key.isEmpty) return key;
    // Replace underscores with spaces
    final text = key.replaceAll('_', ' ');
    // Capitalize first letter only (Sentence case)
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  bool get _isFormValid {
    if (_categories.isEmpty) return false;
    // Must have a selection for every category
    for (var cat in _categories) {
      if (!_selections.containsKey(cat.id)) {
        return false;
      }
    }
    return true;
  }

  Future<void> _onNext() async {
    if (!_isFormValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an option for each category'),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = ref.read(authRepositoryProvider).currentUser;
      if (user != null) {
        final allSelectedChipIds = _selections.values.toList();
        await ref
            .read(onboardingRepositoryProvider)
            .saveLifestylePreferences(user.id, allSelectedChipIds);
        ref.read(onboardingProvider.notifier).completeStep('lifestyle_prefs');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error saving preferences: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseOnboardingStepScreen(
      title: 'Life Style', // Matches Image
      onNext: _onNext,
      isNextEnabled: !_isLoading && _isFormValid,
      showSkipButton: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.0),
            child: Text(
              'Tell us more about your habits. Pick what fits you best.', // Matches Image
              style: TextStyle(color: Colors.black54, fontSize: 14),
            ),
          ),
          const SizedBox(height: 20),
          if (_isLoading && _categories.isEmpty)
            const Center(child: CircularProgressIndicator())
          else if (_error != null)
            Center(child: Text(_error!))
          else if (_categories.isEmpty)
            const Center(child: Text("No lifestyle options available"))
          else
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ..._categories.map((category) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12.0),
                            child: Text(
                              _formatCategoryKey(
                                category.key,
                              ), // Formatted Name
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: category.chips.map((chip) {
                              final isSelected =
                                  _selections[category.id] == chip.id;
                              return SelectionChip(
                                label: chip.label,
                                isSelected: isSelected,
                                onTap: () => _selectChip(category.id, chip.id),
                                icon: null,
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 16),
                        ],
                      );
                    }),
                    const SizedBox(height: 80), // Bottom padding
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
