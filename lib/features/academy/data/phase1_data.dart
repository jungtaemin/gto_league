import '../models/lesson.dart';
import '../models/question.dart';

final phase1Data = Lesson(
  id: 'P1',
  title: '웰컴 투 텍사스',
  description: '텍사스 홀덤의 기본 규칙을 배운다',
  rewardXp: 50,
  questions: [
    // Q1: 내 패 (핸드) 설명
    ConceptQuestion(
      id: 'P1_Q1',
      instructionText:
          "이 두 장을 '내 패' 또는 '핸드'라고 불러. 오직 너만 볼 수 있는 카드야.",
      animationKey: 'hole_cards_deal',
      npcDialogue:
          "어이 애송이, 자리에 앉았으면 패부터 받아야지? 자, 너만 몰래 볼 수 있는 '내 패' 두 장이야. 남들한테 보여줬다간 바로 판 깨지는 거 알지? 이건 네 비밀 병기라고.",
      npcImageAsset: 'assets/images/characters/char_2.png',
    ),
    // Q2: 바닥 카드 (공용 카드) 설명
    ConceptQuestion(
      id: 'P1_Q2',
      instructionText:
          "바닥에 깔린 5장은 '공용 카드'야. 모두가 자기 것처럼 가져다 쓸 수 있지.",
      animationKey: 'community_cards_reveal',
      npcDialogue:
          "그다음은 판 한가운데 깔리는 '바닥 카드'야. 이건 누구 한 명 꺼가 아니라, 이 판에 참여한 놈들이면 다 같이 나눠 쓰는 '공통 카드'지. 남의 떡이 더 커 보인다고? 걱정 마, 너도 똑같이 쓸 수 있으니까.",
      npcImageAsset: 'assets/images/characters/char_2.png',
    ),
    // Q3: 최강의 5장 (족보 만들기)
    ConceptQuestion(
      id: 'P1_Q3',
      instructionText:
          "내 거 2장 + 바닥 5장 = 총 7장 중 최고의 5장으로 족보를 완성한다!",
      animationKey: 'best_five_highlight',
      npcDialogue:
          "자, 이제 계산기 두드려봐. 네 손에 든 '내 패 2장'이랑 '바닥 카드 5장'을 합치면 총 7장이지? 그중에서 제일 센 놈들로 딱 5장만 추려내서 승부를 보는 거야. 이걸로 '족보'를 만드는 거지. 7장 다 쓰려고 욕심부리지 마라, 애송아.",
      npcImageAsset: 'assets/images/characters/char_2.png',
    ),
    // Q4: 미니 퀴즈 - "이 판의 주인은?"
    MultipleChoiceQuestion(
      id: 'P1_Q4',
      instructionText: '바닥에 깔린 5장 중 내가 사용할 수 있는 카드는 몇 장일까?',
      options: ['5장 전부 다', '내 패랑 똑같은 모양만', '잭(나)이 허락한 것만'],
      correctOptionIndex: 0,
      npcDialogue:
          "어이 파트너, 집중해! 저기 바닥에 깔린 5장 중에 네가 갖다 쓸 수 있는 건 몇 장일까?",
      npcFeedbackCorrect:
          "그렇지! 바닥에 깔린 건 먼저 본 놈이 임자...가 아니라 모두의 것이지. 이제 좀 대화가 통하네!",
      npcFeedbackWrong:
          "쥼쥼, 벌써부터 섬다냐? 바닥 카드는 공평하게 다 네 거야. 기죽지 말고 다시 골라봐!",
    ),
  ],
);
