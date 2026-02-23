import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/app_colors.dart';

/// Displays the current BB level as a horizontal row of small casino chips
/// laid flat (side-view), with a "15BB" text label.
/// Designed to sit in the empty space below the game cards.
class ActiveBbChip extends StatelessWidget {
  final int bbLevel;
  final LevelTheme theme;

  const ActiveBbChip({
    super.key,
    required this.bbLevel,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. Horizontal chip row
          _buildChipRow(),

          const SizedBox(height: 8),

          // 2. "15BB" text label
          _buildBbLabel(),
        ],
      )
          // Gentle floating animation
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .moveY(begin: -3, end: 3, duration: 2500.ms, curve: Curves.easeInOutSine)
          // Entrance
          .animate()
          .fadeIn(duration: 500.ms)
          .moveY(begin: 30, end: 0, duration: 600.ms, curve: Curves.easeOutBack),
    );
  }

  Widget _buildChipRow() {
    // Determine number of chips.
    // We cap at 20 visually to avoid overflowing small screens,
    // but the text label will still show the true bbLevel (e.g. 50BB).
    final chipCount = bbLevel.clamp(1, 20);

    // Dynamic width calculation:
    // With 15 chips, we want them closely packed so they fit nicely.
    // Overlap amount increases if there are many chips to fit the space.
    final overlapSpacing = chipCount > 10 ? 12.0 : 18.0;
    final rowWidth = 32.0 + ((chipCount - 1) * overlapSpacing);

    return SizedBox(
      width: rowWidth,
      height: 48, // Slightly taller container for shadows/rotation
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: List.generate(chipCount, (i) {
          // More organic tilt pattern
          // -0.08, 0.05, -0.03, etc...
          final tilt = (i % 4 == 0) ? -0.08 : (i % 4 == 1) ? 0.06 : (i % 4 == 2) ? -0.04 : 0.02;
          
          // Slight vertical jitter for a messy, realistic stack spread
          final yOffset = (i % 3 == 0) ? 2.0 : (i % 3 == 1) ? -1.0 : 0.0;

          return Positioned(
            left: i * overlapSpacing,
            top: 8.0 + yOffset,
            child: Transform.rotate(
              angle: tilt,
              child: _buildSingleChip(i),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildSingleChip(int index) {
    // Alternating slight brightness for depth illusion between overlapping chips
    final isAlt = index % 2 == 0;
    final chipColor = isAlt
        ? theme.background
        : Color.lerp(theme.background, AppColors.deepBlack, 0.4)!;

    return Container(
      width: 32, // Slightly larger base chip
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            Color.lerp(chipColor, Colors.white, 0.1)!, // Highlight center
            Color.lerp(chipColor, Colors.black, 0.8)!  // Dark edge
          ],
          radius: 0.85,
        ),
        border: Border.all(
          color: theme.accent.withOpacity(0.9), // Bright neon edge
          width: 2.0,
        ),
        boxShadow: [
          // Drop shadow onto the chip below it
          BoxShadow(
            color: Colors.black.withOpacity(0.8),
            blurRadius: 4,
            offset: const Offset(2, 2),
          ),
          // Subtle neon glow
          BoxShadow(
            color: theme.accent.withOpacity(0.3),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      // Inner ring details (like real casino chips)
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer decorative dashes (casino chip rim marks)
          ...List.generate(6, (dashIndex) {
            return Transform.rotate(
              angle: (dashIndex * math.pi / 3),
              child: Align(
                alignment: Alignment.topCenter,
                child: Container(
                  width: 3,
                  height: 6,
                  color: AppColors.pureWhite.withOpacity(0.8),
                ),
              ),
            );
          }),
          // Inner circle
          Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.deepBlack.withOpacity(0.5),
              border: Border.all(
                color: theme.accent.withOpacity(0.7),
                width: 1.5,
              ),
            ),
            // Innermost dot
            child: Center(
              child: Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.accent,
                  boxShadow: [
                    BoxShadow(
                      color: theme.accent,
                      blurRadius: 4,
                      spreadRadius: 1,
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBbLabel() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [
            AppColors.deepBlack.withOpacity(0.9),
            AppColors.deepBlack.withOpacity(0.7),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        border: Border.all(
          color: theme.accent.withOpacity(0.6),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.8),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: theme.accent.withOpacity(0.2),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Little spark/dot icon for flavor
          Icon(
            Icons.local_fire_department_rounded,
            color: theme.accent,
            size: 16,
          ),
          const SizedBox(width: 6),
          Text(
            '${bbLevel}BB',
            style: TextStyle(
              fontFamily: 'Black Han Sans',
              fontSize: 20, // Slightly larger, bolder look
              height: 1.1,
              color: AppColors.pureWhite,
              letterSpacing: 1.2,
              shadows: [
                Shadow(
                  color: theme.accent,
                  blurRadius: 10,
                ),
                const Shadow(
                  color: Colors.black,
                  blurRadius: 4,
                  offset: Offset(1, 2),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Icon(
            Icons.local_fire_department_rounded,
            color: theme.accent,
            size: 16,
          ),
        ],
      ),
    );
  }
}
