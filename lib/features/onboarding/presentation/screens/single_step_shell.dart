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
// import 'steps/selfie_capture_screen.dart'; // Mapped via instructions now
import 'steps/selfie_processing_screen.dart';
import 'steps/gov_id_screen.dart';
import 'steps/bio_entry_screen.dart';
import 'steps/interests_select_screen.dart';
import 'steps/lifestyle_prefs_screen.dart';
import 'steps/voice_intro_screen.dart';
import 'steps/profile_prompts_screen.dart';

class SingleStepShell extends ConsumerStatefulWidget {
  final String stepKey;

  const SingleStepShell({super.key, required this.stepKey});

  @override
  ConsumerState<SingleStepShell> createState() => _SingleStepShellState();
}

class _SingleStepShellState extends ConsumerState<SingleStepShell> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(onboardingProvider.notifier).jumpToStep(widget.stepKey);
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(onboardingProvider, (previous, next) {
      // Ignore if loading, or if the key hasn't been set yet (still initializing jump)
      if (next.isLoading || next.currentStepKey == null) return;

      if (next.currentStepKey != widget.stepKey) {
        if (mounted) Navigator.pop(context);
      }
    });

    final currentConfig = ref.watch(onboardingProvider).currentStepConfig;

    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) {
        // Just let it pop naturally - state will handle it
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(currentConfig?.stepName ?? 'Complete Step'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () {
              // Simple pop - just go back
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              }
            },
          ),
        ),
        body: _getScreenForStep(widget.stepKey),
      ),
    );
  }

  Widget _getScreenForStep(String stepKey) {
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
      case 'selfie_capture':
        // Unified Flow: Start with instructions
        return const SelfieInstructionsScreen();
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
