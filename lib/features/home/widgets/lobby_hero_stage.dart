import 'package:flutter/material.dart';
import 'lobby_progress_arc.dart';
import 'lobby_podium.dart';
import 'lobby_character.dart';

class LobbyHeroStage extends StatelessWidget {
  const LobbyHeroStage({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      height: 480, // Increased height
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 1. Progress Arc (Center)
           const Positioned(
             top: 40,
             child: LobbyProgressArc(),
           ),

          // 2. Podium (Bottom)
           const Positioned(
             bottom: 40,
             child: LobbyPodium(),
           ),

          // 3. Character (Floating above Podium)
           const Positioned(
              bottom: 60, // Sits slightly above podium (float handled internally)
              child: LobbyCharacter(),
           ),
        ],
      ),
    );
  }
}
