import 'package:flutter/material.dart';
import 'widgets/gto/gto_background.dart';
import 'widgets/gto/gto_top_bar.dart';
import 'widgets/gto/gto_title.dart';
import 'widgets/gto/gto_hero_stage.dart';
import 'widgets/gto/gto_right_menu.dart';
import 'widgets/gto/gto_comp_play_button.dart';
import 'widgets/gto/gto_bottom_nav.dart';

/// GTO League Home Screen – Stitch V1 layout
class GtoHomeScreen extends StatefulWidget {
  const GtoHomeScreen({super.key});

  @override
  State<GtoHomeScreen> createState() => _GtoHomeScreenState();
}

class _GtoHomeScreenState extends State<GtoHomeScreen> {
  int _navIndex = 2; // default to battle tab

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Layer 0: Full-screen background (gradient + bokeh + floating cards)
          const Positioned.fill(child: GtoBackground()),

          // Layer 1: Main content column
          SafeArea(
            child: Column(
              children: [
                // Top Status Bar
                const GtoTopBar(),

                // Title Section (GTO LEAGUE + subtitle pill)
                const SizedBox(height: 4),
                const GtoTitle(),

                // Hero Stage (arc + robot + podium + side buttons)
                Expanded(
                  child: Stack(
                    alignment: Alignment.center,
                    clipBehavior: Clip.none,
                    children: [
                      const GtoHeroStage(),

                      // Right side menu (achievements + mail)
                      const Positioned(
                        right: 12,
                        top: 80,
                        child: GtoRightMenu(),
                      ),
                    ],
                  ),
                ),

                // Play Button (배틀 시작 + speech bubble)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GtoCompPlayButton(
                    onPressed: () {
                      // TODO: Navigate to battle screen
                    },
                  ),
                ),

                // Space for bottom nav bar so play button isn't covered
                const SizedBox(height: 140),
              ],
            ),
          ),

          // Layer 2: Bottom Navigation Bar (pinned to bottom)
          Positioned(
            left: 0, right: 0, bottom: 0,
            child: GtoBottomNav(
              selectedIndex: _navIndex,
              onTap: (index) {
                setState(() { _navIndex = index; });
                // TODO: Navigate to corresponding screens
              },
            ),
          ),
        ],
      ),
    );
  }
}
