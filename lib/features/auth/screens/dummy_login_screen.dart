import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/auth_repository.dart';

class DummyLoginScreen extends ConsumerStatefulWidget {
  const DummyLoginScreen({super.key});

  @override
  ConsumerState<DummyLoginScreen> createState() => _DummyLoginScreenState();
}

class _DummyLoginScreenState extends ConsumerState<DummyLoginScreen> {
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  bool _isOtpSent = false;
  bool _isLoading = false;

  // TEST: Sending OTP
  Future<void> _testSendOtp() async {
    setState(() => _isLoading = true);
    try {
      final phone = _phoneController.text.trim();
      await ref.read(authRepositoryProvider).signInWithOtp(phone);
      
      setState(() => _isOtpSent = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ OTP Sent! Check SMS.")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // TEST: Verifying OTP
  Future<void> _testVerifyOtp() async {
    setState(() => _isLoading = true);
    try {
      final phone = _phoneController.text.trim();
      final otp = _otpController.text.trim();
      
      await ref.read(authRepositoryProvider).verifyOtp(phone, otp);
      
      // We don't need to navigate manually. 
      // The Router will see the session update and move us automatically!
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("🧪 TEST: Login Logic")),
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!_isOtpSent) ...[
              const Text("Step 1: Enter Phone"),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(hintText: "9876543210"),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading ? null : _testSendOtp,
                child: _isLoading ? const CircularProgressIndicator() : const Text("Send OTP"),
              ),
            ] else ...[
              const Text("Step 2: Enter OTP"),
              TextField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(hintText: "123456"),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading ? null : _testVerifyOtp,
                child: _isLoading ? const CircularProgressIndicator() : const Text("Verify & Login"),
              ),
              TextButton(
                onPressed: () => setState(() => _isOtpSent = false),
                child: const Text("Reset / Wrong Number"),
              ),
            ],
          ],
        ),
      ),
    );
  }
}