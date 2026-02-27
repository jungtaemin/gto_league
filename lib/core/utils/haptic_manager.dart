import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Manages haptic feedback for the game.
/// Provides different haptic patterns for various game events.
class HapticManager {
  // ── Enable / Disable ──────────────────────────────
  static bool _enabled = true;

  /// Whether haptic feedback is enabled.
  static bool get enabled => _enabled;

  /// Enable or disable haptic feedback globally.
  static void setEnabled(bool value) {
    _enabled = value;
    debugPrint('📳 Haptic ${value ? "enabled" : "disabled"}');
  }

  /// Light selection click haptic feedback.
  static Future<void> swipe() async {
    if (!_enabled) return;
    try {
      await HapticFeedback.selectionClick();
    } catch (e) {
      debugPrint('Error playing swipe haptic: $e');
    }
  }

  /// Light impact haptic feedback — correct decisions.
  static Future<void> correct() async {
    if (!_enabled) return;
    try {
      await HapticFeedback.lightImpact();
    } catch (e) {
      debugPrint('Error playing correct haptic: $e');
    }
  }

  /// Heavy impact haptic feedback — wrong decisions.
  static Future<void> wrong() async {
    if (!_enabled) return;
    try {
      await HapticFeedback.heavyImpact();
    } catch (e) {
      debugPrint('Error playing wrong haptic: $e');
    }
  }

  /// Medium impact haptic feedback — snap/bonus.
  static Future<void> snap() async {
    if (!_enabled) return;
    try {
      await HapticFeedback.mediumImpact();
    } catch (e) {
      debugPrint('Error playing snap haptic: $e');
    }
  }

  /// Heavy impact haptic feedback for timer warnings.
  static Future<void> timerWarning() async {
    if (!_enabled) return;
    try {
      await HapticFeedback.heavyImpact();
    } catch (e) {
      debugPrint('Error playing timer warning haptic: $e');
    }
  }

  /// Crescendo haptic pattern for level-up events.
  static Future<void> levelUp() async {
    if (!_enabled) return;
    try {
      await HapticFeedback.lightImpact();
      await Future.delayed(const Duration(milliseconds: 100));
      await HapticFeedback.mediumImpact();
      await Future.delayed(const Duration(milliseconds: 100));
      await HapticFeedback.heavyImpact();
    } catch (e) {
      debugPrint('Error playing levelUp haptic: $e');
    }
  }

  /// Impact + echo haptic pattern for heart loss.
  static Future<void> heartShatter() async {
    if (!_enabled) return;
    try {
      await HapticFeedback.heavyImpact();
      await Future.delayed(const Duration(milliseconds: 50));
      await HapticFeedback.mediumImpact();
    } catch (e) {
      debugPrint('Error playing heartShatter haptic: $e');
    }
  }

  /// Ominous triple thud for game over.
  static Future<void> gameOver() async {
    if (!_enabled) return;
    try {
      await HapticFeedback.heavyImpact();
      await Future.delayed(const Duration(milliseconds: 150));
      await HapticFeedback.heavyImpact();
      await Future.delayed(const Duration(milliseconds: 150));
      await HapticFeedback.heavyImpact();
    } catch (e) {
      debugPrint('Error playing gameOver haptic: $e');
    }
  }
}
