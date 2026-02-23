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
/// Uses AudioContext with no audio focus to avoid stealing from BGM.
class SoundManager {
  static bool _initialized = false;
  static final Map<SoundType, AudioPlayer> _players = {};

  /// Audio context that doesn't steal focus from BGM
  static final _sfxContext = AudioContext(
    android: AudioContextAndroid(
      isSpeakerphoneOn: false,
      audioMode: AndroidAudioMode.normal,
      stayAwake: false,
      contentType: AndroidContentType.sonification,
      usageType: AndroidUsageType.game,
      audioFocus: AndroidAudioFocus.none, // Don't steal BGM focus!
    ),
    iOS: AudioContextIOS(
      category: AVAudioSessionCategory.playback,
      options: {AVAudioSessionOptions.mixWithOthers},
    ),
  );

  /// Initialize the sound manager and preload all sounds.
  static Future<void> preloadAll() async {
    try {
      for (final type in SoundType.values) {
        try {
          final player = AudioPlayer();
          await player.setAudioContext(_sfxContext);
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
    if (!_initialized) return;
    
    try {
      final player = _players[type];
      if (player != null) {
        await player.stop();
        await player.seek(Duration.zero);
        await player.resume();
      } else {
        // Fallback: create new player
        final p = AudioPlayer();
        await p.setAudioContext(_sfxContext);
        await p.setVolume(1.0);
        await p.play(AssetSource('sounds/${type.name}.wav'));
        p.onPlayerComplete.listen((_) => p.dispose());
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
