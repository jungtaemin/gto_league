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
/// Uses preloaded AudioPlayer pool with explicit AudioCache configuration.
class SoundManager {
  static bool _initialized = false;
  static final Map<SoundType, AudioPlayer> _players = {};

  /// Initialize the sound manager and preload all sounds.
  static Future<void> preloadAll() async {
    try {
      // Ensure the global AudioCache prefix is correct
      // By default, AssetSource in audioplayers v6+ looks in 'assets/'
      
      for (final type in SoundType.values) {
        try {
          final player = AudioPlayer();
          await player.setReleaseMode(ReleaseMode.stop);
          await player.setVolume(1.0);
          await player.setSource(AssetSource('sounds/${type.name}.wav'));
          _players[type] = player;
          debugPrint('🔊 Preloaded: ${type.name}');
        } catch (e) {
          debugPrint('🔇 Failed to preload ${type.name}: $e');
        }
      }
      
      _initialized = true;
      debugPrint('🔊 SoundManager initialized with ${_players.length} sounds');
    } catch (e) {
      debugPrint('🔇 SoundManager init error: $e');
      _initialized = true;
    }
  }

  /// Plays a sound effect by type.
  static Future<void> play(SoundType type) async {
    if (!_initialized) {
      debugPrint('🔇 SoundManager not initialized');
      return;
    }
    
    try {
      final player = _players[type];
      if (player != null) {
        // Preloaded player: seek to beginning and resume
        await player.stop();
        await player.seek(Duration.zero);
        await player.resume();
        debugPrint('🔊 Playing (preloaded): ${type.name}');
      } else {
        // Fallback: create new player
        final p = AudioPlayer();
        await p.setVolume(1.0);
        await p.play(AssetSource('sounds/${type.name}.wav'));
        p.onPlayerComplete.listen((_) => p.dispose());
        debugPrint('🔊 Playing (new): ${type.name}');
      }
    } catch (e) {
      debugPrint('🔇 Error playing ${type.name}: $e');
    }
  }

  /// Dispose all players.
  static void dispose() {
    for (final player in _players.values) {
      try { player.dispose(); } catch (_) {}
    }
    _players.clear();
    _initialized = false;
  }
}
