import 'package:flutter/foundation.dart';
import 'package:audioplayers/audioplayers.dart';

enum MusicType {
  lobby,
  game,
}

/// Manages background music (BGM) for the game.
/// Handles looping, switching tracks, and lifecycle resilience.
class MusicManager {
  static final AudioPlayer _player = AudioPlayer();
  static bool _initialized = false;
  static MusicType? _currentType;
  static MusicType? _pendingType;
  static bool _isTransitioning = false;
  
  // ── Volume & Mute ──────────────────────────────────
  static double _volume = 0.4;

  /// Current BGM volume (0.0 – 1.0).
  static double get volume => _volume;

  /// Set BGM volume and immediately apply.
  static Future<void> setVolume(double v) async {
    _volume = v.clamp(0.0, 1.0);
    try {
      await _player.setVolume(_volume);
    } catch (e) {
      debugPrint('🔇 Error setting BGM volume: $e');
    }
  }

  /// Initialize the music manager.
  static Future<void> init() async {
    try {
      await _player.setReleaseMode(ReleaseMode.loop);
      await _player.setPlayerMode(PlayerMode.mediaPlayer);
      _initialized = true;
      debugPrint('🎵 MusicManager initialized');
    } catch (e) {
      debugPrint('🔇 MusicManager init error: $e');
    }
  }

  /// Play background music by type.
  static Future<void> play(MusicType type) async {
    if (!_initialized) return;
    
    if (_currentType == type && _player.state == PlayerState.playing) {
      return;
    }

    if (_isTransitioning) {
      _pendingType = type;
      return;
    }

    await _doPlay(type);
  }

  static Future<void> _doPlay(MusicType type) async {
    _isTransitioning = true;
    _pendingType = null;

    try {
      _currentType = type;
      final assetPath = 'music/${type == MusicType.lobby ? 'lobby_bgm' : 'game_bgm'}.mp3';
      
      debugPrint('🎵 Switching BGM to $assetPath');

      if (_player.state == PlayerState.playing || _player.state == PlayerState.paused) {
        await _player.stop();
      }

      await _player.setSource(AssetSource(assetPath));
      await _player.setVolume(_volume);
      await _player.resume();
      
      debugPrint('🎵 BGM now playing: ${type.name} at volume $_volume');
    } catch (e) {
      debugPrint('🔇 Error playing music ${type.name}: $e');
    } finally {
      _isTransitioning = false;
    }

    if (_pendingType != null && _pendingType != _currentType) {
      final pending = _pendingType!;
      _pendingType = null;
      await _doPlay(pending);
    }
  }

  static Future<void> ensurePlaying(MusicType type) async {
    if (!_initialized) return;
    if (_player.state == PlayerState.playing && _currentType == type) {
      return;
    }
    _currentType = null;
    await play(type);
  }

  static Future<void> stop() async {
    if (!_initialized) return;
    try {
      _currentType = null;
      _pendingType = null;
      await _player.stop();
    } catch (e) {
      debugPrint('🔇 Error stopping music: $e');
    }
  }
  
  static Future<void> pause() async {
    if (!_initialized) return;
    if (_player.state == PlayerState.playing) {
      await _player.pause();
    }
  }

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
