import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:just_audio/just_audio.dart' as ja;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../providers/onboarding_provider.dart';
import 'base_onboarding_step_screen.dart';

class VoiceIntroScreen extends ConsumerStatefulWidget {
  const VoiceIntroScreen({super.key});

  @override
  ConsumerState<VoiceIntroScreen> createState() => _VoiceIntroScreenState();
}

class _VoiceIntroScreenState extends ConsumerState<VoiceIntroScreen> {
  final FlutterSoundRecorder _audioRecorder = FlutterSoundRecorder();
  final ja.AudioPlayer _audioPlayer = ja.AudioPlayer();
  
  bool _isRecording = false;
  bool _hasRecording = false;
  String? _audioPath;
  int _recordDuration = 0;
  Timer? _timer;
  StreamSubscription<ja.PlayerState>? _playerStateSubscription;
  StreamSubscription<Duration>? _positionSubscription;
  bool _isPlaying = false;
  bool _isInitialized = false;
  Duration _playbackPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;

  static const int maxRecordingDuration = 30;

  @override
  void initState() {
    super.initState();
    _initRecorder();
    
    // Listen to player state
    _playerStateSubscription = _audioPlayer.playerStateStream.listen((state) {
      setState(() {
        _isPlaying = state.playing;
      });
    });
    
    // Listen to playback position
    _positionSubscription = _audioPlayer.positionStream.listen((position) {
      setState(() {
        _playbackPosition = position;
      });
    });
    
    // Listen to duration
    _audioPlayer.durationStream.listen((duration) {
      if (duration != null) {
        setState(() {
          _totalDuration = duration;
        });
      }
    });
  }

