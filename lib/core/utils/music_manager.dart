import 'package:flutter/foundation.dart';
import 'package:audioplayers/audioplayers.dart';

enum MusicType {
  lobby,
  game,
}

/// Manages background music (BGM) for the game.
/// Handles looping, fading, and switching tracks.
class MusicManager {
  static final AudioPlayer _player = AudioPlayer();
  static bool _initialized = false;
  static MusicType? _currentType;
  
  // Volume settings
  static const double _defaultVolume = 0.4;
  static const Duration _fadeDuration = Duration(milliseconds: 800);

  /// Initialize the music manager.
  static Future<void> init() async {
    try {
      await _player.setReleaseMode(ReleaseMode.loop); // Loop BGM
      await _player.setPlayerMode(PlayerMode.mediaPlayer);
      _initialized = true;
      debugPrint('🎵 MusicManager initialized');
    } catch (e) {
      debugPrint('🔇 MusicManager init error: $e');
    }
  }

  /// Play background music by type.
  /// If the same music is already playing, does nothing.
  /// If new music, fades out current and fades in new.
  static Future<void> play(MusicType type) async {
    if (!_initialized) return;
    
    // If already playing this type, do nothing
    if (_currentType == type && _player.state == PlayerState.playing) {
      return;
    }

    try {
      _currentType = type;
      final assetPath = 'music/${type == MusicType.lobby ? 'lobby_bgm' : 'game_bgm'}.mp3';
      
      debugPrint('🎵 Switching BGM to $assetPath');

      // Fade out current if playing
      if (_player.state == PlayerState.playing) {
        await _player.setVolume(0.0); // Simple cut for now, or implement fade out
        await _player.stop();
      }

      // Play new track
      await _player.setSource(AssetSource(assetPath));
      await _player.setVolume(_defaultVolume); // Restore volume
      await _player.resume();
      
    } catch (e) {
      debugPrint('🔇 Error playing music ${type.name}: $e');
    }
  }

  /// Stop music (with optional fade out).
  static Future<void> stop() async {
    if (!_initialized) return;
    try {
      _currentType = null;
      await _player.stop();
      debugPrint('🎵 Music stopped');
    } catch (e) {
      debugPrint('🔇 Error stopping music: $e');
    }
  }
  
  /// Pause music (e.g. app background).
  static Future<void> pause() async {
    if (!_initialized) return;
    if (_player.state == PlayerState.playing) {
      await _player.pause();
    }
  }

  /// Resume music (e.g. app foreground).
  static Future<void> resume() async {
    if (!_initialized) return;
    if (_currentType != null && _player.state == PlayerState.paused) {
      await _player.resume();
    }
  }

  static void dispose() {
    _player.dispose();
    _initialized = false;
  }
}
