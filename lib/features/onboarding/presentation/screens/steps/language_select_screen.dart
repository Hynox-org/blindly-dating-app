import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/onboarding_provider.dart';
import 'base_onboarding_step_screen.dart';



class LanguageSelectScreen extends ConsumerStatefulWidget {
  const LanguageSelectScreen({super.key});



  @override
  ConsumerState<LanguageSelectScreen> createState() => _LanguageSelectScreenState();
}



class _LanguageSelectScreenState extends ConsumerState<LanguageSelectScreen> {
  final List<String> _selectedLanguages = [];
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';


  // Suggested languages (based on user location or preferences)
  final List<Map<String, String>> _suggestedLanguages = [
    {'name': 'English', 'native': 'English', 'code': 'en'},
    {'name': 'Espanol', 'native': 'Spanish', 'code': 'es'},
  ];


  // All available languages
  final List<Map<String, String>> _allLanguages = [
    {'name': 'Tamil', 'native': 'Tamil', 'code': 'ta'},
    {'name': 'Deutsch', 'native': 'German', 'code': 'de'},
    {'name': 'Francais', 'native': 'French', 'code': 'fr'},
    {'name': 'Portugues', 'native': 'Portuguese', 'code': 'pt'},
    {'name': 'Malayalam', 'native': 'Malayalam', 'code': 'ml'},
    {'name': 'Kannada', 'native': 'Kannada', 'code': 'kn'},
    {'name': 'Hindi', 'native': 'हिन्दी', 'code': 'hi'},
    {'name': 'Telugu', 'native': 'తెలుగు', 'code': 'te'},
    {'name': 'Marathi', 'native': 'मराठी', 'code': 'mr'},
    {'name': 'Bengali', 'native': 'বাংলা', 'code': 'bn'},
    {'name': 'Gujarati', 'native': 'ગુજરાતી', 'code': 'gu'},
    {'name': 'Punjabi', 'native': 'ਪੰਜਾਬੀ', 'code': 'pa'},
    {'name': 'Chinese', 'native': '中文', 'code': 'zh'},
    {'name': 'Japanese', 'native': '日本語', 'code': 'ja'},
    {'name': 'Korean', 'native': '한국어', 'code': 'ko'},
    {'name': 'Arabic', 'native': 'العربية', 'code': 'ar'},
    {'name': 'Russian', 'native': 'Русский', 'code': 'ru'},
    {'name': 'Italian', 'native': 'Italiano', 'code': 'it'},
    {'name': 'Turkish', 'native': 'Türkçe', 'code': 'tr'},
  ];


  List<Map<String, String>> get _filteredLanguages {
    if (_searchQuery.isEmpty) {
      return _allLanguages;
    }
    return _allLanguages.where((lang) {
      final nameLower = lang['name']!.toLowerCase();
      final nativeLower = lang['native']!.toLowerCase();
      final queryLower = _searchQuery.toLowerCase();
      return nameLower.contains(queryLower) || nativeLower.contains(queryLower);
    }).toList();
  }


  void _toggleLanguage(String languageName) {
    setState(() {
      if (_selectedLanguages.contains(languageName)) {
        _selectedLanguages.remove(languageName);
      } else {
        _selectedLanguages.add(languageName);
      }
    });
  }


  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return BaseOnboardingStepScreen(
      title: 'Languages',
      showBackButton: true,
      nextLabel: 'Save changes',
      onNext: () {
        // Validation: Check if at least one language is selected
        if (_selectedLanguages.isEmpty) {
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
                      'No Language Selected',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                content: const Text(
                  'Please select at least one language you speak.',
                  style: TextStyle(fontSize: 16),
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

        // All validations passed - save and proceed
        // TODO: Save _selectedLanguages to backend/provider
        debugPrint('Selected Languages: $_selectedLanguages');
        
        ref.read(onboardingProvider.notifier).completeStep('language_select');
      },
      child: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 0),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Search languages',
                hintStyle: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 15,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: Colors.grey[400],
                  size: 22,
                ),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Content
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Suggested Section
                  if (_searchQuery.isEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.only(left: 4, bottom: 12),
                      child: Text(
                        'Suggested',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                      ),
                    ),
                    // Suggested Languages List
                    ..._suggestedLanguages.map((lang) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _LanguageTile(
                        language: lang,
                        isSelected: _selectedLanguages.contains(lang['name']),
                        onTap: () => _toggleLanguage(lang['name']!),
                      ),
                    )),
                    const SizedBox(height: 12),
                  ],

                  // All Languages Section
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 12),
                    child: Text(
                      _searchQuery.isEmpty ? 'All languages' : 'Search Results',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                  ),
                  // All Languages List
                  ..._filteredLanguages.map((lang) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _LanguageTile(
                      language: lang,
                      isSelected: _selectedLanguages.contains(lang['name']),
                      onTap: () => _toggleLanguage(lang['name']!),
                    ),
                  )),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}


// Separate Language Tile Component - Each language as a card/button
class _LanguageTile extends StatelessWidget {
  final Map<String, String> language;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageTile({
    required this.language,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.grey[300]!,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Row(
            children: [
              // Language Name and Native Name
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      language['name']!,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      language['native']!,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              // Selection Indicator
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? const Color(0xFF4A5A3E) : Colors.white,
                  border: Border.all(
                    color: isSelected ? const Color(0xFF4A5A3E) : Colors.grey[400]!,
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? const Icon(
                        Icons.check,
                        size: 16,
                        color: Colors.white,
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
