import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';

class LobbyStatusBar extends StatelessWidget {
  const LobbyStatusBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Bronze Badge
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFFCD7F32), Color(0xFFFFDAAB)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                 BoxShadow(
                   color: Colors.black.withOpacity(0.3),
                   blurRadius: 6,
                   offset: const Offset(0, 4),
                 )
              ],
            ),
            padding: const EdgeInsets.all(2),
            child: Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF3A2211), // Dark bronze inner
              ),
              child: Center(
                child: Image.asset(
                  'assets/images/lobby_badge_bronze.png',
                  width: 32,
                  height: 32,
                  errorBuilder: (c, e, s) => const Icon(Icons.shield, color: Color(0xFFCD7F32), size: 24),
                ),
              ),
            ),
          ),
          
          const SizedBox(width: 12),
          
          // 2. Currency & Energy
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Currency
                Container(
                  height: 32,
                  margin: const EdgeInsets.only(bottom: 6),
                  padding: const EdgeInsets.only(right: 12, left: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 24, height: 24,
                        decoration: const BoxDecoration(
                          color: AppColors.stitchPrimary,
                          shape: BoxShape.circle,
                        ),
                        child: const Center(child: Text('G', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 10))),
                      ),
                      const SizedBox(width: 8),
                      Text('1,240,500', style: GoogleFonts.spaceGrotesk(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                      const SizedBox(width: 8),
                      Container(
                        width: 20, height: 20,
                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), shape: BoxShape.circle),
                        child: const Icon(Icons.add, size: 14, color: Colors.white),
                      )
                    ],
                  ),
                ),
                
                // Energy
                Container(
                  height: 32,
                  padding: const EdgeInsets.only(right: 12, left: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 24, height: 24,
                        decoration: const BoxDecoration(
                            color: AppColors.stitchCyan,
                            shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.bolt, size: 14, color: Colors.black),
                      ),
                      const SizedBox(width: 8),
                      Text('45/50', style: GoogleFonts.spaceGrotesk(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                      const SizedBox(width: 8),
                      Text('08:12', style: GoogleFonts.spaceGrotesk(color: AppColors.stitchCyan, fontSize: 10, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // 3. Settings
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
               color: Colors.white.withOpacity(0.05),
               shape: BoxShape.circle,
               border: Border.all(color: Colors.white.withOpacity(0.1)),
               boxShadow: [
                 BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 4),
               ]
            ),
            child: const Icon(Icons.settings, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
