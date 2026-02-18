import 'package:flutter/foundation.dart';
import 'package:audioplayers/audioplayers.dart';

enum SoundType {
  heartbeat,
  timerTick,
  timerWarning,
  chipStack,
  snap,
  correct,
  wrong,
  gameOver,
  slotMachine,
  levelUp,
}

/// Manages sound effects for the game using audioplayers package.
/// Uses a simple play-per-call approach for maximum reliability.
class SoundManager {
  static final AudioPlayer _player = AudioPlayer();
  static bool _initialized = false;

  /// Initialize the sound manager.
  /// Call this once at app initialization.
  static Future<void> preloadAll() async {
    try {
      // Set player mode to low latency for sound effects
      await _player.setPlayerMode(PlayerMode.lowLatency);
      _initialized = true;
      debugPrint('🔊 SoundManager initialized successfully');
    } catch (e) {
      debugPrint('🔇 SoundManager init error: $e');
    }
  }

  /// Plays a sound effect by type.
  /// Creates a fresh play call each time for reliability.
  static Future<void> play(SoundType type) async {
    if (!_initialized) {
      debugPrint('🔇 SoundManager not initialized, skipping ${type.name}');
      return;
    }
    try {
      debugPrint('🔊 Playing sound: ${type.name}');
      await _player.stop();
      await _player.play(AssetSource('sounds/${type.name}.wav'));
    } catch (e) {
      debugPrint('🔇 Error playing sound ${type.name}: $e');
    }
  }

  /// Disposes all audio players and cleans up resources.
  static void dispose() {
    _player.dispose();
    _initialized = false;
  }
}
