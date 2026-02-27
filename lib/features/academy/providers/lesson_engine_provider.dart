import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../models/lesson.dart';
import '../../../providers/user_stats_provider.dart';

class LessonState {
  final Lesson? activeLesson;
  final int currentQuestionIndex;
  final int streak;
  final bool isAnswerRevealed;
  final bool isCorrect;
  final bool isLessonCompleted;

  LessonState({
    this.activeLesson,
    this.currentQuestionIndex = 0,
    this.streak = 0,
    this.isAnswerRevealed = false,
    this.isCorrect = false,
    this.isLessonCompleted = false,
  });

  LessonState copyWith({
    Lesson? activeLesson,
    int? currentQuestionIndex,
    int? streak,
    bool? isAnswerRevealed,
    bool? isCorrect,
    bool? isLessonCompleted,
  }) {
    return LessonState(
      activeLesson: activeLesson ?? this.activeLesson,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      streak: streak ?? this.streak,
      isAnswerRevealed: isAnswerRevealed ?? this.isAnswerRevealed,
      isCorrect: isCorrect ?? this.isCorrect,
      isLessonCompleted: isLessonCompleted ?? this.isLessonCompleted,
    );
  }
  
  double get progress => activeLesson == null ? 0.0 : ((currentQuestionIndex) / activeLesson!.questions.length).clamp(0.0, 1.0);
}

class LessonEngineNotifier extends StateNotifier<LessonState> {
  final Ref ref;

  LessonEngineNotifier(this.ref) : super(LessonState());

  void startLesson(Lesson lesson) {
    state = LessonState(activeLesson: lesson);
  }

  void submitAnswer(bool isCorrect) {
    if (state.activeLesson == null) return;
    
    // UI에서 haptic, particle 효과를 재생하도록 상태를 업데이트합니다.
    state = state.copyWith(
      isAnswerRevealed: true,
      isCorrect: isCorrect,
      streak: isCorrect ? state.streak + 1 : 0,
    );
  }

  void nextQuestion() {
    if (state.activeLesson == null) return;
    
    if (state.currentQuestionIndex < state.activeLesson!.questions.length - 1) {
      state = state.copyWith(
        currentQuestionIndex: state.currentQuestionIndex + 1,
        isAnswerRevealed: false,
        isCorrect: false,
      );
    } else {
      // 레슨의 모든 문제를 완료함
      state = state.copyWith(
        isLessonCompleted: true,
        isAnswerRevealed: false,
      );
    }
  }

  void finishLesson() {
    if (state.activeLesson != null) {
      // 보상 지급 (XP 추가)
      ref.read(userStatsProvider.notifier).addXp(state.activeLesson!.rewardXp);
    }
    // 상태 초기화
    state = LessonState();
  }
}

final lessonEngineProvider = StateNotifierProvider<LessonEngineNotifier, LessonState>((ref) {
  return LessonEngineNotifier(ref);
});
