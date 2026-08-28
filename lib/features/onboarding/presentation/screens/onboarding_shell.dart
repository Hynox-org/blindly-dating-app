import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:blindly_dating_app/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:blindly_dating_app/features/onboarding/presentation/providers/onboarding_provider.dart';
import 'package:blindly_dating_app/core/widgets/app_loader.dart';

import 'package:blindly_dating_app/features/auth/providers/auth_providers.dart';

// Import all step screens
import 'package:blindly_dating_app/features/onboarding/presentation/screens/steps/terms_screen.dart';
import 'package:blindly_dating_app/features/onboarding/presentation/screens/steps/name_birth_entry_screen.dart';
import 'package:blindly_dating_app/features/onboarding/presentation/screens/steps/gender_select_screen.dart';
import 'package:blindly_dating_app/features/onboarding/presentation/screens/steps/photo_upload_screen.dart';
import 'package:blindly_dating_app/features/profile/presentation/screens/setup_steps/bio_entry_screen.dart';
import 'package:blindly_dating_app/features/profile/presentation/screens/setup_steps/interests_select_screen.dart';
import 'package:blindly_dating_app/features/profile/presentation/screens/setup_steps/lifestyle_prefs_screen.dart';
import 'package:blindly_dating_app/features/profile/presentation/screens/setup_steps/voice_intro_screen.dart';
import 'package:blindly_dating_app/features/profile/presentation/screens/setup_steps/profile_prompts_screen.dart';
import 'package:blindly_dating_app/features/profile/presentation/screens/setup_steps/gov_id_screen.dart';
import 'package:blindly_dating_app/features/profile/presentation/screens/setup_steps/language_select_screen.dart';

class OnboardingShell extends ConsumerStatefulWidget {
  const OnboardingShell({super.key});

  @override
  ConsumerState<OnboardingShell> createState() => _OnboardingShellState();
}

class _OnboardingShellState extends ConsumerState<OnboardingShell> {
  AppLocalizations get l10n => AppLocalizations.of(context);


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

      if (next.errorMessage != null &&
          next.errorMessage!.contains("Profile not found")) {
        // Clear auth state as profile issue is critical
        ref.read(authRepositoryProvider).signOut();
        Navigator.pushNamedAndRemoveUntil(context, '/auth', (route) => false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    _listenForNavigation();

    final state = ref.watch(onboardingProvider);
    final stepConfig = state.currentStepConfig;

    if (state.isLoading) {
      return const Scaffold(body: AppLoader());
    }

    if (state.errorMessage != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(l10n.errGeneric('${state.errorMessage}')),
              ElevatedButton(
                onPressed: () => ref.read(onboardingProvider.notifier).init(),
                child: Text(l10n.retry),
              ),
            ],
          ),
        ),
      );
    }

    if (stepConfig == null) {
      return const Scaffold(body: AppLoader());
    }

    // System back walks the flow backwards like the on-screen arrow does.
    // Popping is never right here: the shell is the only route, so letting the
    // pop through would empty the navigator. At the first step there is nothing
    // behind us, and back means leave.
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final movedBack = await ref
            .read(onboardingProvider.notifier)
            .goToPreviousStep();
        if (!movedBack) SystemNavigator.pop();
      },
      child: Scaffold(
        // First-run onboarding always renders in English — the user hasn't been
        // near the language setting yet. The same step screens opened from
        // Settings in edit mode are *not* wrapped, so those follow the app locale.
        body: Localizations.override(
          context: context,
          locale: const Locale('en'),
          child: getScreenForStep(stepConfig.stepKey, ref),
        ),
      ),
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
      case 'gov_id_optional':
        return const GovernmentIdVerificationScreen();
      case 'bio_entry':
        return const BioEntryScreen();
      case 'interests_select':
        return const InterestsSelectScreen();
      case 'lifestyle_prefs':
        return const LifestylePrefsScreen();
      case 'voice_intro':
        return const VoiceIntroScreen();
      case 'profile_prompts':
        return const ProfilePromptsScreen();
      case 'language_select':
        return const LanguageSelectScreen();
      default:
        return Center(child: Text("Screen for $stepKey not implemented"));
    }
  }
}
