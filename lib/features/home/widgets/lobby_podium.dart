import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class LobbyPodium extends StatelessWidget {
  const LobbyPodium({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 224, // w-56 (56 * 4 = 224)
      height: 60, // approximate height including shadow
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Contact Shadow (bur-xl)
          Positioned(
            bottom: 0,
            child: Container(
              width: 160, // w-40 (40 * 4 = 160)
              height: 32, // h-8
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(100),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.6),
                    blurRadius: 24, // blur-xl
                    spreadRadius: 4,
                  )
                ],
              ),
            ),
          ),
          
          // Main Body (Thick Glass Depth)
          Positioned(
            top: 8,
            child: Container(
              width: 192, // w-48
              height: 40, // h-10
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(100),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(color: Colors.transparent),
              ),
            ),
          ),
          
          // Top Surface (Glass + Bloom)
          Positioned(
            top: 0,
            child: Container(
              width: 224, // w-56
              height: 48, // h-12
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(100),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.stitchCyan.withOpacity(0.4),
                    blurRadius: 20,
                  ),
                  BoxShadow(
                    color: AppColors.stitchCyan.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 0), // inset simulation not direct in BoxShadow, use Container structure
                  )
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                  child: Center(
                    // Inner cyan light strip
                     child: Container(
                       width: 192,
                       height: 16,
                       decoration: BoxDecoration(
                         color: AppColors.stitchCyan.withOpacity(0.2),
                         borderRadius: BorderRadius.circular(100),
                       ),
                       child: BackdropFilter(
                         filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                         child: Container(color: Colors.transparent),
                       ),
                     ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
