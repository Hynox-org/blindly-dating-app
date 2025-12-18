import 'package:flutter/material.dart';
import 'auth_service.dart';

class DummyTestScreen extends StatefulWidget {
  const DummyTestScreen({super.key});

  @override
  State<DummyTestScreen> createState() => _DummyTestScreenState();
}

class _DummyTestScreenState extends State<DummyTestScreen> {
  final AuthService _authService = AuthService();
  
  // Text Controllers
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();

  String _statusMessage = "Ready to test";

  // HELPER: Send OTP
  void _handleSendOtp() async {
    setState(() => _statusMessage = "Sending OTP...");
    try {
      // NOTE: Use your TEST NUMBER here (e.g. 919999999999)
      await _authService.sendOtp(_phoneController.text.trim());
      setState(() => _statusMessage = "OTP Sent! Check console.");
    } catch (e) {
      setState(() => _statusMessage = "Error: $e");
    }
  }

  // HELPER: Verify OTP
  void _handleVerifyOtp() async {
    setState(() => _statusMessage = "Verifying...");
    try {
      await _authService.verifyOtp(
        _phoneController.text.trim(),
        _otpController.text.trim(),
      );
      setState(() => _statusMessage = "LOGIN SUCCESS! User is Authenticated.");
    } catch (e) {
      setState(() => _statusMessage = "Login Failed: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Backend Dummy Tester")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text("Status: $_statusMessage", 
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
            const SizedBox(height: 20),
            
            // Phone Input
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(labelText: "Phone (e.g. +919999999999)"),
            ),
            ElevatedButton(
              onPressed: _handleSendOtp,
              child: const Text("1. Send OTP"),
            ),
            
            const SizedBox(height: 30),
            
            // OTP Input
            TextField(
              controller: _otpController,
              decoration: const InputDecoration(labelText: "OTP (e.g. 123456)"),
            ),
            ElevatedButton(
              onPressed: _handleVerifyOtp,
              child: const Text("2. Login & Verify"),
            ),
          ],
        ),
      ),
    );
  }
}