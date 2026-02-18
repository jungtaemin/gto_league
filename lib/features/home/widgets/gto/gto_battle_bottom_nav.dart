import 'package:flutter/material.dart';
import 'stitch_colors.dart';

class GtoBattleBottomNav extends StatelessWidget {
  const GtoBattleBottomNav({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      padding: const EdgeInsets.only(bottom: 10),
      color: const Color(0xFF0F102A).withOpacity(0.8), // background-dark
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.storefront_rounded, "상점"),
          _buildNavItem(Icons.card_giftcard_rounded, "이벤트"),
          
          // Center Battle Button (Active)
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Transform.translate(
                offset: const Offset(0, -20),
                child: Transform.rotate(
                  angle: 0.785, // 45 deg
                  child: Container(
                    width: 56, height: 56,
                    decoration: BoxDecoration(
                      color: StitchColors.blue600,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: StitchColors.blue400, width: 2),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 10, offset: const Offset(0, 5)),
                      ],
                    ),
                    child: Center(
                      child: Transform.rotate(
                        angle: -0.785, // -45 deg to correct icon
                        child: const Icon(Icons.sports_kabaddi_rounded, color: Colors.white, size: 30), // swords alternative
                      ),
                    ),
                  ),
                ),
              ),
              Transform.translate(
                offset: const Offset(0, -10),
                child: const Text("배틀", style: TextStyle(
                  color: StitchColors.blue400, fontSize: 10, fontWeight: FontWeight.bold
                )),
              ),
            ],
          ),

          _buildNavItem(Icons.school_rounded, "훈련하기"),
          _buildNavItem(Icons.bar_chart_rounded, "랭킹"),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white54, size: 26),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 10)),
      ],
    );
  }
}
