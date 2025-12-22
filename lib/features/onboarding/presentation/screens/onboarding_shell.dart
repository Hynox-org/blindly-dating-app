import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/onboarding_provider.dart';

// Import all step screens
import 'steps/terms_screen.dart';
import 'steps/permissions_screen.dart';
import 'steps/language_select_screen.dart';
import 'steps/name_entry_screen.dart';
import 'steps/birth_date_screen.dart';
import 'steps/gender_select_screen.dart';
import 'steps/location_set_screen.dart';
import 'steps/photo_upload_screen.dart';
import 'steps/photo_reorder_screen.dart';
import 'steps/selfie_instructions_screen.dart';
import 'steps/selfie_capture_screen.dart';
import 'steps/selfie_processing_screen.dart';
import 'steps/gov_id_screen.dart';
import 'steps/bio_entry_screen.dart';
import 'steps/interests_select_screen.dart';
import 'steps/lifestyle_prefs_screen.dart';
import 'steps/voice_intro_screen.dart';
import 'steps/profile_prompts_screen.dart';

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

    if (stepConfig == null) {
      return const Scaffold(
        body: Center(child: Text('Onboarding setup incomplete.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(stepConfig.stepName),
        leading: stepConfig.isSkippable
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  if (Navigator.canPop(context)) Navigator.pop(context);
                },
              )
            : null,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4.0),
          child: LinearProgressIndicator(
            value: (stepConfig.stepPosition) / 20.0, // approx total steps
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).primaryColor,
            ),
          ),
        ),
      ),
      body: getScreenForStep(stepConfig.stepKey, ref),
    );
  }

  Widget getScreenForStep(String stepKey, WidgetRef ref) {
    switch (stepKey) {
      case 'terms_accept':
        return const TermsScreen();
      case 'permissions':
        return const PermissionsScreen();
      case 'language_select':
        return const LanguageSelectScreen();
      case 'name_entry':
        return const NameEntryScreen();
      case 'birth_date':
        return const BirthDateScreen();
      case 'gender_select':
        return const GenderSelectScreen();
      case 'location_set':
        return const LocationSetScreen();
      case 'photo_upload':
        return const PhotoUploadScreen();
      case 'photo_reorder':
        return const PhotoReorderScreen();
      case 'selfie_instructions':
        return const SelfieInstructionsScreen();
      case 'selfie_capture':
        return const SelfieCaptureScreen();
      case 'selfie_processing':
        return const SelfieProcessingScreen();
      case 'gov_id_optional':
        return const GovIdScreen();
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
      default:
        return Center(child: Text("Screen for $stepKey not implemented"));
    }
  }
}
