import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../onboarding/domain/models/interest_chip_model.dart';
import '../../../../onboarding/presentation/providers/onboarding_provider.dart';
import '../../../../auth/providers/auth_providers.dart';
import '../../../../onboarding/data/repositories/onboarding_repository.dart';
import '../../../../onboarding/presentation/screens/steps/base_onboarding_step_screen.dart';
import '../../../../onboarding/presentation/widgets/selection_chip.dart';
import '../../../../../core/utils/custom_popups.dart';

class InterestsSelectScreen extends ConsumerStatefulWidget {
  const InterestsSelectScreen({super.key});

  @override
  ConsumerState<InterestsSelectScreen> createState() =>
      _InterestsSelectScreenState();
}

class _InterestsSelectScreenState extends ConsumerState<InterestsSelectScreen> {
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

      // Fetch user selections if logged in
      final user = ref.read(authRepositoryProvider).currentUser;
      final Set<String> loadedSelections = {};
      if (user != null) {
        final userChips = await repo.getUserInterestChips(user.id);
        loadedSelections.addAll(userChips);
      }

      setState(() {
        _allChips = rawChips
            .map((data) => InterestChip.fromJson(data))
            .toList();
        _selectedChipIds.addAll(loadedSelections);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load interests. Please try again.';
        _isLoading = false;
      });
    }
  }

  void _toggleChip(String chipId) {
    setState(() {
      if (_selectedChipIds.contains(chipId)) {
        _selectedChipIds.remove(chipId);
      } else {
        if (_selectedChipIds.length >= 10) {
          showErrorPopup(context, 'You can select up to 10 interests');
          return;
        }
        _selectedChipIds.add(chipId);
      }
    });
  }

  Future<void> _onNext() async {
    // Validation: If any selected, must be at least 5. If 0, allowed to proceed (skip).
    if (_selectedChipIds.isNotEmpty && _selectedChipIds.length < 5) {
      showErrorPopup(context, 'Please select at least 5 interests');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = ref.read(authRepositoryProvider).currentUser;
      if (user != null) {
        await ref
            .read(onboardingRepositoryProvider)
            .saveUserInterests(user.id, _selectedChipIds.toList());

        if (mounted) {
          ref
              .read(onboardingProvider.notifier)
              .completeStep('interests_select');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        showErrorPopup(context, 'Error saving interests: $e');
      }
    }
  }

  void _onSkip() {
    ref.read(onboardingProvider.notifier).skipStep('interests_select');
  }

  void _onBack() {
    ref.read(onboardingProvider.notifier).goToPreviousStep();
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

    // Check if "Continue" should be enabled based on validation
    // User Requirement: "disable the continue btn when no interests are selected."
    // Logic: Enabled ONLY if selected > 0.
    final hasSelection = _selectedChipIds.isNotEmpty;
    final isNextEnabled = !_isLoading && hasSelection;

    return BaseOnboardingStepScreen(
      title: 'Select Your Interests',
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
                      'Please select at least 5 interest. This helps us find your peoples',
                      style: TextStyle(
                        color: colorScheme.onSurface.withOpacity(0.6),
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
                      hintText: 'Search for interest',
                      hintStyle: TextStyle(
                        color: colorScheme.onSurface.withOpacity(0.54),
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: colorScheme.onSurface.withOpacity(0.54),
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
                      ? const Center(child: CircularProgressIndicator())
                      : _error != null
                      ? Center(child: Text(_error!))
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (grouped.isEmpty)
                              const Padding(
                                padding: EdgeInsets.all(20.0),
                                child: Center(
                                  child: Text("No interests found"),
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
