import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path/path.dart' as path;

class AudioPlayerWidget extends StatefulWidget {
  final String filePath;

  const AudioPlayerWidget({
    super.key,
    required this.filePath,
  });

  @override
  State<AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isAudioPlaying = false;
  Duration? _audioDuration;
  Duration _audioPosition = Duration.zero;
  String? _errorMessage;
  double _playbackSpeed = 1.0;
  bool _isLooping = false;
  double _volume = 1.0;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    try {
      await _audioPlayer.setFilePath(widget.filePath);
      _audioDuration = _audioPlayer.duration;

      _audioPlayer.positionStream.listen((position) {
        if (mounted) {
          setState(() {
            _audioPosition = position;
          });
        }
      });

      _audioPlayer.playerStateStream.listen((state) {
        if (mounted) {
          setState(() {
            _isAudioPlaying = state.playing;

            // Handle completion - reset to beginning instead of showing error
            if (state.processingState == ProcessingState.completed &&
                !_isLooping) {
              _audioPlayer.seek(Duration.zero);
              _audioPlayer.pause();
            }
          });
        }
      });

      // Set up looping listener
      _audioPlayer.loopModeStream.listen((loopMode) {
        if (mounted) {
          setState(() {
            _isLooping = loopMode == LoopMode.one;
          });
        }
      });

      setState(() {});
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
        });
      }
    }
  }

  void _toggleLoop() {
    final newLoopMode = _isLooping ? LoopMode.off : LoopMode.one;
    _audioPlayer.setLoopMode(newLoopMode);
    setState(() {
      _isLooping = !_isLooping;
    });
  }

  void _setPlaybackSpeed(double speed) {
    _audioPlayer.setSpeed(speed);
    setState(() {
      _playbackSpeed = speed;
    });
  }

  void _setVolume(double volume) {
    _audioPlayer.setVolume(volume);
    setState(() {
      _volume = volume;
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return hours == '00' ? '$minutes:$seconds' : '$hours:$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Error loading audio:',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(color: Colors.red),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              onPressed: _initializePlayer,
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue.shade900,
            Colors.blue.shade800,
            Colors.blue.shade700,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Waveform visual representation (simulated)
          Container(
            height: 80,
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(
                40,
                (index) {
                  final double barHeight = (index % 3 == 0)
                      ? 40.0
                      : (index % 2 == 0)
                          ? 25.0
                          : 15.0;

                  // Change color of bars based on current position
                  final bool isActive = index / 40 <
                      _audioPosition.inMilliseconds /
                          (_audioDuration?.inMilliseconds ?? 1);

                  return Container(
                    width: 3,
                    height: barHeight,
                    decoration: BoxDecoration(
                      color: isActive
                          ? Colors.white
                          : Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  );
                },
              ),
            ),
          ),

          const SizedBox(height: 16),

          // File name with nicer styling
          Text(
            path.basename(widget.filePath),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [
                Shadow(
                  blurRadius: 4,
                  color: Colors.black26,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 24),

          // Playback controls
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Play/Pause button with animation
              GestureDetector(
                onTap: () {
                  if (_isAudioPlaying) {
                    _audioPlayer.pause();
                  } else {
                    _audioPlayer.play();
                  }
                },
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        spreadRadius: 1,
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    _isAudioPlaying ? Icons.pause : Icons.play_arrow,
                    size: 40,
                    color: Colors.blue.shade900,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Progress slider with improved styling
          if (_audioDuration != null)
            SliderTheme(
              data: SliderThemeData(
                trackHeight: 4,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
                activeTrackColor: Colors.white,
                inactiveTrackColor: Colors.white.withOpacity(0.3),
                thumbColor: Colors.white,
                overlayColor: Colors.white.withOpacity(0.2),
              ),
              child: Slider(
                value: _audioPosition.inMilliseconds.toDouble(),
                max: _audioDuration!.inMilliseconds.toDouble(),
                onChanged: (value) {
                  _audioPlayer.seek(Duration(milliseconds: value.toInt()));
                },
              ),
            ),

          // Time indicators
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDuration(_audioPosition),
                  style: const TextStyle(color: Colors.white70),
                ),
                Text(
                  _formatDuration(_audioDuration ?? Duration.zero),
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Additional controls in a row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Volume control
              Row(
                children: [
                  IconButton(
                    icon: Icon(
                      _volume > 0 ? Icons.volume_up : Icons.volume_off,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      _setVolume(_volume > 0 ? 0 : 1);
                    },
                    tooltip: 'Toggle mute',
                  ),
                  SizedBox(
                    width: 80,
                    child: SliderTheme(
                      data: SliderThemeData(
                        trackHeight: 2,
                        thumbShape:
                            const RoundSliderThumbShape(enabledThumbRadius: 6),
                        overlayShape:
                            const RoundSliderOverlayShape(overlayRadius: 12),
                        activeTrackColor: Colors.white,
                        inactiveTrackColor: Colors.white.withOpacity(0.3),
                        thumbColor: Colors.white,
                      ),
                      child: Slider(
                        value: _volume,
                        max: 1.0,
                        onChanged: _setVolume,
                      ),
                    ),
                  ),
                ],
              ),

              // Loop toggle button
              IconButton(
                icon: Icon(
                  Icons.repeat,
                  color:
                      _isLooping ? Colors.white : Colors.white.withOpacity(0.5),
                ),
                onPressed: _toggleLoop,
                tooltip: 'Toggle loop',
              ),

              // Playback speed
              PopupMenuButton<double>(
                initialValue: _playbackSpeed,
                tooltip: 'Playback speed',
                onSelected: _setPlaybackSpeed,
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 0.5,
                    child: Text('0.5x'),
                  ),
                  const PopupMenuItem(
                    value: 0.75,
                    child: Text('0.75x'),
                  ),
                  const PopupMenuItem(
                    value: 1.0,
                    child: Text('1.0x'),
                  ),
                  const PopupMenuItem(
                    value: 1.25,
                    child: Text('1.25x'),
                  ),
                  const PopupMenuItem(
                    value: 1.5,
                    child: Text('1.5x'),
                  ),
                  const PopupMenuItem(
                    value: 2.0,
                    child: Text('2.0x'),
                  ),
                ],
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    children: [
                      Icon(
                        Icons.speed,
                        color: Colors.white.withOpacity(0.9),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${_playbackSpeed}x',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
