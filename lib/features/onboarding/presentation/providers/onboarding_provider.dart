import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:blindly_dating_app/features/onboarding/data/models/onboarding_step_model.dart';
import 'package:blindly_dating_app/features/onboarding/data/repositories/onboarding_repository.dart';
import 'package:blindly_dating_app/features/auth/providers/auth_providers.dart';
import 'package:blindly_dating_app/features/profile/provider/profile_provider.dart';
import 'package:blindly_dating_app/core/utils/app_logger.dart';

// State for the onboarding flow
class OnboardingState {
  final bool isLoading;
  final OnboardingStep? currentStepConfig;
  final String? errorMessage;
  final String? currentStepKey;
  // We can cache the full progress map if needed for UI, but for now strict derivation is fine.

  OnboardingState({
    this.isLoading = true,
    this.currentStepConfig,
    this.errorMessage,
    this.currentStepKey,
  });

  OnboardingState copyWith({
    bool? isLoading,
    OnboardingStep? currentStepConfig,
    String? errorMessage,
    String? currentStepKey,
  }) {
    return OnboardingState(
      isLoading: isLoading ?? this.isLoading,
      currentStepConfig: currentStepConfig ?? this.currentStepConfig,
      errorMessage: errorMessage,
      currentStepKey: currentStepKey ?? this.currentStepKey,
    );
  }
}

final onboardingProvider =
    StateNotifierProvider<OnboardingNotifier, OnboardingState>((ref) {
      return OnboardingNotifier(ref);
    });

class OnboardingNotifier extends StateNotifier<OnboardingState> {
  final Ref _ref;

  OnboardingNotifier(this._ref) : super(OnboardingState());

  OnboardingRepository get _repo => _ref.read(onboardingRepositoryProvider);

  /// Called when the shell initializes.
  /// Fetches all steps + user progress map to determine WHERE the user is.
  Future<void> init() async {
    state = state.copyWith(isLoading: true);
    final user = _ref.read(authRepositoryProvider).currentUser;
    if (user == null) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: "User not logged in",
      );
      return;
    }

    try {
      final profile = await _repo.getProfileRaw(user.id);
      if (profile == null) {
        AppLogger.info('Profile missing in OnboardingShell. Auto-creating...');
        try {
          // Auto-heal: Create profile if missing
          await _ref.read(authRepositoryProvider).createProfile(user.id);
          // Retry init after creation
          return init();
        } catch (e) {
          AppLogger.error('Failed to auto-create profile', e);
          state = state.copyWith(
            isLoading: false,
            errorMessage: "Profile not found and creation failed",
          );
          return;
        }
      }

      // Where the user actually is, derived from their progress rather than
      // trusted from the onboarding_status flag -- a flag can say 'complete'
      // while a step is still unanswered.
      final nextStep = nextIncompleteStep(
        await _repo.getAllSteps(),
        parseStepProgress(profile['steps_progress']),
      );

      if (nextStep == null) {
        state = state.copyWith(isLoading: false, currentStepKey: 'complete');
      } else {
        AppLogger.info('Onboarding step: ${nextStep.stepKey}');
        state = state.copyWith(
          isLoading: false,
          currentStepConfig: nextStep,
          currentStepKey: nextStep.stepKey,
        );
      }
    } catch (e) {
      AppLogger.info('Onboarding Init Error: $e');
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> jumpToStep(String stepKey) async {
    state = state.copyWith(isLoading: true);
    try {
      final step = await _repo.getStepConfig(stepKey);
      if (step == null) {
        // Unknown step. Stay where we are rather than moving the key while the
        // shell still holds the old config -- that renders the wrong screen.
        AppLogger.error('No config for step $stepKey; staying put');
        state = state.copyWith(isLoading: false);
        return;
      }
      state = state.copyWith(
        isLoading: false,
        currentStepConfig: step,
        currentStepKey: stepKey,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> completeStep(String stepKeyToComplete) async {
    await _updateStepAndAdvance(stepKeyToComplete, 'completed');
  }

  Future<void> skipStep(String stepKeyToSkip) async {
    await _updateStepAndAdvance(stepKeyToSkip, 'skipped');
  }

  // Helper to update status and re-run init to find next step
  Future<void> _updateStepAndAdvance(String stepKey, String status) async {
    state = state.copyWith(isLoading: true);
    final user = _ref.read(authRepositoryProvider).currentUser;
    if (user == null) return;

    try {
      // 1. Update the JSON status map
      await _repo.updateStepStatus(user.id, stepKey, status);

      // 2. Re-evaluate "Where am I?" by running init logic again
      // This is robust: it reads the new state and finds the next incomplete step.
      await init();

      // 3. Trigger trust calculation to update score based on latest step data
      // Use the Auth User ID (user.id) as requested
      _ref
          .read(currentUserProfileProvider.notifier)
          .triggerTrustCalculation(user.id);
    } catch (e) {
      AppLogger.info('Error advancing step: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to save progress',
      );
    }
  }

  Future<void> completeOnboarding({String? skippedStepKey}) async {
    final user = _ref.read(authRepositoryProvider).currentUser;
    if (user == null) return;

    // If a final step is skipped, mark it in the JSON map
    if (skippedStepKey != null) {
      await _repo.updateStepStatus(user.id, skippedStepKey, 'skipped');
    }

    // Mark high-level status as complete
    await _repo.completeOnboarding(user.id);

    // Trigger trust calculation using the Auth User ID
    _ref
        .read(currentUserProfileProvider.notifier)
        .triggerTrustCalculation(user.id);

    state = state.copyWith(currentStepKey: 'complete');
  }

  /// Steps back one position. Returns false when there is nothing behind the
  /// current step, which is how the shell knows to let a system back press
  /// leave the app instead of swallowing it.
  Future<bool> goToPreviousStep() async {
    try {
      final allSteps = await _repo.getAllSteps();
      final index = allSteps.indexWhere(
        (s) => s.stepKey == state.currentStepKey,
      );
      if (index <= 0) return false;
      await jumpToStep(allSteps[index - 1].stepKey);
      return true;
    } catch (e) {
      AppLogger.error('Failed to go back', e);
      return false;
    }
  }
}
