import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:blindly_dating_app/features/onboarding/presentation/providers/onboarding_provider.dart';
import '../../../../onboarding/data/repositories/onboarding_repository.dart';
import '../../../../onboarding/domain/models/prompt_category_model.dart';
import '../../../../onboarding/domain/models/prompt_template_model.dart';
import '../../../../onboarding/domain/models/profile_prompt_model.dart';
import '../../../../auth/providers/auth_providers.dart';
import '../../../../../core/utils/custom_popups.dart';
import 'package:blindly_dating_app/features/onboarding/presentation/screens/steps/base_onboarding_step_screen.dart';
import '../../../../../core/widgets/app_loader.dart';
import '../../../../../core/providers/connection_mode_provider.dart';

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
      final currentMode = ref.read(connectionModeProvider).toLowerCase();

      final results = await Future.wait([
        repo.getPromptCategories(),
        repo.getPromptTemplates(),
        repo.getUserProfilePrompts(userId, mode: currentMode),
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

  // --- Logic ---

  void _onCategorySelected(int index) {
    setState(() {
      _selectedCategoryIndex = index;
      _expandedTemplateId = null; // Collapse any open input
      _answerController.clear();
    });
  }

  void _onTemplateTap(PromptTemplate template) {
    if (_isTemplateSelected(template.id)) return; // Already selected

    setState(() {
      if (_expandedTemplateId == template.id) {
        _expandedTemplateId = null;
      } else {
        // Can only expand if < 3 selected
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

  Future<void> _onRemovePrompt(String templateId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Are you sure?'),
        content: const Text('Want to remove this prompt?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Yes'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() {
        _selectedPrompts.removeWhere((p) => p.promptTemplateId == templateId);
      });
    }
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

      final currentMode = ref.read(connectionModeProvider).toLowerCase();

      await ref
          .read(onboardingRepositoryProvider)
          .saveProfilePrompts(userId, promptsToSave, mode: currentMode);

      if (mounted) {
        ref.read(onboardingProvider.notifier).completeStep('profile_prompts');
      }
    } catch (e) {
      if (mounted) {
        showErrorPopup(context, 'Error saving prompts: $e');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _handleSkip() {
    ref.read(onboardingProvider.notifier).skipStep('profile_prompts');
  }

  // --- Rendering ---

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final primaryColor = colorScheme.primary;

    return BaseOnboardingStepScreen(
      title: 'Choose Your Prompt',
      showBackButton: false, // Custom footer used
      showNextButton: false, // Custom footer used
      showSkipButton: false, // Custom footer used
      child: Column(
        children: [
          // Subtitle
          Text(
            'Select up to 3 prompt to showing up your personality.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.6),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 20),

          // Categories
          if (_categories.isNotEmpty)
            Container(
              height: 40,
              margin: const EdgeInsets.only(bottom: 12),
              child: ListView.separated(
                padding: EdgeInsets.zero,
                scrollDirection: Axis.horizontal,
                itemCount: _categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  final isSelected = index == _selectedCategoryIndex;
                  return GestureDetector(
                    onTap: () => _onCategorySelected(index),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected ? primaryColor : colorScheme.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? Colors.transparent
                              : colorScheme.outline.withOpacity(0.2),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        category.displayName,
                        style: TextStyle(
                          color: isSelected
                              ? colorScheme.onPrimary
                              : colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
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
            padding: const EdgeInsets.only(top: 16, bottom: 24),
            child: Column(
              children: [
                // Confirm / Continue Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _selectedPrompts.length == 3
                        ? _handleNext
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? AppLoader(
                            color: colorScheme.onPrimary,
                            size: 24,
                            strokeWidth: 2.5,
                          )
                        : Text(
                            'Continue',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 8),
                if (_selectedPrompts.length < 3)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      'Please select ${3 - _selectedPrompts.length} prompt to continue',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.5),
                      ),
                    ),
                  ),

                // Back / Skip Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton.icon(
                      onPressed: () => ref
                          .read(onboardingProvider.notifier)
                          .goToPreviousStep(),
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
                    ),
                    Directionality(
                      textDirection: TextDirection.rtl,
                      child: TextButton.icon(
                        onPressed: _handleSkip,
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

  Widget _buildTemplateList(ThemeData theme) {
    if (_isLoading) return const AppLoader();
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
      padding: const EdgeInsets.symmetric(vertical: 12),
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          // Subtle shadow/border
          border: Border.all(color: theme.colorScheme.outline.withOpacity(0.1)),
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
            const SizedBox(width: 8),
            Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: theme.colorScheme.onSurface.withOpacity(0.4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandedCard(PromptTemplate template, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        // Active border or shadow
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GestureDetector(
            onTap: () => _onTemplateTap(template),
            behavior: HitTestBehavior.opaque,
            child: Row(
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
                Icon(
                  Icons.keyboard_arrow_up, // Change to Up arrow when expanded
                  size: 20,
                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _answerController,
            maxLines: 4,
            maxLength: 300,
            decoration: InputDecoration(
              hintText: 'Type your answer...',
              hintStyle: TextStyle(
                color: theme.colorScheme.onSurface.withOpacity(0.4),
                fontSize: 14,
              ),
              filled: true,
              fillColor: theme.colorScheme.surfaceContainerHighest.withOpacity(
                0.3,
              ), // Very light grey
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(12),
            ),
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 12),
          Center(
            child: SizedBox(
              height: 36,
              child: ElevatedButton(
                onPressed: () => _onAddPrompt(template),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary, // Dark olive
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  elevation: 0,
                ),
                child: Text(
                  'Add Prompt',
                  style: TextStyle(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedCard(PromptTemplate template, ThemeData theme) {
    final prompt = _getSelectedPrompt(template.id);
    // Gold color
    final goldColor = theme.colorScheme.secondary;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: goldColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: goldColor.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 24.0),
                child: Text(
                  template.promptText,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    color: theme.colorScheme.onSecondary,
                  ),
                ),
              ),
              if (prompt != null) ...[
                const SizedBox(height: 8),
                Text(
                  prompt.userResponse,
                  style: TextStyle(
                    fontSize: 14,
                    color: theme.colorScheme.onSecondary.withOpacity(0.9),
                    height: 1.3,
                  ),
                ),
              ],
            ],
          ),
          Positioned(
            right: 0,
            top: 0,
            child: GestureDetector(
              onTap: () => _onRemovePrompt(template.id),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.8), // Dark circle
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  size: 12, // Small X
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
