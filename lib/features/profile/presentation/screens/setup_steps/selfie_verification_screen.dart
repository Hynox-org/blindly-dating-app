import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../onboarding/data/repositories/verification_repository.dart';
import '../../../../onboarding/presentation/providers/onboarding_provider.dart';
import '../../../../onboarding/presentation/utils/pose_matcher.dart';
import '../../../../onboarding/presentation/screens/steps/base_onboarding_step_screen.dart';
import '../../../../../core/widgets/app_loader.dart';
import '../../../../../core/utils/custom_popups.dart';

enum SelfieStep { instructions, capture, processing, verified }

class SelfieVerificationScreen extends ConsumerStatefulWidget {
  const SelfieVerificationScreen({super.key});

  @override
  ConsumerState<SelfieVerificationScreen> createState() =>
      _SelfieVerificationScreenState();
}

class _SelfieVerificationScreenState
    extends ConsumerState<SelfieVerificationScreen> {
  SelfieStep _currentStep = SelfieStep.instructions;

  // Camera & ML Kit
  CameraController? _cameraController;
  PoseDetector? _poseDetector;
  bool _isDetecting = false;
  CameraDescription? _frontCamera;

  // Matching State
  PoseTarget? _targetPose;
  bool _isMatching = false;
  DateTime? _matchStartTime;
  double _matchProgress = 0.0; // 0.0 to 1.0
  String _feedbackMessage = "Align yourself with the camera"; // UI Feedback

  // Theme Colors from Mockup
  // Removed hardcoded colors to use App Theme

  @override
  void initState() {
    super.initState();
    _initializePoseDetector();
    // Select a random target pose for this session
    _targetPose = PoseLibrary.getRandomPose();
  }

  void _initializePoseDetector() {
    final options = PoseDetectorOptions(mode: PoseDetectionMode.stream);
    _poseDetector = PoseDetector(options: options);
  }

  Future<void> _initializeCamera() async {
    final status = await Permission.camera.request();
    if (status != PermissionStatus.granted) {
      if (mounted) {
        showErrorPopup(
          context,
          'Camera permission is required for verification.',
        );
      }
      return;
    }

    final cameras = await availableCameras();
    // Find front camera
    try {
      _frontCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
      );
    } catch (e) {
      if (cameras.isNotEmpty) {
        _frontCamera = cameras.first;
      } else {
        if (mounted) {
          showErrorPopup(context, 'No camera found on device.');
        }
        return;
      }
    }

    // Initialize with specific format handling
    _cameraController = CameraController(
      _frontCamera!,
      ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup: Platform.isAndroid
          ? ImageFormatGroup
                .nv21 // Prefer nv21 on Android
          : ImageFormatGroup.bgra8888,
    );

    try {
      await _cameraController!.initialize();
      if (!mounted) return;

      await _cameraController!.startImageStream(_processCameraImage);
      setState(() {});
    } catch (e) {
      debugPrint("Error initializing camera: $e");
    }
  }

  void _processCameraImage(CameraImage image) async {
    if (_isDetecting || _currentStep != SelfieStep.capture) return;
    _isDetecting = true;

    try {
      final inputImage = _inputImageFromCameraImage(image);
      if (inputImage == null) {
        debugPrint("InputImage is null");
        _isDetecting = false;
        return;
      }

      final poses = await _poseDetector!.processImage(inputImage);
      // debugPrint("Detected ${poses.length} poses");

      if (poses.isNotEmpty && _targetPose != null) {
        final pose = poses.first;
        final MatchResult result = PoseMatcher.isPoseMatching(
          pose,
          _targetPose!,
        );
        // debugPrint("Match Result: ${result.isMatch} - ${result.feedback}");

        if (mounted) {
          setState(() {
            _feedbackMessage = result.feedback;
          });
        }

        if (result.isMatch) {
          if (!_isMatching) {
            _isMatching = true;
            _matchStartTime = DateTime.now();
          } else {
            // Calculate progress - Reduced to 1s
            final duration = DateTime.now().difference(_matchStartTime!);
            final progress = (duration.inMilliseconds / 1000).clamp(0.0, 1.0);

            if (mounted) {
              setState(() {
                _matchProgress = progress;
              });
            }

            if (duration.inSeconds >= 1) {
              // Faster 1-second capture
              _onCaptureComplete();
            }
          }
        } else {
          _isMatching = false;
          _matchStartTime = null;
          if (mounted && _matchProgress > 0) {
            setState(() {
              _matchProgress = 0.0;
            });
          }
        }
      } else {
        // debugPrint("No poses detected");
        _isMatching = false;
        _matchStartTime = null;
        if (mounted) {
          setState(() {
            _matchProgress = 0.0;
            _feedbackMessage = "No body detected";
          });
        }
      }
    } catch (e) {
      debugPrint("Error processing image: $e");
    } finally {
      _isDetecting = false;
    }
  }

  InputImage? _inputImageFromCameraImage(CameraImage image) {
    if (_cameraController == null) return null;

    // 1. Get Camera Rotation
    final camera = _frontCamera!;
    final sensorOrientation = camera.sensorOrientation;
    var rotation = InputImageRotation.rotation0deg;

    if (Platform.isAndroid) {
      var rotationCompensation =
          _orientations[_cameraController!.value.deviceOrientation];
      if (rotationCompensation == null) return null;
      if (camera.lensDirection == CameraLensDirection.front) {
        // front-facing
        rotationCompensation = (sensorOrientation + rotationCompensation) % 360;
      } else {
        // back-facing
        rotationCompensation =
            (sensorOrientation - rotationCompensation + 360) % 360;
      }
      rotation =
          InputImageRotationValue.fromRawValue(rotationCompensation) ??
          InputImageRotation.rotation0deg;
    } else if (Platform.isIOS) {
      rotation =
          InputImageRotationValue.fromRawValue(sensorOrientation) ??
          InputImageRotation.rotation0deg;
    }

    // 2. Handle Image Format
    final format =
        InputImageFormatValue.fromRawValue(image.format.raw) ??
        InputImageFormat.nv21;

    // Validation checks... (Existing logic preserved)
    if (Platform.isAndroid &&
        image.planes.length != 3 &&
        format == InputImageFormat.nv21) {
      // Tolerant
    }
    if (Platform.isIOS && format != InputImageFormat.bgra8888) {
      // Tolerant
    }

    // compose InputImage
    return InputImage.fromBytes(
      bytes: _concatenatePlanes(image.planes),
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: format,
        bytesPerRow: image.planes.first.bytesPerRow,
      ),
    );
  }

  Uint8List _concatenatePlanes(List<Plane> planes) {
    final allBytes = WriteBuffer();
    for (var plane in planes) {
      allBytes.putUint8List(plane.bytes);
    }
    return allBytes.done().buffer.asUint8List();
  }

  static final _orientations = {
    DeviceOrientation.portraitUp: 0,
    DeviceOrientation.landscapeLeft: 90,
    DeviceOrientation.portraitDown: 180,
    DeviceOrientation.landscapeRight: 270,
  };

  @override
  void dispose() {
    _cameraController?.dispose();
    _poseDetector?.close();
    super.dispose();
  }

  void _startCapture() {
    setState(() {
      _currentStep = SelfieStep.capture;
    });
    _initializeCamera();
  }

  final _verificationRepo = VerificationRepository();

  Future<void> _onCaptureComplete() async {
    // Prevent multiple calls
    if (_currentStep == SelfieStep.processing ||
        _currentStep == SelfieStep.verified) {
      return;
    }

    _isDetecting = false;

    // 1. Show Processing State immediately to give UI feedback
    if (mounted) {
      setState(() {
        _currentStep = SelfieStep.processing;
      });
    }

    try {
      debugPrint("SelfieVerification: Starting capture sequence...");

      // 2. Take High-Res Picture (do this BEFORE stopping stream to ensure camera is active)
      XFile? photo;
      try {
        if (_cameraController != null &&
            _cameraController!.value.isInitialized) {
          photo = await _cameraController?.takePicture();
        }
      } catch (e) {
        debugPrint("SelfieVerification: takePicture failed: $e");
        throw Exception("Camera capture failed: $e");
      }

      if (photo == null) {
        throw Exception("Failed to capture photo (null result)");
      }
      debugPrint("SelfieVerification: Photo captured at ${photo.path}");

      // 3. Stop ML Stream now that we have the photo
      await _cameraController?.stopImageStream();

      // 4. Get User ID
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) throw Exception("User not logged in");

      // 5. Upload & Verify
      debugPrint("SelfieVerification: Uploading to Supabase...");
      final storagePath = await _verificationRepo.uploadSelfie(
        File(photo.path),
        userId,
      );
      debugPrint("SelfieVerification: Upload success. Path: $storagePath");

      debugPrint("SelfieVerification: Creating verification request...");
      await _verificationRepo.createVerificationRequest(
        userId: userId,
        mediaStoragePath: storagePath,
        verificationType: 'liveness',
        additionalData: {'pose_name': _targetPose?.name ?? 'Unknown'},
      );
      debugPrint("SelfieVerification: Request created.");

      // 6. Show Success State
      if (mounted) {
        setState(() {
          _currentStep = SelfieStep.verified;
        });
      }
    } catch (e) {
      debugPrint("SelfieVerification: Verification FAILED: $e");
      if (mounted) {
        showErrorPopup(
          context,
          "Verification failed: $e",
          onRetry: _initializeCamera,
        );

        // Return to instructions
        setState(() {
          _currentStep = SelfieStep.instructions;
          _isMatching = false;
          _matchProgress = 0.0;
        });
        _initializeCamera();
      }
    }
  }

  void _onVerifiedComplete() {
    // 4. Actually Complete Step
    ref.read(onboardingProvider.notifier).completeStep('selfie_capture');
  }

  void _onSkip() {
    _cameraController?.stopImageStream();
    ref.read(onboardingProvider.notifier).skipStep('selfie_capture');
  }

  void _onBack() {
    if (_currentStep == SelfieStep.capture) {
      _cameraController?.stopImageStream();
      setState(() {
        _currentStep = SelfieStep.instructions;
        _isMatching = false;
        _matchProgress = 0.0;
      });
    } else {
      ref.read(onboardingProvider.notifier).goToPreviousStep();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Processing View
    if (_currentStep == SelfieStep.processing) {
      return _buildStatusView(
        context,
        icon: Icons.access_time_filled_rounded,
        title: "We're reviewing your photos",
        subtitle:
            "Your profile verification is in progress. This usually takes a few seconds.",
        buttonText: null, // No button while processing
        onPressed: null,
      );
    }

    // Verified View
    if (_currentStep == SelfieStep.verified) {
      return _buildStatusView(
        context,
        icon: Icons.check_circle_rounded,
        title: "Verified Successfully!",
        subtitle: "Profile verification successfully completed",
        buttonText: "Got it",
        onPressed: _onVerifiedComplete,
        showSecondaryBackButton: true, // Show back button at bottom
      );
    }

    // Capture View
    if (_currentStep == SelfieStep.capture) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            // 1. Full Screen Camera Live Feed
            if (_cameraController != null &&
                _cameraController!.value.isInitialized)
              SizedBox.expand(
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    // Swap width/height because camera sensor is landscape
                    width: _cameraController!.value.previewSize!.height,
                    height: _cameraController!.value.previewSize!.width,
                    child: CameraPreview(_cameraController!),
                  ),
                ),
              )
            else
              const Center(child: AppLoader(color: Colors.white)),

            // 2. Dark Overlay Gradients for text visibility
            Positioned.fill(
              child: Column(
                children: [
                  Container(
                    height: 160,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.black.withOpacity(0.7),
                          Colors.transparent,
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    height: 160,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 3. Top Navigation Bar
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.black45,
                        child: IconButton(
                          icon: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                          onPressed: _onBack,
                        ),
                      ),
                      TextButton(
                        onPressed: _onSkip,
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.black45,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                        ),
                        child: const Text(
                          "Skip",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // 4. Pose Instructions (Centered Top)
            Positioned(
              top: 120,
              left: 20,
              right: 20,
              child: Column(
                children: [
                  // Icon removed as specificially requested
                  // const SizedBox(height: 16),
                  Text(
                    _targetPose?.description ?? "Copy this pose",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          blurRadius: 8,
                          color: Colors.black,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // 5. Feedback & Progress
            if (_matchProgress > 0)
              Center(
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white24, width: 2),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        value: _matchProgress,
                        color: Colors.greenAccent,
                        backgroundColor: Colors.white24,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "${(_matchProgress * 100).toInt()}%",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // User Feedback Text
            Positioned(
              bottom: 50,
              left: 20,
              right: 20,
              child: Text(
                _feedbackMessage,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _isMatching ? Colors.greenAccent : Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  shadows: const [
                    Shadow(
                      blurRadius: 4,
                      color: Colors.black,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),

            // Success Flash Overlay
            if (_matchProgress >= 1.0)
              Positioned.fill(
                child: Container(
                  color: Colors.green.withOpacity(0.6),
                  child: const Center(
                    child: Icon(
                      Icons.check_circle_rounded,
                      color: Colors.white,
                      size: 100,
                    ),
                  ),
                ),
              ),
          ],
        ),
      );
    }

    // Instructions View (Default)
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return BaseOnboardingStepScreen(
      title: 'Selfie Verification',
      showBackButton: false, // Custom implementation below
      onBack: _onBack,
      showNextButton: false,
      showSkipButton: false,
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Illustration
                  Image.asset(
                    'assets/static/selfie_verification_screen.png',
                    height: 250,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 32),
                  Text(
                    "Prove You're the\nReal Deal",
                    textAlign: TextAlign.center,
                    style: textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "This quick helps takes keep our community safe and authentic",
                    textAlign: TextAlign.center,
                    style: textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 40),
                  _buildBenefitItem(
                    context,
                    title: "Get a verified badge",
                    subtitle:
                        "Build trust with other users and shown you're real.",
                    color: colorScheme.primary, // Used Theme
                  ),
                  const SizedBox(height: 24),
                  _buildBenefitItem(
                    context,
                    title: "Keep the community safe",
                    subtitle: "Help us weed out fake profiles and bots.",
                    color: colorScheme.primary, // Used Theme
                  ),
                  const SizedBox(height: 24),
                  _buildBenefitItem(
                    context,
                    title: "Copy a simple pose",
                    subtitle:
                        "You'll take quick selfie to confirm your identity",
                    color: colorScheme.primary, // Used Theme
                  ),
                  const SizedBox(height: 32),
                  Text(
                    "Note: Your selfie is only for verification and won't to be on your profile",
                    textAlign: TextAlign.center,
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _startCapture,
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary, // Used Theme
              foregroundColor: colorScheme.onPrimary, // Used Theme
              padding: const EdgeInsets.symmetric(vertical: 18),
              elevation: 0,
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text(
              "Get verified",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 16),
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

  // --- Helper Widgets ---

  Widget _buildStatusView(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    String? buttonText,
    VoidCallback? onPressed,
    bool showSecondaryBackButton = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Custom Header similar to BaseOnboardingStepScreen
            Container(
              height: kToolbarHeight,
              alignment: Alignment.center,
              // Empty space as requested
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    const Spacer(),
                    // Centered Icon Bubble
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Icon(
                          icon,
                          size: 50,
                          color: colorScheme.onPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Title
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Subtitle
                    Text(
                      subtitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.5,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const Spacer(),
                    // Button (Optional)
                    if (buttonText != null)
                      ElevatedButton(
                        onPressed: onPressed,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          foregroundColor: colorScheme.onPrimary,
                          minimumSize: const Size(double.infinity, 56),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          buttonText,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),

                    // Secondary Back Button (Bottom)
                    if (showSecondaryBackButton) ...[
                      const SizedBox(height: 16),
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
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          minimumSize: const Size(double.infinity, 48),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ] else ...[
                      // Add spacing if no back button to keep layout balanced or just standard padding
                      const SizedBox(height: 12),
                    ],

                    const SizedBox(height: 12), // Bottom padding
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBenefitItem(
    BuildContext context, {
    required String title,
    required String subtitle,
    required Color color,
  }) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
