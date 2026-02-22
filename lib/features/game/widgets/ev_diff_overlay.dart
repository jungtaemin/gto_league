import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// EV loss stamp overlay for Deep Run mode.
///
/// Shows a large red "-X.X BB" stamp when the player makes a negative EV play.
/// Stamps in with scale-down + rotation, auto-fades after 1.5s.
/// Wrapped in [IgnorePointer] so it never blocks swipe gestures.
class EvDiffOverlay extends StatelessWidget {
  /// EV difference in BB (negative = loss, positive = gain).
  final double evDiffBb;

  /// Whether this overlay should be visible.
  final bool isVisible;

  /// Called when the auto-fade completes.
  final VoidCallback? onComplete;

  const EvDiffOverlay({
    super.key,
    required this.evDiffBb,
    required this.isVisible,
    this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    // Only show for negative EV (wrong answer)
    if (!isVisible || evDiffBb >= 0) {
      return const SizedBox.shrink();
    }

    final formattedEv = evDiffBb.toStringAsFixed(1);

    return IgnorePointer(
      ignoring: true,
      child: Center(
        child: _EvStampContent(
          text: '$formattedEv BB',
          onComplete: onComplete,
        ),
      ),
    );
  }
}

/// Internal animated stamp content.
class _EvStampContent extends StatefulWidget {
  final String text;
  final VoidCallback? onComplete;

  const _EvStampContent({
    required this.text,
    this.onComplete,
  });

  @override
  State<_EvStampContent> createState() => _EvStampContentState();
}

class _EvStampContentState extends State<_EvStampContent>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _stampScale;
  late final Animation<double> _stampRotation;
  late final Animation<double> _fadeOut;

  @override
  void initState() {
    super.initState();

    // Total: 200ms stamp-in + 1300ms hold + 500ms fade = 2000ms
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    // (0-200ms) Scale from 2.0→1.0 with easeOut (stamp-in)
    _stampScale = Tween<double>(begin: 2.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.10, curve: Curves.easeOut),
      ),
    );

    // (0-200ms) Rotation from -5° to 0°
    _stampRotation = Tween<double>(
      begin: -5.0 * math.pi / 180.0,
      end: 0.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.10, curve: Curves.easeOut),
      ),
    );

    // (1500-2000ms) Fade out
    _fadeOut = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.75, 1.0, curve: Curves.easeIn),
      ),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete?.call();
      }
    });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeOut.value.clamp(0.0, 1.0),
          child: Transform.scale(
            scale: _stampScale.value,
            child: Transform.rotate(
              angle: _stampRotation.value,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  boxShadow: AppColors.neonGlow(AppColors.laserRed),
                ),
                child: Text(
                  widget.text,
                  style: AppTextStyles.display(color: AppColors.laserRed),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
