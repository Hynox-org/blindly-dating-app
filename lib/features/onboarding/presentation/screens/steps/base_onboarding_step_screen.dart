import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BaseOnboardingStepScreen extends ConsumerWidget {
  final String title;
  final Widget child;
  final VoidCallback? onNext;
  final VoidCallback? onSkip;
  final String nextLabel;
  final String skipLabel;
  final bool showNextButton;
  final bool showSkipButton;
  final Widget? fab;

  const BaseOnboardingStepScreen({
    super.key,
    required this.title,
    required this.child,
    this.onNext,
    this.onSkip,
    this.nextLabel = 'Continue',
    this.skipLabel = 'Skip',
    this.showNextButton = true,
    this.showSkipButton = false,
    this.fab,
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
              // Title
              Text(
                title,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
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
                  onPressed: onNext,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(nextLabel),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
