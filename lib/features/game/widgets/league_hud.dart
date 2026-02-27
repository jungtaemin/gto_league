import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:holdem_allin_fold/core/theme/app_colors.dart';
import 'package:holdem_allin_fold/core/theme/app_shadows.dart';
import 'package:holdem_allin_fold/core/theme/app_text_styles.dart';

import 'time_chip_button.dart';
import 'gto_hud_components.dart';

/// Top HUD assembly for the League Survival mode.
///
/// Layout: [ScoreBadge LEFT] — [Combo CENTER] — [TimeChip + Heart RIGHT]
///
/// Forked from [DeepRunHud] with key differences:
/// - Single heart display instead of 3-heart NeonHeartsDisplay
/// - Time chip button for manual +15s activation
class LeagueHud extends StatelessWidget {
  /// Remaining strikes (0 or 1 in League mode).
  final int strikesRemaining;

  /// Current score
  final int score;

  /// Current combo streak
  final int combo;

  /// Current difficulty level (1–5).
  final int currentLevel;

  /// Current big-blind level.
  final int bbLevel;

  /// Remaining time chips (0–3).
  final int timeChipsRemaining;

  /// Whether the countdown timer is in the critical phase.
  final bool isTimerCritical;

  /// Called when the player taps the time chip button.
  final VoidCallback onUseTimeChip;

  /// Whether hard mode is active.
  final bool isHardMode;

  const LeagueHud({
    super.key,
    required this.strikesRemaining,
    required this.score,
    required this.combo,
    required this.currentLevel,
    required this.bbLevel,
    required this.timeChipsRemaining,
    required this.isTimerCritical,
    required this.onUseTimeChip,
    this.isHardMode = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = isHardMode
        ? AppColors.getHardModeLevelTheme(currentLevel)
        : AppColors.getLevelTheme(currentLevel);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ── Score Badge (LEFT) ─────────────────────────────
          AnimatedScoreBadge(
            score: score,
            theme: theme,
            isHardMode: isHardMode,
          ),

          const SizedBox(width: 12),

          // ── Combo Display (CENTER) ───────────────────────────
          Expanded(
            child: ComboDisplay(
              combo: combo,
              theme: theme,
            ),
          ),

          const SizedBox(width: 8),

          // ── Time Chip + Heart (RIGHT) ───────────────────────
          TimeChipButton(
            chipsRemaining: timeChipsRemaining,
            onUseChip: onUseTimeChip,
            isTimerCritical: isTimerCritical,
          ),

          const SizedBox(width: 6),

          _SingleNeonHeart(isAlive: strikesRemaining > 0),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// Private sub-widgets
// ═══════════════════════════════════════════════════════════════════

/// Single neon heart for the League 1-life system.
///
/// Active: bright red heart with neon glow and idle pulse (1500ms loop).
/// Lost: dark broken heart icon — game over.
class _SingleNeonHeart extends StatelessWidget {
  /// Whether the player is still alive.
  final bool isAlive;

  const _SingleNeonHeart({required this.isAlive});

  @override
  Widget build(BuildContext context) {
    if (!isAlive) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 3),
        child: Icon(
          Icons.heart_broken,
          color: AppColors.pureWhite.withOpacity(0.15),
          size: 24,
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: Icon(
        Icons.favorite,
        color: AppColors.laserRed,
        size: 24,
        shadows: AppColors.neonGlow(AppColors.laserRed),
      ),
    )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .scaleXY(
          begin: 1.0,
          end: 1.12,
          duration: 1500.ms,
          curve: Curves.easeInOut,
        );
  }
}
