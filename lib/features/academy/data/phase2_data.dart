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
      instructionText: "자, 이제 기본은 배웠으니 진짜 무기, '족보'를 배워볼 차례야.",
      animationKey: 'intro_seven_cards_epic',
      npcDialogue: "카드 5장으로 승부하는 건 알겠지? 이제 어떤 카드가 더 센지, 서열부터 확실히 짚고 가자고.",
      npcImageAsset: 'assets/images/characters/char_2.webp',
      customButtonText: '준비 완료!',
    ),
    // Q1-A: Ace 카드 설명
    ConceptQuestion(
      id: 'P2_Q1_A',
      instructionText: "제일 센 카드는 무조건 A(에이스).",
      animationKey: 'single_card_A',
      npcDialogue: "가장 높은 놈은 'A', 에이스(Ace)야. 숫자 1처럼 생겼지만 이 바닥 끝판왕이지. 에이스 한 장 뜨면 판이 뒤집힌다!",
      npcImageAsset: 'assets/images/characters/char_2.webp',
      customButtonText: '에이스 접수!',
    ),
    // Q1-K: King 카드 설명
    ConceptQuestion(
      id: 'P2_Q1_K',
      instructionText: "수염 난 이 아저씨는 킹. 왕이니까 당연히 세겠지?",
      animationKey: 'single_card_K',
      npcDialogue: "그다음은 'K', 킹(King)이야. 왕관 쓴 영감탱이지. 에이스 다음으로 무자비한 놈이니까 무시하면 큰일 난다고.",
      npcImageAsset: 'assets/images/characters/char_2.webp',
    ),
    // Q1-Q: Queen 카드 설명
    ConceptQuestion(
      id: 'P2_Q1_Q',
      instructionText: "이쪽은 퀸. 왕비님이야. 킹 다음으로 높다고.",
      animationKey: 'single_card_Q',
      npcDialogue: "이 아리따운 아가씨는 'Q', 여왕(Queen)이시다. 영감탱이 킹 바로 다음 서열을 잡고 있지.",
      npcImageAsset: 'assets/images/characters/char_2.webp',
    ),
    // Q1-J: Jack 카드 설명
    ConceptQuestion(
      id: 'P2_Q1_J',
      instructionText: "마지막은 잭. 나랑 이름이 같네? 기사님이라고 생각하면 돼.",
      animationKey: 'single_card_J',
      npcDialogue: "마지막 귀족은 'J', 기사(Jack)야. 뭐, 내 이름인 '잭'이랑 똑같아서 내가 좀 아끼는 놈이지. 하하! 이 네 놈이 판을 쥐고 흔든다고 보면 돼.",
      npcImageAsset: 'assets/images/characters/char_2.webp',
      customButtonText: '알파벳 순서 완벽 이해!',
    ),
    // Q2: 나머지 숫자 카드 (10~2)
    ConceptQuestion(
      id: 'P2_Q2',
      instructionText: "딱 하나만 기억해. A > K > Q > J > 10 ... > 2 순서야. 쉽지?",
      animationKey: 'number_cards_staircase',
      npcDialogue: "나머진 더 쉬워, 애송아. 적힌 숫자 그대로야! 10이 제일 형님, 번호가 내려갈수록 쫄짜고, 2가 이 바닥 최약체 샌드백이지.",
      npcImageAsset: 'assets/images/characters/char_2.webp',
    ),
    // Q3: 미니 퀴즈 — 9 vs 7 하이카드
    MultipleChoiceQuestion(
      id: 'P2_Q3',
      instructionText: '두 장 중 어느 카드가 더 강할까? (9 vs 7)',
      options: ['9', '7'],
      correctOptionIndex: 0,
      displayCardLeft: PlayingCard(Suit.hearts, CardValue.nine),
      displayCardRight: PlayingCard(Suit.spades, CardValue.seven),
      npcDialogue: "어이, 집중해! 나도 혼자, 너도 혼자 대장전 떴다 치자. 이런 '솔로전'에선 뭐가 깡패라고?",
      npcFeedbackCorrect: "아따, 말귀 한 번 빨리 알아듣네! 단순무식하게 큰 놈이 장땡, 그걸 '하이카드'라고 부른다!",
      npcFeedbackWrong: "하아... 애송아, 벌써부터 쫄았냐? 숫자가 큰 놈 주먹이 더 맵다고! 9가 7보다 형님이잖아!",
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
      instructionText: '둘 다 대장이 J로 똑같은데, 판돈은 누가 가져갈까? (내 키커 9 vs 쟤 키커 4)',
      options: ['무승부! 판돈을 반반 나눈다.', "내 키커 '9'가 쟤 키커 '4'보다 높으니 내 승리!", '무늬가 예쁜 쪽이 이긴다.'],
      correctOptionIndex: 1,
      animationKey: 'kicker_battle_view',
      npcDialogue: "자, 방금 배웠지? 대장은 'J'로 동급이야. 피 튀기는 키커 싸움에서 판갈이는 누가 할까?",
      npcFeedbackCorrect: "빙고! J 똑같다고 무승부 외치는 호구들 널렸는데 넌 아니네. 네 부대장 9가 저쪽 부대장 4를 밟아버렸어!",
      npcFeedbackWrong: "야 이 멍청아! 대장이 같으면 뭐부터 따지라고? 부대장! 네 부대장(9)이 쟤 막내둥이(4)보단 크잖아!",
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
