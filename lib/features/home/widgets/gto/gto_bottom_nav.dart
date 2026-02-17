import 'dart:ui';
import 'package:flutter/material.dart';

/// Stitch V2 Bottom Nav: Glassmorphism, 5 tabs, Center Home with Glow
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
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          height: 90,
          decoration: BoxDecoration(
            color: const Color(0xFF0D071E).withOpacity(0.9),
          ),
          child: Stack(
            children: [
              // Top border line (replaces non-uniform Border)
              Positioned(
                top: 0, left: 0, right: 0,
                child: Container(height: 1, color: Colors.white.withOpacity(0.1)),
              ),
              // Content
              Padding(
                padding: const EdgeInsets.only(bottom: 8, top: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _buildNavItem(0, Icons.storefront_rounded, "상점"),
                    _buildNavItem(1, Icons.style_rounded, "덱"),
                    _buildHomeButton(),
                    _buildNavItem(3, Icons.bar_chart_rounded, "랭킹"),
                    _buildNavItem(4, Icons.account_circle_rounded, "프로필"),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = selectedIndex == index;
    final color = isSelected ? Colors.white : Colors.white.withOpacity(0.4);

    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 60,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w500,
              letterSpacing: 1.0,
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeButton() {
    return GestureDetector(
      onTap: () => onTap(2),
      child: SizedBox(
        width: 70,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                // Outer Glow Ring
                Container(
                  width: 54, height: 54,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF22D3EE).withOpacity(0.2),
                    border: Border.all(color: const Color(0xFF22D3EE).withOpacity(0.4)),
                    boxShadow: [
                      BoxShadow(color: const Color(0xFF22D3EE).withOpacity(0.4), blurRadius: 20),
                    ],
                  ),
                ),
                // Inner Circle
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF22D3EE),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 4, offset: const Offset(0, 2)),
                    ],
                  ),
                  child: const Icon(Icons.home_rounded, color: Color(0xFF0D071E), size: 30),
                ),
              ],
            ),
            const SizedBox(height: 4),
            const Text("홈", style: TextStyle(
              color: Color(0xFF22D3EE),
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
            )),
          ],
        ),
      ),
    );
  }
}
