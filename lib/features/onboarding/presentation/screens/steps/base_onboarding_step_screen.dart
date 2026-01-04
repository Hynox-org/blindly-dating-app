import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/onboarding_provider.dart';
import '../../../../auth/providers/auth_providers.dart';

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
    final onboardingState = ref.watch(onboardingProvider);
    final currentConfig = onboardingState.currentStepConfig;

    // Determine validity of skipping
    // If we have config, use isMandatory. If not, fallback to passed param or default true (mandatory).
    final isMandatory = currentConfig?.isMandatory ?? !showSkipButton;
    final canSkip = !isMandatory && onSkip != null;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        centerTitle: true,
        leading: showBackButton
            ? Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios),
                  onPressed: () {
                    if (onBack != null) {
                      onBack!();
                    } else {
                      ref.read(onboardingProvider.notifier).goToPreviousStep();
                    }
                  },
                ),
              )
            : null,
        title: Text(
          title,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        actions: [
          if (headerAction != null)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: headerAction!,
            ),

          // Dynamic Skip Button
          if (canSkip && headerAction == null)
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: TextButton(
                onPressed: onSkip,
                child: Text(
                  skipLabel,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          PopupMenuButton<String>(
            icon: Icon(
              Icons.more_vert,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            onSelected: (value) async {
              if (value == 'logout') {
                await ref.read(authRepositoryProvider).signOut();
                if (context.mounted) {
                  Navigator.of(
                    context,
                  ).pushNamedAndRemoveUntil('/', (route) => false);
                }
              } else if (value == 'delete') {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Delete Account'),
                    content: const Text(
                      'Are you sure you want to delete your account? This action cannot be undone.\n\n'
                      'If account deletion is not supported, you will be signed out instead.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                );

                if (confirm == true) {
                  await ref.read(authRepositoryProvider).deleteAccount();
                  if (context.mounted) {
                    Navigator.of(
                      context,
                    ).pushNamedAndRemoveUntil('/', (route) => false);
                  }
                }
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem<String>(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(Icons.logout, color: Colors.grey),
                      SizedBox(width: 8),
                      Text('Sign Out'),
                    ],
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete_forever, color: Colors.red),
                      SizedBox(width: 8),
                      Text(
                        'Delete Account',
                        style: TextStyle(color: Colors.red),
                      ),
                    ],
                  ),
                ),
              ];
            },
          ),
        ],
      ),
      floatingActionButton: fab,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Main Content
              Expanded(child: child),

              const SizedBox(height: 16),

              // Bottom Buttons
              // Removed Skip button from here as it's moved to AppBar
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
