import 'package:flutter/material.dart';
import 'widgets/gto/gto_background.dart';
import 'widgets/gto/gto_bottom_nav.dart';
import 'widgets/gto/gto_lobby_body.dart';
import 'widgets/gto/gto_league_body.dart';

/// GTO League Home Screen – Stitch V1 layout
class GtoHomeScreen extends StatefulWidget {
  const GtoHomeScreen({super.key});

  @override
  State<GtoHomeScreen> createState() => _GtoHomeScreenState();
}

class _GtoHomeScreenState extends State<GtoHomeScreen> {
  int _navIndex = 2; // default to battle tab (Lobby)

  @override
  Widget build(BuildContext context) {
    print('BUILDING GTO HOME SCREEN V2');
    return Scaffold(
      body: Stack(
        children: [
          // Layer 0: Full-screen background (Persistent)
          const Positioned.fill(child: GtoBackground()),

          // Layer 1: Body Content (Switchable)
          Positioned.fill(
            child: SafeArea(
              bottom: false,
              child: IndexedStack(
                index: _navIndex,
                children: [
                  const Center(child: Text("Shop (Wait)", style: TextStyle(color: Colors.white))), // 0
                  const Center(child: Text("Deck (Wait)", style: TextStyle(color: Colors.white))), // 1
                  const GtoLobbyBody(), // 2: Home
                  const GtoLeagueBody(), // 3: Ranking
                  const Center(child: Text("Profile (Wait)", style: TextStyle(color: Colors.white))), // 4
                ],
              ),
            ),
          ),

          // Layer 2: Bottom Navigation Bar (Persistent)
          Positioned(
            left: 0, right: 0, bottom: 0,
            child: GtoBottomNav(
              selectedIndex: _navIndex,
              onTap: (index) {
                setState(() { _navIndex = index; });
                // If special handling needs to push route instead of tab switch?
                // User requirement: "below menu layout maintain... touch and scroll comfortably"
                // Tab switching is best for this.
                // However, Play Button in LobbyBody still pushes '/game'.
              },
            ),
          ),
        ],
      ),
    );
  }
}
