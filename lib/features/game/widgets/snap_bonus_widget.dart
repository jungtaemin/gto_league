import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/neon_text.dart';

/// The "⚡ SNAP!" text animation that appears when user swipes within 2 seconds.
class SnapBonusWidget extends StatefulWidget {
  final bool isVisible;
  final VoidCallback? onComplete;

  const SnapBonusWidget({
    super.key,
    required this.isVisible,
    this.onComplete,
  });

  @override
  State<SnapBonusWidget> createState() => _SnapBonusWidgetState();
}

class _SnapBonusWidgetState extends State<SnapBonusWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // Explicitly set duration to cover the longest animation chain
    _controller = AnimationController(vsync: this, duration: 1500.ms);
  }

  @override
  void didUpdateWidget(SnapBonusWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isVisible && !oldWidget.isVisible) {
      _playAnimation();
    }
  }

  void _playAnimation() {
    _controller.forward(from: 0).then((_) {
      widget.onComplete?.call();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // We keep the widget in the tree but hidden when not visible 
    // to ensure the controller and state are preserved if needed,
    // or we can return SizedBox.shrink(). 
    // Given the requirement "When isVisible changes from false to true",
    // returning SizedBox.shrink() is fine as long as we handle the restart.
    if (!widget.isVisible) return const SizedBox.shrink();

    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Gradient Burst Background
          Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [
                  AppColors.acidYellow.withOpacity(0.2),
                  Colors.transparent,
                ],
                stops: const [0.0, 1.0],
                center: Alignment.center,
                radius: 0.8,
              ),
            ),
          )
          .animate(
            controller: _controller,
            autoPlay: false,
          )
          .scale(
            begin: const Offset(0, 0),
            end: const Offset(1.2, 1.2),
            duration: 300.ms,
            curve: Curves.easeOutBack,
          )
          .scale(
            begin: const Offset(1.2, 1.2),
            end: const Offset(1.0, 1.0),
            duration: 200.ms,
            curve: Curves.easeOut,
            delay: 300.ms,
          )
          .fadeOut(
            duration: 300.ms,
            delay: 1000.ms,
          )
          .scale(
            end: const Offset(1.5, 1.5),
            duration: 300.ms,
            delay: 1000.ms,
          ),

          // Text Column
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              NeonText(
                '⚡ SNAP!',
                style: AppTextStyles.display(),
                color: AppColors.neonCyan,
                fontSize: 56,
                strokeWidth: 3.0,
                glowIntensity: 1.5,
              )
              .animate(
                controller: _controller,
                autoPlay: false,
              )
              // 1. Scale from 0.0 -> 1.2 (300ms, overshoot curve)
              .scale(
                begin: const Offset(0, 0),
                end: const Offset(1.2, 1.2),
                duration: 300.ms,
                curve: Curves.easeOutBack,
              )
              // 2. Scale 1.2 -> 1.0 (200ms, ease out)
              .scale(
                begin: const Offset(1.2, 1.2),
                end: const Offset(1.0, 1.0),
                duration: 200.ms,
                curve: Curves.easeOut,
                delay: 300.ms, // Wait for previous animation
              )
              // Add subtle rotating shimmer effect during hold phase
              .shimmer(
                duration: 500.ms,
                delay: 500.ms, // Wait for scale down
                color: Colors.white.withOpacity(0.5),
                angle: 0.5,
              )
              // 3. Hold for 500ms (implicit by delay of next step)
              // 4. Fade out + scale up to 1.5 (300ms)
              .fadeOut(
                duration: 300.ms,
                delay: 1000.ms, // 300 + 200 + 500
              )
              .scale(
                end: const Offset(1.5, 1.5),
                duration: 300.ms,
                delay: 1000.ms,
              ),

              // Optional: small "+1.5x" score multiplier text below
              const NeonText(
                '+1.5x',
                color: AppColors.acidYellow,
                fontSize: 22,
                glowIntensity: 1.0,
                strokeWidth: 1.5,
              )
              .animate(
                controller: _controller,
                autoPlay: false,
              )
              .fadeIn(duration: 200.ms, delay: 200.ms)
              .moveY(begin: 10, end: 0, duration: 300.ms, curve: Curves.easeOut)
              .fadeOut(duration: 200.ms, delay: 1100.ms),
            ],
          ),
        ],
      ),
    );
  }
}
