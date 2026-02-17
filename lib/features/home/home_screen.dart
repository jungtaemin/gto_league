import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/game_state_notifier.dart';
import 'widgets/lobby_background.dart';
import 'widgets/lobby_status_bar.dart';
import 'widgets/lobby_title.dart';
import 'widgets/lobby_hero_stage.dart';
import 'widgets/lobby_bottom_cta.dart';
import 'widgets/lobby_bottom_nav.dart';
import 'widgets/lobby_right_menu.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.black, // Fallback
      body: LobbyBackground(
        child: Stack(
          children: [
            // 1. Center Hero Stage (Behind UI)
            const Positioned.fill(
              child: Padding(
                padding: EdgeInsets.only(bottom: 120), // Push up for bottom nav/cta
                child: Center(child: LobbyHeroStage()),
              ),
            ),

            // 2. Top UI: Status Bar
            const Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(child: LobbyStatusBar()),
            ),
            
            // 3. Title (Below Status Bar + Centered)
            const Positioned(
               top: 100, // Adjusted based on status bar height
               left: 0, right: 0,
               child: Center(child: LobbyTitle()),
            ),

            // 4. Right Side Menu
            const Positioned(
              right: 16,
              top: 0, bottom: 0,
              child: Center( // Align vertically center-ish
                child: Padding(
                  padding: EdgeInsets.only(bottom: 100), // Push up
                  child: LobbyRightMenu(),
                ),
              ),
            ),

            // 5. Bottom UI: CTA & NavBar
            Positioned(
              bottom: 0,
              left: 0, right: 0,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                   // Speech Bubble (Optional - add later if needed)
                   
                   // CTA Button
                   LobbyBottomCTA(
                     onPressed: () {
                       ref.read(gameStateNotifierProvider.notifier).reset();
                       Navigator.of(context).pushNamed('/game');
                     },
                   ),
                   
                   // Bottom Nav
                   LobbyBottomNav(
                     selectedIndex: 2, // Home
                     onItemSelected: (index) {},
                   ),
                ],
              ),
            ),
          ],
        )
        .animate()
        .fadeIn(duration: 800.ms),
      ),
    );
  }
}
