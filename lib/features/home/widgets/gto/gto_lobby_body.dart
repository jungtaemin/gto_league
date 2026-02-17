import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'gto_top_bar.dart';
import 'gto_hero_stage.dart';
import 'stitch_colors.dart';
import 'dart:ui';

/// Stitch V2 Lobby Body
/// Matches stitch_15bb.html layout exactly.
class GtoLobbyBody extends StatelessWidget {
  const GtoLobbyBody({super.key});

  @override
  Widget build(BuildContext context) {
    // HTML Layout Structure:
    // 1. Top Bar
    // 2. Logo (Center Top)
    // 3. Robot (Flex Expanded)
    // 4. Battle Button (Bottom)
    // 5. Right Side Menu (Absolute Top-Right)

    return Stack(
      children: [
        // Main Flow
        Column(
          children: [
            // 1. Top Bar
            const Padding(
              padding: EdgeInsets.only(top: 8.0),
              child: GtoTopBar(),
            ),

            const SizedBox(height: 10),

            // 2. Logo Section (Moved to Top)
            _buildLogoSection(),

            // 3. Hero Stage (Robot)
            const Expanded(
              child: GtoHeroStage(),
            ),

            // 4. Battle Button
            Padding(
              padding: const EdgeInsets.only(left: 24.0, right: 24.0, bottom: 100.0), // 100px for Nav
              child: _buildBattleButton(context),
            ),
          ],
        ),

        // 5. Right Side Menu (Absolute Position from HTML: top-[140px] right-[-10px])
        Positioned(
          top: 140,
          right: 0,
          child: _buildRightSideMenu(),
        ),
      ],
    );
  }

