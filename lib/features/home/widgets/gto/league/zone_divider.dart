import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/utils/responsive.dart';

/// Zone divider with a gradient line and a centered badge label.
class ZoneDivider extends StatelessWidget {
  const ZoneDivider({
    super.key,
    required this.label,
    required this.color,
    required this.icon,
  });

  final String label;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: context.w(16),
        vertical: context.w(8),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.transparent, color, Colors.transparent],
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: context.w(12),
              vertical: context.w(4),
            ),
            decoration: BoxDecoration(
              color: AppColors.leagueBgDark,
              borderRadius: BorderRadius.circular(context.r(12)),
              border: Border.all(color: color.withValues(alpha: 0.5)),
              boxShadow: [
                BoxShadow(color: color.withValues(alpha: 0.3), blurRadius: 10),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: color, size: context.w(14)),
                SizedBox(width: context.w(4)),
                Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontSize: context.sp(10),
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
