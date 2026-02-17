import 'dart:math' show pi;
import 'package:flutter/material.dart';

/// 스와이프 방향 피드백 오버레이 (Stitch V1 스타일)
class SwipeFeedbackOverlay extends StatelessWidget {
  final double dragProgress; // -1.0 (full left) to +1.0 (full right), 0.0 = center

  const SwipeFeedbackOverlay({
    super.key,
    required this.dragProgress,
  });

  static const _red = Color(0xFFEF4444);
  static const _green = Color(0xFF22C55E);

  @override
  Widget build(BuildContext context) {
    final double progressAbs = dragProgress.abs();
    
    if (progressAbs < 0.05) {
      return const SizedBox.shrink();
    }

    final bool isFold = dragProgress < 0;
    final double opacity = progressAbs.clamp(0.0, 1.0);
    final double scale = 0.8 + (0.2 * opacity);
    
    final String text = isFold ? 'FOLD' : 'ALL-IN!';
    final String emoji = isFold ? '💀' : '🚀';
    final Color color = isFold ? _red : _green;
    final double rotation = isFold ? -15 * (pi / 180) : 15 * (pi / 180);
    final Alignment alignment = isFold ? Alignment.centerLeft : Alignment.centerRight;
    
    final Gradient gradient = LinearGradient(
      begin: isFold ? Alignment.centerLeft : Alignment.centerRight,
      end: isFold ? Alignment.centerRight : Alignment.centerLeft,
      colors: [
        color.withOpacity(0.4 * opacity),
        color.withOpacity(0.0),
      ],
    );

    return IgnorePointer(
      child: Stack(
        children: [
          // Background Tint
          Positioned.fill(
            child: Container(decoration: BoxDecoration(gradient: gradient)),
          ),

          // Edge Glow
          Positioned(
            top: 0,
            bottom: 0,
            left: isFold ? 0 : null,
            right: isFold ? null : 0,
            width: 4,
            child: Container(
              decoration: BoxDecoration(
                color: color,
                boxShadow: [BoxShadow(color: color.withOpacity(opacity * 0.6), blurRadius: 12, spreadRadius: 2)],
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
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [BoxShadow(color: color.withOpacity(opacity * 0.4), blurRadius: 16, spreadRadius: 4)],
                          ),
                          child: Text(emoji, style: const TextStyle(fontSize: 60)),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          text,
                          style: TextStyle(
                            color: color,
                            fontSize: 56,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2.0,
                            shadows: [Shadow(color: color.withOpacity(opacity * 1.2), blurRadius: 20)],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
