import 'package:flutter/material.dart';

class SelfieProcessingScreen extends StatelessWidget {
  const SelfieProcessingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Verifying your selfie...'),
          ],
        ),
      ),
    );
  }
}
