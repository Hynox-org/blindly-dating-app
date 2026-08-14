import 'package:flutter/material.dart';
import 'package:blindly_dating_app/l10n/app_localizations.dart';
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
import 'package:blindly_dating_app/features/profile/provider/profile_provider.dart';

/// Onboarding asks for exactly three prompts. Editing later is looser -- the
/// user may keep fewer, but not none, or the section would render empty.
const int requiredPrompts = 3;

bool promptsAreValid(int count, {required bool isEditMode}) =>
    isEditMode ? count > 0 : count == requiredPrompts;

class ProfilePromptsScreen extends ConsumerStatefulWidget {
  final bool isEditMode;
  final String? initialTemplateId;

  const ProfilePromptsScreen({
    super.key,
    this.isEditMode = false,
    this.initialTemplateId,
  });

  @override
  ConsumerState<ProfilePromptsScreen> createState() =>
      _ProfilePromptsScreenState();
}

class _ProfilePromptsScreenState extends ConsumerState<ProfilePromptsScreen> {
  AppLocalizations get l10n => AppLocalizations.of(context);

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
      if (userId == null) throw Exception(l10n.userNotLoggedIn);

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

          // Handle initial template expansion for editing
          if (widget.initialTemplateId != null) {
            final existingPrompt = userPrompts.firstWhere(
              (p) => p.promptTemplateId == widget.initialTemplateId,
              orElse: () => ProfilePrompt(
                profileId: '',
                promptTemplateId: '',
                userResponse: '',
                promptDisplayOrder: 0,
              ), // Dummy
            );

            if (existingPrompt.promptTemplateId.isNotEmpty) {
              _expandedTemplateId = widget.initialTemplateId;
              _answerController.text = existingPrompt.userResponse;

              // Also switch to the category containing this template
              final template = _templates.firstWhere(
                (t) => t.id == widget.initialTemplateId,
                orElse: () => _templates.first,
              );
              final catIndex = _categories.indexWhere(
                (c) => c.id == template.categoryId,
              );
              if (catIndex != -1) {
                _selectedCategoryIndex = catIndex;
              }
            }
          }

          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = l10n.failedToLoadPrompts('$e');
        });
      }
    }
  }

  // --- Logic ---

  void _onCategorySelected(int index) {
    setState(() {
      _selectedCategoryIndex = index;
      _expandedTemplateId = null; // Collapse any open input
      _answerController.clear();
    });
  }

  void _onTemplateTap(PromptTemplate template) {
    // Logic update: Allow tapping a selected template to edit it (expand it)
    // if (_isTemplateSelected(template.id)) return; // REMOVED to allow re-editing

    setState(() {
      if (_expandedTemplateId == template.id) {
        _expandedTemplateId = null;
      } else {
        // Can only expand if < 3 selected OR if we are editing the one already selected
        final isAlreadySelected = _isTemplateSelected(template.id);
        if (_selectedPrompts.length >= requiredPrompts && !isAlreadySelected) {
          showErrorPopup(context, l10n.maxThreePrompts);
          return;
        }

        _expandedTemplateId = template.id;

        // Pre-fill if editing existing
        if (isAlreadySelected) {
          final prompt = _getSelectedPrompt(template.id);
          _answerController.text = prompt?.userResponse ?? '';
        } else {
          _answerController.clear();
        }
      }
    });
  }

  void _onAddPrompt(PromptTemplate template) {
    final text = _answerController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      // Check if updating existing
      final existingIndex = _selectedPrompts.indexWhere(
        (p) => p.promptTemplateId == template.id,
      );

      if (existingIndex != -1) {
        // Update existing
        final old = _selectedPrompts[existingIndex];
        _selectedPrompts[existingIndex] = old.copyWith(userResponse: text);
      } else {
        // Add new
        _selectedPrompts.add(
          ProfilePrompt(
            profileId: '',
            promptTemplateId: template.id,
            userResponse: text,
            promptDisplayOrder: _selectedPrompts.length + 1,
            promptQuestion: template.promptText,
          ),
        );
      }

      _expandedTemplateId = null;
      _answerController.clear();
    });
  }

  Future<void> _onRemovePrompt(String templateId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.areYouSure),
        content: Text(l10n.removeThisPrompt),
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
            child: Text(l10n.yes),
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
    if (!widget.isEditMode && _selectedPrompts.length < 3) {
      showErrorPopup(context, l10n.selectThreePrompts);
      return;
    }
    if (widget.isEditMode && _selectedPrompts.isEmpty) {
      showErrorPopup(context, l10n.selectOnePrompt);
      return;
    }

    setState(() => _isLoading = true);
    try {
      final user = ref.read(authRepositoryProvider).currentUser;
      if (user == null) throw Exception(l10n.userNotLoggedIn);
      final userId = user.id;

      // Re-assign display orders
      final promptsToSave = _selectedPrompts.asMap().entries.map((entry) {
        return entry.value.copyWith(promptDisplayOrder: entry.key + 1);
      }).toList();

      final currentMode = ref.read(connectionModeProvider).toLowerCase();

      await ref
          .read(onboardingRepositoryProvider)
          .saveProfilePrompts(userId, promptsToSave, mode: currentMode);

      if (widget.isEditMode) {
        if (mounted) {
          final currentProfile = ref.read(currentUserProfileProvider).value;
          if (currentProfile != null) {
            final updatedProfile = currentProfile.copyWith(
              prompts: promptsToSave,
            );
            ref
                .read(currentUserProfileProvider.notifier)
                .updateProfile(updatedProfile);

            // Trigger trust calculation
            await ref
                .read(currentUserProfileProvider.notifier)
                .triggerTrustCalculation();
          }
          Navigator.pop(context);
        }
      } else {
        if (mounted) {
          ref.read(onboardingProvider.notifier).completeStep('profile_prompts');
        }
      }
    } catch (e) {
      if (mounted) {
        showErrorPopup(context, l10n.errorSavingPrompts('$e'));
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
      title: l10n.chooseYourPrompt,
      showBackButton: widget.isEditMode, // Allow back if edit mode
      onBack: widget.isEditMode ? () => Navigator.pop(context) : null,
      showNextButton: false, // Custom footer used
      showSkipButton: false, // Custom footer used
      isEditMode: widget.isEditMode,
      child: Column(
        children: [
          // Subtitle
          Text(
            l10n.selectUpTo3Prompts,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.6),
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
                              : colorScheme.outline.withValues(alpha: 0.2),
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
                    onPressed:
                        promptsAreValid(
                          _selectedPrompts.length,
                          isEditMode: widget.isEditMode,
                        )
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
                            widget.isEditMode ? 'Update' : 'Continue',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 8),
                if (_selectedPrompts.length < 3 && !widget.isEditMode)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      l10n.selectNMorePrompts('${3 - _selectedPrompts.length}'),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                  ),

                // Back / Skip Row - only if NOT edit mode
                if (!widget.isEditMode)
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
      return Center(
        child: Text(l10n.noPromptsForCategory),
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
        if (isExpanded) {
          return _buildExpandedCard(template, theme);
        } else if (isSelected) {
          return _buildSelectedCard(template, theme);
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
          color: const Color(0xFFF5F5F5), // Light Grey
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                template.promptText,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: Colors.black.withValues(alpha: 0.5),
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
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(20),
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
                      color: Colors.black,
                    ),
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_up,
                  size: 20,
                  color: Colors.black.withValues(alpha: 0.5),
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
              hintText: l10n.typeYourAnswer,
              hintStyle: TextStyle(
                color: Colors.black.withValues(alpha: 0.4),
                fontSize: 14,
              ),
              filled: true,
              fillColor: Colors.white, // White input area
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(12),
            ),
            style: const TextStyle(fontSize: 14, color: Colors.black),
          ),
          const SizedBox(height: 12),
          Center(
            child: SizedBox(
              height: 40,
              child: ElevatedButton(
                onPressed: () => _onAddPrompt(template),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A503D), // Dark olive
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  elevation: 0,
                ),
                child: Text(
                  l10n.addPrompt,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
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

    return GestureDetector(
      onTap: () => _onTemplateTap(template),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(20),
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
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.black,
                    ),
                  ),
                ),
                if (prompt != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    '"${prompt.userResponse}"',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
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
                    color: Colors.black.withValues(alpha: 0.1), // Light grey circle
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, size: 16, color: Colors.black),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
