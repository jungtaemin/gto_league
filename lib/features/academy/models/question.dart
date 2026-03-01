import 'package:playing_cards/playing_cards.dart';

enum QuestionType {
  concept,       // 개념 설명 (애니메이션, 텍스트)
  multipleChoice,// 객관식 (4지선다, 비교 등)
  battle,        // AI와의 미니 승부
}

abstract class Question {
  final String id;
  final QuestionType type;
  final String instructionText;
  final int timeLimitSeconds;

  Question({
    required this.id,
    required this.type,
    required this.instructionText,
    this.timeLimitSeconds = 10,
  });
}

class ConceptQuestion extends Question {
  final String? imageAsset;
  final String? animationKey;
  final String? npcDialogue;
  final String? npcImageAsset;

  ConceptQuestion({
    required super.id,
    required super.instructionText,
    this.imageAsset,
    this.animationKey,
    this.npcDialogue,
    this.npcImageAsset,
    super.timeLimitSeconds = 0, // 시간 제한 없음
  }) : super(type: QuestionType.concept);
}

class MultipleChoiceQuestion extends Question {
  final List<String> options;
  final int correctOptionIndex;
  
  // 카드를 보여주며 퀴즈를 낼 때 옵셔널로 사용
  final PlayingCard? displayCardLeft;
  final PlayingCard? displayCardRight;
  final String? npcDialogue;
  final String? npcFeedbackCorrect;
  final String? npcFeedbackWrong;

  MultipleChoiceQuestion({
    required super.id,
    required super.instructionText,
    required this.options,
    required this.correctOptionIndex,
    this.displayCardLeft,
    this.displayCardRight,
    this.npcDialogue,
    this.npcFeedbackCorrect,
    this.npcFeedbackWrong,
    super.timeLimitSeconds = 10,
  }) : super(type: QuestionType.multipleChoice);
}

class BattleQuestion extends Question {
  final List<PlayingCard> userHoleCards;
  final List<PlayingCard> aiHoleCards;
  final List<PlayingCard> communityCards; // 옵셔널 (빈 배열이면 프리플랍)
  final bool isUserWinner; // 반드시 이겨야 하는 연출 등을 위해 플래그 추가

  BattleQuestion({
    required super.id,
    required super.instructionText,
    required this.userHoleCards,
    required this.aiHoleCards,
    this.communityCards = const [],
    required this.isUserWinner,
    super.timeLimitSeconds = 10,
  }) : super(type: QuestionType.battle);
}
