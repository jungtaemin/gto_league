import 'package:flutter/material.dart';
import 'stitch_colors.dart';

class GtoTopBar extends StatelessWidget {
  const GtoTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    // HTML Lines 115-146
    // flex justify-between items-center px-4 pt-4 pb-2 w-full gap-2
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 1. League Badge (Lines 116-124)
          Container(
            padding: const EdgeInsets.only(right: 12, top: 4, bottom: 4, left: 4),
            decoration: BoxDecoration(
              color: StitchColors.orange600.withOpacity(0.9),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: StitchColors.orange400),
              boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))],
            ),
            child: Row(
              children: [
                // Icon Circle
                Container(
                  width: 32, height: 32,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: StitchColors.orange800,
                    shape: BoxShape.circle,
                    border: Border.all(color: StitchColors.orange300, width: 2),
                  ),
                  child: const Icon(Icons.emoji_events_rounded, color: StitchColors.yellow200, size: 14),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text("리그", style: TextStyle(color: StitchColors.orange300, fontSize: 10, height: 1.0)),
                    const Text("브론즈", style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold, height: 1.0)),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // 2. Chip Badge (Lines 125-136)
          Expanded(
            child: Container(
              padding: const EdgeInsets.only(right: 4, top: 4, bottom: 4, left: 4),
              decoration: BoxDecoration(
                color: Colors.grey[900]!.withOpacity(0.8),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: StitchColors.slate600),
                boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
              ),
              child: Row(
                children: [
                  // Icon Circle
                  Container(
                    width: 28, height: 28,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 2)],
                    ),
                    child: const Icon(Icons.savings_rounded, color: StitchColors.yellow500, size: 16),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text("보유 칩", style: TextStyle(color: StitchColors.slate400, fontSize: 10, height: 1.0)),
                        const Text("12,450", style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold, height: 1.0)),
                      ],
                    ),
                  ),
                  // Add Button
                  Container(
                    width: 24, height: 24,
                    decoration: BoxDecoration(
                      color: StitchColors.green500,
                      shape: BoxShape.circle,
                      border: Border.all(color: StitchColors.green400),
                      boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
                    ),
                    child: const Icon(Icons.add, color: Colors.white, size: 14),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 8),

          // 3. Energy & Settings (Lines 137-145)
          Row(
            children: [
              // Energy Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: StitchColors.blue600.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: StitchColors.blue400),
                  boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.bolt_rounded, color: StitchColors.yellow300, size: 14),
                    const SizedBox(width: 4),
                    const Text("5/5", style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Settings Button
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: StitchColors.slate700.withOpacity(0.8),
                  shape: BoxShape.circle,
                  border: Border.all(color: StitchColors.slate500),
                  boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
                ),
                child: const Icon(Icons.settings_rounded, color: Colors.white, size: 18),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
