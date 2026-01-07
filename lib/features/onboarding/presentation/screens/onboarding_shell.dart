import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/onboarding_provider.dart';

// Import all step screens
import 'steps/terms_screen.dart';
import 'steps/name_birth_entry_screen.dart';
import 'steps/gender_select_screen.dart';
import 'steps/photo_upload_screen.dart';

class OnboardingShell extends ConsumerStatefulWidget {
  const OnboardingShell({super.key});

  @override
  ConsumerState<OnboardingShell> createState() => _OnboardingShellState();
}

class _OnboardingShellState extends ConsumerState<OnboardingShell> {
  @override
  void initState() {
    super.initState();
    // Initialize provider to fetch current step
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(onboardingProvider.notifier).init();
    });
  }

  void _listenForNavigation() {
    ref.listen(onboardingProvider, (previous, next) {
      if (next.currentStepKey == 'complete') {
        Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    _listenForNavigation();

    final state = ref.watch(onboardingProvider);
    final stepConfig = state.currentStepConfig;

    if (state.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (state.errorMessage != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error: ${state.errorMessage}'),
              ElevatedButton(
                onPressed: () => ref.read(onboardingProvider.notifier).init(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    // if (state.currentStepKey == 'pre_onboarding') {
    //   return const Scaffold(body: PreOnboardingWelcomeScreen());
    // }

    if (stepConfig == null) {
      return const Scaffold(
        body: Center(child: Text('Onboarding setup incomplete.')),
      );
    }

    return Scaffold(
      // appBar: AppBar(
      //   title: Text(stepConfig.stepName),
      //   leading: stepConfig.isSkippable
      //       ? IconButton(
      //           icon: const Icon(Icons.arrow_back),
      //           onPressed: () {
      //             if (Navigator.canPop(context)) Navigator.pop(context);
      //           },
      //         )
      //       : null,
      //   bottom: PreferredSize(
      //     preferredSize: const Size.fromHeight(4.0),
      //     child: LinearProgressIndicator(
      //       value: (stepConfig.stepPosition) / 20.0, // approx total steps
      //       backgroundColor: Colors.grey[200],
      //       valueColor: AlwaysStoppedAnimation<Color>(
      //         Theme.of(context).primaryColor,
      //       ),
      //     ),
      //   ),
      // ),
      body: getScreenForStep(stepConfig.stepKey, ref),
    );
  }

  Widget getScreenForStep(String stepKey, WidgetRef ref) {
    switch (stepKey) {
      case 'terms_accept':
        return const TermsScreen();
      case 'name_birth_entry':
        return const NameBirthEntryScreen();
      case 'gender_select':
        return const GenderSelectScreen();
      case 'photo_upload':
        return const PhotoUploadScreen();
      // case 'pre_onboarding':
      //   return const PreOnboardingWelcomeScreen();
      default:
        return Center(child: Text("Screen for $stepKey not implemented"));
    }
  }
}
