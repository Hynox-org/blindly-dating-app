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
    this.fab,
    this.headerAction,
    this.footer,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onboardingState = ref.watch(onboardingProvider);
    final currentConfig = onboardingState.currentStepConfig;

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
                  // Custom Header Action (if any)
                  if (headerAction != null) headerAction!,
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
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface,
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
                children: [
                  // Footer Widget (Fixed Content)
                  if (footer != null) ...[footer!, const SizedBox(height: 16)],

                  // Continue Button
                  if (showNextButton && onNext != null)
                    SizedBox(
                      height: 56, // Fixed height for a more substantial look
                      child: ElevatedButton(
                        onPressed: (isNextEnabled && !isLoading)
                            ? onNext
                            : null,
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.primary,
                          foregroundColor: Theme.of(
                            context,
                          ).colorScheme.onPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              30,
                            ), // Pill shape for modern look
                          ),
                        ),
                        child: isLoading
                            ? SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onPrimary,
                                ),
                              )
                            : Text(
                                nextLabel,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),

                  const SizedBox(height: 16),

                  // Navigation Row (Back & Skip)
                  if (showBackButton || canSkip)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Row(
                        mainAxisAlignment: (showBackButton && canSkip)
                            ? MainAxisAlignment.spaceBetween
                            : MainAxisAlignment.center,
                        children: [
                          if (showBackButton)
                            TextButton.icon(
                              onPressed: () {
                                if (onBack != null) {
                                  onBack!();
                                } else {
                                  ref
                                      .read(onboardingProvider.notifier)
                                      .goToPreviousStep();
                                }
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withOpacity(0.7),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                  horizontal: 16,
                                ),
                              ),
                              icon: const Icon(Icons.arrow_back, size: 20),
                              label: const Text(
                                "Back",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),

                          if (canSkip)
                            Directionality(
                              textDirection: TextDirection.rtl,
                              child: TextButton.icon(
                                onPressed: onSkip,
                                style: TextButton.styleFrom(
                                  foregroundColor: Theme.of(
                                    context,
                                  ).colorScheme.onSurface.withOpacity(0.7),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                    horizontal: 16,
                                  ),
                                ),
                                icon: const Icon(
                                  Icons.skip_next_rounded,
                                  size: 24,
                                ),
                                label: Text(
                                  skipLabel,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),

                  // If neither, add spacing
                  if (!showBackButton && !canSkip) const SizedBox(height: 8),
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
