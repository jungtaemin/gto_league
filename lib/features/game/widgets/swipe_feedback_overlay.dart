import 'dart:math' show pi;
import 'package:flutter/material.dart';
import 'package:holdem_allin_fold/core/theme/app_colors.dart';

/// 스와이프 방향 피드백 오버레이 (E-Sports Enhanced — Stitch V2)
class SwipeFeedbackOverlay extends StatelessWidget {
  final double dragProgress; // -1.0 (full left) to +1.0 (full right), 0.0 = center

  const SwipeFeedbackOverlay({
    super.key,
    required this.dragProgress,
  });

  @override
  Widget build(BuildContext context) {
    final double progressAbs = dragProgress.abs();
    
    if (progressAbs < 0.05) {
      return const SizedBox.shrink();
    }

    final bool isFold = dragProgress < 0;
    final double opacity = progressAbs.clamp(0.0, 1.0);
    final double scale = 0.8 + (0.2 * opacity);
    
    final String text = isFold ? 'FOLD' : 'ALL-IN!';
    final String emoji = isFold ? '💀' : '🚀';
    final Color color = isFold ? AppColors.laserRed : AppColors.acidGreen;
    final double rotation = isFold ? -15 * (pi / 180) : 15 * (pi / 180);
    final Alignment alignment = isFold ? Alignment.centerLeft : Alignment.centerRight;
    
    // More dramatic tint for fold direction
    final Gradient gradient = LinearGradient(
      begin: isFold ? Alignment.centerLeft : Alignment.centerRight,
      end: isFold ? Alignment.centerRight : Alignment.centerLeft,
      colors: [
        color.withOpacity((isFold ? 0.55 : 0.4) * opacity),
        color.withOpacity(0.0),
      ],
    );

    return IgnorePointer(
      child: Stack(
        children: [
          // Background Tint
          Positioned.fill(
            child: Container(decoration: BoxDecoration(gradient: gradient)),
          ),

          // Screen-edge red pulse for fold direction
          if (isFold)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.centerLeft,
                    radius: 1.2,
                    colors: [
                      AppColors.laserRed.withOpacity(0.25 * opacity),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

          // Edge Glow (Enhanced with dual-layer shadow)
          Positioned(
            top: 0,
            bottom: 0,
            left: isFold ? 0 : null,
            right: isFold ? null : 0,
            width: isFold ? 6 : 4,
            child: Container(
              decoration: BoxDecoration(
                color: color,
                boxShadow: [
                  BoxShadow(color: color.withOpacity(opacity * 0.6), blurRadius: 12, spreadRadius: 2),
                  BoxShadow(color: color.withOpacity(opacity * 0.3), blurRadius: 30, spreadRadius: 8),
                ],
              ),
            ),
          ),
          
          // Content Overlay
          Align(
            alignment: alignment,
            child: Transform.rotate(
              angle: rotation,
              child: Transform.scale(
                scale: scale,
                child: Opacity(
                  opacity: opacity,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Emoji with glow aura (green spark particles for ALL-IN)
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: isFold
                                ? [BoxShadow(color: color.withOpacity(opacity * 0.4), blurRadius: 16, spreadRadius: 4)]
                                : AppColors.neonGlow(AppColors.acidGreen, intensity: opacity * 0.8),
                          ),
                          child: Text(
                            emoji,
                            style: TextStyle(
                              fontSize: isFold ? 60 : 60 + (12 * opacity), // Bounce scale for 🚀
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        // Text with outer glow aura for ALL-IN
                        Container(
                          padding: isFold
                              ? EdgeInsets.zero
                              : const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: isFold
                              ? null
                              : BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.acidGreen.withOpacity(opacity * 0.35),
                                      blurRadius: 28,
                                      spreadRadius: 6,
                                    ),
                                  ],
                                ),
                          child: Text(
                            text,
                            style: TextStyle(
                              color: color,
                              fontSize: 56,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 2.0,
                              shadows: [
                                Shadow(color: color.withOpacity(opacity * 1.2), blurRadius: 20),
                                Shadow(color: color.withOpacity(opacity * 0.6), blurRadius: 40),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
