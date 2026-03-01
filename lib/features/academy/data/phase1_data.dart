import '../models/lesson.dart';
import '../models/question.dart';

final phase1Data = Lesson(
  id: 'P1',
  title: '웰컴 투 텍사스',
  description: '텍사스 홀덤의 기본 규칙을 배운다',
  rewardXp: 100,
  questions: [
    // --- NEW: Q1 (텍사스 잭의 강렬한 등장 및 셔플 액션) ---
    ConceptQuestion(
      id: 'P1_Q0_1',
      instructionText: "준비됐어? 인생을 바꿀 두 장의 교차점, 그게 바로 텍사스 마인드야.",
      animationKey: 'intro_shuffle_epic',
      npcDialogue: "어이, 뉴페이스! 여기선 카드 2장이면 인생을 바꿀 수 있지. 그게 바로 텍사스 방식이야. 준비됐나?",
      npcImageAsset: 'assets/images/characters/char_2.png',
      customButtonText: '자리에 앉기',
    ),
    // --- NEW: Q2 (잭 영상 재생) ---
    ConceptQuestion(
      id: 'P1_Q0_2',
      instructionText: "텍사스 잭(마스터) 등장!",
      videoAsset: 'assets/videos/jack_bj.mp4',
      customButtonText: '카드 받기',
    ),
    
    // 기존 Q1: 내 패 (핸드) 설명
    ConceptQuestion(
      id: 'P1_Q1',
      instructionText:
          "이 두 장을 '내 패' 또는 '핸드'라고 불러. 오직 너만 볼 수 있는 카드야.",
      animationKey: 'hole_cards_deal',
      npcDialogue:
          "자, 너만 몰래 볼 수 있는 '내 패' 두 장이야. 남들한테 보여줬다간 바로 판 깨지는 거 알지? 이건 네 비밀 병기라고.",
      npcImageAsset: 'assets/images/characters/char_2.png',
    ),
    // Q2-1: 바닥 카드 (공용 카드) 설명 시작
    ConceptQuestion(
      id: 'P1_Q2_1',
      instructionText:
          "바닥에 깔린 5장은 '공용 카드'야.",
      animationKey: 'community_cards_reveal',
      npcDialogue:
          "그다음은 판 한가운데 깔리는 '바닥 카드'야. 이 판에 참여한 놈들이면 다 같이 나눠 쓰는 '공통 카드'지.",
      npcImageAsset: 'assets/images/characters/char_2.png',
      customButtonText: '계속 듣기',
    ),
    // Q2-2: 바닥 카드 상세
    ConceptQuestion(
      id: 'P1_Q2_2',
      instructionText:
          "모두가 5장을 통째로 가져다 쓸 수 있지.",
      // animationKey: 'community_cards_reveal', // 연속 재생 시 부자연스러울 수 있어 생략하거나 그대로 둬도 됨
      npcDialogue:
          "남의 떡이 더 커 보인다고? 걱정 마, 너도 이 5장 모두 네 것처럼 똑같이 쓸 수 있으니까.",
      npcImageAsset: 'assets/images/characters/char_2.png',
    ),
    // Q3-1: 7장 룰 리마인드 (대사 분할)
    ConceptQuestion(
      id: 'P1_Q3_1',
      instructionText:
          "내 거 2장 + 바닥 5장 = 총 7장의 카드가 있어!",
      animationKey: 'intro_seven_cards_epic', // 시각적으로 7장 강조
      npcDialogue:
          "자, 이제 계산기 두드려봐. 네 손에 든 '내 패 2장'이랑 '바닥 카드 5장'을 합치면 총 7장이지?",
      npcImageAsset: 'assets/images/characters/char_2.png',
      customButtonText: '계속 듣기',
    ),
    // Q3-2: 최강의 5장 (족보 만들기 핵심) (대사 1/2)
    ConceptQuestion(
      id: 'P1_Q3_2',
      instructionText:
          "총 7장 중 최고의 5장으로 족보를 완성한다!",
      animationKey: 'best_five_highlight',
      npcDialogue:
          "그중 제일 센 놈들로 딱 5장만 추려 승부를 보는 거야. \n이걸로 '족보'를 만드는 거지.",
      npcImageAsset: 'assets/images/characters/char_2.png',
      customButtonText: '이해했어!',
    ),
    // Q3-3: 7장 다 쓰지 마라 경고 (대사 2/2)
    ConceptQuestion(
      id: 'P1_Q3_3',
      instructionText:
          "단 5장만 쓴다는 걸 명심해!",
      npcDialogue:
          "7장 다 쓰려고 욕심부리지 마라, 애송아. \n명심해, 승부는 무조건 5장이다.",
      npcImageAsset: 'assets/images/characters/char_2.png',
    ),
    // Q4: 신규 미니 퀴즈 1 - 비밀 병기 취급 주의
    MultipleChoiceQuestion(
      id: 'P1_Q4_NEW',
      instructionText: '가장 기본부터 테스트해보지. 네 손에 들어온 이 2장... 어떻게 해야 할까?',
      options: ['옆 사람에게 자랑한다.', '딜러에게 바꿔달라고 조른다.', '목숨처럼 숨기고 혼자만 본다.'],
      correctOptionIndex: 2,
      animationKey: 'hole_cards_view', // 내 패 2장
      npcDialogue:
          "가장 기본부터 테스트해보지. 네 손에 들어온 이 2장... 어떻게 해야 할까?",
      npcFeedbackCorrect:
          "빙고! 포커페이스의 기본이지. 남한테 보여주는 순간 넌 그 판에서 호구 잡히는 거야.",
      npcFeedbackWrong:
          "하아... 너 지금 내 뒷목 잡게 하려고 일부러 그러는 거지? 핸드는 무조건 너.혼.자.만! 보는 거다.",
    ),
    
    // Q5: 기존 퀴즈 리뉴얼 - 이 판의 주인은?
    MultipleChoiceQuestion(
      id: 'P1_Q5',
      instructionText: '바닥에 깔린 5장 중 내가 사용할 수 있는 카드는 몇 장일까?',
      options: ['5장 전부 다', '내 패랑 똑같은 모양만', '잭(나)이 허락한 것만'],
      correctOptionIndex: 0,
      animationKey: 'community_cards_view', // 바닥 카드 5장
      npcDialogue:
          "어이 파트너, 집중해! 저기 바닥에 깔린 5장 중에 네가 갖다 쓸 수 있는 건 몇 장일까?",
      npcFeedbackCorrect:
          "그렇지! 바닥에 깔린 건 먼저 본 놈이 임자...가 아니라 모두의 것이지. 이제 좀 대화가 통하네!",
      npcFeedbackWrong:
          "쯧쯧, 벌써부터 쫄았냐? 바닥 카드는 공평하게 다 네 거야. 기죽지 말고 다시 골라봐!",
    ),

    // Q6: 신규 미니 퀴즈 3 - 욕심쟁이의 최후
    MultipleChoiceQuestion(
      id: 'P1_Q6',
      instructionText: '바닥 5장, 네 패 2장. 총 7장이 모였지? 최종 승부를 볼 때 몇 장으로 족보를 만들어야 될까?',
      options: ['7장 싹 다 긁어모은다!', '눈물을 머금고 제일 센 5장만', '느낌 가는 대로 3장만'],
      correctOptionIndex: 1,
      animationKey: 'seven_cards_view', // 바닥 5장 + 내 패 2장
      npcDialogue:
          "마지막 문제! 바닥 5장, 네 패 2장. 총 7장이 모였지? 최종 승부를 볼 때 몇 장으로 족보를 만들어야 될까?",
      npcFeedbackCorrect:
          "정답! 7장 다 들고 설치면 바로 출입 금지야. 가장 매서운 5장만 뽑아 드는 게 진짜 타짜지.",
      npcFeedbackWrong:
          "이 욕심쟁이야! 룰 브레이커로 쫓겨나고 싶어? 텍사스 홀덤은 무조건 5장 승부라고!",
    ),
  ],
);
