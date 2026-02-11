import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/onboarding_provider.dart';

class BaseOnboardingStepScreen extends ConsumerWidget {
  final String title;
  final Widget child;
  final VoidCallback? onNext;
  final VoidCallback? onSkip;
  final VoidCallback? onBack;
  final String nextLabel;
  final String skipLabel;
  final bool showNextButton;
  final bool showSkipButton;
  final bool showBackButton;
  final bool isNextEnabled;
  final bool isLoading;
  final bool isEditMode;
  final Widget? fab;
  final Widget? headerAction;
  final Widget? footer;

  const BaseOnboardingStepScreen({
    super.key,
    required this.title,
    required this.child,
    this.onNext,
    this.onSkip,
    this.onBack,
    this.nextLabel = 'Continue',
    this.skipLabel = 'Skip',
    this.showNextButton = true,
    this.showSkipButton = false,
    this.showBackButton = false,
    this.isNextEnabled = true,
    this.isLoading = false,
    this.isEditMode = false,
    this.fab,
    this.headerAction,
    this.footer,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onboardingState = ref.watch(onboardingProvider);
    final currentConfig = onboardingState.currentStepConfig;
    final theme = Theme.of(context);

    // Determine validity of skipping
    // If we have config, use isMandatory. If not, fallback to passed param or default true (mandatory).
    final isMandatory = currentConfig?.isMandatory ?? !showSkipButton;
    final canSkip = !isMandatory && onSkip != null;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // 1. Custom Header Area (Replaces AppBar space)
            Container(
              height: kToolbarHeight,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              alignment: Alignment.centerRight,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (showBackButton)
                    IconButton(
                      onPressed: onBack ?? () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back),
                    ),
                  const Spacer(),
                  // Custom Header Action (if any)
                  ?headerAction,
                  if (canSkip && !isEditMode)
                    TextButton(
                      onPressed: onSkip,
                      child: Text(
                        skipLabel,
                        style: TextStyle(color: theme.colorScheme.onSurface),
                      ),
                    ),
                ],
              ),
            ),

            // 2. Main Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Title in Body
                    Padding(
                      padding: const EdgeInsets.only(bottom: 24.0, top: 8.0),
                      child: Text(
                        title,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ),

                    // Child Content
                    Expanded(child: child),
                  ],
                ),
              ),
            ),

            // 3. Bottom Actions
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Footer Widget (Fixed Content)
                  if (footer != null) ...[footer!, const SizedBox(height: 16)],

                  // Continue Button
                  if (showNextButton)
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: (isNextEnabled && !isLoading)
                            ? onNext
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.primaryColor,
                          foregroundColor: theme.colorScheme.onPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 0,
                        ),
                        child: isLoading
                            ? SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: theme.colorScheme.onPrimary,
                                ),
                              )
                            : Text(
                                isEditMode ? 'Update' : nextLabel,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: fab,
    );
  }
}
