import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:holdem_allin_fold/core/theme/app_colors.dart';

/// Dynamic level background for the 100-Hand Deep Run Survival mode.
///
/// Animated gradient that crossfades when [currentLevel] changes (1–5).
/// Level 5 special: pitch-black with pulsing red vignette edges.
class DeepRunBackground extends StatefulWidget {
  /// Current difficulty level (1–5).
  final int currentLevel;

  const DeepRunBackground({super.key, required this.currentLevel});

  @override
  State<DeepRunBackground> createState() => _DeepRunBackgroundState();
}

class _DeepRunBackgroundState extends State<DeepRunBackground> {
  @override
  Widget build(BuildContext context) {
    final theme = AppColors.getLevelTheme(widget.currentLevel);
    final isLevel5 = widget.currentLevel == 5;
    final size = MediaQuery.of(context).size;

    return Stack(
      children: [
        // ── Main gradient background with crossfade ───────────────────
        AnimatedContainer(
          duration: const Duration(milliseconds: 1500),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                theme.background,
                Color.lerp(theme.background, theme.primary, 0.3) ??
                    theme.background,
                theme.primary,
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        ),

        // ── Blurred blob: top-left (primary tint) ─────────────────────
        Positioned(
          top: -80,
          left: -60,
          width: size.width * 0.5,
          height: size.height * 0.4,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 1500),
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              color: theme.primary.withOpacity(0.25),
              shape: BoxShape.circle,
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
              child: Container(color: Colors.transparent),
            ),
          ),
        ),

        // ── Blurred blob: bottom-right (accent tint) ──────────────────
        Positioned(
          bottom: 80,
          right: -40,
          width: size.width * 0.6,
          height: size.height * 0.45,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 1500),
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              color: theme.accent.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 120, sigmaY: 120),
              child: Container(color: Colors.transparent),
            ),
          ),
        ),

        // ── Level 5 SPECIAL: pulsing red vignette edges ───────────────
        if (isLevel5)
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 0.9,
                    colors: [
                      Colors.transparent,
                      AppColors.laserRed.withOpacity(0.6),
                    ],
                    stops: const [0.4, 1.0],
                  ),
                ),
              )
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .fadeIn(duration: 300.ms, begin: 0.3),
            ),
          ),
      ],
    );
  }
}
