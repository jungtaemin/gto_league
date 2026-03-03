import 'package:flutter/material.dart';
import 'package:holdem_allin_fold/core/theme/app_colors.dart';

/// Robot avatar widget for 9 poker table seats
/// 
/// Displays AI-generated bot avatar images per seat index.
/// Supports folded state (grayscale + opacity), active state (glow), and hero state (gold border).
class RobotAvatarWidget extends StatelessWidget {
  final int seatIndex;      // 0-8 for 9 seats
  final double size;        // Avatar size in logical pixels
  final bool isActive;      // Active/hero turn indicator
  final bool isFolded;      // Folded state indicator
  final bool isHero;        // Hero player indicator
  final String? avatarUrl;  // Custom avatar asset path (e.g., equipped character)

  const RobotAvatarWidget({
    super.key,
    required this.seatIndex,
    required this.size,
    this.isActive = false,
    this.isFolded = false,
    this.isHero = false,
    this.avatarUrl,
  });

  String _getAvatarPath() {
    // Use custom avatar if provided (equipped character)
    if (avatarUrl != null) return avatarUrl!;
    
    // Unify all other positions to use the main robot character
    return 'assets/images/characters/char_robot.webp';
  }

  @override
  Widget build(BuildContext context) {
    Widget avatar = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.grey.shade900, // Added background color 
        border: Border.all(
          color: isHero
              ? AppColors.pokerTableChipGold
              : isActive
                  ? AppColors.pokerTableActiveGlow
                  : Colors.white24,
          width: isHero ? size * 0.06 : size * 0.04,
        ),
      ),
      child: ClipOval(
        child: (avatarUrl != null && avatarUrl!.startsWith('http'))
            ? Image.network(
                avatarUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: Colors.grey.shade800,
                  child: Icon(Icons.smart_toy, color: Colors.white54, size: size * 0.5),
                ),
              )
            : Image.asset(
                _getAvatarPath(),
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: Colors.grey.shade800,
                  child: Icon(Icons.smart_toy, color: Colors.white54, size: size * 0.5),
                ),
              ),
      ),
    );

    // Apply folded state: 50% opacity
    if (isFolded) {
      avatar = Opacity(
        opacity: 0.5,
        child: avatar,
      );
    }

    // Apply active state: glow effect
    if (isActive) {
      avatar = Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.pokerTableActiveGlow.withValues(alpha: 0.6),
              blurRadius: 12,
              spreadRadius: 2,
            ),
            BoxShadow(
              color: AppColors.pokerTableActiveGlow.withValues(alpha: 0.3),
              blurRadius: 24,
              spreadRadius: 6,
            ),
          ],
        ),
        child: avatar,
      );
    }

    return avatar;
  }
}

/// CustomPainter for robot avatar
/// 
/// Draws a simple, cute robot with:
/// - Circle face
/// - Antenna
/// - Two colorful eyes
class _RobotAvatarPainter extends CustomPainter {
  final Color color;
  final double hue;
  final bool isActive;
  final bool isHero;

  _RobotAvatarPainter({
    required this.color,
    required this.hue,
    required this.isActive,
    required this.isHero,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Draw face circle
    final facePaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius * 0.85, facePaint);

    // Draw antenna (simple line with circle top)
    final antennaPaint = Paint()
      ..color = color.withValues(alpha: 0.7)
      ..strokeWidth = radius * 0.08
      ..strokeCap = StrokeCap.round;

    final antennaBase = Offset(center.dx, center.dy - radius * 0.75);
    final antennaTop = Offset(center.dx, center.dy - radius * 1.1);
    canvas.drawLine(antennaBase, antennaTop, antennaPaint);

    // Draw antenna ball
    final antennaBallPaint = Paint()
      ..color = color.withValues(alpha: 0.8)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(antennaTop, radius * 0.12, antennaBallPaint);

    // Draw left eye
    final leftEyeCenter = Offset(
      center.dx - radius * 0.35,
      center.dy - radius * 0.15,
    );
    final eyeRadius = radius * 0.18;

    // Eye white
    final eyeWhitePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(leftEyeCenter, eyeRadius, eyeWhitePaint);

    // Eye pupil (colorful - complementary hue)
    final pupilHue = (hue + 180.0) % 360.0;
    final eyePupilPaint = Paint()
      ..color = HSLColor.fromAHSL(1.0, pupilHue, 0.9, 0.4).toColor()
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      leftEyeCenter,
      eyeRadius * 0.6,
      eyePupilPaint,
    );

    // Draw right eye
    final rightEyeCenter = Offset(
      center.dx + radius * 0.35,
      center.dy - radius * 0.15,
    );

    canvas.drawCircle(rightEyeCenter, eyeRadius, eyeWhitePaint);
    canvas.drawCircle(
      rightEyeCenter,
      eyeRadius * 0.6,
      eyePupilPaint,
    );

    // Draw mouth (simple arc)
    final mouthPaint = Paint()
      ..color = color.withValues(alpha: 0.6)
      ..strokeWidth = radius * 0.06
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final mouthRect = Rect.fromCenter(
      center: Offset(center.dx, center.dy + radius * 0.35),
      width: radius * 0.4,
      height: radius * 0.2,
    );
    canvas.drawArc(mouthRect, 0, 3.14159, false, mouthPaint);
  }

  @override
  bool shouldRepaint(_RobotAvatarPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.hue != hue ||
        oldDelegate.isActive != isActive ||
        oldDelegate.isHero != isHero;
  }
}
