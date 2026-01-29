import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:blindly_dating_app/core/utils/app_logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

import '../../../../auth/providers/auth_providers.dart';
import '../../../../media/providers/media_provider.dart';
import '../../../../onboarding/presentation/providers/onboarding_provider.dart';
import '../../../../onboarding/presentation/screens/steps/base_onboarding_step_screen.dart';
import '../../../../../core/widgets/app_loader.dart';

class VoiceIntroScreen extends ConsumerStatefulWidget {
  const VoiceIntroScreen({super.key});

  @override
  ConsumerState<VoiceIntroScreen> createState() => _VoiceIntroScreenState();
}

class _VoiceIntroScreenState extends ConsumerState<VoiceIntroScreen> {
  // v5.2.0 uses AudioRecorder() class
  final AudioRecorder _audioRecorder = AudioRecorder();
  final AudioPlayer _audioPlayer = AudioPlayer();

  bool _isRecording = false;
  bool _isPlaying = false;
  String? _recordedFilePath;
  String? _existingVoiceUrl; // Remote URL
  int _currentTimerSeconds = 0;
  Timer? _timer;

  // Loading state for upload
  bool _isUploading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _audioPlayer.onPlayerComplete.listen((event) {
      if (mounted) setState(() => _isPlaying = false);
    });

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _fetchExistingVoice();
    });
  }

  Future<void> _fetchExistingVoice() async {
    final user = ref.read(authRepositoryProvider).currentUser;
    if (user == null) return;

    final voiceData = await ref
        .read(mediaRepositoryProvider)
        .getUserVoiceIntro(user.id);
    if (voiceData != null) {
      if (mounted) {
        setState(() {
          _existingVoiceUrl = voiceData['media_url'];
          _currentTimerSeconds = (voiceData['duration_seconds'] as int?) ?? 0;
        });
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _audioRecorder.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _startRecording() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        final directory = await getTemporaryDirectory();
        final filePath =
            '${directory.path}/voice_intro_${DateTime.now().millisecondsSinceEpoch}.m4a';

        // v5 API: start(RecordConfig config, {required String path})
        await _audioRecorder.start(
          const RecordConfig(encoder: AudioEncoder.aacLc),
          path: filePath,
        );

        _startTimer();
        setState(() {
          _isRecording = true;
          _errorMessage = null;
          // Clear existing if we start new recording
          _existingVoiceUrl = null;
        });
      } else {
        setState(() => _errorMessage = 'Microphone permission denied');
      }
    } catch (e) {
      AppLogger.error('Start recording error', e);
      setState(() => _errorMessage = 'Failed to start recording');
    }
  }

  Future<void> _stopRecording() async {
    try {
      // v5 API: stop() returns Future<String?>
      final path = await _audioRecorder.stop();
      _stopTimer();

      if (path != null) {
        setState(() {
          _isRecording = false;
          _recordedFilePath = path;
        });

        // Validate duration immediately (min 1 sec)
        if (_currentTimerSeconds < 1) {
          setState(() {
            _errorMessage = 'Voice intro must be at least 1 second';
            _recordedFilePath = null; // Discard
          });
        }
      }
    } catch (e) {
      AppLogger.error('Stop recording error', e);
      setState(() {
        _isRecording = false;
        _errorMessage = 'Failed to stop recording';
      });
    }
  }

  void _startTimer() {
    _currentTimerSeconds = 0;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _currentTimerSeconds++;
      });
      // Auto-stop at 60 seconds
      if (_currentTimerSeconds >= 30) {
        _stopRecording();
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
  }

  Future<void> _playVoice() async {
    try {
      if (_recordedFilePath != null) {
        await _audioPlayer.play(DeviceFileSource(_recordedFilePath!));
        setState(() => _isPlaying = true);
      } else if (_existingVoiceUrl != null) {
        await _audioPlayer.play(UrlSource(_existingVoiceUrl!));
        setState(() => _isPlaying = true);
      }
    } catch (e) {
      AppLogger.error('Play voice error', e);
      setState(() => _errorMessage = 'Failed to play audio');
    }
  }

  Future<void> _pauseVoice() async {
    await _audioPlayer.pause();
    setState(() => _isPlaying = false);
  }

  void _deleteVoice() {
    _audioPlayer.stop();
    setState(() {
      _recordedFilePath = null;
      _existingVoiceUrl = null;
      _isPlaying = false;
      _currentTimerSeconds = 0;
      _errorMessage = null;
    });
  }

  Future<void> _handleNext() async {
    // If we have an existing URL and no new recording, just proceed
    if (_existingVoiceUrl != null && _recordedFilePath == null) {
      ref.read(onboardingProvider.notifier).completeStep('voice_intro');
      return;
    }

    if (_recordedFilePath == null) {
      setState(() => _errorMessage = 'Please record a voice intro');
      return;
    }

    if (_currentTimerSeconds < 1 || _currentTimerSeconds > 30) {
      setState(
        () => _errorMessage = 'Recording must be between 1 and 30 seconds',
      );
      return;
    }

    setState(() {
      _isUploading = true;
      _errorMessage = null;
    });

    try {
      final user = ref.read(authRepositoryProvider).currentUser;
      if (user == null) throw Exception('User not logged in');

      final mediaRepo = ref.read(mediaRepositoryProvider);
      final profileId = await mediaRepo.getProfileId(user.id);

      if (profileId == null) throw Exception('Profile not found');

      // 1. Upload File
      final file = File(_recordedFilePath!);
      // returns filePath (e.g. userId/uuid.m4a)
      final mediaPath = await mediaRepo.uploadVoice(file, user.id);

      // 2. Save Metadata
      final mediaData = {
        'profile_id': profileId,
        'media_url': mediaPath, // Save PATH
        'media_type': 'voice_intro',
        'display_order': 0,
        'is_primary': false,
        'file_size_bytes': await file.length(),
        'duration_seconds': _currentTimerSeconds,
        'moderation_status': 'pending',
      };

      // 3. Cleanup old entries for this user (enforce 1 voice limit)
      await mediaRepo.deleteUserVoiceIntro(profileId);

      // 4. Save new entry
      await mediaRepo.saveMedia([mediaData]);

      // 5. Complete Step
      if (mounted) {
        ref.read(onboardingProvider.notifier).completeStep('voice_intro');
      }
    } catch (e) {
      AppLogger.error('Upload voice error', e);
      setState(() {
        _errorMessage = 'Failed to upload voice intro: ${e.toString()}';
      });
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  Future<void> _handleSkip() async {
    ref.read(onboardingProvider.notifier).skipStep('voice_intro');
  }

  String _formatDuration(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    // Custom Colors based on the image, mapped to Theme
    final colorScheme = Theme.of(context).colorScheme;
    final primaryDarkColor = colorScheme.primary;
    // Gold/Yellow for accent/progress
    final accentGoldColor = colorScheme.secondary;

    final hasVoice = _recordedFilePath != null || _existingVoiceUrl != null;

    // "Save & Continue" enabled if (not recording) AND (hasVoice or uploading isn't issue yet)
    // Actually, button triggers upload, so disable if uploading.
    final isSaveEnabled = !_isRecording && !_isUploading && hasVoice;

    return BaseOnboardingStepScreen(
      title: 'Voice Intro',
      showBackButton: false, // Custom footer
      showNextButton: false, // Custom footer
      showSkipButton: false, // Custom footer
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Text(
                    'Record a short intro',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                      fontSize: 24,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Text(
                      'Let your personality shine through. Record a 30 seconds short intro.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.6),
                        height: 1.4,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Recording UI
                  GestureDetector(
                    onTap: () {
                      if (_isRecording) {
                        _stopRecording();
                      } else if (hasVoice) {
                        // Toggle Play/Pause
                        if (_isPlaying) {
                          _pauseVoice();
                        } else {
                          _playVoice();
                        }
                      } else {
                        _startRecording();
                      }
                    },
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Progress Ring
                        SizedBox(
                          width: 140,
                          height: 140,
                          child: CircularProgressIndicator(
                            value: _currentTimerSeconds > 0
                                ? _currentTimerSeconds / 30
                                : 0.0,
                            backgroundColor: accentGoldColor.withOpacity(0.3),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              accentGoldColor,
                            ),
                            strokeWidth: 6,
                          ),
                        ),
                        // Main Circle
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: primaryDarkColor,
                            boxShadow: [
                              BoxShadow(
                                color: primaryDarkColor.withOpacity(0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Icon(
                            _isRecording
                                ? Icons.stop
                                : (_isPlaying
                                      ? Icons.pause
                                      : (hasVoice
                                            ? Icons.play_arrow_rounded
                                            : Icons.mic_none_outlined)),
                            color: colorScheme.onPrimary,
                            size: 48,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Messages / Status
                  if (_errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(color: colorScheme.error),
                      ),
                    ),

                  // Timer or "Record Again"
                  if (_isRecording || hasVoice) ...[
                    Text(
                      _formatDuration(_currentTimerSeconds),
                      style: TextStyle(
                        color: primaryDarkColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
                    if (hasVoice && !_isRecording) ...[
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: _deleteVoice,
                        icon: Icon(
                          Icons.refresh,
                          size: 16,
                          color: colorScheme.onSurface.withOpacity(0.6),
                        ),
                        label: Text(
                          'Record Again',
                          style: TextStyle(
                            color: colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ),
                    ],
                  ] else ...[
                    const SizedBox(
                      height: 24,
                    ), // Spacer if no timer to keep layout stable-ish
                  ],

                  const SizedBox(height: 40),

                  // Info Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      children: [
                        Text(
                          'Voice prompts help you stand out and make deeper connections. Share who you really are',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: colorScheme.onSurface.withOpacity(0.6),
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Benefits
                        _buildBenefitItem(
                          primaryDarkColor,
                          '3x more matches in voice record',
                        ),
                        const SizedBox(height: 16),
                        _buildBenefitItem(
                          primaryDarkColor,
                          'Start conversation naturally',
                        ),
                        const SizedBox(height: 16),
                        _buildBenefitItem(
                          primaryDarkColor,
                          'Show your personality',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // Footer Section
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isSaveEnabled ? _handleNext : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryDarkColor,
                      foregroundColor: colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: _isUploading
                        ? SizedBox(
                            height: 24,
                            width: 24,
                            child: AppLoader(
                              strokeWidth: 2,
                              color: colorScheme.onPrimary,
                              size: 24,
                            ),
                          )
                        : const Text(
                            "Save & Continue",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 16),
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
                        onPressed: _handleSkip,
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
          ),
        ],
      ),
    );
  }

  void _onBack() {
    ref.read(onboardingProvider.notifier).goToPreviousStep();
  }

  Widget _buildBenefitItem(Color color, String text) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
          // Checkmark icon can be added inside usage if design implies (image shows solid circles),
          // let's stick to solid circle as requested or seen in prev context,
          // but usually these have checkmarks. Image provided seems to be solid dark circles?
          // Ah, image actually has dark circles. No checkmarks visible in low res description but typical pattern is bullet.
          // I will leave it as solid circle to match "green circle" observation.
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 15, // Slightly reduced
              fontWeight: FontWeight.bold, // Text looks bold on image
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}
