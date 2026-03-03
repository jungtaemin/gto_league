import 'package:flutter/material.dart';

class LessonProgressBar extends StatelessWidget {
  final double progress; // 0.0 ~ 1.0

  const LessonProgressBar({
    super.key,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 16,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2), // 배경
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            width: MediaQuery.of(context).size.width *
                progress, // 단순히 전체 width 대비. 실제 상위 제약에 맞출 필요가 있음.
            decoration: BoxDecoration(
              color: Colors.greenAccent,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.greenAccent.withOpacity(0.5),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                )
              ],
            ),
          ),
          // 반사광 하이라이트 효과 (디테일)
          Container(
            height: 6,
            margin: const EdgeInsets.only(top: 2, left: 4, right: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }
}
