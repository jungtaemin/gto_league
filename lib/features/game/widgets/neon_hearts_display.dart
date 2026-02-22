import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:holdem_allin_fold/core/theme/app_colors.dart';
import 'package:holdem_allin_fold/core/utils/haptic_manager.dart';

/// Three-strike neon heart life system for Deep Run mode.
///
/// Active hearts glow with a neon pulse; lost hearts appear dark
/// and cracked. A shatter animation plays when a heart is lost.
class NeonHeartsDisplay extends StatefulWidget {
  /// Remaining strikes (0–3).
  final int strikesRemaining;

  const NeonHeartsDisplay({super.key, required this.strikesRemaining});

  @override
  State<NeonHeartsDisplay> createState() => _NeonHeartsDisplayState();
}

class _NeonHeartsDisplayState extends State<NeonHeartsDisplay> {
  int? _shatteringIndex;

  @override
  void didUpdateWidget(covariant NeonHeartsDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.strikesRemaining < oldWidget.strikesRemaining) {
      // The heart at this index was just lost.
      _shatteringIndex = widget.strikesRemaining;
      HapticManager.heartShatter();

      // Clear after the shatter animation completes (~600ms).
      Future.delayed(const Duration(milliseconds: 700), () {
        if (mounted) {
          setState(() => _shatteringIndex = null);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        final isActive = index < widget.strikesRemaining;
        final isShattering = _shatteringIndex == index;
        return _HeartIcon(
          key: ValueKey('heart_${index}_${isActive}_$isShattering'),
          isActive: isActive,
          isShattering: isShattering,
        );
      }),
    );
  }
}

/// Single heart icon with idle-pulse, shatter, and lost states.
class _HeartIcon extends StatelessWidget {
  final bool isActive;
  final bool isShattering;

  const _HeartIcon({
    super.key,
    required this.isActive,
    required this.isShattering,
  });

  @override
  Widget build(BuildContext context) {
    if (isShattering) return _buildShattering();
    return isActive ? _buildActive() : _buildLost();
  }

  /// Bright neon heart with idle pulse animation (1500ms loop).
  Widget _buildActive() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: Icon(
        Icons.favorite,
        color: AppColors.laserRed,
        size: 24,
        shadows: AppColors.neonGlow(AppColors.laserRed),
      ),
    )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .scaleXY(
          begin: 1.0,
          end: 1.12,
          duration: 1500.ms,
          curve: Curves.easeInOut,
        );
  }

  /// Dark cracked heart — life already lost.
  Widget _buildLost() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: Icon(
        Icons.heart_broken,
        color: AppColors.pureWhite.withOpacity(0.15),
        size: 24,
      ),
    );
  }

  /// Shake → scale-up → fade-out shatter sequence.
  Widget _buildShattering() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: Icon(
        Icons.favorite,
        color: AppColors.laserRed,
        size: 24,
        shadows: AppColors.neonGlow(AppColors.laserRed),
      ),
    )
        .animate()
        .shake(duration: 200.ms, rotation: 0.05)
        .then()
        .scaleXY(
          begin: 1.0,
          end: 1.5,
          duration: 200.ms,
          curve: Curves.easeOut,
        )
        .fadeOut(duration: 200.ms);
  }
}
