import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:veriff_flutter/veriff_flutter.dart'; // The Native SDK
import '../repository/verification_repository.dart';

enum VerificationFlowStatus { initial, loading, sdk_open, processing, success, retry, error }

class VerificationState {
  final VerificationFlowStatus status;
  final String? failReason;
  final List<dynamic> riskLabels;

  VerificationState({
    this.status = VerificationFlowStatus.initial,
    this.failReason,
    this.riskLabels = const [],
  });
  
  VerificationState copyWith({
    VerificationFlowStatus? status,
    String? failReason,
    List<dynamic>? riskLabels,
  }) {
    return VerificationState(
      status: status ?? this.status,
      failReason: failReason ?? this.failReason,
      riskLabels: riskLabels ?? this.riskLabels,
    );
  }
}

class VerificationNotifier extends StateNotifier<VerificationState> {
  final VerificationRepository _repo;

  VerificationNotifier(this._repo) : super(VerificationState());

  /// 🚀 THE MAIN FUNCTION
  Future<void> startNativeVerification() async {
    try {
      // 1. Loading State
      state = state.copyWith(status: VerificationFlowStatus.loading);

      // 2. Get Session URL from Supabase
      final sessionUrl = await _repo.createSession();

      // 3. Configure Veriff Native SDK
      final config = Configuration(sessionUrl);
      final veriff = Veriff();

      // 4. Launch Native UI
      state = state.copyWith(status: VerificationFlowStatus.sdk_open);
      
      // This line pauses code execution until the user finishes the native flow!
      final result = await veriff.start(config);

      // 5. User came back. Handle the Result.
      if (result.status == Status.done) {
        // User finished uploading. Now check Supabase for the REAL result.
        await checkVerificationResult();
      } else if (result.status == Status.error) {
        state = state.copyWith(
          status: VerificationFlowStatus.error, 
          failReason: "Camera or Network Error: ${result.error}"
        );
      } else {
        // User cancelled (clicked "X")
        state = state.copyWith(status: VerificationFlowStatus.initial);
      }

    } catch (e) {
      state = state.copyWith(
        status: VerificationFlowStatus.error,
        failReason: "Could not start verification. Please try again.",
      );
    }
  }

  /// 🔍 POLLING LOGIC (Same as before)
  Future<void> checkVerificationResult() async {
    state = state.copyWith(status: VerificationFlowStatus.processing);

    // Wait 3 seconds for Webhook to land
    await Future.delayed(const Duration(seconds: 3));

    try {
      final result = await _repo.checkStatus();
      
      final String currentStatus = result['current_status'] ?? 'created';
      final String? reason = result['last_failure_reason'];

      if (currentStatus == 'approved') {
        state = state.copyWith(status: VerificationFlowStatus.success);
      } else if (currentStatus == 'resubmission_requested' || currentStatus == 'declined') {
        state = state.copyWith(
          status: VerificationFlowStatus.retry,
          failReason: reason ?? "Verification failed.",
        );
      } else {
        // Still processing? Wait and try again, or just show pending.
        state = state.copyWith(
          status: VerificationFlowStatus.processing,
          failReason: "Still analyzing... Check back in a moment.",
        );
      }
    } catch (e) {
      state = state.copyWith(
        status: VerificationFlowStatus.error,
        failReason: "Network error checking status.",
      );
    }
  }
}

final verificationProvider = StateNotifierProvider<VerificationNotifier, VerificationState>((ref) {
  final repo = ref.watch(verificationRepositoryProvider);
  return VerificationNotifier(repo);
});