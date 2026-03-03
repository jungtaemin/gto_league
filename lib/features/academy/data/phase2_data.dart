import 'package:playing_cards/playing_cards.dart';
import '../models/lesson.dart';
import '../models/question.dart';

final phase2Data = Lesson(
  id: 'P2',
  title: '무조건 큰 놈이 이긴다',
  description: '카드 서열과 하이카드를 배운다',
  rewardXp: 100,
  questions: [
    // Q0: 본격적인 승부의 시작 (챕터 1 리마인드 & 방향 제시)
    ConceptQuestion(
      id: 'P2_Q0',
      instructionText: "일단 족보를 만들기 전에, 각각 카드의 힘부터 알아야 돼.",
      animationKey: 'intro_seven_cards_epic', // 챕터 1에서 썼던 7장 연출 재활용
      npcDialogue: "저번 시간에 배운 거 기억나지? 7장 조합으로 최고의 5장을 만드는 거! 이번엔 가장 기초적인 전투력인 '카드 서열'에 대해 알아보자고.",
      npcImageAsset: 'assets/images/characters/char_2.webp',
      customButtonText: '카드 서열 배우기',
    ),
    // Q1-A: Ace 카드 설명
    ConceptQuestion(
      id: 'P2_Q1_A',
      instructionText: "숫자 1처럼 생겼지만, 사실 끝판왕이지. 에이스라고 불러.",
      animationKey: 'single_card_A',
      npcDialogue: "어이 애송이, 카드에 적힌 알파벳 보고 당황했나? 이놈들이 바로 이 판의 귀족들이야. 먼저 'A'부터 보실까?",
      npcImageAsset: 'assets/images/characters/char_2.webp',
      customButtonText: '오호, 끝판왕!',
    ),
    // Q1-K: King 카드 설명
    ConceptQuestion(
      id: 'P2_Q1_K',
      instructionText: "수염 난 이 아저씨는 킹. 왕이니까 당연히 세겠지?",
      animationKey: 'single_card_K',
      npcDialogue: "그다음은 'K'. 왕(King)이지. 에이스 다음으로 무서운 영감탱이야.",
      npcImageAsset: 'assets/images/characters/char_2.webp',
    ),
    // Q1-Q: Queen 카드 설명
    ConceptQuestion(
      id: 'P2_Q1_Q',
      instructionText: "이쪽은 퀸. 왕비님이야. 킹 다음으로 높다고.",
      animationKey: 'single_card_Q',
      npcDialogue: "이 아름다운 아가씨는 'Q', 여왕(Queen)이시다. 왕 다음으로 높은 분이지.",
      npcImageAsset: 'assets/images/characters/char_2.webp',
    ),
    // Q1-J: Jack 카드 설명
    ConceptQuestion(
      id: 'P2_Q1_J',
      instructionText: "마지막은 잭. 나랑 이름이 같네? 기사님이라고 생각하면 돼.",
      animationKey: 'single_card_J',
      npcDialogue: "마지막 귀족은 'J', 기사(Jack)야. 뭐, 내 이름인 '잭'이랑 똑같아서 내가 제일 좋아하는 놈이지. 하하!",
      npcImageAsset: 'assets/images/characters/char_2.webp',
      customButtonText: '알파벳 순서 완벽 이해!',
    ),
    // Q2: 나머지 숫자 카드 (10~2)
    ConceptQuestion(
      id: 'P2_Q2',
      instructionText:
          "딱 하나만 기억해. A > K > Q > J > 10 ... > 2 순서야. 쉽지?",
      animationKey: 'number_cards_staircase',
      npcDialogue:
          "나머지는 쉬워. 적힌 숫자 그대로거든! 10이 제일 형님이고, 2가 제일 막내 쫄병이지.",
      npcImageAsset: 'assets/images/characters/char_2.webp',
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
      npcFeedbackWrong: "쯧쯧, 벌써부터 쫄았냐? 숫자가 큰 놈이 이기는 거야. 다시 한번!",
    ),
    // Q4-1: 무승부의 늪 (키커의 필요성)
    ConceptQuestion(
      id: 'P2_Q4_1',
      instructionText: "가장 센 대장이 똑같으면 누가 이길까?",
      npcDialogue:
          "근데 말이야, 이 바닥이 그렇게 호락호락하지가 않아. 너도 최고 대장이 'A'고 쟤도 'A'면 어쩔 건데?",
      npcImageAsset: 'assets/images/characters/char_2.webp',
      customButtonText: '그럼 비기나?',
    ),
    // Q4-2: 키커 설명
    ConceptQuestion(
      id: 'P2_Q4_2',
      instructionText: "제일 강한 카드가 같을 땐, 두 번째 카드(키커)로 승부한다!",
      animationKey: 'kicker_explain_view',
      npcDialogue:
          "그럴 땐 두 번째 부대장의 주먹, '키커(Kicker)'를 비교하는 거야! 대장이 비기면 부대장이 센 놈 보스가 이긴다, 텍사스 법관청 명심해라!",
      npcImageAsset: 'assets/images/characters/char_2.webp',
      customButtonText: '키커, 완벽 접수!',
    ),
    // Q5: 누가 진짜 대장이지? (Kicker 실전 퀴즈)
    MultipleChoiceQuestion(
      id: 'P2_Q5',
      instructionText: '둘 다 대장이 J로 똑같은데, 판돈은 누가 가져갈까?',
      options: ['무승부! 판돈을 반반 나눈다.', "내 키커 '9'가 쟤 키커 '4'보다 높으니 내 승리!", '무늬가 예쁜 쪽이 이긴다.'],
      correctOptionIndex: 1,
      animationKey: 'kicker_battle_view',
      npcDialogue: "자, 방금 배운 거 테스트해보자. 둘 다 대장이 'J'로 똑같은데, 판돈은 누가 가져갈까?",
      npcFeedbackCorrect: "빙고! 대장인 J가 똑같으니 무승부라고 착각하기 십상인데, 부대장인 9가 4보다 높으니 네 완승이라고!",
      npcFeedbackWrong: "야 이 멍청아! 대장이 같으면 뭐 보라고 했어? 두 번째 카드! 네 부대장(9)이 쟤 부대장(4)보다 크잖아!",
    ),
    // Q6: 제왕의 귀환 (에이스 서열 재확인)
    MultipleChoiceQuestion(
      id: 'P2_Q6',
      instructionText: '상대는 강력한 [K, Q] 조합! 하지만 넌 [A, 2]를 들고 있다. 승자는 누굴까?',
      options: ['킹과 퀸의 합동 공격! 상대가 이긴다.', '끝판왕 에이스(A)를 쥔 내가 혼자 씹어먹는다!'],
      correctOptionIndex: 1,
      animationKey: 'ace_dominant_view',
      npcDialogue: "상대는 대장인 'K'에 부대장 'Q'까지... 아주 무시무시하지! 넌 'A' 하나랑 쫄병인 '2'뿐인데, 승자는 누굴까?",
      npcFeedbackCorrect: "역시 똘똘하군. 아무리 상대 쫄병이 세도, 끝판왕 'A' 하나를 넘을 순 없지. 이게 바로 서열의 절대 권력이다.",
      npcFeedbackWrong: "야야, 쫄지 마! 저쪽이 킹이든 퀸이든 네가 떡하니 '에이스'를 들고 있잖아. 에이스는 무조건 이긴다고!",
    ),
  ],
);
