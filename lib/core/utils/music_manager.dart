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
  static MusicType? _pendingType; // Track pending play requests
  static bool _isTransitioning = false; // Prevent race conditions
  
  // Volume settings
  static const double _defaultVolume = 0.4;

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
  /// If the same music is already playing, ensures it keeps playing.
  /// If different music, switches to the new track.
  static Future<void> play(MusicType type) async {
    if (!_initialized) return;
    
    // If already playing this exact type and actually in playing state, skip
    if (_currentType == type && _player.state == PlayerState.playing) {
      debugPrint('🎵 BGM already playing: ${type.name}');
      return;
    }

    // If a transition is already in progress, just record what we want
    if (_isTransitioning) {
      _pendingType = type;
      debugPrint('🎵 BGM transition queued: ${type.name}');
      return;
    }

    await _doPlay(type);
  }

  /// Internal play logic with transition guard.
  static Future<void> _doPlay(MusicType type) async {
    _isTransitioning = true;
    _pendingType = null;

    try {
      _currentType = type;
      final assetPath = 'music/${type == MusicType.lobby ? 'lobby_bgm' : 'game_bgm'}.mp3';
      
      debugPrint('🎵 Switching BGM to $assetPath');

      // Stop current if playing
      if (_player.state == PlayerState.playing || _player.state == PlayerState.paused) {
        await _player.stop();
      }

      // Play new track
      await _player.setSource(AssetSource(assetPath));
      await _player.setVolume(_defaultVolume);
      await _player.resume();
      
      debugPrint('🎵 BGM now playing: ${type.name}');
    } catch (e) {
      debugPrint('🔇 Error playing music ${type.name}: $e');
    } finally {
      _isTransitioning = false;
    }

    // If another type was requested during transition, play it now
    if (_pendingType != null && _pendingType != _currentType) {
      final pending = _pendingType!;
      _pendingType = null;
      await _doPlay(pending);
    }
  }

  /// Ensure the music is playing (call on screen resume/rebuild).
  /// Re-starts the current type if the player stopped unexpectedly.
  static Future<void> ensurePlaying(MusicType type) async {
    if (!_initialized) return;

    if (_player.state == PlayerState.playing && _currentType == type) {
      return; // Already fine
    }

    // Force replay — reset currentType to bypass the duplicate check
    _currentType = null;
    await play(type);
  }

  /// Stop music.
  static Future<void> stop() async {
    if (!_initialized) return;
    try {
      _currentType = null;
      _pendingType = null;
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
