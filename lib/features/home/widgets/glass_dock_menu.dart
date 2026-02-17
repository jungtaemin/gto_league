import 'package:flutter/material.dart';
import 'dart:ui';
import '../../../core/theme/app_colors.dart';

class GlassDockMenu extends StatelessWidget {
  const GlassDockMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final menuItems = [
      _DockItem(Icons.storefront_rounded, "Shop", AppColors.neonPink),
      _DockItem(Icons.inventory_2_rounded, "Deck", AppColors.electricBlue),
      _DockItem(Icons.emoji_events_rounded, "Rank", AppColors.acidGreen),
      _DockItem(Icons.assignment_rounded, "Quest", AppColors.neonPurple),
    ];

    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.4),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.white.withOpacity(0.15)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              )
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: menuItems.map((item) => _buildDockItem(context, item)).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildDockItem(BuildContext context, _DockItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: item.color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: item.color.withOpacity(0.5), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: item.color.withOpacity(0.3),
                  blurRadius: 10,
                  spreadRadius: -2,
                )
              ],
            ),
            child: Icon(item.icon, color: Colors.white, size: 28),
          ),
          const SizedBox(height: 4),
          Text(
            item.label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          )
        ],
      ),
    );
  }
}

class _DockItem {
  final IconData icon;
  final String label;
  final Color color;
  _DockItem(this.icon, this.label, this.color);
}
