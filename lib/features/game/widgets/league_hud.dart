import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:holdem_allin_fold/core/theme/app_colors.dart';
import 'package:holdem_allin_fold/core/theme/app_shadows.dart';
import 'package:holdem_allin_fold/core/theme/app_text_styles.dart';

import 'time_chip_button.dart';

/// Top HUD assembly for the League Survival mode.
///
/// Layout: [Status Badge LEFT] — [Hand Progress Bar CENTER] — [TimeChip + Heart RIGHT]
///
/// Forked from [DeepRunHud] with key differences:
/// - Single heart display instead of 3-heart NeonHeartsDisplay
/// - Time chip button for manual +15s activation
class LeagueHud extends StatelessWidget {
  /// Remaining strikes (0 or 1 in League mode).
  final int strikesRemaining;

  /// Current hand number (1–100).
  final int totalHands;

  /// Current difficulty level (1–5).
  final int currentLevel;

  /// Table position abbreviation (e.g. "BU", "SB").
  final String position;

  /// Current big-blind level.
  final int bbLevel;

  /// Remaining time chips (0–3).
  final int timeChipsRemaining;

  /// Whether the countdown timer is in the critical phase.
  final bool isTimerCritical;

  /// Called when the player taps the time chip button.
  final VoidCallback onUseTimeChip;

  const LeagueHud({
    super.key,
    required this.strikesRemaining,
    required this.totalHands,
    required this.currentLevel,
    required this.position,
    required this.bbLevel,
    required this.timeChipsRemaining,
    required this.isTimerCritical,
    required this.onUseTimeChip,
  });

  @override
  Widget build(BuildContext context) {
    final theme = AppColors.getLevelTheme(currentLevel);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ── Status Badge (LEFT) ─────────────────────────────
          _StatusBadge(
            position: position,
            bbLevel: bbLevel,
            theme: theme,
          ),

          const SizedBox(width: 12),

          // ── Progress Bar (CENTER) ───────────────────────────
          Expanded(
            child: _HandProgressBar(
              totalHands: totalHands,
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

/// Compact cyberpunk badge showing position and BB level.
///
/// Neo-Brutalist card with 2px border and hard shadow.
/// Copied from DeepRunHud._StatusBadge.
class _StatusBadge extends StatelessWidget {
  final String position;
  final int bbLevel;
  final LevelTheme theme;

  const _StatusBadge({
    required this.position,
    required this.bbLevel,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.darkGray,
        border: Border.all(color: AppColors.pureBlack, width: 2),
        borderRadius: BorderRadius.circular(6),
        boxShadow: AppShadows.hardShadowTiny,
      ),
      child: Text(
        '$position | ${bbLevel}BB',
        style: AppTextStyles.tier(color: theme.accent),
      ),
    );
  }
}

/// Thin animated progress bar with "Hand: X / 100" label above.
/// Copied from DeepRunHud._HandProgressBar.
class _HandProgressBar extends StatelessWidget {
  final int totalHands;
  final LevelTheme theme;

  const _HandProgressBar({
    required this.totalHands,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final progress = (totalHands / 100.0).clamp(0.0, 1.0);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Label ─────────────────────────────────────────────
        Text(
          'Hand: $totalHands / 100',
          style: AppTextStyles.caption(color: theme.textPrimary),
        ),

        const SizedBox(height: 4),

        // ── Thin progress bar (8px) ───────────────────────────
        Container(
          height: 8,
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            color: AppColors.darkGray,
            border: Border.all(color: AppColors.pureBlack, width: 2),
            borderRadius: BorderRadius.circular(4),
          ),
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: progress),
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: value.clamp(0.001, 1.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.progressBarColor,
                    boxShadow: [
                      BoxShadow(
                        color: theme.progressBarColor.withOpacity(0.6),
                        blurRadius: 6,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

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
