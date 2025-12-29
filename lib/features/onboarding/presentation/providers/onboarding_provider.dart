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
  final List<OnboardingStep> allSteps;
  final int currentStepIndex;

  OnboardingState({
    this.isLoading = true,
    this.currentStepConfig,
    this.errorMessage,
    this.currentStepKey,
    this.allSteps = const [],
    this.currentStepIndex = 0,
  });

  OnboardingState copyWith({
    bool? isLoading,
    OnboardingStep? currentStepConfig,
    String? errorMessage,
    String? currentStepKey,
    List<OnboardingStep>? allSteps,
    int? currentStepIndex,
  }) {
    return OnboardingState(
      isLoading: isLoading ?? this.isLoading,
      currentStepConfig: currentStepConfig ?? this.currentStepConfig,
      errorMessage: errorMessage,
      currentStepKey: currentStepKey ?? this.currentStepKey,
      allSteps: allSteps ?? this.allSteps,
      currentStepIndex: currentStepIndex ?? this.currentStepIndex,
    );
  }
}

final onboardingProvider =
    StateNotifierProvider<OnboardingNotifier, OnboardingState>((ref) {
      return OnboardingNotifier(ref);
    });

class OnboardingNotifier extends StateNotifier<OnboardingState> {
  final Ref _ref;

  bool _hasDismissedWelcome = false;

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
          await _ref.read(authRepositoryProvider).createProfile(user.id);
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

      final allSteps = await _repo.getAllSteps();
      final rawProgress = profile['steps_progress'];
      final Map<String, dynamic> stepsProgress = (rawProgress != null)
          ? Map<String, dynamic>.from(rawProgress)
          : {};

      bool isFreshUser = stepsProgress.isEmpty;

      if (isFreshUser && !_hasDismissedWelcome) {
        state = state.copyWith(
          isLoading: false,
          currentStepKey: 'pre_onboarding',
          currentStepConfig: null,
          allSteps: allSteps,
          currentStepIndex: -1,
        );
        return;
      }

      OnboardingStep? nextStep;
      int nextStepIndex = 0;

      for (int i = 0; i < allSteps.length; i++) {
        final step = allSteps[i];
        final status = stepsProgress[step.stepKey];

        if (status != 'completed' && status != 'skipped') {
          nextStep = step;
          nextStepIndex = i;
          break;
        }
      }

      final status = profile['onboarding_status'] as String? ?? 'in_progress';

      if (status == 'complete' || nextStep == null) {
        state = state.copyWith(
          isLoading: false,
          currentStepKey: 'complete',
          allSteps: allSteps,
          currentStepIndex: allSteps.length,
        );
      } else {
        AppLogger.info(
          'Derived Step: ${nextStep.stepName} (${nextStep.stepKey})',
        );
        state = state.copyWith(
          isLoading: false,
          currentStepConfig: nextStep,
          currentStepKey: nextStep.stepKey,
          allSteps: allSteps,
          currentStepIndex: nextStepIndex,
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
      final stepIndex = state.allSteps.indexWhere((s) => s.stepKey == stepKey);
      state = state.copyWith(
        isLoading: false,
        currentStepConfig: step,
        currentStepKey: stepKey,
        currentStepIndex: stepIndex >= 0 ? stepIndex : state.currentStepIndex,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  // Go to previous step
  Future<void> previousStep() async {
    if (state.currentStepIndex <= 0 || state.allSteps.isEmpty) {
      AppLogger.info('Already at first step or no steps available');
      return;
    }

    final previousIndex = state.currentStepIndex - 1;
    final previousStep = state.allSteps[previousIndex];
    
    AppLogger.info('Going back to: ${previousStep.stepName} (${previousStep.stepKey})');
    
    state = state.copyWith(
      currentStepConfig: previousStep,
      currentStepKey: previousStep.stepKey,
      currentStepIndex: previousIndex,
    );
  }

  // NEW METHOD: Go to next step in sequence
  Future<void> nextStep() async {
    if (state.currentStepIndex >= state.allSteps.length - 1) {
      AppLogger.info('Already at last step');
      return;
    }

    final nextIndex = state.currentStepIndex + 1;
    final nextStep = state.allSteps[nextIndex];
    
    AppLogger.info('Going forward to: ${nextStep.stepName} (${nextStep.stepKey})');
    
    state = state.copyWith(
      currentStepConfig: nextStep,
      currentStepKey: nextStep.stepKey,
      currentStepIndex: nextIndex,
    );
  }

  Future<void> completeStep(String stepKeyToComplete) async {
    await _updateStepAndAdvance(stepKeyToComplete, 'completed');
  }

  Future<void> skipStep(String stepKeyToSkip) async {
    await _updateStepAndAdvance(stepKeyToSkip, 'skipped');
  }

  // UPDATED: Helper to update status and advance
  Future<void> _updateStepAndAdvance(String stepKey, String status) async {
    state = state.copyWith(isLoading: true);
    final user = _ref.read(authRepositoryProvider).currentUser;
    if (user == null) return;

    try {
      // 1. Update the JSON status map
      await _repo.updateStepStatus(user.id, stepKey, status);

      // 2. Move to next step in sequence (not based on DB)
      if (state.currentStepIndex < state.allSteps.length - 1) {
        final nextIndex = state.currentStepIndex + 1;
        final nextStep = state.allSteps[nextIndex];
        
        state = state.copyWith(
          isLoading: false,
          currentStepConfig: nextStep,
          currentStepKey: nextStep.stepKey,
          currentStepIndex: nextIndex,
        );
      } else {
        // Last step completed - mark onboarding complete
        await completeOnboarding();
      }
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

    if (skippedStepKey != null) {
      await _repo.updateStepStatus(user.id, skippedStepKey, 'skipped');
    }

    await _repo.completeOnboarding(user.id);
    state = state.copyWith(
      currentStepKey: 'complete',
      isLoading: false,
    );
  }

  void dismissWelcome() {
    _hasDismissedWelcome = true;
    init();
  }
}
