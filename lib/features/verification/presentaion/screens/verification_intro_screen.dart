import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/verification_provider.dart';
import 'verification_status_screen.dart';

class VerificationIntroScreen extends ConsumerWidget {
  const VerificationIntroScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 👂 LISTEN FOR CHANGES
    ref.listen(verificationProvider, (previous, next) {
      // ✅ 1. Success -> Go to Status Screen (Green)
      if (next.status == VerificationFlowStatus.success) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const VerificationStatusScreen()),
        );
      }
      // ⚠️ 2. Retry -> Go to Status Screen (Orange)
      else if (next.status == VerificationFlowStatus.retry) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const VerificationStatusScreen()),
        );
      }
      // 🚨 3. Error -> Show SnackBar
      else if (next.status == VerificationFlowStatus.error) {
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text(next.failReason ?? 'Error occurred')),
        );
      }
    });

    final state = ref.watch(verificationProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Get Verified")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.shield, size: 100, color: Colors.blue),
            const SizedBox(height: 20),
            const Text(
              "Verify your identity",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text("We need a government ID and a selfie."),
            const SizedBox(height: 40),
            
            // 🚀 THE TRIGGER BUTTON
            if (state.status == VerificationFlowStatus.loading || 
                state.status == VerificationFlowStatus.processing)
              const Column(
                children: [
                   CircularProgressIndicator(),
                   SizedBox(height: 10),
                   Text("Processing securely...")
                ],
              )
            else
              ElevatedButton(
                onPressed: () {
                  // This one line starts the entire Native Flow!
                  ref.read(verificationProvider.notifier).startNativeVerification();
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                ),
                child: const Text("Start Verification"),
              ),
          ],
        ),
      ),
    );
  }
}