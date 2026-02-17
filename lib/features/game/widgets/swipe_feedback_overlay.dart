import 'dart:math' show pi;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/neon_text.dart';

class SwipeFeedbackOverlay extends StatelessWidget {
  final double dragProgress; // -1.0 (full left) to +1.0 (full right), 0.0 = center

  const SwipeFeedbackOverlay({
    super.key,
    required this.dragProgress,
  });

  @override
  Widget build(BuildContext context) {
    final double progressAbs = dragProgress.abs();
    
    // Dead zone - show nothing if drag is minimal
    if (progressAbs < 0.05) {
      return const SizedBox.shrink();
    }

    // Determine direction and properties
    final bool isFold = dragProgress < 0;
    final double opacity = progressAbs.clamp(0.0, 1.0);
    final double scale = 0.8 + (0.2 * opacity);
    
    final String text = isFold ? "FOLD" : "ALL-IN!";
    final String emoji = isFold ? "💀" : "🚀";
    final Color color = isFold ? AppColors.laserRed : AppColors.acidGreen;
    // Rotate -15 deg for Fold, +15 deg for All-In
    final double rotation = isFold ? -15 * (pi / 180) : 15 * (pi / 180);
    final Alignment alignment = isFold ? Alignment.centerLeft : Alignment.centerRight;
    
    // Background gradient from edge to center
    final Gradient gradient = LinearGradient(
      begin: isFold ? Alignment.centerLeft : Alignment.centerRight,
      end: isFold ? Alignment.centerRight : Alignment.centerLeft,
      colors: [
        color.withOpacity(0.4 * opacity),
        color.withOpacity(0.0),
      ],
      stops: const [0.0, 1.0],
    );

    return IgnorePointer(
      child: Stack(
        children: [
          // Background Tint
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(gradient: gradient),
            ),
          ),

          // Edge Glow Effect
          Positioned(
            top: 0,
            bottom: 0,
            left: isFold ? 0 : null,
            right: isFold ? null : 0,
            width: 4,
            child: Container(
              decoration: BoxDecoration(
                color: color,
                boxShadow: AppColors.neonGlow(color, intensity: opacity * 0.6),
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
                    child: _buildFeedbackContent(text, emoji, color, opacity),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackContent(String text, String emoji, Color color, double opacity) {
    Widget content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Emoji Icon with Glow Halo
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: AppColors.neonGlow(color, intensity: opacity * 0.4),
          ),
          child: Text(
            emoji,
            style: const TextStyle(fontSize: 60),
          ),
        ),
        const SizedBox(height: 10),
        // Neon Text replacement
        NeonText(
          text,
          style: AppTextStyles.display().copyWith(height: 1.0, letterSpacing: 2.0),
          color: color,
          fontSize: 56,
          strokeWidth: 4.0,
          glowIntensity: opacity * 1.2,
        ),
      ],
    );

    // Pulse animation when opacity is high (strong feedback)
    if (opacity > 0.7) {
      content = content
          .animate(onPlay: (controller) => controller.repeat(reverse: true))
          .scale(
            begin: const Offset(1.0, 1.0),
            end: const Offset(1.1, 1.1),
            duration: 500.ms,
            curve: Curves.easeInOut,
          );
    }

    return content;
  }
}
