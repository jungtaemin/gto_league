import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:holdem_allin_fold/core/theme/app_colors.dart';
import 'package:holdem_allin_fold/core/theme/app_shadows.dart';
import 'package:holdem_allin_fold/core/theme/app_text_styles.dart';

/// Compact pill-shaped time chip activation button for League mode.
///
/// Shows remaining chip count with an hourglass icon. When the timer
/// is in the critical phase and chips remain, a pulsing neon glow
/// draws the player's attention. Disabled (dark, non-interactive)
/// when no chips remain.
class TimeChipButton extends StatefulWidget {
  /// Number of time chips remaining (0–3).
  final int chipsRemaining;

  /// Called when the player taps to use a chip.
  final VoidCallback onUseChip;

  /// Whether the countdown timer is in the critical phase (≤ 5s).
  final bool isTimerCritical;

  const TimeChipButton({
    super.key,
    required this.chipsRemaining,
    required this.onUseChip,
    required this.isTimerCritical,
  });

  @override
  State<TimeChipButton> createState() => _TimeChipButtonState();
}

class _TimeChipButtonState extends State<TimeChipButton> {
  bool _isPressed = false;

  bool get _isDisabled => widget.chipsRemaining <= 0;

  void _handleTapDown(TapDownDetails details) {
    if (_isDisabled) return;
    setState(() => _isPressed = true);
  }

  void _handleTapUp(TapUpDetails details) {
    if (_isDisabled) return;
    setState(() => _isPressed = false);
    widget.onUseChip();
  }

  void _handleTapCancel() {
    if (_isDisabled) return;
    setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    final bool shouldPulse =
        widget.isTimerCritical && !_isDisabled;

    Widget chip = AnimatedScale(
      scale: _isPressed ? 0.92 : 1.0,
      duration: const Duration(milliseconds: 100),
      child: GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _isDisabled
                ? AppColors.darkGray
                : AppColors.deepBlack,
            border: Border.all(
              color: _isDisabled
                  ? AppColors.pureWhite.withOpacity(0.15)
                  : AppColors.pureBlack,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              ...AppShadows.hardShadowTiny,
              if (!_isDisabled)
                BoxShadow(
                  color: AppColors.neonCyan.withOpacity(0.3),
                  blurRadius: 8,
                  spreadRadius: 0,
                ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.hourglass_top_rounded,
                color: _isDisabled
                    ? AppColors.pureWhite.withOpacity(0.2)
                    : AppColors.neonCyan,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                '${widget.chipsRemaining}',
                style: AppTextStyles.tier(
                  color: _isDisabled
                      ? AppColors.pureWhite.withOpacity(0.2)
                      : AppColors.neonCyan,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    // Critical pulse animation to draw attention.
    if (shouldPulse) {
      chip = chip
          .animate(onPlay: (controller) => controller.repeat(reverse: true))
          .boxShadow(
            begin: BoxShadow(
              color: AppColors.neonCyan.withOpacity(0.0),
              blurRadius: 0,
              spreadRadius: 0,
            ),
            end: BoxShadow(
              color: AppColors.neonCyan.withOpacity(0.6),
              blurRadius: 12,
              spreadRadius: 2,
            ),
            duration: 300.ms,
            curve: Curves.easeInOut,
          );
    }

    return chip;
  }
}
