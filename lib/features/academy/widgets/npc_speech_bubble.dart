import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// NPC 캐릭터 이미지 + 말풍선 위젯.
/// ConceptQuestionWidget, MultipleChoiceQuestionWidget 에서 조합하여 사용.
class NpcSpeechBubble extends StatelessWidget {
  final String imagePath;
  final String dialogue;
  final bool isVisible;

  const NpcSpeechBubble({
    super.key,
    required this.imagePath,
    required this.dialogue,
    this.isVisible = true,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: isVisible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 400),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Character avatar ---
          SizedBox(
            width: 70,
            height: 70,
            child: ClipOval(
              child: Image.asset(
                imagePath,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: Colors.grey.shade300,
                  child: const Icon(
                    Icons.person,
                    size: 36,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),

          // --- Speech bubble with tail ---
          Expanded(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Tail (small rotated square pointing left toward character)
                Positioned(
                  left: -6,
                  top: 18,
                  child: Transform.rotate(
                    angle: 0.785398, // 45 degrees
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        border: Border.all(
                          color: Colors.grey.shade300,
                          width: 1,
                        ),
                      ),
                    ),
                  ),
                ),

                // Bubble body
                Container(
                  margin: const EdgeInsets.only(left: 4),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.grey.shade300,
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.pureBlack.withValues(alpha: 0.2),
                        offset: Offset(2, 2),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: Text(
                    dialogue,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.body(color: AppColors.pureBlack),
                  ),
                ),
              ],
            )
                .animate(target: isVisible ? 1 : 0)
                .fadeIn(duration: 400.ms)
                .slideX(begin: -0.1, duration: 400.ms),
          ),
        ],
      ),
    );
  }
}
