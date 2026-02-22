import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:holdem_allin_fold/core/theme/app_colors.dart';

/// 🚨 기습 공격! Defense mode alert banner (E-Sports Enhanced).
/// Shown when the current card is from the CALL chart (opponent pushes all-in).
class DefenseAlertBanner extends StatelessWidget {
  final String opponentPosition;
  final String actionHistory;
  
  const DefenseAlertBanner({
    super.key,
    required this.opponentPosition,
    this.actionHistory = '',
  });

  /// Parse actionHistory to create a detailed message like "HJ 올인 CO 콜"
  String _buildMultiMessage() {
    if (actionHistory.isEmpty) return '$opponentPosition이 올인! 콜 or 폴드?';
    
    String pusher = opponentPosition;
    List<String> callers = [];
    
    for (final part in actionHistory.split(', ')) {
      final trimmed = part.trim();
      if (trimmed.contains('pushes')) {
        pusher = _normalizePos(trimmed.split(' ').first);
      } else if (trimmed.contains('calls')) {
        callers.add(_normalizePos(trimmed.split(' ').first));
      }
    }
    
    if (callers.isEmpty) {
      return '$pusher이 올인! 콜 or 폴드?';
    }
    
    final callerString = callers.join(', ');
    return '$pusher 올인 $callerString 콜! 콜 or 폴드?';
  }

  static String _normalizePos(String pos) {
    switch (pos.toUpperCase()) {
      case 'BTN': return 'BU';
      case 'UTG1': return 'UTG+1';
      case 'UTG2': return 'UTG+2';
      default: return pos.toUpperCase();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Stack(
        children: [
          // Warning stripes background (subtle 45° yellow/black)
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Opacity(
                opacity: 0.12,
                child: CustomPaint(
                  painter: _WarningStripesPainter(),
                ),
              ),
            ),
          ),
          // Main content container
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.laserRed.withOpacity(0.25),
                  AppColors.laserRed.withOpacity(0.15),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.laserRed.withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 0,
                ),
                // Intensified second glow layer
                ...AppColors.neonGlow(AppColors.laserRed, intensity: 0.8),
              ],
            ),
            child: Row(
              children: [
                // Pulsing alert icon
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.laserRed.withOpacity(0.3),
                  ),
                  child: const Center(
                    child: Text('🚨', style: TextStyle(fontSize: 18)),
                  ),
                )
                    .animate(onPlay: (c) => c.repeat())
                    .scale(
                      begin: const Offset(1.0, 1.0),
                      end: const Offset(1.15, 1.15),
                      duration: 600.ms,
                    )
                    .then()
                    .scale(
                      begin: const Offset(1.15, 1.15),
                      end: const Offset(1.0, 1.0),
                      duration: 600.ms,
                    ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Neon glowing alert text
                      Text(
                        actionHistory.contains('calls') ? '🔥 다중 올인!' : '기습 공격!',
                        style: TextStyle(
                          color: AppColors.laserRed,
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.0,
                          shadows: [
                            Shadow(color: AppColors.laserRed, blurRadius: 8),
                            Shadow(color: AppColors.laserRed.withOpacity(0.6), blurRadius: 20),
                          ],
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _buildMultiMessage(),
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                // Defense shield icon
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.laserRed.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.laserRed.withOpacity(0.4),
                    ),
                  ),
                  child: const Text(
                    '🛡️ 방어',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Red/Gold animated flashing border overlay (300ms cycle)
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.laserRed.withOpacity(0.8),
                    width: 2.5,
                  ),
                ),
              )
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .tint(color: AppColors.acidYellow.withOpacity(0.8), duration: 150.ms),
            ),
          ),
        ],
      ),
    )
        .animate()
        .slideY(begin: -1.0, end: 0, duration: 400.ms, curve: Curves.easeOutBack)
        .fadeIn(duration: 300.ms);
  }
}

/// Diagonal 45° warning stripes (yellow on transparent)
class _WarningStripesPainter extends CustomPainter {
  _WarningStripesPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.acidYellow
      ..style = PaintingStyle.fill;

    const stripeWidth = 10.0;
    const gap = 10.0;
    const step = stripeWidth + gap;

    for (double x = -size.height; x < size.width; x += step) {
      final path = Path()
        ..moveTo(x, 0)
        ..lineTo(x + stripeWidth, 0)
        ..lineTo(x + stripeWidth + size.height, size.height)
        ..lineTo(x + size.height, size.height)
        ..close();
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
