import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/widgets/neon_text.dart';
import '../../../data/services/timer_service.dart';

/// The 15-second countdown timer bar — THE tension-building element.
/// Mimics real poker tournament shot clock.
class ActionClockWidget extends StatelessWidget {
  final double seconds;
  final TimerPhase phase;
  final double maxDuration;

  const ActionClockWidget({
    super.key,
    required this.seconds,
    required this.phase,
    this.maxDuration = 15.0,
  });

  @override
  Widget build(BuildContext context) {
    final isCritical = phase == TimerPhase.critical;
    final isExpired = phase == TimerPhase.expired;
    final isUrgent = seconds < 3.0;

    // Calculate progress
    final progress = (seconds / maxDuration).clamp(0.0, 1.0);

    // Determine colors based on phase
    final Gradient barGradient;
    final Color glowColor;
    
    if (isExpired) {
      barGradient = AppColors.neonGradient(AppColors.laserRed, AppColors.laserRed);
      glowColor = AppColors.laserRed;
    } else if (isCritical) {
      barGradient = AppColors.neonGradient(AppColors.laserRed, AppColors.neonPink);
      glowColor = AppColors.neonPink;
    } else {
      barGradient = AppColors.neonGradient(AppColors.electricBlue, AppColors.neonCyan);
      glowColor = AppColors.neonCyan;
    }

    final Color borderColor = isCritical ? AppColors.neonPink : AppColors.pureBlack;
    final double borderWidth = isCritical ? 3.0 : 4.0;

    // Container BoxShadow logic
    List<BoxShadow> containerShadows = [...AppShadows.hardShadowTiny];
    if (isCritical) {
      containerShadows.addAll(AppColors.neonGlow(AppColors.neonPink, intensity: 0.5));
    } else if (!isExpired) {
      containerShadows.addAll(AppShadows.innerGlow(glowColor));
    }

    return Container(
      height: 32,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.deepBlack,
        border: Border.all(
          color: borderColor,
          width: borderWidth,
        ),
        borderRadius: BorderRadius.circular(10),
        boxShadow: containerShadows,
      ),
      child: Stack(
        children: [
          // Progress Fill
          FractionallySizedBox(
            widthFactor: progress,
            child: Container(
              decoration: BoxDecoration(
                gradient: barGradient,
                borderRadius: BorderRadius.circular(6), // Slightly less than container (10-4=6)
                boxShadow: [
                  BoxShadow(
                    color: glowColor.withOpacity(0.8),
                    blurRadius: 8,
                    offset: const Offset(2, 0),
                  ),
                ],
              ),
            )
            .animate(
              target: isCritical ? 1 : 0,
              onPlay: (c) => c.repeat(),
            )
            .shimmer(
              duration: 1000.ms,
              color: Colors.white.withOpacity(0.4),
            ),
          ),

          // Inner Highlight Strip
          Positioned(
            top: 2,
            left: 2,
            right: 2,
            height: 6,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),

          // Time Display
          Positioned(
            right: 8,
            top: 0,
            bottom: 0,
            child: Center(
              child: _buildTimerText(isUrgent, isCritical),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimerText(bool isUrgent, bool isCritical) {
    final textValue = '${seconds.toStringAsFixed(1)}s';

    if (isUrgent) {
      return NeonText(
        textValue,
        color: AppColors.laserRed,
        fontSize: 15,
        glowIntensity: 1.5,
        animated: true,
      )
      .animate(onPlay: (c) => c.repeat(reverse: true))
      .shake(hz: 4, offset: const Offset(2, 0));
    } else if (isCritical) {
      return Text(
        textValue,
        style: AppTextStyles.bodySmall(color: AppColors.neonPink).copyWith(
          shadows: [
            const Shadow(
              color: AppColors.neonPink,
              blurRadius: 8,
            ),
          ],
        ),
      );
    } else {
      return Text(
        textValue,
        style: AppTextStyles.bodySmall(color: AppColors.pureWhite).copyWith(
          fontWeight: FontWeight.bold,
        ),
      );
    }
  }
}
