import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/utils/haptic_manager.dart';
import '../providers/lesson_engine_provider.dart';
import '../data/level1_mock_data.dart';
import '../widgets/lesson_progress_bar.dart';
import '../widgets/lesson_bottom_sheet.dart';
import '../widgets/question_renderer.dart';

class AcademyScreen extends ConsumerStatefulWidget {
  const AcademyScreen({super.key});

  @override
  ConsumerState<AcademyScreen> createState() => _AcademyScreenState();
}

class _AcademyScreenState extends ConsumerState<AcademyScreen> {
  @override
  void initState() {
    super.initState();
    // 화면 진입 시 레슨 시작
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(lessonEngineProvider.notifier).startLesson(level1Mock);
    });
  }

  void _handleAnswerSubmitted(bool isCorrect) {
    if (isCorrect) {
      HapticManager.correct();
    } else {
      HapticManager.wrong();
    }
    ref.read(lessonEngineProvider.notifier).submitAnswer(isCorrect);
  }

  void _handleNext() {
    HapticManager.swipe();
    ref.read(lessonEngineProvider.notifier).nextQuestion();
  }

  void _handleFinish() {
    ref.read(lessonEngineProvider.notifier).finishLesson();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(lessonEngineProvider);

    if (state.activeLesson == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (state.isLessonCompleted) {
      return Scaffold(
        backgroundColor: const Color(0xFF1CB0F6), // 듀오링고식 완료 스크린 컬러
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.star_rounded, size: 100, color: Colors.amber)
                    .animate(onPlay: (controller) => controller.repeat())
                    .shimmer(duration: 2.seconds)
                    .scale(duration: 500.ms, curve: Curves.easeOutBack),
                const SizedBox(height: 24),
                const Text(
                  '레슨 완료!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                  ),
                ).animate().fadeIn().slideY(begin: 0.5),
                const SizedBox(height: 12),
                Text(
                  '+${state.activeLesson!.rewardXp} XP 획득',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ).animate().fadeIn().slideY(begin: 0.5, delay: 200.ms),
                const SizedBox(height: 48),
                ElevatedButton(
                  onPressed: _handleFinish,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF1CB0F6),
                    padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    '계속하기',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ).animate().fadeIn(delay: 400.ms).scale(curve: Curves.easeOutBack),
              ],
            ),
          ),
        ),
      );
    }

    final currentQuestion = state.activeLesson!.questions[state.currentQuestionIndex];

    return Scaffold(
      backgroundColor: const Color(0xFF121212), // K-casual 다크 테마 배경
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // 1. 헤더 (닫기 + 진행바 + 스트릭)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close_rounded, color: Colors.white54, size: 32),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: LessonProgressBar(progress: state.progress),
                      ),
                      const SizedBox(width: 16),
                      // 스트릭 불꽃 아이콘
                      Row(
                        children: [
                          Icon(
                            Icons.local_fire_department_rounded,
                            color: state.streak > 0 ? Colors.orangeAccent : Colors.white24,
                            size: 28,
                          ).animate(target: state.streak > 0 ? 1 : 0)
                           .scale(curve: Curves.bounceOut)
                           .tint(color: Colors.orangeAccent),
                          const SizedBox(width: 4),
                          Text(
                            '${state.streak}',
                            style: TextStyle(
                              color: state.streak > 0 ? Colors.orangeAccent : Colors.white24,
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // 2. 문제 바디 영역 (위젯 스위칭)
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    transitionBuilder: (child, animation) {
                      // 듀오링고식 슬라이드 트랜지션
                      final offsetAnimation = Tween<Offset>(
                        begin: const Offset(1.0, 0.0), // 오른쪽에서
                        end: Offset.zero,
                      ).animate(CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeOutCubic,
                      ));
                      return SlideTransition(position: offsetAnimation, child: child);
                    },
                    // Key를 통해 상태 변화를 감지해 교체
                    child: Padding(
                      key: ValueKey(currentQuestion.id),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      child: QuestionRenderer(
                        question: currentQuestion,
                        onAnswerSubmit: _handleAnswerSubmitted,
                      ),
                    ),
                  ),
                ),
                // 하단 바텀시트가 올라올 공간 확보
                const SizedBox(height: 120),
              ],
            ),

            // 3. 정답/오답 바텀시트 오버레이 (AnimatedPositioned)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutBack,
              bottom: state.isAnswerRevealed ? 0 : -200,
              left: 0,
              right: 0,
              child: LessonBottomSheet(
                isCorrect: state.isCorrect,
                onContinue: _handleNext,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
