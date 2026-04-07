import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

class VoicePlaybackWidget extends StatefulWidget {
  final String url;
  final int? durationSeconds;
  final Color? waveColor;
  final Color? progressColor;
  final double height;

  const VoicePlaybackWidget({
    super.key,
    required this.url,
    this.durationSeconds,
    this.waveColor,
    this.progressColor,
    this.height = 40,
  });

  @override
  State<VoicePlaybackWidget> createState() => _VoicePlaybackWidgetState();
}

class _VoicePlaybackWidgetState extends State<VoicePlaybackWidget> {
  late AudioPlayer _audioPlayer;
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    
    if (widget.durationSeconds != null) {
      _duration = Duration(seconds: widget.durationSeconds!);
    }

    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state == PlayerState.playing;
        });
      }
    });

    _audioPlayer.onDurationChanged.listen((d) {
      if (mounted) {
        setState(() {
          _duration = d;
        });
      }
    });

    _audioPlayer.onPositionChanged.listen((p) {
      if (mounted) {
        setState(() {
          _position = p;
        });
      }
    });

    _audioPlayer.onPlayerComplete.listen((event) {
      if (mounted) {
        setState(() {
          _isPlaying = false;
          _position = Duration.zero;
        });
      }
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _togglePlayback() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      if (_position == Duration.zero) {
        await _audioPlayer.play(UrlSource(widget.url));
      } else {
        await _audioPlayer.resume();
      }
    }
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes.toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = widget.progressColor ?? theme.colorScheme.primary;
    final secondaryColor = widget.waveColor ?? theme.colorScheme.surfaceContainerHighest;

    double progress = 0.0;
    if (_duration.inMilliseconds > 0) {
      progress = _position.inMilliseconds / _duration.inMilliseconds;
    }

    return Container(
      height: widget.height + 20,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: _togglePlayback,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: primaryColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                _isPlaying ? Icons.pause : Icons.play_arrow,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  children: [
                    // Waveform background (Simulated with simple bars)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(40, (index) {
                        return Container(
                          width: 2,
                          height: (index % 5 == 0 ? 15 : 10) + (index % 3 == 0 ? 5 : 0),
                          decoration: BoxDecoration(
                            color: secondaryColor,
                            borderRadius: BorderRadius.circular(1),
                          ),
                        );
                      }),
                    ),
                    // Progress Overlay
                    ClipRect(
                      clipper: _WaveClipper(progress),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(40, (index) {
                          return Container(
                            width: 2,
                            height: (index % 5 == 0 ? 15 : 10) + (index % 3 == 0 ? 5 : 0),
                            decoration: BoxDecoration(
                              color: primaryColor,
                              borderRadius: BorderRadius.circular(1),
                            ),
                          );
                        }),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatDuration(_position),
                      style: TextStyle(fontSize: 10, color: theme.colorScheme.onSurfaceVariant),
                    ),
                    Text(
                      _formatDuration(_duration),
                      style: TextStyle(fontSize: 10, color: theme.colorScheme.onSurfaceVariant),
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
}

class _WaveClipper extends CustomClipper<Rect> {
  final double progress;
  _WaveClipper(this.progress);

  @override
  Rect getClip(Size size) {
    return Rect.fromLTWH(0, 0, size.width * progress, size.height);
  }

  @override
  bool shouldReclip(_WaveClipper oldClipper) => oldClipper.progress != progress;
}
