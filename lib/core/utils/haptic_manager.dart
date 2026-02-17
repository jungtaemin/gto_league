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
}
