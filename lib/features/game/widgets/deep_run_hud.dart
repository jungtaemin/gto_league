import 'package:flutter/material.dart';

import 'package:holdem_allin_fold/core/theme/app_colors.dart';
import 'package:holdem_allin_fold/core/theme/app_shadows.dart';
import 'package:holdem_allin_fold/core/theme/app_text_styles.dart';

import 'neon_hearts_display.dart';

/// Top HUD assembly for the Deep Run mode.
///
/// Layout: [Status Badge LEFT] — [Hand Progress Bar CENTER] — [Hearts RIGHT]
class DeepRunHud extends StatelessWidget {
  final int strikesRemaining;

  /// Current hand number (1–100).
  final int totalHands;

  /// Current difficulty level (1–5).
  final int currentLevel;

  /// Table position abbreviation (e.g. "BU", "SB").
  final String position;

  /// Current big-blind level.
  final int bbLevel;

  const DeepRunHud({
    super.key,
    required this.strikesRemaining,
    required this.totalHands,
    required this.currentLevel,
    required this.position,
    required this.bbLevel,
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

          const SizedBox(width: 12),

          // ── Hearts (RIGHT) ──────────────────────────────────
          NeonHeartsDisplay(strikesRemaining: strikesRemaining),
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
class _StatusBadge extends StatelessWidget {
  final String position;
  final int bbLevel;
  final LevelTheme theme;

  const _StatusBadge({
    super.key,
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
class _HandProgressBar extends StatelessWidget {
  final int totalHands;
  final LevelTheme theme;

  const _HandProgressBar({
    super.key,
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
