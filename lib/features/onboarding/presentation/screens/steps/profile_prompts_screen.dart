import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/onboarding_provider.dart';
import '../../../data/repositories/onboarding_repository.dart';
import '../../../domain/models/prompt_category_model.dart';
import '../../../domain/models/prompt_template_model.dart';
import '../../../domain/models/profile_prompt_model.dart';
import '../../../../auth/providers/auth_providers.dart';
import '../../../../../core/utils/custom_popups.dart';

class ProfilePromptsScreen extends ConsumerStatefulWidget {
  const ProfilePromptsScreen({super.key});

  @override
  ConsumerState<ProfilePromptsScreen> createState() =>
      _ProfilePromptsScreenState();
}

class _ProfilePromptsScreenState extends ConsumerState<ProfilePromptsScreen> {
  // State
  final List<ProfilePrompt> _selectedPrompts =
      []; // The actual saved user prompts
  bool _isLoading = false;
  String? _error;

  // UI State
  int _selectedCategoryIndex = 0;
  String? _expandedTemplateId; // Which template is currently being answered
  final TextEditingController _answerController = TextEditingController();

  // Cached data
  List<PromptCategory> _categories = [];
  List<PromptTemplate> _templates = [];

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
  }

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  Future<void> _fetchInitialData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final userId = ref.read(authRepositoryProvider).currentUser?.id;
      if (userId == null) throw Exception('User not logged in');

      final repo = ref.read(onboardingRepositoryProvider);

      final results = await Future.wait([
        repo.getPromptCategories(),
        repo.getPromptTemplates(),
        repo.getUserProfilePrompts(userId),
      ]);

      if (mounted) {
        setState(() {
          _categories = results[0] as List<PromptCategory>;
          _templates = results[1] as List<PromptTemplate>;
          final userPrompts = results[2] as List<ProfilePrompt>;
          _selectedPrompts.clear();
          _selectedPrompts.addAll(userPrompts);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = 'Failed to load prompts: $e';
        });
      }
    }
  }

  // --- Logic ---

  void _onCategorySelected(int index) {
    setState(() {
      _selectedCategoryIndex = index;
      _expandedTemplateId =
          null; // Collapse any open input when changing category
      _answerController.clear();
    });
  }

  void _onTemplateTap(PromptTemplate template) {
    // If already added, do nothing (or maybe allow edit? Design implies 'X' to remove)
    if (_isTemplateSelected(template.id)) return;

    // If already expanded, collapse it? Or keep open?
    // Usually tapping another one collapses the current one.
    setState(() {
      if (_expandedTemplateId == template.id) {
        _expandedTemplateId = null;
      } else {
        // Can only expand if we haven't reached the limit of 3
        if (_selectedPrompts.length >= 3) {
          showErrorPopup(context, 'You can only select up to 3 prompts.');
          return;
        }
        _expandedTemplateId = template.id;
        _answerController.clear();
      }
    });
  }

  void _onAddPrompt(PromptTemplate template) {
    final text = _answerController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _selectedPrompts.add(
        ProfilePrompt(
          profileId: '',
          promptTemplateId: template.id,
          userResponse: text,
          promptDisplayOrder: _selectedPrompts.length + 1,
          promptQuestion: template.promptText,
        ),
      );
      _expandedTemplateId = null;
      _answerController.clear();
    });
  }

  void _onRemovePrompt(String templateId) {
    setState(() {
      _selectedPrompts.removeWhere((p) => p.promptTemplateId == templateId);
    });
  }

  bool _isTemplateSelected(String templateId) {
    return _selectedPrompts.any((p) => p.promptTemplateId == templateId);
  }

  ProfilePrompt? _getSelectedPrompt(String templateId) {
    try {
      return _selectedPrompts.firstWhere(
        (p) => p.promptTemplateId == templateId,
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> _handleNext() async {
    if (_selectedPrompts.length < 3) {
      showErrorPopup(context, 'Please select 3 prompts to continue.');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final user = ref.read(authRepositoryProvider).currentUser;
      if (user == null) throw Exception('User not logged in');
      final userId = user.id;

      // Re-assign display orders
      final promptsToSave = _selectedPrompts.asMap().entries.map((entry) {
        return entry.value.copyWith(promptDisplayOrder: entry.key + 1);
      }).toList();

      await ref
          .read(onboardingRepositoryProvider)
          .saveProfilePrompts(userId, promptsToSave);

      if (mounted) {
        ref.read(onboardingProvider.notifier).completeOnboarding();
      }
    } catch (e) {
      if (mounted) {
        showErrorPopup(context, 'Error saving prompts: $e');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- Rendering ---

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: theme.iconTheme.color),
          onPressed: () =>
              ref.read(onboardingProvider.notifier).goToPreviousStep(),
        ),
        title: Text(
          'Choose Your Prompt',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Text(
                'Select up to 3 prompt to showing up your personality.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
              ),
            ),
            const SizedBox(height: 16),

            // Categories
            if (_categories.isNotEmpty)
              Container(
                height: 40,
                margin: const EdgeInsets.only(bottom: 8),
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  itemCount: _categories.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final category = _categories[index];
                    final isSelected = index == _selectedCategoryIndex;
                    return ChoiceChip(
                      label: Text(category.displayName),
                      selected: isSelected,
                      onSelected: (val) {
                        if (val) _onCategorySelected(index);
                      },
                      // Styles
                      selectedColor: theme.colorScheme.primary.withOpacity(
                        0.8,
                      ), // Use primary as active
                      backgroundColor: Colors.grey[200],
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide.none,
                      ),
                    );
                  },
                ),
              ),

            const Divider(height: 1),

            // List of Templates
            Expanded(child: _buildTemplateList(theme)),

            // Footer
            Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _selectedPrompts.length == 3
                          ? _handleNext
                          : null,
                      style: ElevatedButton.styleFrom(
                        // If you have a specific custom color in theme, use it. Otherwise rely on theme primary.
                        // Attempting to match the specific "Olive Green" from the mockup via a hardcoded fallback
                        // if theme is not set up that way, but keeping it robust.
                        backgroundColor: const Color(0xFF757C64),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        'Continue',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _selectedPrompts.length == 3
                        ? 'All prompts selected'
                        : 'Please select ${3 - _selectedPrompts.length} more prompt${(3 - _selectedPrompts.length) == 1 ? '' : 's'} to continue (${_selectedPrompts.length}/3 selected)',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTemplateList(ThemeData theme) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_error != null) return Center(child: Text(_error!));
    if (_categories.isEmpty) return const SizedBox();

    final categoryId = _categories[_selectedCategoryIndex].id;
    final templates = _templates
        .where((t) => t.categoryId == categoryId)
        .toList();

    if (templates.isEmpty) {
      return const Center(
        child: Text('No prompts available for this category.'),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: templates.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final template = templates[index];
        final isSelected = _isTemplateSelected(template.id);
        final isExpanded = _expandedTemplateId == template.id;

        // Render based on state
        if (isSelected) {
          return _buildSelectedCard(template, theme);
        } else if (isExpanded) {
          return _buildExpandedCard(template, theme);
        } else {
          return _buildNormalCard(template, theme);
        }
      },
    );
  }

  Widget _buildNormalCard(PromptTemplate template, ThemeData theme) {
    return GestureDetector(
      onTap: () => _onTemplateTap(template),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          // Basic shadow
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                template.promptText,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandedCard(PromptTemplate template, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  template.promptText,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _answerController,
            maxLines: 4,
            maxLength: 300,
            decoration: const InputDecoration(
              hintText: 'Type your answer...',
              hintStyle: TextStyle(color: Colors.grey, fontSize: 13),
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 8),
          Center(
            child: ElevatedButton(
              onPressed: () => _onAddPrompt(template),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(
                  0xFF555B46,
                ), // Dark olive form image
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 10,
                ),
              ),
              child: const Text(
                'Add Prompt',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedCard(PromptTemplate template, ThemeData theme) {
    final prompt = _getSelectedPrompt(template.id);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE8D58E), // Gold/Beige color from image
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  template.promptText,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
                if (prompt != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    prompt.userResponse,
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          GestureDetector(
            onTap: () => _onRemovePrompt(template.id),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.black87,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, size: 14, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
