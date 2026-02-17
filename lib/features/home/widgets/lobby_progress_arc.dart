import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class LobbyProgressArc extends StatelessWidget {
  const LobbyProgressArc({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      height: 300,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 1. Inner Soft Glow (White/5 border blur-sm)
          Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(0.05), width: 12),
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withOpacity(0.05),
                  blurRadius: 4,
                  spreadRadius: 0,
                )
              ],
            ),
          ),
          
          // 2. Outer Bloom (Primary/40 blur-15)
          Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.stitchPrimary.withOpacity(0.2), width: 2),
              boxShadow: [
                BoxShadow(
                  color: AppColors.stitchPrimary.withOpacity(0.2),
                  blurRadius: 15,
                  spreadRadius: 0,
                )
              ],
            ),
          ),

          // 3. Segmented Arc (Custom Painter)
          CustomPaint(
            size: const Size(300, 300),
            painter: _ArcPainter(),
          ),
        ],
      ),
    );
  }
}

class _ArcPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 32) / 2; // Inset for stroke width
    final strokeWidth = 16.0;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt; // CSS borders are butt joined? Or rounded? Default borders are butt-ish but creating a circle.
      // Actually CSS border-radius: full makes it a circle.
      // The segments are created by border colors.

    // Rotation 45 degrees (pi/4)
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(pi / 4);
    canvas.translate(-center.dx, -center.dy);

    // Draft the circle using 4 quadrants
    // Top: Cyan
    paint.color = AppColors.stitchCyan.withOpacity(0.8);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      3 * pi / 2 + pi / 4, // Start at -45 deg relative to Top? No, exact CSS logic needed.
      // CSS Border Top corresponds to -45 to 45 in "border space" if rotated?
      // Let's stick to the visual result:
      // Rotated 45deg:
      // Top-Right Quadrant: Cyan
      // Bottom-Right Quadrant: Pink
      // Bottom-Left Quadrant: Transparent
      // Top-Left Quadrant: Yellow
      
      // Arc logic (0 is Right):
      // Top-Right: 270 to 360 (or -90 to 0)
      // Bottom-Right: 0 to 90
      // Bottom-Left: 90 to 180
      // Top-Left: 180 to 270
      
      // With 45 deg rotation clockwise:
      // Top (270-360) -> 315 to 45 (Top-Rightish)
      // Wait, let's just draw quadrants in local space and rotate canvas.
      
      // Border-Top: Top quadrant (225 to 315 in standard math? No, Top is 225-315 is Bottom-Left??)
      // Standard Canvas: 
      // Top is 270 (-90).
      // Border-Top covers the top 90 degrees? (-135 to -45).
      -3 * pi / 4, // Start -135
      pi / 2, // Sweep 90
      false,
      paint
    );
    
    // Border-Right: Pink
    paint.color = AppColors.stitchPink.withOpacity(0.8);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 4, // Start -45
      pi / 2, // Sweep 90
      false,
      paint
    );
    
    // Border-Left: Primary (Yellow)
    paint.color = AppColors.stitchPrimary.withOpacity(0.8);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      3 * pi / 4, // Start 135
      pi / 2,
      false,
      paint
    );
    
    // Border-Bottom: Transparent (Skip)

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
