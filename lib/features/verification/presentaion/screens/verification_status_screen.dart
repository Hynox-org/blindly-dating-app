import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/verification_provider.dart';

class VerificationStatusScreen extends ConsumerWidget {
  const VerificationStatusScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(verificationProvider);

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0), // Generous padding for clean look
          child: _buildContent(context, ref, state),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, VerificationState state) {
    // ⏳ STATE 1: PROCESSING / LOADING
    // This shows while we are polling the database for the final result.
    if (state.status == VerificationFlowStatus.processing || 
        state.status == VerificationFlowStatus.loading) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          SizedBox(
            height: 60, 
            width: 60, 
            child: CircularProgressIndicator(strokeWidth: 4),
          ),
          SizedBox(height: 30),
          Text(
            "Verifying Results...",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 10),
          Text(
            "Please wait while we securely analyze your data.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
        ],
      );
    }

    // ✅ STATE 2: SUCCESS
    // The user has the Blue Checkmark now.
    if (state.status == VerificationFlowStatus.success) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.verified_rounded, color: Colors.blue, size: 100),
          const SizedBox(height: 30),
          const Text(
            "You're Verified!",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const Text(
            "Your profile now has the blue checkmark badge. You are ready to go!",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.black54),
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                // Navigate back to the Home/Profile screen (clear stack)
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text(
                "Continue",
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ),
        ],
      );
    }

    // ⚠️ STATE 3: RETRY (Resubmission Requested / Failed)
    // Veriff said "Blurry", "Glare", or "Document Expired".
    if (state.status == VerificationFlowStatus.retry || 
        state.status == VerificationFlowStatus.error) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.orange.shade700, size: 100),
          const SizedBox(height: 30),
          const Text(
            "Verification Failed",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),
          // 🧠 Smart Feedback: Show exactly WHY it failed
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange.shade100),
            ),
            child: Text(
              state.failReason ?? "We could not verify your identity. Please try again.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16, 
                color: Colors.orange.shade900,
                fontWeight: FontWeight.w500
              ),
            ),
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                // Go back to the Intro Screen to click "Start" again
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text(
                "Try Again",
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ),
        ],
      );
    }

    // ❓ STATE 4: FALLBACK (Should rarely happen)
    return const Text("Unknown State");
  }
}