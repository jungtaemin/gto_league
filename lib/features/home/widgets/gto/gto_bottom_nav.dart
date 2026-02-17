import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Stitch V1 Bottom Nav: glass bg, diamond battle icon, 5 tabs
class GtoBottomNav extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;

  const GtoBottomNav({
    super.key,
    this.selectedIndex = 2,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // Stitch: bg-nav-gradient backdrop-blur-lg rounded-t-[2rem] border-t border-white/5
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            const Color(0xFF0F172A).withOpacity(0.95),
            const Color(0xFF1E293B).withOpacity(0.8),
          ],
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05))),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 20, offset: const Offset(0, -5)),
        ],
      ),
      padding: const EdgeInsets.only(bottom: 12, top: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _buildNavItem(0, Icons.storefront_rounded, "상점"),
          _buildNavItem(1, Icons.card_giftcard_rounded, "이벤트"),
          _buildBattleDiamond(),
          _buildNavItem(3, Icons.school_rounded, "훈련하기"),
          _buildNavItem(4, Icons.bar_chart_rounded, "랭킹"),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = selectedIndex == index;
    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: isSelected ? Colors.white : const Color(0xFFCBD5E1), size: 24),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(
              color: isSelected ? Colors.white : const Color(0xFF94A3B8),
              fontSize: 10, fontWeight: FontWeight.bold, fontFamily: 'Jua',
            )),
          ],
        ),
      ),
    );
  }

  /// Stitch V1: Diamond-shaped (rotate-45) blue gradient battle button
  Widget _buildBattleDiamond() {
    return GestureDetector(
      onTap: () => onTap(2),
      child: SizedBox(
        width: 64, height: 80,
        child: Stack(
          alignment: Alignment.topCenter,
          clipBehavior: Clip.none,
          children: [
            // Diamond button
            Positioned(
              top: -24,
              child: Transform.rotate(
                angle: math.pi / 4,
                child: Container(
                  width: 56, height: 56,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    border: Border(top: BorderSide(color: const Color(0xFF60A5FA), width: 1)),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF3B82F6).withOpacity(0.6),
                        blurRadius: 15, spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Transform.rotate(
                      angle: -math.pi / 4,
                      child: _buildCrossedSwordsIcon(24, const Color(0xFFFDE047)),
                    ),
                  ),
                ),
              ),
            ),
            // Label
            Positioned(
              bottom: 0,
              child: Text("배틀", style: TextStyle(
                color: const Color(0xFFFBBF24), fontSize: 11,
                fontWeight: FontWeight.w900, fontFamily: 'Jua',
                letterSpacing: 1,
                shadows: [Shadow(color: Colors.black.withOpacity(0.3), blurRadius: 2)],
              )),
            ),
          ],
        ),
      ),
    );
  }

  /// Cross/swords icon matching Stitch SVG
  Widget _buildCrossedSwordsIcon(double size, Color color) {
    return CustomPaint(
      size: Size(size, size),
      painter: _CrossSwordsPainter(color),
    );
  }
}

class _CrossSwordsPainter extends CustomPainter {
  final Color color;
  _CrossSwordsPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // Two crossed lines
    canvas.drawLine(Offset(4, 4), Offset(size.width - 4, size.height - 4), paint);
    canvas.drawLine(Offset(size.width - 4, 4), Offset(4, size.height - 4), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
