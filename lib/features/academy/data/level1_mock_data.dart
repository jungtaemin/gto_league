import 'package:playing_cards/playing_cards.dart';
import '../models/lesson.dart';
import '../models/question.dart';

final level1Mock = Lesson(
  id: 'L1',
  title: '홀덤 첫걸음',
  description: '텍사스 홀덤의 기본 규칙과 카드 무늬, 숫자의 강도를 배워봅니다.',
  rewardXp: 50,
  questions: [
    // 1️⃣ 오프닝 - ConceptQuestion
    ConceptQuestion(
      id: 'L1_Q1',
      instructionText: '텍사스 홀덤에 오신 것을 환영합니다.\n이 게임은 전략과 확률을 사용하는 마인드 스포츠입니다.',
      animationKey: 'shuffle',
    ),
    // 2️⃣ 기본 개념 설명 - ConceptQuestion
    ConceptQuestion(
      id: 'L1_Q2',
      instructionText: '홀덤은 내 카드 2장, 바닥 카드 5장으로 승부합니다.',
      animationKey: 'two_to_five',
    ),
    // 3️⃣ 무늬 학습 1 (스페이드)
    MultipleChoiceQuestion(
      id: 'L1_Q3',
      instructionText: '이 무늬의 이름은 무엇일까요?',
      options: ['하트', '스페이드', '클럽', '다이아몬드'],
      correctOptionIndex: 1,
      displayCardLeft: PlayingCard(Suit.spades, CardValue.ace),
    ),
    // 3️⃣ 무늬 학습 2 (하트)
    MultipleChoiceQuestion(
      id: 'L1_Q4',
      instructionText: '이 무늬의 이름은 무엇일까요?',
      options: ['다이아몬드', '스페이드', '하트', '클럽'],
      correctOptionIndex: 2,
      displayCardLeft: PlayingCard(Suit.hearts, CardValue.king),
    ),
    // 4️⃣ 숫자 강도 학습 1
    MultipleChoiceQuestion(
       id: 'L1_Q5',
       instructionText: '숫자가 높은 카드가 더 강합니다.\n어느 카드가 더 강할까요?',
       options: ['A 스페이드', 'K 하트'],
       correctOptionIndex: 0,
       displayCardLeft: PlayingCard(Suit.spades, CardValue.ace),
       displayCardRight: PlayingCard(Suit.hearts, CardValue.king),
    ),
    // 4️⃣ 숫자 강도 학습 2
    MultipleChoiceQuestion(
       id: 'L1_Q6',
       instructionText: '어느 카드가 더 강할까요?',
       options: ['8 클럽', 'Q 다이아'],
       correctOptionIndex: 1,
       displayCardLeft: PlayingCard(Suit.clubs, CardValue.eight),
       displayCardRight: PlayingCard(Suit.diamonds, CardValue.queen),
    ),
    // 5️⃣ 하이카드 승부 개념
    MultipleChoiceQuestion(
       id: 'L1_Q7',
       instructionText: '나의 가장 높은 숫자와 상대의 높은 숫자를 비교합니다.\n누가 이길까요?',
       options: ['나 (J 최고)', '상대 (A 최고)'],
       correctOptionIndex: 1,
       displayCardLeft: PlayingCard(Suit.hearts, CardValue.jack),
       displayCardRight: PlayingCard(Suit.spades, CardValue.ace),
    ),
    // 6️⃣ 첫 핸드 랭킹 (원 페어)
    MultipleChoiceQuestion(
       id: 'L1_Q8',
       instructionText: '같은 숫자 2장이 모이면 원 페어!\n원 페어 vs 높은 숫자, 누가 이길까요?',
       options: ['나 (8 원 페어)', '상대 (A 하이)'],
       correctOptionIndex: 0,
       displayCardLeft: PlayingCard(Suit.hearts, CardValue.eight),
       displayCardRight: PlayingCard(Suit.spades, CardValue.ace),
    ),
    // 7️⃣ 미니 승부 게임 (AI 대결 3번) - 1
    BattleQuestion(
      id: 'L1_Q9',
      instructionText: '첫 번째 승부! 나의 패와 커뮤니티 카드를 조합해 보세요.',
      userHoleCards: [PlayingCard(Suit.hearts, CardValue.king), PlayingCard(Suit.spades, CardValue.king)], // 포켓 킹
      aiHoleCards: [PlayingCard(Suit.clubs, CardValue.seven), PlayingCard(Suit.diamonds, CardValue.six)], // 쓰레기 패
      isUserWinner: true,
    ),
    // 7️⃣ 미니 승부 게임 - 2
    BattleQuestion(
      id: 'L1_Q10',
      instructionText: '두 번째 승부! 바닥에 같은 무늬가 많네요.',
      userHoleCards: [PlayingCard(Suit.hearts, CardValue.ace), PlayingCard(Suit.hearts, CardValue.jack)], // 넛 플러시
      aiHoleCards: [PlayingCard(Suit.spades, CardValue.queen), PlayingCard(Suit.clubs, CardValue.queen)], // 퀸 원페어
      communityCards: [PlayingCard(Suit.hearts, CardValue.two), PlayingCard(Suit.hearts, CardValue.five), PlayingCard(Suit.hearts, CardValue.nine), PlayingCard(Suit.spades, CardValue.two), PlayingCard(Suit.clubs, CardValue.three)],
      isUserWinner: true,
    ),
    // 7️⃣ 미니 승부 게임 - 3 (필승 연출)
    BattleQuestion(
      id: 'L1_Q11',
      instructionText: '운명의 마지막 라운드!',
      userHoleCards: [PlayingCard(Suit.spades, CardValue.ace), PlayingCard(Suit.hearts, CardValue.ace)], // 탑 티어 포켓 에이스
      aiHoleCards: [PlayingCard(Suit.clubs, CardValue.king), PlayingCard(Suit.diamonds, CardValue.king)], // 콩라인 포켓 킹
      isUserWinner: true,
    ),
  ],
);
