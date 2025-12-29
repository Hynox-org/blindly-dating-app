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
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      floatingActionButton: fab,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header with Title and optional Back Button
              Row(
                children: [
                  if (showBackButton)
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_ios),
                        onPressed: () {
                          if (onBack != null) {
                            onBack!();
                          } else {
                            ref
                                .read(onboardingProvider.notifier)
                                .goToPreviousStep();
                          }
                        },
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ),
                  Expanded(
                    child: Text(
                      title,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                    ),
                  ),
                  if (headerAction != null) headerAction!,
                ],
              ),
              const SizedBox(height: 24),

              // Main Content
              Expanded(child: child),

              const SizedBox(height: 16),

              // Bottom Buttons
              if (showSkipButton && onSkip != null) ...[
                TextButton(
                  onPressed: onSkip,
                  child: Text(
                    skipLabel,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],

              if (showNextButton && onNext != null)
                ElevatedButton(
                  onPressed: (isNextEnabled && !isLoading) ? onNext : null,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(nextLabel),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
