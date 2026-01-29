import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../onboarding/presentation/providers/onboarding_provider.dart';
import '../../../../auth/providers/auth_providers.dart';
import '../../../../onboarding/data/repositories/onboarding_repository.dart';
import '../../../../onboarding/presentation/screens/steps/base_onboarding_step_screen.dart';
import '../../../../../core/utils/custom_popups.dart';
import '../../../../../core/widgets/app_loader.dart';

class BioEntryScreen extends ConsumerStatefulWidget {
  const BioEntryScreen({super.key});

  @override
  ConsumerState<BioEntryScreen> createState() => _BioEntryScreenState();
}

class _BioEntryScreenState extends ConsumerState<BioEntryScreen> {
  final _controller = TextEditingController();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {});
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchExistingData());
  }

  Future<void> _fetchExistingData() async {
    final user = ref.read(authRepositoryProvider).currentUser;
    if (user != null) {
      final profile = await ref
          .read(onboardingRepositoryProvider)
          .getProfileRaw(user.id);
      if (profile != null && profile['bio'] != null) {
        setState(() {
          _controller.text = profile['bio'];
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
      if (user != null) {
        await ref.read(onboardingRepositoryProvider).updateProfileData(
          user.id,
          {'bio': bio},
        );
      }
      if (mounted) {
        ref.read(onboardingProvider.notifier).completeStep('bio_entry');
      }
    } catch (e) {
      if (mounted) {
        showErrorPopup(context, 'Failed to save bio: $e');
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _handleSkip() {
    ref.read(onboardingProvider.notifier).skipStep('bio_entry');
  }

  void _handleBack() {
    ref.read(onboardingProvider.notifier).goToPreviousStep();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isNextEnabled = _controller.text.trim().length >= 10 && !_isSaving;

    return BaseOnboardingStepScreen(
      title: 'About You',
      showBackButton: false,
      showNextButton: false,
      showSkipButton: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Don't be shy! This is your chance to share your personality with a short bio.",
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
                      hintText: 'Text Here.....',
                      hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                      filled: true,
                      fillColor: colorScheme.surfaceContainerHighest
                          .withOpacity(0.5),
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
                  disabledBackgroundColor: colorScheme.primary.withOpacity(0.5),
                  disabledForegroundColor: colorScheme.onPrimary.withOpacity(
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
                    : const Text(
                        "Continue",
                        style: TextStyle(
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
