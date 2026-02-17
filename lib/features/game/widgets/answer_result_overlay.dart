import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/neon_text.dart';

class AnswerResultOverlay extends StatefulWidget {
  final bool isCorrect;
  final bool isVisible;
  final VoidCallback onComplete;

  const AnswerResultOverlay({
    super.key,
    required this.isCorrect,
    required this.isVisible,
    required this.onComplete,
  });

  @override
  State<AnswerResultOverlay> createState() => _AnswerResultOverlayState();
}

class _AnswerResultOverlayState extends State<AnswerResultOverlay> {
  @override
  Widget build(BuildContext context) {
    if (!widget.isVisible) return const SizedBox.shrink();

    final color = widget.isCorrect ? AppColors.acidGreen : AppColors.laserRed;
    final emoji = widget.isCorrect ? "✅" : "❌";
    final text = widget.isCorrect ? "NICE!" : "MISS...";

    return IgnorePointer(
      ignoring: true,
      child: Stack(
        children: [
          // Background Burst
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    color.withOpacity(0.4),
                    color.withOpacity(0.0),
                  ],
                  stops: const [0.2, 1.0],
                  center: Alignment.center,
                  radius: 0.8,
                ),
              ),
            )
            .animate(onComplete: (controller) => widget.onComplete())
            .fadeIn(duration: 100.ms)
            .scale(
              begin: const Offset(0.5, 0.5),
              end: const Offset(1.5, 1.5),
              duration: 400.ms,
              curve: Curves.easeOutBack,
            )
            .fadeOut(delay: 600.ms, duration: 200.ms),
          ),

          // Content
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Emoji
                Text(
                  emoji,
                  style: const TextStyle(fontSize: 80),
                )
                .animate()
                .scale(
                  duration: 400.ms,
                  curve: Curves.elasticOut,
                  begin: const Offset(0.5, 0.5),
                )
                .fadeIn(duration: 200.ms)
                .moveY(begin: 20, end: 0, duration: 300.ms)
                .fadeOut(delay: 600.ms, duration: 200.ms),

                const SizedBox(height: 16),

                // Text
                NeonText(
                  text,
                  color: color,
                  fontSize: 48,
                  fontWeight: FontWeight.w900,
                  strokeWidth: 3.0,
                  glowIntensity: 0.8,
                  style: AppTextStyles.display(color: color),
                  animated: true,
                )
                .animate()
                .scale(
                  delay: 100.ms,
                  duration: 400.ms,
                  curve: Curves.elasticOut,
                  begin: const Offset(0.8, 0.8),
                )
                .fadeIn(delay: 100.ms, duration: 200.ms)
                .shake(delay: 200.ms, duration: 300.ms, hz: 4, rotation: 0.05)
                .fadeOut(delay: 600.ms, duration: 200.ms),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
