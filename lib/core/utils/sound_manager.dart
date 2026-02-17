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
/// Preloads all sounds at app start and maintains a single AudioPlayer per sound type.
class SoundManager {
  static final Map<SoundType, AudioPlayer> _players = {};

  /// Preloads all sound effects into memory.
  /// Call this once at app initialization.
  static Future<void> preloadAll() async {
    for (var type in SoundType.values) {
      _players[type] = AudioPlayer();
      try {
        await _players[type]!
            .setSource(AssetSource('sounds/${type.name}.wav'));
        await _players[type]!.setReleaseMode(ReleaseMode.stop);
      } catch (e) {
        debugPrint('Error preloading sound ${type.name}: $e');
      }
    }
  }

  /// Plays a sound effect by type.
  /// Uses resume() to play from the beginning.
  static Future<void> play(SoundType type) async {
    try {
      final player = _players[type];
      if (player != null) {
        await player.seek(Duration.zero);
        await player.resume();
      }
    } catch (e) {
      debugPrint('Error playing sound ${type.name}: $e');
    }
  }

  /// Disposes all audio players and cleans up resources.
  /// Call this when the app is shutting down.
  static void dispose() {
    for (var player in _players.values) {
      player.dispose();
    }
    _players.clear();
  }
}
