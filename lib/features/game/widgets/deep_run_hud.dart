import 'package:flutter/material.dart';

import 'package:holdem_allin_fold/core/theme/app_colors.dart';
import 'package:holdem_allin_fold/core/theme/app_shadows.dart';
import 'package:holdem_allin_fold/core/theme/app_text_styles.dart';

import 'neon_hearts_display.dart';
import 'gto_hud_components.dart';

/// Top HUD assembly for the Deep Run mode.
///
/// Layout: [ScoreBadge LEFT] — [Combo CENTER] — [Hearts RIGHT]
class DeepRunHud extends StatelessWidget {
  final int strikesRemaining;

  /// Current score
  final int score;

  /// Current combo streak
  final int combo;

  /// Current difficulty level (1–5).
  final int currentLevel;

  /// Current big-blind level.
  final int bbLevel;

  /// Whether hard mode is active.
  final bool isHardMode;

  const DeepRunHud({
    super.key,
    required this.strikesRemaining,
    required this.score,
    required this.combo,
    required this.currentLevel,
    required this.bbLevel,
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

          const SizedBox(width: 12),

          // ── Hearts (RIGHT) ──────────────────────────────────
          NeonHeartsDisplay(strikesRemaining: strikesRemaining),
        ],
      ),
    );
  }
}
