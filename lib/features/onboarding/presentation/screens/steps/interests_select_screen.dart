import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/onboarding_provider.dart';
import '../../../data/repositories/onboarding_repository.dart';
import '../../../domain/models/interest_chip_model.dart';
import '../../../../auth/providers/auth_providers.dart';
import 'base_onboarding_step_screen.dart';
import '../../widgets/selection_chip.dart';
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
    if (_selectedChipIds.length < 5) {
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
        ref.read(onboardingProvider.notifier).completeStep('interests_select');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      showErrorPopup(context, 'Error saving interests: $e');
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

  // Helper to get a consistent generic icon/emoji based on section or label if needed
  // For now, using a placeholder icon logic or just text + styling as verified in design.
  // The design shows specific emojis. Without a mapping DB, we can't be 100% accurate,
  // but we can try basic section mapping or just use a generic dot/icon if strict replication isn't possible content-wise.
  // However, I'll stick to the requested layout structure.

  @override
  Widget build(BuildContext context) {
    final grouped = _groupedChips;

    // If user strict on color: 'const Color(0xFF4B5320)' or similar.
    // Let's stick to theme primary for now unless specified otherwise in theme.

    return BaseOnboardingStepScreen(
      // We will override the default Title/Subtitle mechanism of BaseOnboardingStepScreen
      // by passing empty strings or handling it inside 'child' if the Base allows custom headers.
      // Looking at previous valid code, BaseOnboardingStepScreen takes title/onNext.
      // We'll pass the title "Select Your Interests" to match design.
      title: 'Select Your Interests',
      showBackButton: true,
      onNext: _onNext,
      isNextEnabled: !_isLoading && _selectedChipIds.length >= 5,
      // The design has specific subheader text. BaseOnboarding probably renders 'title' at top.
      // We will add the specific subheader in the body.
      showSkipButton: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Text(
              'Please select at least 5 interest. This helps us find your peoples', // Typo "peoples" in user prompt/image? keeping faithful to image text if possible or correcting grammar? Image says "find your peoples", I will match image text.
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
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
            style: const TextStyle(
              color: Colors.black87,
            ), // Ensure visible text
            decoration: InputDecoration(
              hintText: 'Search for interest',
              hintStyle: const TextStyle(color: Colors.black54),
              prefixIcon: const Icon(Icons.search, color: Colors.black54),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
            ),
          ),
          const SizedBox(height: 20),

          Expanded(
            child: _isLoading && _allChips.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                ? Center(child: Text(_error!))
                : SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (grouped.isEmpty)
                          const Padding(
                            padding: EdgeInsets.all(20.0),
                            child: Center(child: Text("No interests found")),
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
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Wrap(
                                spacing: 12,
                                runSpacing: 12,
                                children: entry.value.map((chip) {
                                  final isSelected = _selectedChipIds.contains(
                                    chip.id,
                                  );
                                  return SelectionChip(
                                    label: chip.label,
                                    isSelected: isSelected,
                                    onTap: () => _toggleChip(chip.id),
                                    // No icon mapping for general interests available yet
                                    icon: null,
                                  );
                                }).toList(),
                              ),
                              const SizedBox(height: 16),
                            ],
                          );
                        }),
                        const SizedBox(height: 80), // Fab padding
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
