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

  // ── Volume & Mute ──────────────────────────────────
  static double _volume = 1.0;
  static bool _enabled = true;

  /// Current SFX volume (0.0 – 1.0).
  static double get volume => _volume;

  /// Whether SFX is enabled.
  static bool get enabled => _enabled;

  /// Set SFX volume — applied to all preloaded players.
  static Future<void> setVolume(double v) async {
    _volume = v.clamp(0.0, 1.0);
    for (final player in _players.values) {
      try {
        await player.setVolume(_volume);
      } catch (_) {}
    }
  }

  /// Enable or disable SFX globally.
  static void setEnabled(bool value) {
    _enabled = value;
  }

  /// Audio context that doesn't steal focus from BGM
  static final _sfxContext = AudioContext(
    android: AudioContextAndroid(
      isSpeakerphoneOn: false,
      audioMode: AndroidAudioMode.normal,
      stayAwake: false,
      contentType: AndroidContentType.sonification,
      usageType: AndroidUsageType.game,
      audioFocus: AndroidAudioFocus.none,
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
          await player.setVolume(_volume);
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
    if (!_initialized || !_enabled || _volume <= 0) return;
    
    try {
      final player = _players[type];
      if (player != null) {
        try { await player.setVolume(_volume); } catch (_) {}
        // Avoid calling stop() which triggers prepareAsync in bad state
        try { await player.seek(Duration.zero); } catch (_) {}
        try { await player.resume(); } catch (_) {}
      } else {
        final p = AudioPlayer();
        await p.setAudioContext(_sfxContext);
        await p.setVolume(_volume);
        await p.play(AssetSource('sounds/${type.name}.wav'));
        p.onPlayerComplete.listen((_) {
          try { p.dispose(); } catch (_) {}
        });
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