  Widget _buildLogoSection() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 140, // Increased to prevent GTO/LEAGUE overlap
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              // --- GTO LAYER ---
              // 1. Deep Shadow (The "Ground" shadow)
              Positioned(
                top: 5,
                child: Text("GTO", style: TextStyle(
                  fontFamily: 'Black Han Sans', fontSize: 72, 
                  color: Colors.black.withOpacity(0.3),
                  letterSpacing: 2.0,
                  shadows: const [Shadow(color: Colors.black45, offset: Offset(0, 10), blurRadius: 12)],
                )),
              ),
              // 2. Extrusion (Dark Blue Sides)
              Positioned(
                top: 4,
                child: Text("GTO", style: TextStyle(
                  fontFamily: 'Black Han Sans', fontSize: 72,
                  color: const Color(0xFF1E3A8A), // Deep Blue
                  letterSpacing: 2.0,
                )),
              ),
              // 3. Main Face (Gradient Blue)
              Positioned(
                top: 0,
                child: ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [Color(0xFF93C5FD), Color(0xFF3B82F6)], // Light Blue to Blue
                    begin: Alignment.topCenter, end: Alignment.bottomCenter,
                    stops: [0.2, 1.0],
                  ).createShader(bounds),
                  child: const Text("GTO", style: TextStyle(
                    fontFamily: 'Black Han Sans', fontSize: 72, color: Colors.white,
                    letterSpacing: 2.0,
                  )),
                ),
              ),

              // --- LEAGUE LAYER ---
              // 1. Deep Shadow
              Positioned(
                bottom: 0,
                child: Text("LEAGUE", style: TextStyle(
                  fontFamily: 'Black Han Sans', fontSize: 40,
                  color: Colors.black.withOpacity(0.5),
                  letterSpacing: 1.0,
                  shadows: const [Shadow(color: Colors.black45, offset: Offset(0, 8), blurRadius: 8)],
                )),
              ),
              // 2. Extrusion (Dark Orange/Brown)
              Positioned(
                bottom: 2,
                child: Text("LEAGUE", style: TextStyle(
                  fontFamily: 'Black Han Sans', fontSize: 40,
                  color: const Color(0xFF7C2D12), // Dark Brown
                  letterSpacing: 1.0,
                  shadows: const [
                    Shadow(color: Color(0xFF7C2D12), offset: Offset(0, 2)),
                    Shadow(color: Color(0xFF7C2D12), offset: Offset(2, 2)),
                    Shadow(color: Color(0xFF7C2D12), offset: Offset(-2, 2)),
                  ], // Fake stroke/bulk
                )),
              ),
              // 3. Main Face (Gradient Yellow-Orange)
              Positioned(
                bottom: 4,
                child: ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [Color(0xFFFDE047), Color(0xFFF97316)], // Yellow to Orange
                    begin: Alignment.topCenter, end: Alignment.bottomCenter,
                  ).createShader(bounds),
                  child: const Text("LEAGUE", style: TextStyle(
                    fontFamily: 'Black Han Sans', fontSize: 40, color: Colors.white,
                    letterSpacing: 1.0,
                  )),
                ),
              ),
            ],
          ),
        ),
        
        // Chip Tag
        Container(
          margin: const EdgeInsets.only(top: 8),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF172554).withOpacity(0.8), // blue-950
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: StitchColors.blue500.withOpacity(0.5), width: 1),
            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))],
          ),
          child: const Text("홀덤 푸시폴드 배틀", style: TextStyle(
            color: StitchColors.blue200, fontSize: 13, fontWeight: FontWeight.normal, letterSpacing: 0.5
          )),
        ),
      ],
    );
  }

  Widget _buildBattleButton(BuildContext context) {
    // HTML: w-full h-[88px] relative group active:scale-95
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/game'),
      child: SizedBox(
        height: 88,
        width: double.infinity,
        child: Stack(
          children: [
            // Button Body
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(32), // rounded-[2rem]
                gradient: const LinearGradient(
                  begin: Alignment.topCenter, end: Alignment.bottomCenter,
                  colors: [StitchColors.buttonGoldStart, StitchColors.buttonGoldMid, StitchColors.buttonGoldEnd],
                ),
                boxShadow: [
                  const BoxShadow(color: StitchColors.shadowGold, offset: Offset(0, 6), blurRadius: 0), // 3D bevel
                  BoxShadow(color: Colors.black.withOpacity(0.4), offset: const Offset(0, 15), blurRadius: 20),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(32),
                child: Stack(
                  children: [
                    // Top Border Simulation (border-t border-yellow-200)
                    Positioned(top: 0, left: 0, right: 0, height: 1, child: Container(color: StitchColors.yellow200)),
                    
                    // Content
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                           // Icon Container
                           Transform.rotate(
                             angle: -12 * 3.14159 / 180,
                             child: const Icon(Icons.sports_mma, size: 48, color: Color(0xFF6D4C41)),
                           ),
                           const SizedBox(width: 12),
                           // Text
                           const Text("배틀 시작", style: TextStyle(
                             fontFamily: 'Black Han Sans', fontSize: 32, 
                             color: Color(0xFF5D4037), letterSpacing: 1.0,
                             height: 1.2,
                             shadows: [Shadow(color: Colors.white24, offset: Offset(0, 1), blurRadius: 0)],
                           )),
                           const SizedBox(width: 8),
                           // Arrow
                           const Icon(Icons.navigate_next_rounded, size: 40, color: Color(0xFF8D6E63)),
                        ],
                      ),
                    ),
                    
                    // Shine Effect
                    Positioned(
                      top: 0, left: 0, right: 0, height: 44,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter, end: Alignment.bottomCenter,
                            colors: [Colors.white.withOpacity(0.3), Colors.transparent],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRightSideMenu() {
    return Column(
      children: [
        _buildSideButton(Icons.emoji_events_rounded, "업적", StitchColors.blue400),
        const SizedBox(height: 16),
        _buildSideButton(Icons.mail_rounded, "우편함", StitchColors.cyan400),
      ],
    );
  }

  Widget _buildSideButton(IconData icon, String label, Color color) {
    // w-[50px] h-[50px] bg-white/10 rounded-l-2xl border-l-3 ...
    // Fix: Cannot use borderRadius with non-uniform Border.
    return Container(
      width: 50, height: 50,
      margin: const EdgeInsets.only(right: 0),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
        // border: Border(left: BorderSide(color: color, width: 3)), // Removed
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8)],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
        child: Stack(
          children: [
            // Left Accent Border
            Positioned(
              left: 0, top: 0, bottom: 0,
              child: Container(width: 3, color: color),
            ),
            // Content
            Center(
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  Icon(icon, color: StitchColors.blue300, size: 28),
                  Positioned(
                    bottom: -18,
                    child: Text(label, style: const TextStyle(
                      color: StitchColors.blue300, fontSize: 10, fontWeight: FontWeight.bold,
                      shadows: [Shadow(color: Colors.black, blurRadius: 2)],
                    )),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 600.ms).slideX(begin: 1, end: 0, curve: Curves.easeOutBack);
  }
}
