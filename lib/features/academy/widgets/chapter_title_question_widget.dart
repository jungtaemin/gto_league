import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/haptic_manager.dart';
import '../models/question.dart';

class ChapterTitleQuestionWidget extends StatefulWidget {
  final ChapterTitleQuestion question;
  final VoidCallback onContinue;

  const ChapterTitleQuestionWidget({
    super.key,
    required this.question,
    required this.onContinue,
  });

  @override
  State<ChapterTitleQuestionWidget> createState() =>
      _ChapterTitleQuestionWidgetState();
}

class _ChapterTitleQuestionWidgetState
    extends State<ChapterTitleQuestionWidget> {
  @override
  void initState() {
    super.initState();
    // 텍스트 등장 시 강렬한 진동 (Heavy Haptic) 임팩트
    Future.delayed(400.ms, () {
      HapticManager.wrong(); // wrong 햅틱이 보통 가장 묵직함
      Future.delayed(100.ms, () => HapticManager.wrong());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      // 어두운 배경으로 몰입감 극대화
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.85),
        borderRadius: BorderRadius.circular(24),
        border:
            Border.all(color: AppColors.acidYellow.withOpacity(0.3), width: 1),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 스탬프처럼 쾅! 찍히는 타이틀 연출
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Colors.white, AppColors.acidYellow],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ).createShader(bounds),
            child: Text(
              widget.question.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: -1.0,
                height: 1.2,
              ),
            ),
          )
              .animate()
              .scale(
                begin: const Offset(3.0, 3.0),
                end: const Offset(1.0, 1.0),
                duration: 600.ms,
                curve: Curves.easeOutBack, // 튕기는 모션
              )
              .fadeIn(duration: 400.ms)
              .shake(
                  delay: 500.ms,
                  hz: 4,
                  curve: Curves.easeInOut), // 쾅 찍힌 직후의 반동(화면 흔들림)

          const SizedBox(height: 24),

          // 서브타이틀 (점차 희미하게 나타남)
          if (widget.question.subtitle != null)
            Text(
              widget.question.subtitle!,
              textAlign: TextAlign.center,
              style: AppTextStyles.body(color: Colors.white70).copyWith(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            )
                .animate()
                .fadeIn(delay: 1.2.seconds, duration: 600.ms)
                .slideY(begin: 0.5),

          const SizedBox(height: 60),

          // 계속하기 버튼
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.acidYellow,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                elevation: 8,
              ),
              onPressed: () {
                HapticManager.swipe();
                widget.onContinue();
              },
              child: const Text('계속하기',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ).animate().fadeIn(delay: 2.seconds).scale(curve: Curves.easeOutBack),
        ],
      ),
    );
  }
}
