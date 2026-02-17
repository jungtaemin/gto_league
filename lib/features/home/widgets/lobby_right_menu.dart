import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class LobbyRightMenu extends StatelessWidget {
  const LobbyRightMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _buildCircularButton(Icons.emoji_events, "업적", AppColors.stitchPink),
        const SizedBox(height: 16),
        _buildCircularButton(Icons.mail, "우편", AppColors.stitchCyan, showBadge: true),
      ],
    );
  }

  Widget _buildCircularButton(IconData icon, String label, Color color, {bool showBadge = false}) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.05),
            border: Border.all(color: color.withOpacity(0.3)),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.2),
                blurRadius: 15,
                spreadRadius: 0,
              )
            ],
          ),
          child: Material(
            color: Colors.transparent,
            shape: const CircleBorder(),
            child: InkWell(
              onTap: () {},
              customBorder: const CircleBorder(),
              child: Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  Icon(icon, color: color, size: 28),
                  if (showBadge)
                    Positioned(
                      top: 10,
                      right: 12, // Adjusted for circular feel
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: AppColors.laserRed,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.stitchDarkBG, width: 2),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}
