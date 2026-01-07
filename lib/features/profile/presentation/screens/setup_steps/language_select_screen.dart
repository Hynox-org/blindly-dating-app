import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../onboarding/presentation/providers/onboarding_provider.dart';
import '../../../../auth/providers/auth_providers.dart';
import '../../../../onboarding/data/repositories/onboarding_repository.dart';
import '../../../../onboarding/presentation/screens/steps/base_onboarding_step_screen.dart';
import '../../../../../core/utils/custom_popups.dart';

class LanguageSelectScreen extends ConsumerStatefulWidget {
  const LanguageSelectScreen({super.key});

  @override
  ConsumerState<LanguageSelectScreen> createState() =>
      _LanguageSelectScreenState();
}

class _LanguageSelectScreenState extends ConsumerState<LanguageSelectScreen> {
  // Using a Set to store multiple selected language codes
  final Set<String> _selectedLanguageCodes = {'en'}; // Default English selected
  bool _isSaving = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<Map<String, String>> _allLanguages = [
    {'code': 'en', 'name': 'English', 'native': 'English'},
    {'code': 'hi', 'name': 'Hindi', 'native': 'हिन्दी'},
    {'code': 'ta', 'name': 'Tamil', 'native': 'தமிழ்'},
    {'code': 'te', 'name': 'Telugu', 'native': 'తెలుగు'},
    {'code': 'kn', 'name': 'Kannada', 'native': 'ಕನ್ನಡ'},
    {'code': 'ml', 'name': 'Malayalam', 'native': 'മലയാളം'},
    {'code': 'mr', 'name': 'Marathi', 'native': 'मराठी'},
    {'code': 'bn', 'name': 'Bengali', 'native': 'বাংলা'},
    {'code': 'gu', 'name': 'Gujarati', 'native': 'ગુજરાતી'},
    {'code': 'pa', 'name': 'Punjabi', 'native': 'ਪੰਜਾਬੀ'},
    {'code': 'or', 'name': 'Odia', 'native': 'ଓଡ଼ିଆ'},
    {'code': 'es', 'name': 'Spanish', 'native': 'Español'},
    {'code': 'fr', 'name': 'French', 'native': 'Français'},
    {'code': 'de', 'name': 'German', 'native': 'Deutsch'},
    {'code': 'it', 'name': 'Italian', 'native': 'Italiano'},
    {'code': 'pt', 'name': 'Portuguese', 'native': 'Português'},
    {'code': 'ru', 'name': 'Russian', 'native': 'Русский'},
    {'code': 'ja', 'name': 'Japanese', 'native': '日本語'},
    {'code': 'ko', 'name': 'Korean', 'native': '한국어'},
  ];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });

    // Fetch existing data
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchExistingData());
  }

  Future<void> _fetchExistingData() async {
    final user = ref.read(authRepositoryProvider).currentUser;
    if (user != null) {
      final profile = await ref
          .read(onboardingRepositoryProvider)
          .getProfileRaw(user.id);
      if (profile != null && profile['languages_known'] != null) {
        final List<dynamic> loaded = profile['languages_known'];
        if (loaded.isNotEmpty) {
          setState(() {
            _selectedLanguageCodes.clear();
            _selectedLanguageCodes.addAll(loaded.cast<String>());
          });
        }
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _handleNext() async {
    if (_selectedLanguageCodes.isEmpty) return;

    setState(() => _isSaving = true);

    try {
      final user = ref.read(authRepositoryProvider).currentUser;
      if (user != null) {
        // Save languages known to profile
        await ref.read(onboardingRepositoryProvider).updateProfileData(
          user.id,
          {'languages_known': _selectedLanguageCodes.toList()},
        );
      }

      await ref
          .read(onboardingProvider.notifier)
          .completeStep('language_select');
    } catch (e) {
      if (mounted) {
        showErrorPopup(context, 'Failed to save languages: $e');
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Filter languages based on search query
    final filteredLanguages = _allLanguages.where((lang) {
      final name = lang['name']!.toLowerCase();
      final native = lang['native']!.toLowerCase();
      return name.contains(_searchQuery) || native.contains(_searchQuery);
    }).toList();

    // Grouping logic:
    // If searching, show flat list.
    // If not searching, show Suggested (English) + All.
    final bool isSearching = _searchQuery.isNotEmpty;

    return BaseOnboardingStepScreen(
      title: 'Languages I know',
      showBackButton: true, // As seen in UI reference
      nextLabel:
          'Save changes', // Matches UI reference button text style roughly
      isNextEnabled: _selectedLanguageCodes.isNotEmpty && !_isSaving,
      isLoading: _isSaving,
      onNext: _handleNext,
      child: Column(
        children: [
          // Search Bar
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search languages',
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              filled: true,
              fillColor: Colors.grey.shade100, // Light grey background
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
            ),
          ),
          const SizedBox(height: 20),

          // Lists
          Expanded(
            child: ListView(
              children: [
                if (!isSearching) ...[
                  Text(
                    'Suggested',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.87),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // English as suggested
                  _buildLanguageCard(
                    _allLanguages.firstWhere((l) => l['code'] == 'en'),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'All languages',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.87),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                // List of languages
                ...filteredLanguages.map((lang) {
                  // If suggested is shown (not searching), hide English from 'All'
                  if (!isSearching && lang['code'] == 'en') {
                    return const SizedBox.shrink();
                  }

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildLanguageCard(lang),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageCard(Map<String, String> lang) {
    final code = lang['code']!;
    final isSelected = _selectedLanguageCodes.contains(code);
    // Color used in UI reference for selection border seems to be a golden/brownish color.
    // I'll use a generic primary color or a specific amber/orange if I can guess.
    // The "Save changes" button is distinct dark green/olive.
    // Let's rely on Theme primary color but maybe override for this specific UI if requested.
    // The user didn't specify colors, just "like in the image".
    // I will use the App primary color for selection for consistency,
    // unless the image suggests the "Save changes" button color is the theme.

    return InkWell(
      onTap: () {
        setState(() {
          if (isSelected) {
            // Prevent deselecting if it's the only one? Or allow empty?
            // Usually "Languages Known" requires at least one.
            // Let's allow deselect, validation on Next button checks isEmpty.
            _selectedLanguageCodes.remove(code);
          } else {
            _selectedLanguageCodes.add(code);
          }
        });
      },
      borderRadius: BorderRadius.circular(25), // Rounded pill shape in UI
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(25),
          border: isSelected
              ? Border.all(
                  color: Theme.of(context).colorScheme.secondary,
                  width: 2,
                ) // Approximate Gold/Beige color from image
              : Border.all(color: Colors.transparent),
          boxShadow: [
            if (!isSelected)
              BoxShadow(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lang['native']!, // Native name prominent
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.87),
                    ),
                  ),
                  Text(
                    lang['name']!, // English name subtitle
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                FontAwesomeIcons.solidCircleCheck,
                color: Theme.of(context).colorScheme.secondary, // Match border
                size: 20,
              )
            else
              // Use a simple circle placeholder or nothing?
              // UI shows check mark on selected. Unselected just blank white space or icon?
              // Image doesn't clearly show unselected icon state, usually empty radio or nothing.
              // I'll leave it empty.
              const SizedBox(width: 24),
          ],
        ),
      ),
    );
  }
}
