import 'package:flutter/material.dart';
import '../models/question.dart';
import 'concept_question_widget.dart';
import 'multiple_choice_question_widget.dart';
import 'battle_question_widget.dart';
import 'chapter_title_question_widget.dart';

class QuestionRenderer extends StatelessWidget {
  final Question question;
  final ValueChanged<bool> onAnswerSubmit;

  const QuestionRenderer({
    super.key,
    required this.question,
    required this.onAnswerSubmit,
  });

  @override
  Widget build(BuildContext context) {
    // 챕터 타이틀
    if (question is ChapterTitleQuestion) {
      return ChapterTitleQuestionWidget(
        question: question as ChapterTitleQuestion,
        onContinue: () => onAnswerSubmit(true),
      );
    }
    // 다형성 기반 렌더링
    if (question is ConceptQuestion) {
      return ConceptQuestionWidget(
        question: question as ConceptQuestion,
        onContinue: () => onAnswerSubmit(true),
      );
    } else if (question is MultipleChoiceQuestion) {
      return MultipleChoiceQuestionWidget(
        question: question as MultipleChoiceQuestion,
        onSelectAnswer: (bool isCorrect) => onAnswerSubmit(isCorrect),
      );
    } else if (question is BattleQuestion) {
      return BattleQuestionWidget(
        question: question as BattleQuestion,
        onBattleComplete: (bool isWin) => onAnswerSubmit(isWin),
      );
    }
    
    return const Center(child: Text('Unknown Question Type'));
  }
}
