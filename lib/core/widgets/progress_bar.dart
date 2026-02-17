import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_colors.dart';

/// Dynamic progress bar with game-like visuals
/// 
/// Features:
/// - Animated fill transition
/// - Inner highlight strip for 3D depth
/// - Tick marks
/// - Danger zone pulse (value < 0.2)
/// - Optional label
class ProgressBar extends StatelessWidget {
  final double value;
  final Color color;
  final Color backgroundColor;
  final double height;
  final double borderRadius;
  final bool showShimmer;
  
  // New optional parameter
  final String? label;

  const ProgressBar({
    super.key,
    required this.value,
    this.color = AppColors.neonCyan,
    this.backgroundColor = AppColors.darkGray,
    this.height = 24,
    this.borderRadius = 8,
    this.showShimmer = false,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    final clampedValue = value.clamp(0.0, 1.0);
    final isLowHealth = clampedValue < 0.2 && clampedValue > 0.0;

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(
          color: AppColors.pureBlack,
          width: 4,
        ),
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          // Inner shadow for depth
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            offset: const Offset(2, 2),
            blurRadius: 0,
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius - 4), // Adjust for border width
        child: Stack(
          children: [
            // Animated Fill
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: clampedValue),
              duration: 300.ms,
              curve: Curves.easeOutCubic,
              builder: (context, val, child) {
                return FractionallySizedBox(
                  widthFactor: val == 0 ? 0.001 : val, // Avoid 0 width issues
                  child: Container(
                    decoration: BoxDecoration(
                      color: isLowHealth ? AppColors.laserRed : color,
                      boxShadow: [
                        // Glow on the leading edge
                        BoxShadow(
                          color: (isLowHealth ? AppColors.laserRed : color).withOpacity(0.8),
                          blurRadius: 10,
                          spreadRadius: 2,
                          offset: const Offset(2, 0),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            // Inner Highlight Strip (Top)
            Positioned(
              top: 2,
              left: 2,
              right: 2,
              height: height * 0.25,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(borderRadius / 2),
                ),
              ),
            ),

            // Tick Marks (every 25%)
            Row(
              children: List.generate(3, (index) {
                return Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      width: 2,
                      height: height,
                      color: Colors.black.withOpacity(0.2),
                    ),
                  ),
                );
              }) + [const Expanded(child: SizedBox())], // Fill last segment
            ),

            // Shimmer Effect
            if (showShimmer)
              Positioned.fill(
                child: Animate(
                  onPlay: (controller) => controller.repeat(),
                  effects: [
                    ShimmerEffect(
                      duration: 1500.ms,
                      color: Colors.white.withOpacity(0.6),
                      angle: 0.5,
                      size: 1.0, // Wider shimmer
                    ),
                  ],
                  child: Container(color: Colors.transparent),
                ),
              ),

            // Label
            if (label != null)
              Center(
                child: Text(
                  label!,
                  style: const TextStyle(
                    color: AppColors.pureBlack,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              
            // Low Health Pulse Overlay
            if (isLowHealth)
              Positioned.fill(
                child: Container(
                  color: AppColors.laserRed.withOpacity(0.3),
                )
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .fadeIn(duration: 300.ms)
                .fadeOut(duration: 300.ms),
              ),
          ],
        ),
      ),
    );
  }
}
