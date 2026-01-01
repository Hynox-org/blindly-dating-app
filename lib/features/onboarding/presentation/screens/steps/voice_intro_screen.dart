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
import '../../providers/onboarding_provider.dart';
import 'base_onboarding_step_screen.dart';

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
    // Dark Olive/Green -> Primary Color
    final Color primaryDarkColor = Theme.of(context).primaryColor;
    // Gold/Yellow -> Secondary/Accent Color
    final Color accentGoldColor = Theme.of(context).colorScheme.secondary;

    final hasVoice = _recordedFilePath != null || _existingVoiceUrl != null;

    return BaseOnboardingStepScreen(
      title: 'Voice Intro',
      showBackButton: true,
      showNextButton: false, // We will implement our own "Save & Continue"
      // showSkipButton: handled dynamically
      onSkip: _handleSkip, // Provide callback for dynamic skip button in AppBar
      isNextEnabled: !_isRecording && !_isUploading && hasVoice,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Column(
            children: [
              // 1. Top Text Section
              const SizedBox(height: 10),
              Text(
                'Record a short intro',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                  fontSize: 28,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Text(
                  'Let your personality shine through. Record a 30 seconds short intro.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                    height: 1.4,
                    fontSize: 15,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              // 2. Spacer to push Recording UI to center
              const Spacer(),

              // 3. Recording / Playback UI (Centered)
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
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
                        // Progress Indicator Ring
                        SizedBox(
                          width: 160,
                          height: 160,
                          child: CircularProgressIndicator(
                            value: _currentTimerSeconds > 0
                                ? _currentTimerSeconds / 30
                                : 0.0,
                            backgroundColor: accentGoldColor.withOpacity(0.3),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              accentGoldColor,
                            ),
                            strokeWidth: 8,
                          ),
                        ),
                        // Main Circle
                        Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: primaryDarkColor,
                          ),
                          child: Icon(
                            _isRecording
                                ? Icons.stop
                                : (_isPlaying
                                      ? Icons.pause
                                      : (hasVoice
                                            ? Icons.play_arrow_rounded
                                            : Icons.mic)),
                            color: Colors.white,
                            size: 50,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Timer Display
                  if (_isRecording || hasVoice)
                    Text(
                      _formatDuration(_currentTimerSeconds),
                      style: TextStyle(
                        color: primaryDarkColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 24, // Slightly larger for visibility
                      ),
                    ),
                  // Delete / Re-record button
                  if (hasVoice && !_isRecording)
                    TextButton.icon(
                      onPressed: _deleteVoice,
                      icon: const Icon(
                        Icons.refresh,
                        size: 18,
                        color: Colors.grey,
                      ),
                      label: const Text(
                        'Record Again',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                ],
              ),

              // 4. Spacer to balance bottom
              const Spacer(),

              // 5. Bottom Info & Button Section (Grouped with Highlight)
              Container(
                margin: const EdgeInsets.only(bottom: 10.0),
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.05), // Subtle highlight
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Text(
                      'Voice prompts help you stand out and make deeper connections. Share who you really are',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Benefits List
                    _buildBenefitItem(
                      primaryDarkColor,
                      '3x more matches in voice record',
                    ),
                    const SizedBox(height: 12),
                    _buildBenefitItem(
                      primaryDarkColor,
                      'Start conversation naturally',
                    ),
                    const SizedBox(height: 12),
                    _buildBenefitItem(
                      primaryDarkColor,
                      'Show your personality',
                    ),
                  ],
                ),
              ),

              // 6. Save Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: (_isUploading || _isRecording)
                      ? null
                      : (_handleNext),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryDarkColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _isUploading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          // Change text based on whether it's new or existing?
                          // "Save & Continue" implies saving. If existing, it's just "Continue".
                          // But we might want to keep it consistent.
                          _existingVoiceUrl != null && _recordedFilePath == null
                              ? 'Continue'
                              : 'Save & Continue',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 10), // Little extra bottom padding
            ],
          );
        },
      ),
    );
  }

  Widget _buildBenefitItem(Color color, String text) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
        ),
      ],
    );
  }
}
