import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class LobbyBottomNav extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const LobbyBottomNav({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80, // Reduced from 100 for better proportion
      decoration: BoxDecoration(
        color: AppColors.stitchDarkBG.withOpacity(0.9),
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.1))),
      ),
      child: ClipRect( // Backdrop filter needs clip
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _NavItem(icon: Icons.storefront, label: '상점', isSelected: selectedIndex == 0, onTap: () => onItemSelected(0)),
              _NavItem(icon: Icons.style, label: '덱', isSelected: selectedIndex == 1, onTap: () => onItemSelected(1)),
              _ActiveHomeItem(onTap: () => onItemSelected(2)), // Home is center
              _NavItem(icon: Icons.leaderboard, label: '랭킹', isSelected: selectedIndex == 3, onTap: () => onItemSelected(3)),
              _NavItem(icon: Icons.account_circle, label: '프로필', isSelected: selectedIndex == 4, onTap: () => onItemSelected(4)),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({required this.icon, required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? Colors.white : Colors.white.withOpacity(0.4);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

class _ActiveHomeItem extends StatelessWidget {
  final VoidCallback onTap;
  const _ActiveHomeItem({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Transform.translate(
        offset: const Offset(0, -20), // Pop up
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Glowing Circle
            Container(
              width: 64, height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.stitchCyan.withOpacity(0.1),
                border: Border.all(color: AppColors.stitchCyan.withOpacity(0.4)),
                boxShadow: [
                  BoxShadow(color: AppColors.stitchCyan.withOpacity(0.4), blurRadius: 20)
                ],
              ),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.stitchCyan,
                  boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))]
                ),
                child: const Icon(Icons.home, color: AppColors.stitchDarkBG, size: 32),
              ),
            ),
            const SizedBox(height: 8),
            const Text('홈', style: TextStyle(color: AppColors.stitchCyan, fontSize: 10, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
