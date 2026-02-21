import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../core/widgets/bouncing_button.dart';
import '../../../../core/utils/responsive.dart';

/// Stitch V2 Bottom Nav: Glassmorphism, 5 tabs, Center Home with Glow
class GtoBottomNav extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;

  const GtoBottomNav({
    super.key,
    this.selectedIndex = 2,
    required this.onTap,
  });

  /// 외부에서 참조할 수 있는 고정 높이 (w 기준)
  static const double designHeight = 80;

  @override
  Widget build(BuildContext context) {
    // 높이를 w 기반으로 통일 (화면 비율 무관하게 일정한 높이)
    final navHeight = context.w(designHeight);
    final bottomPad = context.bottomSafePadding;

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          height: navHeight + bottomPad,
          padding: EdgeInsets.only(bottom: bottomPad),
          decoration: BoxDecoration(
            color: const Color(0xFF0D071E).withOpacity(0.9),
          ),
          child: Stack(
            children: [
              // Top border line
              Positioned(
                top: 0, left: 0, right: 0,
                child: Container(height: 1, color: Colors.white.withOpacity(0.1)),
              ),
              // Content
              Padding(
                padding: EdgeInsets.only(top: context.w(8)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildNavItem(context, 0, Icons.storefront_rounded, "상점"),
                    _buildNavItem(context, 1, Icons.palette_rounded, "꾸미기"),
                    _buildHomeButton(context),
                    _buildNavItem(context, 3, Icons.bar_chart_rounded, "리그"),
                    _buildNavItem(context, 4, Icons.school_rounded, "훈련하기"),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, int index, IconData icon, String label) {
    final isSelected = selectedIndex == index;
    final color = isSelected ? Colors.white : Colors.white.withOpacity(0.4);

    return BouncingButton(
      onTap: () => onTap(index),
      scaleDown: 0.9,
      child: SizedBox(
        width: context.w(56),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: context.w(24)),
            SizedBox(height: context.w(2)),
            Text(label, style: TextStyle(
              color: color,
              fontSize: context.sp(9),
              fontWeight: FontWeight.w500,
              letterSpacing: 1.0,
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeButton(BuildContext context) {
    return BouncingButton(
      onTap: () => onTap(2),
      scaleDown: 0.85,
      child: SizedBox(
        width: context.w(64),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                // Outer Glow Ring
                Container(
                  width: context.w(48), height: context.w(48),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF22D3EE).withOpacity(0.2),
                    border: Border.all(color: const Color(0xFF22D3EE).withOpacity(0.4)),
                    boxShadow: [
                      BoxShadow(color: const Color(0xFF22D3EE).withOpacity(0.4), blurRadius: context.w(16)),
                    ],
                  ),
                ),
                // Inner Circle
                Container(
                  width: context.w(38), height: context.w(38),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF22D3EE),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 4, offset: const Offset(0, 2)),
                    ],
                  ),
                  child: Icon(Icons.home_rounded, color: const Color(0xFF0D071E), size: context.w(24)),
                ),
              ],
            ),
            SizedBox(height: context.w(2)),
            Text("홈", style: TextStyle(
              color: const Color(0xFF22D3EE),
              fontSize: context.sp(9),
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
            )),
          ],
        ),
      ),
    );
  }
}
