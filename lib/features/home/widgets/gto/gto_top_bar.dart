import 'package:flutter/material.dart';

/// Stitch V1 Top Bar: Bronze badge, gold counter, energy capsule, settings
class GtoTopBar extends StatelessWidget {
  const GtoTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // 1. Bronze League Badge Capsule
          Container(
            padding: const EdgeInsets.only(left: 4, right: 12, top: 4, bottom: 4),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFFB923C), Color(0xFFEA580C)],
              ),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: const Color(0xFFFDBA74)),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))],
            ),
            child: Row(
              children: [
                // Badge icon
                Container(
                  width: 32, height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFF78350F),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFFB923C).withOpacity(0.5)),
                  ),
                  child: const Icon(Icons.emoji_events, color: Color(0xFFFBBF24), size: 16),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("리그", style: TextStyle(
                      color: const Color(0xFFFFEDD5), fontSize: 10, fontWeight: FontWeight.bold,
                    )),
                    const Text("브론즈", style: TextStyle(
                      color: Colors.white, fontSize: 12, fontFamily: 'Jua', fontWeight: FontWeight.w900,
                      shadows: [Shadow(color: Colors.black26, blurRadius: 2)],
                    )),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 4),

          // 2. Gold Currency Capsule
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              constraints: const BoxConstraints(maxWidth: 140),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A).withOpacity(0.8),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 8)],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.paid, color: Color(0xFFFBBF24), size: 16),
                  const SizedBox(width: 8),
                  const Text("12,450", style: TextStyle(
                    color: Colors.white, fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 0.5,
                  )),
                  const SizedBox(width: 8),
                  Container(
                    width: 20, height: 20,
                    decoration: BoxDecoration(
                      color: const Color(0xFF22C55E),
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: Colors.green.withOpacity(0.3), blurRadius: 4)],
                    ),
                    child: const Icon(Icons.add, color: Colors.white, size: 12),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 8),

          // 3. Energy Capsule
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF2563EB).withOpacity(0.9),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: const Color(0xFF60A5FA).withOpacity(0.5)),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 8)],
            ),
            child: Row(
              children: [
                const Icon(Icons.bolt, color: Color(0xFFFDE047), size: 12),
                const SizedBox(width: 4),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text("5/5", style: TextStyle(
                      color: Colors.white, fontSize: 12, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic,
                    )),
                    Text("활동력", style: TextStyle(
                      color: const Color(0xFFBFDBFE), fontSize: 8,
                    )),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // 4. Settings Button
          GestureDetector(
            onTap: () {},
            child: Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF475569)),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 8)],
              ),
              child: const Icon(Icons.settings, color: Color(0xFFD1D5DB), size: 18),
            ),
          ),
        ],
      ),
    );
  }
}
