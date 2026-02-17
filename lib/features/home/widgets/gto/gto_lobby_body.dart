import 'package:flutter/material.dart';
import 'gto_top_bar.dart';
import 'gto_title.dart';
import 'gto_hero_stage.dart';
import 'gto_right_menu.dart';
import 'gto_comp_play_button.dart';

class GtoLobbyBody extends StatelessWidget {
  const GtoLobbyBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
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
                ],
              ),
            ),

            // Play Button (배틀 시작 + speech bubble)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GtoCompPlayButton(
                onPressed: () {
                  Navigator.of(context).pushNamed('/game'); // Keep push for Game screen?
                },
              ),
            ),

            // Space for bottom nav bar so play button isn't covered
            const SizedBox(height: 140),
          ],
        ),

        // Side Menu (Achievements/Mail) - Global positioning
        // "왼쪽 제일위 리그 브론즈 UI 아래에 세로로"
        const Positioned(
          left: 12, top: 110,
          child: GtoRightMenu(),
        ),
      ],
    );
  }
}
