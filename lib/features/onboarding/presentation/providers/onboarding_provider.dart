import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/onboarding_step_model.dart';
import '../../data/repositories/onboarding_repository.dart';
import '../../../../features/auth/providers/auth_providers.dart';
import '../../../../core/utils/app_logger.dart';

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

      // 1. Get ordered list of ALL steps
      final allSteps = await _repo.getAllSteps();

      // 2. Get user's progress map
      // Map<String, dynamic> stepsProgress = {};
      final rawProgress = profile['steps_progress'];
      final Map<String, dynamic> stepsProgress = (rawProgress != null)
          ? Map<String, dynamic>.from(rawProgress)
          : {};

      // 3. Determine current step
      // Find the first step that is NOT 'completed'.
      // (Optionally: also skip 'skipped' steps so they don't block progress)
      OnboardingStep? nextStep;

      for (final step in allSteps) {
        final status = stepsProgress[step.stepKey];
        // If status is NOT completed and NOT skipped, this is our next step.
        // Or if we want to FORCE users to revisit skipped steps before finishing?
        // Requirement: "user can access app because all mandatory fields completed... skipped steps... in home page"
        // So 'skipped' means we moved PAST it.

        if (status != 'completed' && status != 'skipped') {
          nextStep = step;
          break;
        }
      }

      // High-level check
      final status = profile['onboarding_status'] as String? ?? 'in_progress';

      if (status == 'complete' || nextStep == null) {
        // If no incomplete steps found, or explicitly marked complete
        state = state.copyWith(isLoading: false, currentStepKey: 'complete');
      } else {
        AppLogger.info(
          'Derived Step: ${nextStep.stepName} (${nextStep.stepKey})',
        );
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
    state = state.copyWith(currentStepKey: 'complete');
  }
}
