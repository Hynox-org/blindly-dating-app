import 'package:flutter/material.dart';
import 'package:blindly_dating_app/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../onboarding/domain/models/interest_chip_model.dart';
import '../../../../onboarding/presentation/providers/onboarding_provider.dart';
import '../../../../auth/providers/auth_providers.dart';
import '../../../../onboarding/data/repositories/onboarding_repository.dart';
import '../../../../onboarding/presentation/screens/steps/base_onboarding_step_screen.dart';
import '../../../../onboarding/presentation/widgets/selection_chip.dart';
import '../../../../../core/utils/custom_popups.dart';
import '../../../../../core/widgets/app_loader.dart';
import '../../../../../core/providers/connection_mode_provider.dart';
import 'package:blindly_dating_app/features/profile/provider/profile_provider.dart';

/// Interests are all-or-a-real-handful: none is fine (Skip covers that), but
/// once the user starts picking they commit to at least five, and no more than
/// ten so the profile stays readable.
const int minInterests = 5;
const int maxInterests = 10;

bool interestsAreValid(int count) =>
    count == 0 || (count >= minInterests && count <= maxInterests);

class InterestsSelectScreen extends ConsumerStatefulWidget {
  final bool isEditMode;

  const InterestsSelectScreen({super.key, this.isEditMode = false});

  @override
  ConsumerState<InterestsSelectScreen> createState() =>
      _InterestsSelectScreenState();
}

class _InterestsSelectScreenState extends ConsumerState<InterestsSelectScreen> {
  AppLocalizations get l10n => AppLocalizations.of(context);

  bool _isLoading = true;
  List<InterestChip> _allChips = [];
  final Set<String> _selectedChipIds = {};
  String? _error;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchChips();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchChips() async {
    try {
      final repo = ref.read(onboardingRepositoryProvider);
      final rawChips = await repo.getInterestChips();

      if (!mounted) return;

      // Fetch user selections if logged in
      final user = ref.read(authRepositoryProvider).currentUser;
      final Set<String> loadedSelections = {};
      if (user != null) {
        final currentMode = ref.read(connectionModeProvider).toLowerCase();
        final userChips = await repo.getUserInterestChips(
          user.id,
          mode: currentMode,
        );
        if (!mounted) return;
        loadedSelections.addAll(userChips);
      }

      final List<InterestChip> validChips = [];
      for (final data in rawChips) {
        try {
          validChips.add(InterestChip.fromJson(data));
        } catch (e) {
          debugPrint('⚠️ INTEREST_SCREEN: Invalid chip data: $e');
          // Skip invalid chips silently or log if needed
        }
      }

      setState(() {
        _allChips = validChips;
        _selectedChipIds.addAll(loadedSelections);
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('❌ INTEREST_SCREEN: Error fetching chips: $e');
      setState(() {
        _error = l10n.failedLoadInterests;
        _isLoading = false;
      });
    }
  }

  void _toggleChip(String chipId) {
    setState(() {
      if (_selectedChipIds.contains(chipId)) {
        _selectedChipIds.remove(chipId);
      } else {
        if (_selectedChipIds.length >= maxInterests) {
          showErrorPopup(context, l10n.maxTenInterests);
          return;
        }
        _selectedChipIds.add(chipId);
      }
    });
  }

  Future<void> _onNext() async {
    if (!interestsAreValid(_selectedChipIds.length)) {
      showErrorPopup(context, l10n.minFiveInterests);
      return;
    }

    // Bail before the spinner goes up: returning after it with nothing to save
    // against would leave the button dead.
    final user = ref.read(authRepositoryProvider).currentUser;
    if (user == null) return;

    setState(() => _isLoading = true);

    try {
      await ref
          .read(onboardingRepositoryProvider)
          .saveUserInterests(
            user.id,
            _selectedChipIds.toList(),
            mode: ref.read(connectionModeProvider).toLowerCase(),
          );
      if (!mounted) return;

      if (widget.isEditMode) {
        final currentProfile = ref.read(currentUserProfileProvider).value;
        if (currentProfile != null) {
          ref
              .read(currentUserProfileProvider.notifier)
              .updateProfile(
                currentProfile.copyWith(interests: _selectedChipIds.toList()),
              );
          await ref
              .read(currentUserProfileProvider.notifier)
              .triggerTrustCalculation();
        }
        if (mounted) Navigator.pop(context);
        return;
      }

      ref.read(onboardingProvider.notifier).completeStep('interests_select');
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        showErrorPopup(context, l10n.errorSavingInterests('$e'));
      }
    }
  }

  void _onSkip() {
    if (widget.isEditMode) return;
    ref.read(onboardingProvider.notifier).skipStep('interests_select');
  }

  void _onBack() {
    if (widget.isEditMode) {
      Navigator.pop(context);
    } else {
      ref.read(onboardingProvider.notifier).goToPreviousStep();
    }
  }

  Map<String, List<InterestChip>> get _groupedChips {
    final Map<String, List<InterestChip>> grouped = {};
    for (var chip in _allChips) {
      // Filter based on search query
      if (_searchQuery.isNotEmpty &&
          !chip.label.toLowerCase().contains(_searchQuery)) {
        continue;
      }

      if (!grouped.containsKey(chip.section)) {
        grouped[chip.section] = [];
      }
      grouped[chip.section]!.add(chip);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final grouped = _groupedChips;
    final colorScheme = Theme.of(context).colorScheme;

    // Continue commits a selection; Skip is how you move on without one, so
    // Continue stays disabled until something is picked. Edit mode has no Skip
    // button, so it must still allow clearing every interest.
    final isNextEnabled =
        !_isLoading && (widget.isEditMode || _selectedChipIds.isNotEmpty);

    return BaseOnboardingStepScreen(
      title: l10n.selectYourInterests,
      showBackButton: false,
      showNextButton: false,
      showSkipButton: false,
      isEditMode: widget.isEditMode, // Pass edit mode to base
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
                      l10n.atLeast5Interests,
                      style: TextStyle(
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Search Bar
                  TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value.toLowerCase().trim();
                      });
                    },
                    style: TextStyle(color: colorScheme.onSurface),
                    decoration: InputDecoration(
                      hintText: l10n.searchForInterest,
                      hintStyle: TextStyle(
                        color: colorScheme.onSurface.withValues(alpha: 0.54),
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: colorScheme.onSurface.withValues(alpha: 0.54),
                      ),
                      filled: true,
                      fillColor: colorScheme.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    ),
                  ),
                  const SizedBox(height: 20),

                  _isLoading && _allChips.isEmpty
                      ? const Center(child: AppLoader())
                      : _error != null
                      ? Center(child: Text(_error!))
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (grouped.isEmpty)
                              Padding(
                                padding: EdgeInsets.all(20.0),
                                child: Center(
                                  child: Text(l10n.noInterestsFound),
                                ),
                              ),
                            ...grouped.entries.map((entry) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12.0,
                                    ),
                                    child: Text(
                                      entry.key, // Section Name
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
                                    children: entry.value.map((chip) {
                                      final isSelected = _selectedChipIds
                                          .contains(chip.id);
                                      return SelectionChip(
                                        label: chip.label,
                                        isSelected: isSelected,
                                        onTap: () => _toggleChip(chip.id),
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

          // Custom Footer Buttons
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
                    // Hide SKIP button in Edit Mode
                    if (!widget.isEditMode)
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
