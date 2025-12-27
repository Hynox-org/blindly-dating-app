import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/onboarding_step_model.dart';
import '../../../../features/auth/providers/auth_providers.dart';
import '../../../../core/utils/app_logger.dart';

// 1. IMPORT THE REPOSITORY FILE (So we know the class type)
import '../../../onboarding/data/repositories/onboarding_repository.dart';

// 2. IMPORT THE PROVIDER FILE (So we can find 'onboardingRepositoryProvider')
// import '../providers/onboarding_provider.dart';

// -----------------------------------------------------------------------------
// STATE CLASS
// -----------------------------------------------------------------------------
class OnboardingState {
  final bool isLoading;
  final OnboardingStep? currentStepConfig;
  final String? errorMessage;
  final String? currentStepKey;

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

// -----------------------------------------------------------------------------
// PROVIDER DEFINITION
// -----------------------------------------------------------------------------
final onboardingProvider =
    StateNotifierProvider<OnboardingNotifier, OnboardingState>((ref) {
  return OnboardingNotifier(ref);
});

// -----------------------------------------------------------------------------
// NOTIFIER (THE MANAGER)
// -----------------------------------------------------------------------------
class OnboardingNotifier extends StateNotifier<OnboardingState> {
  final Ref _ref;
  bool _hasDismissedWelcome = false;

  OnboardingNotifier(this._ref) : super(OnboardingState());

  // Access the Repository using the provider from 'onboarding_providers.dart'
  OnboardingRepository get _repo => _ref.read(onboardingRepositoryProvider);

  // ===========================================================================
  // 🚀 NEW BRIDGE FUNCTIONS (Call these from your UI Screens)
  // ===========================================================================

  /// Call this from NameEntryScreen
  Future<void> saveDisplayName(String name) async {
    final user = _ref.read(authRepositoryProvider).currentUser;
    if (user != null) {
      await _repo.updateDisplayName(user.id, name);
    }
  }

  /// Call this from BirthDateScreen
  Future<void> saveBirthDate(DateTime date) async {
    final user = _ref.read(authRepositoryProvider).currentUser;
    if (user != null) {
      await _repo.updateBirthDate(user.id, date);
    }
  }

  /// Call this from GenderScreen
  Future<void> saveGender(String gender) async {
    final user = _ref.read(authRepositoryProvider).currentUser;
    if (user != null) {
      await _repo.updateGender(user.id, gender);
    }
  }

  /// Call this from BioScreen
  Future<void> saveBio(String bio) async {
    final user = _ref.read(authRepositoryProvider).currentUser;
    if (user != null) {
      await _repo.updateBio(user.id, bio);
    }
  }

  /// Call this from LocationScreen
  Future<void> saveLocation(String city, String state, String country) async {
    final user = _ref.read(authRepositoryProvider).currentUser;
    if (user != null) {
      await _repo.updateLocationText(user.id, city, state, country);
    }
  }

  // ===========================================================================
  // NAVIGATION LOGIC (Your existing flow)
  // ===========================================================================

  Future<void> init() async {
    state = state.copyWith(isLoading: true);
    final user = _ref.read(authRepositoryProvider).currentUser;
    if (user == null) {
      state = state.copyWith(
          isLoading: false, errorMessage: "User not logged in");
      return;
    }

    try {
      final profile = await _repo.getProfileRaw(user.id);
      
      // Auto-heal logic
      if (profile == null) {
        AppLogger.info('Profile missing. Auto-creating...');
        try {
          await _ref.read(authRepositoryProvider).createProfile(user.id);
          return init();
        } catch (e) {
          state = state.copyWith(
              isLoading: false, errorMessage: "Profile creation failed");
          return;
        }
      }

      final allSteps = await _repo.getAllSteps();
      final rawProgress = profile['steps_progress'];
      final Map<String, dynamic> stepsProgress = (rawProgress != null)
          ? Map<String, dynamic>.from(rawProgress)
          : {};

      // Determine Start Point
      bool isFreshUser = stepsProgress.isEmpty;
      if (isFreshUser && !_hasDismissedWelcome) {
        state = state.copyWith(
          isLoading: false,
          currentStepKey: 'pre_onboarding',
          currentStepConfig: null,
        );
        return;
      }

      // Find next incomplete step
      OnboardingStep? nextStep;
      for (final step in allSteps) {
        final status = stepsProgress[step.stepKey];
        if (status != 'completed' && status != 'skipped') {
          nextStep = step;
          break;
        }
      }

      final status = profile['onboarding_status'] as String? ?? 'in_progress';

      if (status == 'complete' || nextStep == null) {
        state = state.copyWith(isLoading: false, currentStepKey: 'complete');
      } else {
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

  Future<void> completeStep(String stepKeyToComplete) async {
    await _updateStepAndAdvance(stepKeyToComplete, 'completed');
  }

  Future<void> skipStep(String stepKeyToSkip) async {
    await _updateStepAndAdvance(stepKeyToSkip, 'skipped');
  }

  Future<void> _updateStepAndAdvance(String stepKey, String status) async {
    state = state.copyWith(isLoading: true);
    final user = _ref.read(authRepositoryProvider).currentUser;
    if (user == null) return;

    try {
      await _repo.updateStepStatus(user.id, stepKey, status);
      await init(); // Refresh to find next step
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: 'Failed to save progress');
    }
  }

  Future<void> completeOnboarding({String? skippedStepKey}) async {
    final user = _ref.read(authRepositoryProvider).currentUser;
    if (user == null) return;

    if (skippedStepKey != null) {
      await _repo.updateStepStatus(user.id, skippedStepKey, 'skipped');
    }
    await _repo.completeOnboarding(user.id);
    state = state.copyWith(currentStepKey: 'complete');
  }
  // ---------------------------------------------------------------------------
  // MISSING NAVIGATION FUNCTIONS
  // ---------------------------------------------------------------------------

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

  Future<void> goToPreviousStep() async {
    try {
      final allSteps = await _repo.getAllSteps();
      final currentIndex = allSteps.indexWhere(
        (s) => s.stepKey == state.currentStepKey,
      );

      if (currentIndex > 0) {
        final prevStep = allSteps[currentIndex - 1];
        await jumpToStep(prevStep.stepKey);
      } else {
        // Logic for when you are at the start (optional)
        // e.g., maybe go back to 'pre_onboarding' or do nothing
      }
    } catch (e) {
      AppLogger.error('Failed to go back', e);
    }
  }
  
  void dismissWelcome() {
    _hasDismissedWelcome = true;
    init();
  }
}