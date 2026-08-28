import 'package:flutter/material.dart';
import 'package:blindly_dating_app/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:blindly_dating_app/features/onboarding/presentation/providers/onboarding_provider.dart';
import 'package:blindly_dating_app/features/onboarding/presentation/screens/steps/base_onboarding_step_screen.dart';
import 'package:blindly_dating_app/features/onboarding/data/repositories/onboarding_repository.dart';
import 'package:blindly_dating_app/features/onboarding/domain/models/lifestyle_category_model.dart';
import 'package:blindly_dating_app/features/auth/providers/auth_providers.dart';
import 'package:blindly_dating_app/features/onboarding/presentation/widgets/selection_chip.dart';
import 'package:blindly_dating_app/core/utils/custom_popups.dart';
import 'package:blindly_dating_app/core/widgets/app_loader.dart';
import 'package:blindly_dating_app/core/providers/connection_mode_provider.dart';
import 'package:blindly_dating_app/features/profile/provider/profile_provider.dart';
import 'package:blindly_dating_app/features/profile/domain/models/profile_user_model.dart';
import 'package:blindly_dating_app/features/onboarding/domain/models/lifestyle_chip_model.dart';

/// Lifestyle answers are all or nothing: a half-filled set reads worse on a
/// profile than an empty one, and Skip is there for people who want none.
bool lifestyleIsValid({
  required int answered,
  required int categoryCount,
}) {
  if (categoryCount == 0) return false;
  return answered == 0 || answered == categoryCount;
}

class LifestylePrefsScreen extends ConsumerStatefulWidget {
  final bool isEditMode;

  const LifestylePrefsScreen({super.key, this.isEditMode = false});

  @override
  ConsumerState<LifestylePrefsScreen> createState() =>
      _LifestylePrefsScreenState();
}

class _LifestylePrefsScreenState extends ConsumerState<LifestylePrefsScreen> {
  AppLocalizations get l10n => AppLocalizations.of(context);

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
        final currentMode = ref.read(connectionModeProvider).toLowerCase();
        final userChipIds = await repo.getUserLifestyleChips(
          user.id,
          mode: currentMode,
        );
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
        _error = l10n.failedLoadLifestyle;
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

  bool get _isFormValid => lifestyleIsValid(
    answered: _categories.where((c) => _selections.containsKey(c.id)).length,
    categoryCount: _categories.length,
  );

  Future<void> _onNext() async {
    if (!_isFormValid) {
      if (_selections.isNotEmpty) {
        showErrorPopup(context, l10n.selectEachCategory);
      }
      return;
    }

    // Bail before the spinner goes up: returning after it with nothing to save
    // against would leave the button dead.
    final user = ref.read(authRepositoryProvider).currentUser;
    if (user == null) return;

    setState(() => _isLoading = true);

    try {
      {
        final allSelectedChipIds = _selections.values.toList();
        final currentMode = ref.read(connectionModeProvider).toLowerCase();
        await ref
            .read(onboardingRepositoryProvider)
            .saveLifestylePreferences(
              user.id,
              allSelectedChipIds,
              mode: currentMode,
            );

        if (widget.isEditMode) {
          if (mounted) {
            final ProfileUser? currentProfile = ref
                .read(currentUserProfileProvider)
                .value;
            if (currentProfile != null) {
              // Construct new list of LifestyleChip objects
              final List<LifestyleChip> newLifestyleItems = [];
              for (var cat in _categories) {
                final catKey = cat.key;
                final catName = _formatCategoryKey(cat.key);
                for (var chip in cat.chips) {
                  if (allSelectedChipIds.contains(chip.id)) {
                    newLifestyleItems.add(
                      chip.copyWith(categoryKey: catKey, categoryName: catName),
                    );
                  }
                }
              }

              final updatedProfile = currentProfile.copyWith(
                lifestyleItems: newLifestyleItems,
              );
              ref
                  .read(currentUserProfileProvider.notifier)
                  .updateProfile(updatedProfile);

              // Trigger trust calculation
              await ref
                  .read(currentUserProfileProvider.notifier)
                  .triggerTrustCalculation();
            }
            if (mounted) Navigator.pop(context);
          }
        } else {
          if (mounted) {
            ref
                .read(onboardingProvider.notifier)
                .completeStep('lifestyle_prefs');
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        showErrorPopup(context, l10n.errorSavingPreferences('$e'));
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
    // Same rule as the interests step: Continue commits answers, Skip is how
    // you move on without any. Edit mode has no Skip, so it must still allow
    // clearing every answer.
    final isNextEnabled =
        !_isLoading &&
        _isFormValid &&
        (widget.isEditMode || _selections.isNotEmpty);

    return BaseOnboardingStepScreen(
      title: l10n.lifeStyle,
      showBackButton: widget.isEditMode, // Show back button in edit mode
      isEditMode: widget.isEditMode,
      // In edit mode we rely on BaseOnboardingStepScreen's button or custom one?
      // BaseOnboardingStepScreen has a bottom button. We are overriding Child and providing our own footer in original code.
      // Let's use BaseOnboardingStepScreen's footer functionality if possible, or keep custom.
      // The original code passed `showNextButton: false` and built its own footer.
      // To keep it consistent, let's keep the custom footer but adapt it.
      showNextButton: false,
      showSkipButton: false,
      onBack: widget.isEditMode ? () => Navigator.pop(context) : _onBack,
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
                      l10n.lifestylePrompt,
                      style: TextStyle(
                        color: colorScheme.onSurface.withValues(alpha: 0.54),
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (_isLoading && _categories.isEmpty)
                    const Center(child: AppLoader())
                  else if (_error != null)
                    Center(child: Text(_error!))
                  else if (_categories.isEmpty)
                    Center(
                      child: Text(
                        l10n.noLifestyleOptions,
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
                            child: AppLoader(
                              strokeWidth: 2,
                              color: colorScheme.onPrimary,
                              size: 24,
                            ),
                          )
                        : Text(
                            widget.isEditMode ? "Update" : "Continue",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 16),

                // Navigation Row (Back & Skip) - Only show if NOT in Edit Mode or if we want Back in Edit Mode but we have AppBar back usually?
                // BaseOnboardingStepScreen handles AppBar back if showBackButton is true.
                if (!widget.isEditMode)
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
