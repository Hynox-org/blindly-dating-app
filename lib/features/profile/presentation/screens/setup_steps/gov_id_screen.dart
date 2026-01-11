import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../onboarding/data/repositories/verification_repository.dart';
import '../../../../onboarding/presentation/providers/onboarding_provider.dart';
import '../../../../onboarding/presentation/screens/steps/base_onboarding_step_screen.dart';
import '../../../../../core/utils/custom_popups.dart';

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
  File? _selectedImage;
  final _verificationRepo = VerificationRepository();

  // --- Actions ---

  Future<void> _uploadAndVerify() async {
    if (_selectedImage == null) return;

    setState(() {
      _currentStep = GovIdStep.processing;
    });

    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) throw Exception("User not logged in");

      // 1. Upload Image
      final storagePath = await _verificationRepo.uploadGovernmentId(
        _selectedImage!,
        userId,
      );

      // 2. Create Request
      await _verificationRepo.createVerificationRequest(
        userId: userId,
        mediaStoragePath: storagePath,
        verificationType: 'gov_id',
        additionalData: {'document_type': _selectedDocType.name},
      );

      if (mounted) {
        setState(() {
          _currentStep = GovIdStep.verified;
        });
      }
    } catch (e) {
      if (mounted) {
        showErrorPopup(context, "Verification upload failed: $e");
        setState(() {
          _currentStep = GovIdStep.instructions;
        });
      }
    }
  }

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
      // In processing or verified, usually disable back or go to start
      // For now, go back to instructions
      setState(() {
        _currentStep = GovIdStep.instructions;
        _selectedImage = null;
      });
    }
  }

  // --- UI Builders ---

  @override
  Widget build(BuildContext context) {
    if (_currentStep == GovIdStep.processing) {
      return _buildStatusView(
        context,
        icon: Icons.access_time_filled_rounded,
        title: "We’re reviewing your Government ID proof",
        subtitle:
            "Your ID verification is in progress. This usually take a few hours. We’ll notify you once complete.",
        buttonText: "Got it",
        onPressed: _onVerifiedComplete,
      );
    }

    if (_currentStep == GovIdStep.verified) {
      return _buildStatusView(
        context,
        icon: Icons.check_circle_rounded,
        title: "Verified Successfully!",
        subtitle: "Government ID proof successfully verified",
        buttonText: "Got it",
        onPressed: _onVerifiedComplete,
      );
    }

    final colorScheme = Theme.of(context).colorScheme;

    return BaseOnboardingStepScreen(
      title: 'Verify Your Profile',
      showBackButton: false, // Custom handling
      onBack: _onBack,
      showNextButton: false,
      showSkipButton: false, // Custom handling
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
                      color: Theme.of(
                        context,
                      ).colorScheme.primary, // Dark Olive Green from image
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.shield_outlined,
                      size: 40,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ), // Gold color
                  ),
                  const SizedBox(height: 24),
                  Text(
                    "A quick check to keep you safe",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "To confirm your identity and ensure community safety, Please upload a valid government issue ID.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Document Type Selector
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(30), // More rounded
                    ),
                    padding: const EdgeInsets.all(4),
                    child: Row(
                      children: [
                        _buildTabItem(
                          DocumentType.drivers_license,
                          "Driver's License",
                        ),
                        _buildTabItem(DocumentType.aadhar_card, "Aadhar Card"),
                        _buildTabItem(DocumentType.pan_card, "PAN card"),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Upload Area

                  // Upload Area - Disabled
                  Container(
                    height: 220,
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest.withOpacity(
                        0.5,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: colorScheme.outline.withOpacity(0.2),
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.cloud_off_rounded,
                            size: 40,
                            color: colorScheme.onSurfaceVariant.withOpacity(
                              0.5,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "Upload currently disabled",
                            style: TextStyle(
                              color: colorScheme.onSurfaceVariant.withOpacity(
                                0.5,
                              ),
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "This feature will be available soon",
                            style: TextStyle(
                              color: colorScheme.onSurfaceVariant.withOpacity(
                                0.5,
                              ),
                              fontSize: 12,
                            ),
                          ),
                        ],
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
                        _buildGuidelineItem(
                          context,
                          Icons
                              .circle, // Placeholder, updated in _buildGuidelineItem
                          "Place on a flat and dark surface",
                        ),
                        const SizedBox(height: 16),
                        _buildGuidelineItem(
                          context,
                          Icons.circle,
                          "Avoid glare from lights",
                        ),
                        const SizedBox(height: 16),
                        _buildGuidelineItem(
                          context,
                          Icons.circle,
                          "Ensure all 4 corners are visible",
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  Text(
                    "Your ID is encrypted and will be deleted after verification.\nWe never share it with other users. Learn more",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      color: Theme.of(context).colorScheme.onSurface,
                      height: 1.4,
                    ),
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
                onPressed: _selectedImage != null ? _uploadAndVerify : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  disabledBackgroundColor: Theme.of(context).colorScheme.primary
                      .withOpacity(0.5), // Keep it green but dim
                  disabledForegroundColor: colorScheme.onPrimary.withOpacity(
                    0.7,
                  ),
                ),
                child: const Text(
                  "Upload & continue",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),

          // Navigation Row: Back and Skip
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton.icon(
                onPressed: _onBack,
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
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 8,
                  ),
                ),
              ),
              Directionality(
                textDirection: TextDirection.rtl,
                child: TextButton.icon(
                  onPressed: _onSkip,
                  icon: Icon(
                    Icons.skip_next_rounded,
                    size: 24,
                    color: colorScheme.onSurface,
                  ),
                  label: Text(
                    "Skip",
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 8,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabItem(DocumentType type, String label) {
    final isSelected = _selectedDocType == type;
    final colorScheme = Theme.of(context).colorScheme;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedDocType = type;
          });
        },
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
    // Override icon with simple circle for this specific design
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
              // Back button only at the very bottom or top?
              // Mockup shows "Back" at bottom for verified, but maybe top for processing?
              // Standardize:
              // Processing: No back.
              // Verified: "Back" at bottom.
              const Spacer(),
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  // Inner shield icon logic or just the icon
                  child: Icon(icon, size: 50, color: colorScheme.onPrimary),
                ), // Updated to match likely "Green Circle with Check" or "Green Loading"
              ),
              const SizedBox(height: 32),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    buttonText,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              // Back Button
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: TextButton.icon(
                  onPressed: _onBack,
                  icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
                  label: Text(
                    "Back",
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
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

class DashedRectPainter extends CustomPainter {
  final double strokeWidth;
  final Color color;
  final double gap;
  final double borderRadius;

  DashedRectPainter({
    this.strokeWidth = 2.0,
    this.color = Colors.black,
    this.gap = 5.0,
    this.borderRadius = 0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    Paint dashedPaint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final RRect rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(borderRadius),
    );

    Path path = Path()..addRRect(rrect);

    // Simple implementation of dashing a path
    // For a perfect dashed RRect we can use path metrics, but for speed simplified approach:
    // Just drawing the path with a dash effect is hard in vanilla flutter without path_drawing.
    // I'll stick to manual if needed, OR use a simplified approach since importing path_drawing isn't allowed without pubspec check.
    // Let's blindly try to use PathMetrics which IS in dart:ui (exported via material).

    Path dashPath = Path();
    double dashWidth = 10.0;
    double dashSpace = gap;
    double distance = 0.0;

    for (var pathMetric in path.computeMetrics()) {
      while (distance < pathMetric.length) {
        dashPath.addPath(
          pathMetric.extractPath(distance, distance + dashWidth),
          Offset.zero,
        );
        distance += dashWidth;
        distance += dashSpace;
      }
    }
    canvas.drawPath(dashPath, dashedPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
