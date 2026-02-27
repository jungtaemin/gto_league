import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/question.dart';
import '../../../core/utils/haptic_manager.dart';

class ConceptQuestionWidget extends StatelessWidget {
  final ConceptQuestion question;
  final VoidCallback onContinue;

  const ConceptQuestionWidget({
    super.key,
    required this.question,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 애니메이션 연출 영역 (추후 Rive/Lottie 교체 가능)
                if (question.animationKey == 'shuffle')
                  const Icon(Icons.style_rounded, size: 120, color: Colors.blueAccent)
                    .animate(onPlay: (controller) => controller.repeat())
                    .shimmer(duration: 1.seconds)
                    .shakeX(duration: 500.ms, hz: 4)
                else if (question.animationKey == 'two_to_five')
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.rectangle, size: 60, color: Colors.orange)
                        .animate().slideY(begin: 1.0, duration: 400.ms, curve: Curves.easeOutBack),
                      const SizedBox(width: 8),
                      const Icon(Icons.rectangle, size: 60, color: Colors.orange)
                        .animate().slideY(begin: 1.0, duration: 450.ms, curve: Curves.easeOutBack),
                      const SizedBox(width: 24),
                      const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 32),
                      const SizedBox(width: 24),
                      ...List.generate(5, (index) => 
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: const Icon(Icons.rectangle_outlined, size: 40, color: Colors.greenAccent)
                            .animate().scale(delay: (200 + index * 100).ms, curve: Curves.elasticOut),
                        )
                      )
                    ],
                  )
                else
                  const Icon(Icons.lightbulb_outline_rounded, size: 100, color: Colors.yellow)
                    .animate().scale(curve: Curves.elasticOut),
                    
                const SizedBox(height: 48),

                // 설명 텍스트
                Text(
                  question.instructionText,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    height: 1.5,
                  ),
                ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2),
              ],
            ),
          ),
        ),
        
        // 하단 계속하기 버튼
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 8,
            ),
            onPressed: () {
              HapticManager.swipe();
              onContinue();
            },
            child: const Text('잘 알겠어요!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ),
        ).animate().fadeIn(delay: 1.seconds).scale(curve: Curves.easeOutBack),
      ],
    );
  }
}
