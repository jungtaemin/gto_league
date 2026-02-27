import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/responsive.dart';

/// ── Score Badge (Left HUD) ─────────────────────────────────────
/// Cyberpunk-style pill with neon border glow and bounce animation
/// whenever score value changes.
class AnimatedScoreBadge extends StatelessWidget {
  final int score;
  final LevelTheme theme;
  final bool isHardMode;

  const AnimatedScoreBadge({
    super.key,
    required this.score,
    required this.theme,
    this.isHardMode = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.w(12),
        vertical: context.h(6),
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.deepBlack.withOpacity(0.95),
            theme.background.withOpacity(0.6),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: theme.accent.withOpacity(0.8),
          width: context.w(1.5),
        ),
        borderRadius: BorderRadius.circular(context.r(8)),
        boxShadow: [
          // Cyberpunk subtle underglow
          BoxShadow(
            color: theme.accent.withOpacity(0.3),
            blurRadius: context.r(8),
            spreadRadius: context.r(1),
          ),
          // Spread AppShadows.hardShadowTiny (it's a List<BoxShadow>)
          ...AppShadows.hardShadowTiny,
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star_rounded, color: theme.accent, size: context.sp(16)),
          SizedBox(width: context.w(6)),
          Text(
            '$score',
            style: AppTextStyles.tier(color: AppColors.pureWhite).copyWith(
              fontSize: context.sp(16),
              letterSpacing: 1.2,
              shadows: [
                Shadow(color: theme.accent, blurRadius: context.r(6)),
              ],
            ),
          )
              .animate(key: ValueKey(score))
              .scaleXY(
                begin: 1.3,
                end: 1.0,
                duration: 300.ms,
                curve: Curves.easeOutBack,
              )
              .tint(color: Colors.white, duration: 150.ms),
          if (isHardMode) ...[
            SizedBox(width: context.w(6)),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: context.w(4),
                vertical: context.h(2),
              ),
              decoration: BoxDecoration(
                color: AppColors.laserRed.withOpacity(0.2),
                borderRadius: BorderRadius.circular(context.r(4)),
                border: Border.all(
                  color: AppColors.laserRed.withOpacity(0.5),
                ),
              ),
              child: Text(
                'HARD',
                style: TextStyle(
                  color: AppColors.laserRed,
                  fontSize: context.sp(9),
                  fontWeight: FontWeight.w900,
                  fontFamily: 'Black Han Sans',
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// ── Combo Display (Center HUD) ─────────────────────────────────
/// Energetic combo counter that intensifies visually at higher streaks.
/// combo < 2  → subtle "READY" placeholder
/// combo 2–4  → normal accent
/// combo 5–9  → orange high-combo with pulsing icon
/// combo 10+  → red "crazy" combo with continuous shake
class ComboDisplay extends StatelessWidget {
  final int combo;
  final LevelTheme theme;

  const ComboDisplay({
    super.key,
    required this.combo,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    if (combo < 2) {
      return Container(
        height: context.h(32),
        alignment: Alignment.center,
        child: Text(
          'READY',
          style: TextStyle(
            color: theme.textPrimary.withOpacity(0.3),
            fontFamily: 'Black Han Sans',
            fontSize: context.sp(14),
            letterSpacing: 2.0,
          ),
        ),
      );
    }

    final isHighCombo = combo >= 5;
    final isCrazyCombo = combo >= 10;

    // Use laserRed for crazy, a warm orange for high, accent for normal
    final textColor = isCrazyCombo
        ? AppColors.laserRed
        : (isHighCombo ? const Color(0xFFFF9800) : theme.accent);
    final glowColor = textColor.withOpacity(0.6);
    final shadowRadius = isCrazyCombo ? 20.0 : (isHighCombo ? 12.0 : 6.0);

    return Container(
      height: context.h(36),
      alignment: Alignment.center,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isCrazyCombo ? Icons.local_fire_department : Icons.bolt,
            color: textColor,
            size: context.sp(isCrazyCombo ? 24 : 20),
          )
              .animate(
                onPlay: (c) => isHighCombo ? c.repeat(reverse: true) : null,
              )
              .scaleXY(begin: 1.0, end: 1.2, duration: 300.ms),
          SizedBox(width: context.w(4)),
          Text(
            '$combo COMBO',
            style: TextStyle(
              fontFamily: 'Black Han Sans',
              color: AppColors.pureWhite,
              fontSize: context.sp(isCrazyCombo ? 22 : 18),
              fontWeight: FontWeight.w900,
              fontStyle: FontStyle.italic,
              letterSpacing: 1.5,
              shadows: [
                Shadow(
                  color: glowColor,
                  blurRadius: context.r(shadowRadius),
                ),
                const Shadow(
                  color: Colors.black,
                  blurRadius: 2,
                  offset: Offset(1, 1),
                ),
              ],
            ),
          ),
        ],
      )
          .animate(key: ValueKey(combo))
          .scaleXY(
            begin: 1.4,
            end: 1.0,
            duration: 400.ms,
            curve: Curves.elasticOut,
          )
          .shake(
            hz: isCrazyCombo ? 8 : 4,
            offset: Offset(isCrazyCombo ? 2 : 0, 0),
            duration: 300.ms,
          ),
    );
  }
}
