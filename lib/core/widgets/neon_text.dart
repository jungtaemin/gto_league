import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_colors.dart';

/// High-energy neon text with multi-layer glow
/// 
/// Features:
/// - 3-layer glow for realistic neon effect
/// - Optional flicker animation
/// - Optional Neo-Brutalist stroke outline
class NeonText extends StatelessWidget {
  final String text;
  final Color color;
  final double fontSize;
  final double glowIntensity;
  final FontWeight? fontWeight;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final TextStyle? style;
  
  // New optional parameters
  final bool animated;
  final double strokeWidth;

  const NeonText(
    this.text, {
    super.key,
    this.color = AppColors.neonPink,
    this.fontSize = 16,
    this.glowIntensity = 1.0,
    this.fontWeight,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.style,
    this.animated = false,
    this.strokeWidth = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    // Base text style
    final baseStyle = (style ?? const TextStyle()).copyWith(
      fontSize: fontSize,
      fontWeight: fontWeight ?? FontWeight.bold,
    );

    // Glow layers
    final shadows = [
      // Core (Tight & Bright)
      Shadow(
        color: color,
        blurRadius: 5 * glowIntensity,
        offset: Offset.zero,
      ),
      // Mid (Saturated)
      Shadow(
        color: color.withOpacity(0.8),
        blurRadius: 15 * glowIntensity,
        offset: Offset.zero,
      ),
      // Outer (Wide & Soft)
      Shadow(
        color: color.withOpacity(0.4),
        blurRadius: 40 * glowIntensity,
        offset: Offset.zero,
      ),
    ];

    Widget textWidget = Text(
      text,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      style: baseStyle.copyWith(
        color: color,
        shadows: shadows,
      ),
    );

    // Apply stroke if requested (Neo-Brutalist outline)
    if (strokeWidth > 0) {
      textWidget = Stack(
        children: [
          // Stroke Layer
          Text(
            text,
            textAlign: textAlign,
            maxLines: maxLines,
            overflow: overflow,
            style: baseStyle.copyWith(
              foreground: Paint()
                ..style = PaintingStyle.stroke
                ..strokeWidth = strokeWidth
                ..color = AppColors.pureBlack,
            ),
          ),
          // Fill Layer
          textWidget,
        ],
      );
    }

    // Apply flicker animation if requested
    if (animated) {
      textWidget = textWidget
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .custom(
            duration: 2000.ms,
            builder: (context, value, child) {
              // Random-ish flicker effect using sine wave combination
              final opacity = 0.85 + (0.15 * (0.5 + 0.5 * (
                (DateTime.now().millisecondsSinceEpoch % 1000) / 1000.0
              )));
              return Opacity(opacity: opacity, child: child);
            },
          );
    }

    return textWidget;
  }
}
