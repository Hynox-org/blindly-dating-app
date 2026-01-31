import 'dart:convert'; // Needed for jsonEncode if body is complex
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:veriff_flutter/veriff_flutter.dart';

import '../../../../onboarding/presentation/providers/onboarding_provider.dart';
import '../../../../onboarding/presentation/screens/steps/base_onboarding_step_screen.dart';

enum GovIdStep { instructions, processing, verified }
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

  // --- 1. Real-time Database Listener ---
  @override
  void initState() {
    super.initState();
    _listenForVerificationStatus();
  }

  void _listenForVerificationStatus() {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    // Listen to the 'profiles' table. 
    // When the webhook updates 'is_verified' -> this stream fires -> UI updates automatically.
    Supabase.instance.client
        .from('profiles')
        .stream(primaryKey: ['id'])
        .eq('id', userId)
        .listen((List<Map<String, dynamic>> data) {
          if (data.isNotEmpty) {
            // Note: Ensure your column name matches DB ('is_verified' or 'is_identity_verified')
            final isVerified = data.first['is_verified'] ?? false; 
            
            if (mounted) {
              if (isVerified) {
                setState(() => _currentStep = GovIdStep.verified);
              } 
              // If you want to handle "failures" (e.g. is_verified = false but they tried),
              // you might need to query the 'veriff_verifications' table separately.
            }
          }
        });
  }

  // --- 2. The Veriff Logic (WIRED UP) ---
  Future<void> _startVeriffFlow() async {
    setState(() => _isLoading = true);

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) throw Exception("User not logged in");

      // A. Call Supabase Edge Function to get Session URL
      // We use the function name 'create-veriff-session' we deployed earlier
      final response = await Supabase.instance.client.functions.invoke(
        'create-veriff-session',
        body: {
          'firstName': user.userMetadata?['first_name'] ?? '',
          'lastName': user.userMetadata?['last_name'] ?? '',
        },
      );

      final sessionUrl = response.data['url'];
      if (sessionUrl == null) throw Exception("Failed to generate Veriff URL");

      // B. Configure Veriff
      Configuration config = Configuration(sessionUrl);
      // Optional: Customize branding colors to match your app if needed
      // config.branding = Branding(themeColor: '#YOUR_COLOR_HEX');

      Veriff veriff = Veriff();

      // C. Start the SDK and AWAIT the result 🚨
      // We pause execution here until the user closes the Veriff screen
      print("🚀 Launching Veriff SDK...");
      Result result = await veriff.start(config);

      // D. Handle the Result
      print("🏁 Veriff SDK Closed. Status: ${result.status}, Error: ${result.error}");

      if (result.status == Status.done) {
        // User clicked "Submit" in Veriff. 
        // We move to "Processing" state while the Webhook talks to Supabase.
        setState(() {
          _currentStep = GovIdStep.processing;
        });
      } else if (result.status == Status.error) {
        // Technical error (camera permission, no internet)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Verification Error: ${result.error}")),
        );
      } else if (result.status == Status.canceled) {
        // User clicked "X" to close. Do nothing, just stop loading.
        print("User cancelled verification");
      }

    } catch (e) {
      print('❌ Error starting verification: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Could not start verification. Please try again.")),
      );
    } finally {
      // Always stop the spinner when they come back
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- Actions ---

  void _onVerifiedComplete() {
    ref.read(onboardingProvider.notifier).completeStep('gov_id_optional');
  }

  void _onSkip() {
    ref.read(onboardingProvider.notifier).skipStep('gov_id_optional');
  }

  void _onBack() {
    if (_currentStep == GovIdStep.instructions) {
      ref.read(onboardingProvider.notifier).goToPreviousStep();
    } else {
      setState(() {
        _currentStep = GovIdStep.instructions;
      });
    }
  }

  // --- UI Builders (Your Exact UI - Unchanged) ---

  @override
  Widget build(BuildContext context) {
    // 1. PROCESSING VIEW
    if (_currentStep == GovIdStep.processing) {
      return _buildStatusView(
        context,
        icon: Icons.access_time_filled_rounded,
        title: "We’re reviewing your ID",
        subtitle:
            "Veriff is analyzing your documents. This usually takes less than 2 minutes. Stay on this screen or check back later.",
        buttonText: "Refresh Status",
        onPressed: () {
           // The Stream listener handles updates, but this allows manual check/refresh if needed
           setState(() {}); 
        },
      );
    }

    // 2. VERIFIED VIEW
    if (_currentStep == GovIdStep.verified) {
      return _buildStatusView(
        context,
        icon: Icons.check_circle_rounded,
        title: "Verified Successfully!",
        subtitle: "Your Government ID has been confirmed.",
        buttonText: "Continue",
        onPressed: _onVerifiedComplete,
      );
    }

    // 3. MAIN INSTRUCTIONS VIEW
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
                  // Shield Icon
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.shield_outlined,
                      size: 40,
                      color: colorScheme.onPrimary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    "A quick check to keep you safe",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "To confirm your identity, we use Veriff for secure document scanning.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: colorScheme.onSurfaceVariant,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Document Type Selector (Visual Only)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.all(4),
                    child: Row(
                      children: [
                        _buildTabItem(DocumentType.drivers_license,"Driver's License"),
                        _buildTabItem(DocumentType.aadhar_card, "Aadhar Card"),
                        _buildTabItem(DocumentType.pan_card, "Passport"),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Upload/Start Area
                  GestureDetector(
                    onTap: _startVeriffFlow, // Allow tapping the box to start
                    child: Container(
                      height: 220,
                      width: double.infinity,
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: colorScheme.primary.withOpacity(0.5),
                          width: 2,
                          style: BorderStyle.solid, 
                        ),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.camera_alt_rounded,
                              size: 40,
                              color: colorScheme.primary,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              "Tap to Scan Document",
                              style: TextStyle(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Powered by Veriff",
                              style: TextStyle(
                                color: colorScheme.onSurfaceVariant.withOpacity(0.5),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Guidelines
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                          _buildGuidelineItem(context, Icons.circle, "Prepare your physical ID card"),
                          const SizedBox(height: 16),
                          _buildGuidelineItem(context, Icons.circle, "Ensure good lighting"),
                          const SizedBox(height: 16),
                          _buildGuidelineItem(context, Icons.circle, "Be ready for a quick selfie"),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  Text(
                    "Your ID is encrypted and deleted after verification.\nWe never share it with other users.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 11, color: colorScheme.onSurface, height: 1.4),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // Bottom Button
          Padding(
            padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                // Button is disabled ONLY if loading. 
                // If not loading, it triggers the flow.
                onPressed: _isLoading ? null : _startVeriffFlow, 
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _isLoading 
                  ? const SizedBox(
                      height: 20, width: 20, 
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                    )
                  : const Text(
                      "Start Verification",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
              ),
            ),
          ),

          // Navigation Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton.icon(
                onPressed: _onBack,
                icon: Icon(Icons.arrow_back, size: 20, color: colorScheme.onSurface),
                label: Text("Back", style: TextStyle(color: colorScheme.onSurface, fontSize: 16, fontWeight: FontWeight.w600)),
              ),
              Directionality(
                textDirection: TextDirection.rtl,
                child: TextButton.icon(
                  onPressed: _onSkip,
                  icon: Icon(Icons.skip_next_rounded, size: 24, color: colorScheme.onSurface),
                  label: Text("Skip", style: TextStyle(color: colorScheme.onSurface, fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- Helper Methods ---

  Widget _buildTabItem(DocumentType type, String label) {
    final isSelected = _selectedDocType == type;
    final colorScheme = Theme.of(context).colorScheme;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedDocType = type),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? colorScheme.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? colorScheme.onPrimary : colorScheme.onSurface,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGuidelineItem(BuildContext context, IconData icon, String text) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(Icons.circle, color: colorScheme.primary, size: 16),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: colorScheme.onSurface),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusView(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required String buttonText,
    VoidCallback? onPressed,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Container(
                width: 120, height: 120,
                decoration: BoxDecoration(color: colorScheme.primary, shape: BoxShape.circle),
                child: Center(child: Icon(icon, size: 50, color: colorScheme.onPrimary)),
              ),
              const SizedBox(height: 32),
              Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Text(subtitle, textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: colorScheme.onSurfaceVariant)),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text(buttonText, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}