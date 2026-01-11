import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../onboarding/presentation/providers/onboarding_provider.dart';
import '../../../../onboarding/presentation/screens/steps/base_onboarding_step_screen.dart';
import '../../../../onboarding/data/repositories/onboarding_repository.dart';
import '../../../../onboarding/domain/models/lifestyle_category_model.dart';
import '../../../../auth/providers/auth_providers.dart';
import '../../../../onboarding/presentation/widgets/selection_chip.dart';
import '../../../../../core/utils/custom_popups.dart';

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

      // Fetch user selections
      final user = ref.read(authRepositoryProvider).currentUser;
      final Map<int, String> loadedSelections = {};

      if (user != null) {
        final userChipIds = await repo.getUserLifestyleChips(user.id);
        // Map chip IDs back to selections map (CategoryId -> ChipId)
        // We need to find which category each chip belongs to
        for (var chipId in userChipIds) {
          for (var cat in categories) {
            if (cat.chips.any((c) => c.id == chipId)) {
              loadedSelections[cat.id] = chipId;
              break;
            }
          }
        }
      }

      setState(() {
        _categories = categories;
        _selections.addAll(loadedSelections);
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
      // Toggle logic: if already selected, unselect. Else replace.
      if (_selections[categoryId] == chipId) {
        _selections.remove(categoryId);
      } else {
        _selections[categoryId] = chipId;
      }
    });
  }

  String _formatCategoryKey(String key) {
    if (key.isEmpty) return key;
    final text = key.replaceAll('_', ' ');
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  bool get _isFormValid {
    if (_categories.isEmpty) return false;
    // If nothing selected at all -> valid (can skip/empty save)
    if (_selections.isEmpty) return true;

    // If at least one selected -> MUST select for ALL categories
    for (var cat in _categories) {
      if (!_selections.containsKey(cat.id)) {
        return false;
      }
    }
    return true;
  }

  Future<void> _onNext() async {
    // Logic:
    // If selections empty -> proceed (save empty/skip).
    // If selections not empty -> must correspond to all categories (checked by _isFormValid).

    if (!_isFormValid) {
      // Should check specifically if we have partial selection
      if (_selections.isNotEmpty && _selections.length < _categories.length) {
        showErrorPopup(
          context,
          'Please select an option for each category, or clear all to skip.',
        );
      }
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

        if (mounted) {
          ref.read(onboardingProvider.notifier).completeStep('lifestyle_prefs');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        showErrorPopup(context, 'Error saving preferences: $e');
      }
    }
  }

  void _onSkip() {
    ref.read(onboardingProvider.notifier).skipStep('lifestyle_prefs');
  }

  void _onBack() {
    ref.read(onboardingProvider.notifier).goToPreviousStep();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // Valid state for button: not loading AND form logic satisfied
    final isNextEnabled = !_isLoading && _isFormValid;

    return BaseOnboardingStepScreen(
      title: 'Life Style',
      showBackButton: false,
      showNextButton: false,
      showSkipButton: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: Text(
                      'Tell us more about your habits. Pick what fits you best.',
                      style: TextStyle(
                        color: colorScheme.onSurface.withOpacity(0.54),
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (_isLoading && _categories.isEmpty)
                    const Center(child: CircularProgressIndicator())
                  else if (_error != null)
                    Center(child: Text(_error!))
                  else if (_categories.isEmpty)
                    Center(
                      child: Text(
                        "No lifestyle options available",
                        style: TextStyle(color: colorScheme.onSurface),
                      ),
                    )
                  else
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ..._categories.map((category) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12.0,
                                ),
                                child: Text(
                                  _formatCategoryKey(category.key),
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.onSurface,
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
                                    onTap: () =>
                                        _selectChip(category.id, chip.id),
                                    icon: null,
                                  );
                                }).toList(),
                              ),
                              const SizedBox(height: 16),
                            ],
                          );
                        }),
                        const SizedBox(height: 20),
                      ],
                    ),
                ],
              ),
            ),
          ),

          // Custom Footer
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isNextEnabled ? _onNext : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: colorScheme.onPrimary,
                            ),
                          )
                        : const Text(
                            "Continue",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton.icon(
                      onPressed: _onBack,
                      icon: Icon(
                        Icons.arrow_back,
                        size: 20,
                        color: colorScheme.onSurface,
                      ),
                      label: Text(
                        "Back",
                        style: TextStyle(
                          color: colorScheme.onSurface,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 8,
                        ),
                      ),
                    ),
                    Directionality(
                      textDirection: TextDirection.rtl,
                      child: TextButton.icon(
                        onPressed: _onSkip,
                        icon: Icon(
                          Icons.skip_next_rounded,
                          size: 24,
                          color: colorScheme.onSurface,
                        ),
                        label: Text(
                          "Skip",
                          style: TextStyle(
                            color: colorScheme.onSurface,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 8,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
