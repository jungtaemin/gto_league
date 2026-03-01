enum NodeStatus {
  completed, // 이미 클리어한 스테이지
  current,   // 현재 도전해야 하는 스테이지
  locked,    // 아직 진입할 수 없는 스테이지
}

class MapNodeData {
  final int level;
  final String title;
  final String description;
  final List<String> topics; // 배열 형태의 상세 학습 내용 순서
  final int xpReward;
  
  // UI 렌더링용 x 오프셋 (지그재그 배치용, -1.0 ~ 1.0)
  final double xOffset;

  const MapNodeData({
    required this.level,
    required this.title,
    required this.description,
    required this.topics,
    required this.xpReward,
    required this.xOffset,
  });
}

// Level 1 ~ 10 가상 데이터 (듀오링고식 지그재그 xOffset 적용)
const List<MapNodeData> dummyMapNodes = [
  MapNodeData(
    level: 1, title: '웰컴 투 텍사스', description: '텍사스 홀덤의 기본 규칙', 
    topics: ['내 패(핸드)', '바닥 카드(공용 카드)', '최강의 5장(족보)', '미니 퀴즈'], 
    xpReward: 100, xOffset: 0.0),
  MapNodeData(
    level: 2, title: '무조건 큰 놈이 이긴다', description: '카드 서열과 하이카드', 
    topics: ['왕족 카드 (A,K,Q,J)', '숫자 카드 (10~2)', '하이카드 승부'], 
    xpReward: 50, xOffset: -0.4),
  MapNodeData(
    level: 3, title: '포지션의 이해', description: '버튼과 블라인드 족보', 
    topics: ['딜러 버튼(SB, BB)', '얼리 포지션(UTG)', '레이트 포지션의 이점'], 
    xpReward: 100, xOffset: -0.7),
  MapNodeData(
    level: 4, title: '베팅의 기초', description: '콜, 레이즈, 폴드', 
    topics: ['액션의 종류', '팟(Pot)의 이해', '올인(All-in) 액션'], 
    xpReward: 50, xOffset: -0.3),
  MapNodeData(
    level: 5, title: '프리플랍 레인지', description: '어떤 패로 들어갈까?', 
    topics: ['프리미엄 핸드 종류', '수티드 커넥터의 가치', '포지션별 오픈 레인지'], 
    xpReward: 80, xOffset: 0.2),
  MapNodeData(
    level: 6, title: '보드 리딩', description: '커뮤니티 카드 텍스쳐 파악', 
    topics: ['플랍(Flop)의 구조', '드로우(Draw) 보드', '턴과 리버 읽기'], 
    xpReward: 100, xOffset: 0.6),
  MapNodeData(
    level: 7, title: '오즈와 아웃츠', description: '내가 역전할 확률은?', 
    topics: ['아웃츠(Outs) 세기', '팟 오즈 계산법', '4-2 법칙 적용하기'], 
    xpReward: 100, xOffset: 0.8),
  MapNodeData(
    level: 8, title: '블러핑 101', description: '상대를 속이는 기술', 
    topics: ['블러핑의 종류', '세미 블러프 연습', '상대 유형별 대처'], 
    xpReward: 150, xOffset: 0.4),
  MapNodeData(
    level: 9, title: '포스트플랍 전략', description: 'C-Bet과 동크벳', 
    topics: ['C-Bet (컨티뉴에이션 벳)', '체크 레이즈', '동크벳(Donk Bet) 이해'], 
    xpReward: 200, xOffset: 0.0),
  MapNodeData(
    level: 10, title: '최종 평가전', description: '마스터 봇과의 대결', 
    topics: ['규칙 총정리', '오즈 계산 퀴즈', '실전 배틀 시뮬레이션'], 
    xpReward: 500, xOffset: -0.5),
];
