import 'package:playing_cards/playing_cards.dart';
import '../models/lesson.dart';
import '../models/question.dart';

final phase2Data = Lesson(
  id: 'P2',
  title: '무조건 큰 놈이 이긴다',
  description: '카드 서열과 하이카드를 배운다',
  rewardXp: 50,
  questions: [
    // Q1: 왕족 카드 (A, K, Q, J)
    ConceptQuestion(
      id: 'P2_Q1',
      instructionText:
          "딱 하나만 기억해. A > K > Q > J > 10 ... > 2 순서야. 쉽지?",
      animationKey: 'face_cards_reveal',
      npcDialogue:
          "어이 애송이, 카드에 적힌 알파벳 보고 당황했나? 이놈들이 바로 이 판의 귀족들이야.",
      npcImageAsset: 'assets/images/characters/char_2.png',
    ),
    // Q2: 나머지 숫자 카드 (10~2)
    ConceptQuestion(
      id: 'P2_Q2',
      instructionText:
          "딱 하나만 기억해. A > K > Q > J > 10 ... > 2 순서야. 쉽지?",
      animationKey: 'number_cards_staircase',
      npcDialogue:
          "나머지는 쉬워. 적힌 숫자 그대로거든! 10이 제일 형님이고, 2가 제일 막내 쫄병이지.",
      npcImageAsset: 'assets/images/characters/char_2.png',
    ),
    // Q3: 미니 퀴즈 — 9 vs 7 하이카드
    MultipleChoiceQuestion(
      id: 'P2_Q3',
      instructionText: '두 장 중 어느 카드가 더 강할까?',
      options: ['9', '7'],
      correctOptionIndex: 0,
      displayCardLeft: PlayingCard(Suit.hearts, CardValue.nine),
      displayCardRight: PlayingCard(Suit.spades, CardValue.seven),
      npcDialogue:
          "나도 혼자, 너도 혼자지? 이럴 땐 누가 형님이야? 대장끼리 붙어봐!",
      npcFeedbackCorrect:
          "정답! 이걸 유식하게 '하이카드'라고 불러. 그냥 '솔로 대장전'인 거지!",
      npcFeedbackWrong:
          "쯧쯧, 벌써부터 쫄았냐? 숫자가 큰 놈이 이기는 거야. 다시 한번!",
    ),
  ],
);
