import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';

class LobbyTitle extends StatelessWidget {
  const LobbyTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // "GTO" 3D Text
        Stack(
          children: [
            // Shadow Layer (Depth)
            Text(
              'GTO',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 64,
                fontWeight: FontWeight.w900,
                color: AppColors.stitchDarkBG, // Shadow color
                height: 1.0,
              ),
            ),
            // Main Text Layer
            Transform.translate(
              offset: const Offset(-4, -4),
              child: Text(
                'GTO',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 64,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF2A2A5A), // Dark Blue 3D face
                  height: 1.0,
                  shadows: [
                     BoxShadow(
                       color: Colors.black.withOpacity(0.5),
                       blurRadius: 10,
                       offset: const Offset(5, 5),
                     )
                  ],
                ),
              ),
            ),
          ],
        ),
        
        // "LEAGUE" Text
        Transform.translate(
          offset: const Offset(0, -10),
          child: Text(
            'LEAGUE',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: AppColors.stitchPrimary,
              letterSpacing: 2.0,
              height: 1.0,
              shadows: [
                BoxShadow(
                  color: AppColors.acidYellow.withOpacity(0.5), // Glow
                  blurRadius: 10,
                ),
                const BoxShadow(
                  color: Colors.black, // Drop shadow
                  offset: Offset(2, 2),
                  blurRadius: 2,
                )
              ]
            ),
          ),
        ),

        const SizedBox(height: 8),

        // Subtitle Pill
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
            boxShadow: [
              BoxShadow(
                color: AppColors.stitchDeepBlue.withOpacity(0.5),
                blurRadius: 10,
              )
            ]
          ),
          child: Text(
            '홀덤 푸시폴드 배틀', // Korean subtitle
            style: GoogleFonts.notoSansKr( // Assuming NotoSans or fallback
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ),
      ],
    );
  }
}
