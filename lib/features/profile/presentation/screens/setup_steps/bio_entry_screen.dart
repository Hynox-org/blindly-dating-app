import 'package:flutter/material.dart';
import 'package:blindly_dating_app/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:blindly_dating_app/core/providers/connection_mode_provider.dart';
import 'package:blindly_dating_app/features/onboarding/presentation/providers/onboarding_provider.dart';
import 'package:blindly_dating_app/features/auth/providers/auth_providers.dart';
import 'package:blindly_dating_app/features/onboarding/data/repositories/onboarding_repository.dart';
import 'package:blindly_dating_app/features/onboarding/presentation/screens/steps/base_onboarding_step_screen.dart';
import 'package:blindly_dating_app/core/utils/custom_popups.dart';
import 'package:blindly_dating_app/core/widgets/app_loader.dart';
import 'package:blindly_dating_app/features/profile/provider/profile_provider.dart';

/// A bio worth showing: long enough to say something, short enough to read.
/// The 300 ceiling matches the input's maxLength and the column.
bool bioIsValid(String text) {
  final length = text.trim().length;
  return length >= 10 && length <= 300;
}

class BioEntryScreen extends ConsumerStatefulWidget {
  final bool isEditMode;
  final String? initialBio;

  const BioEntryScreen({super.key, this.isEditMode = false, this.initialBio});

  @override
  ConsumerState<BioEntryScreen> createState() => _BioEntryScreenState();
}

class _BioEntryScreenState extends ConsumerState<BioEntryScreen> {
  AppLocalizations get l10n => AppLocalizations.of(context);

  late final TextEditingController _controller;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialBio ?? '');
    _controller.addListener(() {
      setState(() {});
    });
    // Only fetch if initialBio is not provided (or we want to force refresh, but usually passing is better)
    if (widget.initialBio == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _fetchExistingData());
    }
  }

  Future<void> _fetchExistingData() async {
    final user = ref.read(authRepositoryProvider).currentUser;
    final currentMode = ref.read(connectionModeProvider).toLowerCase();

    if (user != null) {
      final bio = await ref
          .read(onboardingRepositoryProvider)
          .getUserBio(user.id, mode: currentMode);

      if (mounted) {
        setState(() {
          _controller.text = bio ?? ''; // Handle null safely
        });
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleNext() async {
    final bio = _controller.text.trim();

    if (bio.isEmpty) {
      return; // Should be handled by button state, but safety check
    }

    setState(() => _isSaving = true);

    try {
      final user = ref.read(authRepositoryProvider).currentUser;
      final currentMode = ref.read(connectionModeProvider).toLowerCase();

      if (user != null) {
        await ref
            .read(onboardingRepositoryProvider)
            .saveBio(user.id, bio, mode: currentMode);
      }

      if (widget.isEditMode) {
        if (mounted) {
          final currentProfile = ref.read(currentUserProfileProvider).value;
          if (currentProfile != null) {
            final updatedProfile = currentProfile.copyWith(bio: bio);
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
        return;
      }

      if (mounted) {
        ref.read(onboardingProvider.notifier).completeStep('bio_entry');
      }
    } catch (e) {
      if (mounted) {
        showErrorPopup(context, l10n.failedToSaveBio('$e'));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _handleSkip() {
    if (widget.isEditMode) return;
    ref.read(onboardingProvider.notifier).skipStep('bio_entry');
  }

  void _handleBack() {
    if (widget.isEditMode) {
      Navigator.pop(context);
    } else {
      ref.read(onboardingProvider.notifier).goToPreviousStep();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isNextEnabled = bioIsValid(_controller.text) && !_isSaving;

    return BaseOnboardingStepScreen(
      title: l10n.aboutYou,
      showBackButton: false,
      showNextButton: false,
      showSkipButton: false,
      isEditMode: widget.isEditMode,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.bioPrompt,
                    style: TextStyle(
                      fontSize: 14,
                      color: colorScheme.onSurface,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 32),
                  TextField(
                    controller: _controller,
                    maxLines: 8,
                    maxLength: 300,
                    style: TextStyle(color: colorScheme.onSurface),
                    decoration: InputDecoration(
                      hintText: l10n.textHereHint,
                      hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                      filled: true,
                      fillColor: colorScheme.surfaceContainerHighest
                          .withValues(alpha: 0.5),
                      contentPadding: const EdgeInsets.all(16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(
                          color: colorScheme.outlineVariant,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(color: colorScheme.primary),
                      ),
                      counterText: "",
                    ),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      '${_controller.text.length}/300',
                      style: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Actions
          Padding(
            padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isNextEnabled ? _handleNext : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  disabledBackgroundColor: colorScheme.primary.withValues(alpha: 0.5),
                  disabledForegroundColor: colorScheme.onPrimary.withValues(alpha: 
                    0.7,
                  ),
                  elevation: 0,
                ),
                child: _isSaving
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
          ),

          // Navigation Row: Back and Skip
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton.icon(
                onPressed: _handleBack,
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
              if (!widget.isEditMode)
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
    );
  }
}
