import 'package:playing_cards/playing_cards.dart';
import '../models/lesson.dart';
import '../models/question.dart';

final phase2Data = Lesson(
  id: 'P2',
  title: '무조건 큰 놈이 이긴다',
  description: '서열의 법칙과 대장(하이카드) 승부 원칙을 배운다',
  rewardXp: 100,
  questions: [
    // Q0-1: 서열 개념 도입 (인트로)
    ConceptQuestion(
      id: 'P2_Q0_1',
      instructionText: "카드 5장으로 승부하는 건 배웠지? 그럼 서열은 알고 있나?",
      animationKey: 'intro_seven_cards_epic', // 일단 화려하게 시작
      npcDialogue: "저번 시간에 5장으로 족보 만드는 건 확실히 배웠겠지? 그럼 질문 하나 하자. 어떤 카드가 더 센지, 서열은 알고 있나?",
      npcImageAsset: 'assets/images/characters/char_2.webp',
      customButtonText: '아직 몰라...',
    ),
    // Q0-2: 서열 전체 깔기 (시각적 장관)
    ConceptQuestion(
      id: 'P2_Q0_2',
      instructionText: "제일 높은 놈부터 차례대로 깔아줄 테니 똑똑히 봐 둬.",
      animationKey: 'intro_staircase_all', // NEW: 13장 쫙 깔리는 연출
      npcDialogue: "이 바닥엔 아주 엄격하고 냉혹한 계급이 존재해. 제일 높은 놈부터 차례대로 쫙 깔아줄 테니 똑똑히 봐 두라고.",
      npcImageAsset: 'assets/images/characters/char_2.webp',
      customButtonText: '준비 완료!',
    ),
    // Q1-1: Ace 카드 (끝판왕)
    ConceptQuestion(
      id: 'P2_Q1_1',
      instructionText: "제일 높은 분은 바로 'A' (에이스).",
      animationKey: 'epic_single_A', // NEW: 거대한 A 
      npcDialogue: "가장 높은 분은 바로 'A', 에이스(Ace)야. 숫자 1처럼 생겼지만 서바이벌 생태계의 무적 끝판왕이지.",
      npcImageAsset: 'assets/images/characters/char_2.webp',
      customButtonText: '계속 듣기',
    ),
    // Q1-2: Ace 카드 추가 강조
    ConceptQuestion(
      id: 'P2_Q1_2',
      instructionText: "에이스가 뜨면 판이 뒤집힌다!",
      animationKey: 'epic_single_A', // 이펙트 재탕 혹은 유지
      npcDialogue: "에이스 한 장 뜨면 판이 어떻게 뒤집힐지 몰라! 절대 잊지 마. 에이스는 곧 권력이다.",
      npcImageAsset: 'assets/images/characters/char_2.webp',
      customButtonText: '에이스 접수!',
    ),
    // Q2-1: K, Q, J (상위 귀족들) 모아서 소개
    ConceptQuestion(
      id: 'P2_Q2_1',
      instructionText: "그 밑으로 세 명의 뼈대 있는 귀족(K, Q, J)들이 버티고 있지.",
      animationKey: 'face_cards_kqj_reveal', // NEW: 세 장 쾅쾅쾅
      npcDialogue: "그 밑으로는 영감탱이 킹(K), 아리따운 퀸(Q), 그리고 내 이름인 기사 잭(J)이 버티고 있어.",
      npcImageAsset: 'assets/images/characters/char_2.webp',
      customButtonText: '계속 읽기',
    ),
    // Q2-2: K, Q, J 서열 정의 완료
    ConceptQuestion(
      id: 'P2_Q2_2',
      instructionText: "A, K, Q, J... 텍사스 홀덤을 쥐락펴락하는 네 놈들이지.",
      animationKey: 'face_cards_reveal', // 기존의 4장 깔리는 연출 활용
      npcDialogue: "에이스 다음가는 귀족들이지. A, K, Q, J... 이 네 놈이 사실상 이 판을 쥐락펴락한다고 보면 돼. 순서 헷갈리지 마!",
      npcImageAsset: 'assets/images/characters/char_2.webp',
      customButtonText: '알파벳 서열 완벽 이해!',
    ),
    // Q3: 숫자 카드 모음
    ConceptQuestion(
      id: 'P2_Q3',
      instructionText: "나머지는 10부터 2까지. 완전 직관적이지?",
      animationKey: 'number_cards_staircase', // 계단식 연출
      npcDialogue: "나머지는 뭐... 숫자가 큰 놈이 센 거야! 10이 알파벳 없는 놈들 중엔 제일 형님이고, 내려갈수록 쫄짜, 2가 이 바닥 최약체지. 아주 직관적이지?",
      npcImageAsset: 'assets/images/characters/char_2.webp',
    ),
    // Q4: 하이카드 (대장전 퀴즈)
    MultipleChoiceQuestion(
      id: 'P2_Q4',
      instructionText: '두 장 중 어느 카드가 더 강할까? (9 vs 7)',
      options: ['9', '7'],
      correctOptionIndex: 0,
      displayCardLeft: PlayingCard(Suit.hearts, CardValue.nine),
      displayCardRight: PlayingCard(Suit.spades, CardValue.seven),
      npcDialogue: "그럼 실전 테스트! 너도 한 장, 나도 한 장 대장전 떴다 치자. 이런 눈치싸움에서 누가 판돈을 먹을 자격이 있지?",
      npcFeedbackCorrect: "아따, 말귀 빨리 알아듣네! 단순무식하게 주먹 큰 놈이 장땡, 그걸 우리는 고급스럽게 '하이카드'라고 부른다!",
      npcFeedbackWrong: "하아... 애송아, 벌써부터 쫄았냐? 숫자가 큰 놈 주먹이 더 맵다고! 9가 7보다 크잖아!",
    ),
    // Q5-1: 무승부의 늪 (대사가 길어서 쪼갬)
    ConceptQuestion(
      id: 'P2_Q5_1',
      instructionText: "서로 제일 높은 카드가 똑같으면 어떻게 될까?",
      npcDialogue: "근데 말이야, 실전이 그렇게 호락호락하지 않아. 너도 제일 높은 대장이 'A'고, 쟤도 'A'면 어쩌려고?",
      npcImageAsset: 'assets/images/characters/char_2.webp',
      customButtonText: '그럼 비기나?',
    ),
    // Q5-2: 키커 해결사
    ConceptQuestion(
      id: 'P2_Q5_2',
      instructionText: "대장이 같을 땐 두 번째 부대장 카드로 겨룬다! (이를 키커(Kicker)라 부름)",
      animationKey: 'kicker_explain_view',
      npcDialogue: "그럴 땐 두 번째 카드, '키커(Kicker)'로 승부하는 거야! 대장이 비기면 부대장이 센 놈 보스가 이긴다!",
      npcImageAsset: 'assets/images/characters/char_2.webp',
      customButtonText: '키커 완벽 접수!',
    ),
    // Q6: 진짜 대장을 찾아라 (Kicker 퀴즈)
    MultipleChoiceQuestion(
      id: 'P2_Q6',
      instructionText: '둘 다 대장이 J로 완벽히 같은 상황! 승자는 누구일까? (내 키커 9 vs 쟤 키커 4)',
      options: ['무승부! 판돈을 나눈다.', "내 키커 '9'가 쟤 쫄다구 '4'를 박살냈어! 내가 승리!", '무늬가 예쁜 쪽이 이긴다.'],
      correctOptionIndex: 1,
      animationKey: 'kicker_battle_view',
      npcDialogue: "자, 방금 배웠지? 대장은 'J'로 동급이야. 둘 다 양보할 생각 없는 피 튀기는 키커 싸움에서 판갈이는 누가 할까?",
      npcFeedbackCorrect: "빙고! J 똑같다고 무승부 외치는 호구들 널렸는데 넌 아니네. 네 부대장 9가 저쪽 찌그러진 부대장 4를 확실히 밟아버렸지!",
      npcFeedbackWrong: "야 이 멍청아! 대장이 같으면 뭐부터 따지라고? 부대장이라고! 네 부대장(9)이 쟤 막내둥이(4)보단 크잖아!",
    ),
    // Q7: 서열의 절대 권력 재확인
    MultipleChoiceQuestion(
      id: 'P2_Q7',
      instructionText: '상대는 [K, Q] 조합! 하지만 넌 [A, 2]를 들고 있다. 심장 쫄리는 이 승부에서 승자는 누굴까?',
      options: ['왕과 여왕의 합동 시너지! 상대가 압승한다.', '서열 끝판왕 에이스(A)를 쥔 내가 혼자 씹어먹는다!'],
      correctOptionIndex: 1,
      animationKey: 'ace_dominant_view',
      npcDialogue: "대망의 마지막 문제! 상대는 대장인 'K'에 부대장 'Q'까지... 아주 무시무시해! 넌 'A' 하나에 쓸모없는 '2'뿐인데, 승자는 누굴까?",
      npcFeedbackCorrect: "그래! 텍사스 홀덤은 철저하게 대장 싸움이야. 아무리 저쪽 쫄병 군단이 화려해도, 끝판왕 'A' 하나를 절대 넘을 순 없지.",
      npcFeedbackWrong: "야야, 쫄보 다 됐네! 저쪽이 킹이든 퀸이든 네가 떡하니 '에이스'를 들고 있잖아. 에이스가 제일 높은 서열이라고 배웠어 안 배웠어?!",
    ),
  ],
);