  Future<void> _initRecorder() async {
    await _audioRecorder.openRecorder();
    setState(() {
      _isInitialized = true;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _audioRecorder.closeRecorder();
    _audioPlayer.dispose();
    _playerStateSubscription?.cancel();
    _positionSubscription?.cancel();
    super.dispose();
  }

  Future<void> _checkPermissions() async {
    final status = await Permission.microphone.request();
    if (!status.isGranted) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Text('Microphone Permission Required'),
              content: const Text(
                'Please grant microphone permission to record your voice intro.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    openAppSettings();
                  },
                  child: const Text('Settings'),
                ),
              ],
            );
          },
        );
      }
    }
  }

  Future<void> _startRecording() async {
    try {
      if (!_isInitialized) {
        await _initRecorder();
      }

      final status = await Permission.microphone.request();
      if (!status.isGranted) {
        await _checkPermissions();
        return;
      }

      // Stop any ongoing playback
      await _audioPlayer.stop();

      final Directory appDocDir = await getApplicationDocumentsDirectory();
      // Use .m4a format which is more compatible
      final String filePath = '${appDocDir.path}/voice_intro_${DateTime.now().millisecondsSinceEpoch}.m4a';
      
      await _audioRecorder.startRecorder(
        toFile: filePath,
        codec: Codec.aacMP4, // Changed from aacADTS to aacMP4
        bitRate: 128000,
        sampleRate: 44100,
      );
      
      setState(() {
        _isRecording = true;
        _recordDuration = 0;
        _hasRecording = false;
        _audioPath = filePath;
        _playbackPosition = Duration.zero;
      });

      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          _recordDuration++;
          
          if (_recordDuration >= maxRecordingDuration) {
            _stopRecording();
          }
        });
      });
    } catch (e) {
      debugPrint('Error starting recording: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to start recording: $e')),
        );
      }
    }
  }

  Future<void> _stopRecording() async {
    try {
      await _audioRecorder.stopRecorder();
      _timer?.cancel();
      
      setState(() {
        _isRecording = false;
        _hasRecording = _audioPath != null && File(_audioPath!).existsSync();
      });
      
      // Verify file exists and has content
      if (_audioPath != null) {
        final file = File(_audioPath!);
        if (await file.exists()) {
          final fileSize = await file.length();
          debugPrint('Recording saved: $_audioPath (Size: $fileSize bytes)');
          
          if (fileSize == 0) {
            debugPrint('Warning: Recorded file is empty');
            setState(() {
              _hasRecording = false;
            });
          }
        } else {
          debugPrint('Error: Recording file does not exist');
          setState(() {
            _hasRecording = false;
          });
        }
      }
    } catch (e) {
      debugPrint('Error stopping recording: $e');
    }
  }

  Future<void> _playRecording() async {
    if (_audioPath != null) {
      try {
        debugPrint('Attempting to play: $_audioPath');
        
        // Verify file exists
        final file = File(_audioPath!);
        if (!await file.exists()) {
          debugPrint('Error: File does not exist');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Recording file not found')),
            );
          }
          return;
        }
        
        // Set audio source and play
        await _audioPlayer.setFilePath(_audioPath!);
        await _audioPlayer.play();
        
        debugPrint('Playback started successfully');
      } catch (e) {
        debugPrint('Error playing recording: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to play recording: $e')),
          );
        }
      }
    }
  }

  Future<void> _pausePlayback() async {
    await _audioPlayer.pause();
  }

  Future<void> _deleteRecording() async {
    if (_audioPath != null) {
      try {
        await _audioPlayer.stop();
        
        final file = File(_audioPath!);
        if (await file.exists()) {
          await file.delete();
          debugPrint('Recording deleted: $_audioPath');
        }
        
        setState(() {
          _audioPath = null;
          _hasRecording = false;
          _recordDuration = 0;
          _playbackPosition = Duration.zero;
          _totalDuration = Duration.zero;
        });
      } catch (e) {
        debugPrint('Error deleting recording: $e');
      }
    }
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
  
  String _formatDurationObj(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return BaseOnboardingStepScreen(
      title: 'Voice Intro',
      showBackButton: true,
      nextLabel: 'Save & Continue',
      onNext: () {
        if (!_hasRecording || _audioPath == null) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                title: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.orange[700],
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'No Voice Intro',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                content: const Text(
                  'You haven\'t recorded a voice intro yet. Would you like to skip this step?',
                  style: TextStyle(fontSize: 16),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Record', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      ref.read(onboardingProvider.notifier).skipStep('voice_intro');
                    },
                    child: Text('Skip', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey[600])),
                  ),
                ],
              );
            },
          );
          return;
        }

        // TODO: Upload audio file to backend
        debugPrint('Saving voice intro: $_audioPath');
        
        ref.read(onboardingProvider.notifier).completeStep('voice_intro');
      },
      showSkipButton: true,
      onSkip: () {
        ref.read(onboardingProvider.notifier).skipStep('voice_intro');
      },
      child: Column(
        children: [
          const Text(
            'Record a short intro',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 12),
          
          Text(
            'Let your personality shine through. Record a 30 seconds short intro.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 40),

          // Record/Stop Button
          GestureDetector(
            onTap: () {
              if (_isRecording) {
                _stopRecording();
              } else {
                _startRecording();
              }
            },
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _isRecording ? Colors.red : const Color(0xFF4A5A3E),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  _isRecording ? Icons.stop : Icons.mic,
                  size: 60,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Duration Display
          if (_isRecording || _hasRecording)
            Text(
              _isPlaying 
                  ? _formatDurationObj(_playbackPosition)
                  : _formatDuration(_recordDuration),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black87),
            ),
          if (_isRecording)
            Text(
              '${maxRecordingDuration - _recordDuration}s remaining',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          const SizedBox(height: 24),

          // Playback Controls
          if (_hasRecording && !_isRecording) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Play/Pause Button
                IconButton(
                  onPressed: () {
                    if (_isPlaying) {
                      _pausePlayback();
                    } else {
                      _playRecording();
                    }
                  },
                  icon: Icon(
                    _isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
                    size: 48,
                    color: const Color(0xFF4A5A3E),
                  ),
                ),
                const SizedBox(width: 16),
                // Re-record Button
                IconButton(
                  onPressed: _startRecording,
                  icon: const Icon(Icons.refresh, size: 32, color: Color(0xFF4A5A3E)),
                  tooltip: 'Re-record',
                ),
                const SizedBox(width: 16),
                // Delete Button
                IconButton(
                  onPressed: _deleteRecording,
                  icon: const Icon(Icons.delete_outline, size: 32, color: Colors.red),
                  tooltip: 'Delete',
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],

          const Spacer(),

          // Benefits List
          const Align(
            alignment: Alignment.centerLeft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _BenefitItem(text: '3x more matches in voice record'),
                SizedBox(height: 12),
                _BenefitItem(text: 'Start conversation naturally'),
                SizedBox(height: 12),
                _BenefitItem(text: 'Show your personality'),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _BenefitItem extends StatelessWidget {
  final String text;

  const _BenefitItem({required this.text});
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.black87,
          ),
        ),
        const SizedBox(width: 12),
        Text(text, style: const TextStyle(fontSize: 14, color: Colors.black87)),
      ],
    );
  }
}
