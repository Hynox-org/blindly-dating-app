// import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:veriff_flutter/veriff_flutter.dart';

import '../../../../onboarding/presentation/providers/onboarding_provider.dart';
import '../../../../onboarding/presentation/screens/steps/base_onboarding_step_screen.dart';

enum GovIdStep { instructions, verified } // Removed 'processing' as we skip it

enum DocumentType { drivers_license, aadhar_card, pan_card }

class GovernmentIdVerificationScreen extends ConsumerStatefulWidget {
  const GovernmentIdVerificationScreen({super.key});

  @override
  ConsumerState<GovernmentIdVerificationScreen> createState() =>
      _GovernmentIdVerificationScreenState();
}

class _GovernmentIdVerificationScreenState
    extends ConsumerState<GovernmentIdVerificationScreen> {
  GovIdStep _currentStep = GovIdStep.instructions;
  DocumentType _selectedDocType = DocumentType.drivers_license;
  bool _isLoading = false;

  // Track the last handled status to prevent duplicate popups
  String? _lastHandledStatus;

  @override
  void initState() {
    super.initState();
    _listenForDetailedVerificationStatus();
  }

  // --- 1. INTELLIGENT LISTENER (Updated to check status immediately) ---
  Future<void> _listenForDetailedVerificationStatus() async {
    final authUserId = Supabase.instance.client.auth.currentUser?.id;
    if (authUserId == null) return;

    try {
      // 🕵️ STEP 1: Get Profile ID AND Current Status
      final profileData = await Supabase.instance.client
          .from('profiles')
          .select('id, is_verified')
          .eq('user_id', authUserId)
          .maybeSingle();

      if (profileData == null) {
        print("❌ Error: Could not find a profile for this user.");
        return;
      }

      final profileId = profileData['id'];
      final bool isAlreadyVerified = profileData['is_verified'] ?? false;

      // 🛑 CHECK: Are they already verified?
      if (isAlreadyVerified) {
        print("✅ User is already verified. Skipping stream.");
        if (mounted) {
          setState(() {
            _isLoading = false;
            _currentStep = GovIdStep
                .verified; // Used to track state, but we stay on same screen
          });
          // 🔔 Show the specific message you asked for
          _showProfessionalToast(
            "You have been already verified",
            isError: false,
          );
        }
        return; // STOP HERE.
      }

      print("✅ Found Profile ID: $profileId. Listening for updates...");

      // 🕵️ STEP 2: Listen using the Profile ID (Only if NOT verified yet)
      Supabase.instance.client
          .from('veriff_verifications')
          .stream(primaryKey: ['id'])
          .eq('profile_id', profileId)
          .order('created_at', ascending: false)
          .limit(1)
          .listen((List<Map<String, dynamic>> data) {
            if (data.isNotEmpty && mounted) {
              final latestLog = data.first;
              final String status = latestLog['status'] ?? 'created';
              final String? reason = latestLog['fail_reason'];

              if (_lastHandledStatus == status) return;
              _lastHandledStatus = status;

              // ✅ CASE A: APPROVED
              if (status == 'approved' || status == 'full_verified') {
                if (mounted) {
                  setState(() {
                    _isLoading = false;
                    _currentStep = GovIdStep.verified;
                  });
                  _showProfessionalToast(
                    "Verification Successful",
                    isError: false,
                  );
                }
              }
              // ❌ CASE B: FAILED / RESUBMIT
              else if (status == 'resubmission_requested' ||
                  status == 'declined') {
                if (mounted) {
                  setState(() => _isLoading = false);
                  // Don't change step, stay here to retry
                  _showFailureDialog(
                    reason ?? "Document could not be verified.",
                  );
                }
              }
            }
          });
    } catch (e) {
      print("❌ Listener Error: $e");
    }
  }

  // --- 2. PROFESSIONAL DIALOGS ---

  void _showFailureDialog(String reason) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
            SizedBox(width: 10),
            Text("Verification Failed"),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("We could not verify your ID. Veriff provided this reason:"),
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.all(12),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Text(
                reason,
                style: TextStyle(
                  color: Colors.brown.shade800,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SizedBox(height: 12),
            Text("Please try again with a clearer image."),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Try Again",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _showProfessionalToast(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle,
              color: Colors.white,
            ),
            SizedBox(width: 12),
            Text(message, style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        backgroundColor: isError ? Colors.red.shade700 : Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: EdgeInsets.all(16),
      ),
    );
  }

  // --- 3. VERIFF LOGIC ---
  Future<void> _startVeriffFlow() async {
    setState(() => _isLoading = true);

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) throw Exception("User not logged in");

      // A. Call Edge Function
      final response = await Supabase.instance.client.functions.invoke(
        'create-veriff-session',
        body: {
          'firstName': user.userMetadata?['first_name'] ?? '',
          'lastName': user.userMetadata?['last_name'] ?? '',
        },
      );

      final sessionUrl = response.data['url'];
      if (sessionUrl == null) throw Exception("Failed to generate Veriff URL");

      // B. Start SDK
      Configuration config = Configuration(sessionUrl);
      Veriff veriff = Veriff();

      // Wait for user to finish
      Result result = await veriff.start(config);

      if (result.status == Status.done) {
        // User finished. We keep spinner loading while waiting for Webhook.
        print("Veriff finished. Waiting for webhook...");
      } else if (result.status == Status.error) {
        setState(() => _isLoading = false);
        _showProfessionalToast("Camera Error: ${result.error}", isError: true);
      } else if (result.status == Status.canceled) {
        setState(() => _isLoading = false);
        print("User cancelled verification");
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showProfessionalToast(
        "Connection Failed. Please try again.",
        isError: true,
      );
    }
  }

  // --- Actions ---

  void _onSkip() {
    ref.read(onboardingProvider.notifier).skipStep('gov_id_optional');
  }

  void _onBack() {
    if (_currentStep == GovIdStep.instructions) {
      ref.read(onboardingProvider.notifier).goToPreviousStep();
    }
  }

  // --- UI Builders ---

  @override
  Widget build(BuildContext context) {
    // 1. DETERMINE IF VERIFIED
    final bool isVerified = _currentStep == GovIdStep.verified;

    final colorScheme = Theme.of(context).colorScheme;

    return BaseOnboardingStepScreen(
      title: 'Verify Your Profile',
      showBackButton: false,
      onBack: _onBack,
      showNextButton: false,
      showSkipButton: false,
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: isVerified
                          ? Colors.green.shade100
                          : colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isVerified
                          ? Icons.check_circle_rounded
                          : Icons.shield_outlined,
                      size: 40,
                      color: isVerified
                          ? Colors.green.shade700
                          : colorScheme.onPrimary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    isVerified
                        ? "You are Verified!"
                        : "A quick check to keep you safe",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    isVerified
                        ? "Your identity has been confirmed."
                        : "To confirm your identity, we use Veriff for secure document scanning.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: colorScheme.onSurfaceVariant,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Upload/Start Area
                  GestureDetector(
                    // Disabled if loading OR verified
                    onTap: (_isLoading || isVerified) ? null : _startVeriffFlow,
                    child: Container(
                      height: 220,
                      width: double.infinity,
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: isVerified
                            ? Colors.green.shade50.withOpacity(0.5)
                            : colorScheme.surfaceContainerHighest.withOpacity(
                                0.3,
                              ),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: isVerified
                              ? Colors.green.shade300
                              : (_isLoading
                                    ? Colors.grey
                                    : colorScheme.primary.withOpacity(0.5)),
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: _isLoading
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircularProgressIndicator(),
                                  SizedBox(height: 16),
                                  Text(
                                    "Verifying Results...",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    isVerified
                                        ? Icons.check_circle
                                        : Icons.camera_alt_rounded,
                                    size: 40,
                                    color: isVerified
                                        ? Colors.green.shade600
                                        : colorScheme.primary,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    isVerified
                                        ? "Verification Complete"
                                        : "Tap to Scan Document",
                                    style: TextStyle(
                                      color: isVerified
                                          ? Colors.green.shade800
                                          : colorScheme.primary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  if (!isVerified) ...[
                                    const SizedBox(height: 8),
                                    Text(
                                      "Powered by Veriff",
                                      style: TextStyle(
                                        color: colorScheme.onSurfaceVariant
                                            .withOpacity(0.5),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  if (!isVerified)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildGuidelineItem(
                            context,
                            Icons.circle,
                            "Prepare your physical ID card",
                          ),
                          const SizedBox(height: 16),
                          _buildGuidelineItem(
                            context,
                            Icons.circle,
                            "Ensure good lighting",
                          ),
                          const SizedBox(height: 16),
                          _buildGuidelineItem(
                            context,
                            Icons.circle,
                            "Be ready for a quick selfie",
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                // Disabled if loading OR verified
                onPressed: (_isLoading || isVerified) ? null : _startVeriffFlow,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _isLoading
                    ? const Text(
                        "Processing...",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : Text(
                        isVerified ? "Verified ✅" : "Start Verification",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton.icon(
                // Disabled ONLY if loading. Enabled if verified.
                onPressed: _isLoading ? null : _onBack,
                icon: Icon(
                  Icons.arrow_back,
                  size: 20,
                  color: colorScheme.onSurface,
                ),
                label: Text(
                  "Back",
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              TextButton(
                onPressed: _isLoading ? null : _onSkip,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      isVerified ? "Next" : "Skip",
                      style: TextStyle(
                        color: colorScheme.onSurface,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      isVerified
                          ? Icons.arrow_forward_rounded
                          : Icons.skip_next_rounded,
                      size: 24,
                      color: colorScheme.onSurface,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- Helpers ---

  Widget _buildGuidelineItem(BuildContext context, IconData icon, String text) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(Icons.circle, color: colorScheme.primary, size: 16),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}
