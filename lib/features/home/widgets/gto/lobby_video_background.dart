import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../../../core/theme/app_colors.dart';

class LobbyVideoBackground extends StatefulWidget {
  const LobbyVideoBackground({super.key});

  @override
  State<LobbyVideoBackground> createState() => _LobbyVideoBackgroundState();
}

class _LobbyVideoBackgroundState extends State<LobbyVideoBackground> {
  VideoPlayerController? _controller;
  bool _isError = false;
  int _loopCount = 0;
  final int _maxLoops = 7; // 3초 영상 * 7번 = 약 21초간 움직임 유지

  @override
  void initState() {
    super.initState();
    _initVideo();
  }

  void _videoListener() {
    if (_controller == null || !_controller!.value.isInitialized) return;

    final value = _controller!.value;
    // Check if video reached the end
    if (value.position >= value.duration && value.duration > Duration.zero && !value.isPlaying) {
      _loopCount++;
      if (_loopCount < _maxLoops) {
        _controller!.seekTo(Duration.zero).then((_) {
          _controller!.play();
        });
      } else {
        _controller!.removeListener(_videoListener);
      }
    }
  }

  Future<void> _initVideo() async {
    try {
      // User should put 'lobby_bg.mp4' in assets/videos/
      _controller = VideoPlayerController.asset(
        'assets/videos/lobby_bg.mp4',
        videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
      );
      await _controller!.initialize();
      _controller!.setVolume(0.0); // Muted background video
      _controller!.addListener(_videoListener);
      _controller!.play();
      if (mounted) {
        setState(() {}); // Update to show the video
      }
    } catch (e) {
      debugPrint("Video init failed: $e");
      if (mounted) {
        setState(() {
          _isError = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _controller?.removeListener(_videoListener);
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isError || _controller == null || !_controller!.value.isInitialized) {
      // Fallback background while loading or if missing
      return Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0F172A), Color(0xFF020617)], // Dark slate to near black
          ),
        ),
        child: _isError 
            ? const Center(
                child: Text(
                  "assets/videos/lobby_bg.mp4\n파일을 넣어주세요", 
                  style: TextStyle(color: Colors.white54),
                  textAlign: TextAlign.center,
                ),
              )
            : const SizedBox.shrink(),
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        // AspectRatio might not cover the whole screen, so we use SizedBox.expand with FittedBox
        SizedBox.expand(
          child: FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: _controller!.value.size.width,
              height: _controller!.value.size.height,
              child: VideoPlayer(_controller!),
            ),
          ),
        ),
        // Optional dark overlay to ensure UI text is readable
        Container(
          color: Colors.black.withOpacity(0.3),
        ),
      ],
    );
  }
}
