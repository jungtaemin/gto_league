import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Manages haptic feedback for the game.
/// Provides different haptic patterns for various game events.
class HapticManager {
  /// Light selection click haptic feedback.
  /// Used for UI interactions like swiping.
  static Future<void> swipe() async {
    try {
      await HapticFeedback.selectionClick();
    } catch (e) {
      debugPrint('Error playing swipe haptic: $e');
    }
  }

  /// Light impact haptic feedback.
  /// Used for positive game events like correct decisions.
  static Future<void> correct() async {
    try {
      await HapticFeedback.lightImpact();
    } catch (e) {
      debugPrint('Error playing correct haptic: $e');
    }
  }

  /// Heavy impact haptic feedback.
  /// Used for negative game events like wrong decisions.
  static Future<void> wrong() async {
    try {
      await HapticFeedback.heavyImpact();
    } catch (e) {
      debugPrint('Error playing wrong haptic: $e');
    }
  }

  /// Medium impact haptic feedback.
  /// Used for snap/bonus events.
  static Future<void> snap() async {
    try {
      await HapticFeedback.mediumImpact();
    } catch (e) {
      debugPrint('Error playing snap haptic: $e');
    }
  }

  /// Heavy impact haptic feedback for timer warnings.
  /// Can be called repeatedly for urgent notifications.
  static Future<void> timerWarning() async {
    try {
      await HapticFeedback.heavyImpact();
    } catch (e) {
      debugPrint('Error playing timer warning haptic: $e');
    }
  }

  /// Crescendo haptic pattern for level-up events.
  /// Plays light → medium → heavy impacts with 100ms delays.
  /// Used during level-up cutscene between 20-hand blocks.
  static Future<void> levelUp() async {
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

  /// Impact + echo haptic pattern for heart loss events.
  /// Plays heavy impact followed by medium impact with 50ms delay.
  /// Used when a heart/life is lost (wrong answer).
  static Future<void> heartShatter() async {
    try {
      await HapticFeedback.heavyImpact();
      await Future.delayed(const Duration(milliseconds: 50));
      await HapticFeedback.mediumImpact();
    } catch (e) {
      debugPrint('Error playing heartShatter haptic: $e');
    }
  }

  /// Ominous triple thud haptic pattern for game over events.
  /// Plays three heavy impacts with 150ms delays between each.
  /// Used when all 3 strikes are used.
  static Future<void> gameOver() async {
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
