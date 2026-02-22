  # League System Analysis

  > 분석 일시: 2026-02-21
  > 대상: holdem_allin_fold (Flutter)

  ---

  ## 1. 시스템 개요

  리그 시스템은 **듀오링고 스타일의 주간 경쟁 시스템**으로, 플레이어를 20명 그룹에 배정하고 순위를 경쟁시킵니다.
  현재 코드베이스에는 **두 개의 독립된 리그 구현체**가 공존하고 있습니다.

  | 구분 | RankingService (레거시) | LeagueService (신규) |
  |------|------------------------|---------------------|
  | 파일 | `data/services/ranking_service.dart` | `data/services/league_service.dart` |
  | 그룹 크기 | 9명 (9-Max) | 20명 |
  | 주기 | 일간 (midnight 리셋) | 주간 (ISO 8601 주차) |
  | 데이터 소스 | 로컬 SharedPreferences + 고스트 | Supabase RPC + 고스트/빈슬롯 |
  | UI 연결 | `RankingScreen` (구 라우트 `/ranking`) | `GtoLeagueBody` (홈 하단 네비 3번 탭) |
  | Provider | `rankingServiceProvider` | `leagueServiceProvider` |
  | 로그인 필수 | 아니오 (항상 로컬 고스트) | 핵심 기능은 예 / 비로그인은 로컬 모드 |

  ---

  ## 2. 아키텍처 상세

  ### 2.1 데이터 모델

  #### Tier (enum) — `data/models/tier.dart`
  ```
  fish(0~99) → donkey(100~299) → callingStation(300~599) →
  pubReg(600~999) → grinder(1000~1499) → shark(1500~1999) → gtoMachine(2000+)
  ```
  - 포커 슬랭 기반 7단계 티어
  - `Tier.fromScore(int)` / `Tier.fromName(String)` 팩토리 제공
  - 각 티어에 emoji, displayName(한국어), minScore, maxScore 존재

  #### LeaguePlayer — `data/models/league_player.dart`
  ```dart
  class LeaguePlayer {
    final String id;          // UUID 또는 Supabase user_id
    final String nickname;    // 표시 이름
    final int score;          // 점수
    final Tier tier;          // 현재 티어
    final int rank;           // 순위 (1-based)
    final bool isGhost;       // 고스트 플레이어 여부
    final bool isEmptySlot;   // 매칭 대기 슬롯 여부
  }
  ```

  #### GameState — `data/models/game_state.dart`
  - `currentTier` 필드가 실시간 점수에 따라 갱신됨
  - 리그 시스템과의 연결점: 게임 종료 시 `score`를 리그에 제출

  ### 2.2 서비스 계층

  #### LeagueService (신규 — 주력)

  ```
  joinOrCreateLeague(score)     → Supabase RPC 'join_or_create_league' 호출
  updateScore(score)            → Supabase RPC 'update_league_score' 호출
  getCurrentGroupId()           → league_members 테이블 조회
  fetchLeagueRanking(groupId)   → league_members + profiles JOIN 조회
  generateLocalLeague(score)    → 비로그인 시 로컬 고스트 리그 생성
  ```

  **핵심 흐름:**
  1. 게임 완료 → `GameOverScreen._joinLeagueAndUpdateScore()` 호출
  2. `joinOrCreateLeague(score)` → 같은 티어/주차의 20명 그룹에 JIT 배정
  3. `updateScore(score)` → 서버사이드 `GREATEST`로 최고 점수만 유지
  4. 홈 화면 리그 탭 → `fetchLeagueRanking(groupId)` → 20명 순위표 표시
  5. 20명 미달 시 → `_fillWithEmptySlots()`로 "매칭 중..." 슬롯 보충

  **승급/강등 규칙:**
  - 1~5위: 승급 (promotionCount = 5)
  - 6~15위: 안전권
  - 16~20위: 강등 (demotionCount = 5)

  **빈 슬롯 정렬 전략:**
  - 빈 슬롯을 상위(1~N위)에 배치
  - 실제 유저는 하위(N+1~20위)에 배치
  - 목적: 강등권 위기감 조성

  #### RankingService (레거시)

  ```
  generateLeague(playerScore)   → 9명 고스트 리그 생성
  submitScore(score)            → SharedPreferences에 일일 최고 점수 저장
  syncScoreToCloud(score)       → game_scores 테이블에 INSERT
  fetchCloudGhosts()            → game_scores + profiles JOIN 조회
  ```

  **고스트 점수 분포:**
  - index 0~2: 플레이어보다 약간 위 (도전감)
  - index 3~5: 플레이어보다 약간 아래 (경쟁감)
  - index 6~7: 넓은 범위 아웃라이어

  ### 2.3 UI 계층

  #### GtoLeagueBody (신규 UI) — `features/home/widgets/gto/gto_league_body.dart`
  - **위치**: 홈 화면(`GtoHomeScreen`) 하단 네비 index=3
  - **722줄** 단일 위젯 파일
  - 카드 종류: MeCard, PromotionCard, NormalCard, DemotionCard, EmptySlotCard
  - 존 구분자: 승급 존(금색), 안전 구간(회색), 강등 라인(빨간색)
  - 티어 아이콘 가로 스크롤 바
  - 시즌 종료 카운트다운 (`_getSeasonEndTime()`)
  - 미배정 상태 뷰 ("배치고사 보러가기" 버튼)
  - RefreshIndicator + 수동 새로고침 버튼

  #### RankingScreen (레거시 UI) — `features/ranking/ranking_screen.dart`
  - **위치**: 독립 라우트 `/ranking`
  - Neo-Brutalism 스타일 (NeonText, NeoBrutalistButton)
  - 9명 리스트, 새로고침/나가기 버튼
  - 골드/시안/핑크 랭크 하이라이트

  #### ShinyLeagueCard — `features/home/widgets/shiny_league_card.dart`
  - 홈 화면에 표시되는 현재 시즌 티어 카드
  - 메탈릭 그라디언트 + 3D 엠블렘 + 프로그레스 바
  - **하드코딩된 "Ranked #4,203"** (실제 데이터 미연결)

  #### GameOverScreen — `features/game_over/game_over_screen.dart`
  - 게임 종료 시 자동으로 `_joinLeagueAndUpdateScore()` 실행
  - 첫 배정 시 리그 배치 다이얼로그 표시
  - `static bool _leagueJoined = false` 플래그로 1회 실행 보장

  ### 2.4 Provider 계층

  ```dart
  // game_providers.dart
  rankingServiceProvider  → Provider<RankingService>   // 레거시
  leagueServiceProvider   → Provider<LeagueService>    // 신규

  // game_state_notifier.dart
  gameStateNotifierProvider → @Riverpod(keepAlive: true) GameStateNotifier
    // score, hearts, combo, currentStreak, isFeverMode, currentTier
  ```

  ### 2.5 Supabase 테이블 구조 (코드에서 추론)

  ```sql
  -- LeagueService가 참조하는 테이블들
  league_groups (
    id UUID PK,
    tier TEXT,
    week_number INT,
    ...
  )

  league_members (
    user_id UUID FK → profiles,
    group_id UUID FK → league_groups,
    score INT,
    updated_at TIMESTAMP,
    ...
  )

  profiles (
    id UUID PK,
    username TEXT,
    avatar_url TEXT,
    tier TEXT,
    ...
  )

  -- RankingService가 참조하는 테이블
  game_scores (
    user_id UUID FK → profiles,
    score INT,
    tier TEXT,
    created_at TIMESTAMP,
    ...
  )

  -- Supabase RPC Functions (서버사이드)
  join_or_create_league(u_id, u_tier, u_week) → group_id
  update_league_score(u_id, new_score) → void  -- GREATEST로 최고 점수만 유지
  ```

  ---

  ## 3. 데이터 흐름 다이어그램

  ```
  [Game Session]
      │
      ▼
  [GameScreen] ─── processAnswer() ──→ [GameStateNotifier]
      │                                       │
      │ hearts <= 0                            │ score, tier 갱신
      ▼                                       │
  [_navigateToGameOver()]                     │
      │                                       │
      ├── submitScore(score) ──────────→ [RankingService] (레거시, SharedPreferences)
      │
      ▼
  [GameOverScreen]
      │
      ├── joinOrCreateLeague(score) ──→ [LeagueService] ──→ Supabase RPC
      ├── updateScore(score) ─────────→ [LeagueService] ──→ Supabase RPC
      │
      ▼
  [GtoHomeScreen] ── navIndex=3 ──→ [GtoLeagueBody]
                                        │
                                        ├── getCurrentGroupId() ──→ Supabase
                                        ├── fetchLeagueRanking() ─→ Supabase
                                        └── generateLocalLeague() → 로컬 고스트
  ```

  ---

  ## 4. 문제점 분석

  ### 4.1 Critical (런치 블로커)

  #### P0-1. 두 개의 리그 서비스 공존 — 데이터 정합성 불일치
  - **현상**: `RankingService`(9명/일간)와 `LeagueService`(20명/주간)가 동시 존재
  - **영향**: 게임 종료 시 `RankingService.submitScore()`와 `LeagueService.updateScore()`가 **각각 다른 테이블**에 점수를 기록
    - `RankingService` → `SharedPreferences` + `game_scores` 테이블
    - `LeagueService` → Supabase RPC `update_league_score`
  - **위험**: 사용자가 보는 순위가 어떤 서비스 기준인지에 따라 달라짐. 통합 필요.

  #### P0-2. `_leagueJoined` static 플래그 — 앱 세션 내 1회만 작동
  ```dart
  // game_over_screen.dart:216
  static bool _leagueJoined = false;
  ```
  - **현상**: `static bool`이므로 앱이 재시작되지 않는 한 두 번째 게임부터는 리그 배정/점수 업데이트가 **절대 실행되지 않음**
  - **영향**: 사용자가 더 높은 점수를 달성해도 리그에 반영 안 됨
  - **수정 필요**: 게임 오버 화면에 진입할 때마다 실행되어야 함. `static` 제거 또는 다른 메커니즘 필요.

  #### P0-3. Supabase RPC 함수 미확인
  - `join_or_create_league`, `update_league_score` RPC 함수가 Supabase에 실제 생성되어 있는지 확인 불가
  - 클라이언트 코드만 존재하고 서버사이드 SQL/Edge Function이 이 코드베이스에 포함되어 있지 않음
  - DB 스키마(league_groups, league_members 테이블)도 마이그레이션 파일 없음

  ### 4.2 High (기능적 문제)

  #### P1-1. 빈 슬롯 정렬 로직 — 사용자 혼란 유발
  ```dart
  // league_service.dart:203-207
  players.sort((a, b) {
    if (a.isEmptySlot && !b.isEmptySlot) return -1; // 빈 슬롯이 위
    if (!a.isEmptySlot && b.isEmptySlot) return 1;  // 실제 유저가 아래
    return b.score.compareTo(a.score);
  });
  ```
  - **현상**: 빈 슬롯(score=0)이 실제 유저보다 **상위에 배치**됨
  - **영향**: 실제 점수가 500인 유저가 score=0인 빈 슬롯보다 아래에 표시됨
  - 의도는 "강등권 위기감 조성"이지만, 실제로는 **부조리한 순위표**로 보임
  - "매칭 중..." 슬롯이 1위~N위를 차지하는 것은 UX 관점에서 비직관적

  #### P1-2. 주차 계산 버그 가능성
  ```dart
  // league_service.dart:53-54
  final dayOfYear = now.difference(DateTime(now.year, 1, 1)).inDays;
  final weekday = now.weekday; // 1=Mon, 7=Sun
  final weekNumber = ((dayOfYear - weekday + 10) / 7).floor();
  ```
  - ISO 8601 주차 계산이 수동 구현됨 (라이브러리 미사용)
  - 경계값(12월 마지막 주 / 1월 첫 주) 처리가 불완전할 수 있음
  - `weekNumber > 52` 케이스에서 53주가 아닌 경우의 처리가 `dec31.weekday < 4` 조건에만 의존

  #### P1-3. 시즌 종료 시간 계산 — 타임존 미고려
  ```dart
  // gto_league_body.dart:706
  // 실제 서비스에서는 UTC 고려 필요하나, 모바일 게임 특성상 로컬 시간 기준
  var nextMonday = DateTime(now.year, now.month, now.day);
  ```
  - 로컬 타임존 기반으로 "다음 월요일"을 계산
  - 서버(Supabase)의 `week_number`는 서버 시간 기준일 수 있음
  - 사용자에게 "종료까지 2일 남음"이라고 표시하지만, 실제 서버 리셋 시점과 불일치 가능

  #### P1-4. `isGhost` vs `isEmptySlot` 이중 분류 혼란
  - `LeaguePlayer`에 `isGhost`와 `isEmptySlot` 두 개의 boolean이 존재
  - `LeagueService`에서는 `isGhost`를 **사용하지 않음** (항상 `false` 설정)
  - `RankingService`에서는 `isGhost=true`로 고스트 생성, `isEmptySlot`은 미사용
  - UI에서 `isGhost` 체크 (`👻` 이모지 표시)가 `GtoLeagueBody`에도 남아있지만 실제로는 발동하지 않음

  ### 4.3 Medium (코드 품질)

  #### P2-1. 고스트 닉네임 풀 중복 선언
  ```
  ranking_service.dart:15  → _ghostNicknames (40개)
  league_service.dart:12   → _ghostNicknames (30개)
  ```
  - 동일 변수명, 다른 내용, 각각 별도 선언
  - `LeagueService`에서는 실제 사용하지 않음 (`_fillWithEmptySlots`에서 '매칭 중...'으로 고정)

  #### P2-2. GtoLeagueBody 단일 파일 비대화 — 722줄
  - 하나의 `ConsumerStatefulWidget`에 모든 UI 카드 종류 + 헬퍼 + 빌더 포함
  - 위젯 분리 없이 모든 카드 스타일(`_buildMeCard`, `_buildPromotionCard`, `_buildDemotionCard`, `_buildNormalCard`, `_buildEmptySlotCard`)이 한 파일에 존재

  #### P2-3. 하드코딩된 색상 — AppColors 미준수
  ```dart
  // gto_league_body.dart:29-33
  static const _bgDark = Color(0xFF0F0C29);
  static const _gold = Color(0xFFFBBF24);
  static const _goldDark = Color(0xFFD97706);
  static const _cyan = Color(0xFF22D3EE);
  static const _red = Color(0xFFF87171);
  ```
  - 프로젝트 컨벤션은 "AppColors only — NO hardcoded Color(0x...)" 
  - 이 파일에서 5개의 커스텀 컬러가 static const로 직접 정의됨

  #### P2-4. ShinyLeagueCard — 하드코딩된 랭크
  ```dart
  // shiny_league_card.dart:114
  Text("Ranked #4,203", ...)
  ```
  - 실제 랭킹 데이터가 아닌 고정 문자열
  - `game_screen.dart:289`에서도 동일: `rank: 4203, // Mock rank for now`

  #### P2-5. `print()` 사용 — 컨벤션 위반
  ```dart
  // gto_home_screen.dart:28
  print('BUILDING GTO HOME SCREEN V2');
  ```
  - 프로젝트 규칙: `debugPrint()`만 사용. `print()` 금지.

  #### P2-6. 참여 인원 카운트 — isGhost 기준 부정확
  ```dart
  // gto_league_body.dart:153
  '${_players.where((p) => !p.isGhost).length}명 참여중'
  ```
  - `isGhost`가 아닌 `isEmptySlot`으로 필터링해야 함
  - `LeagueService`는 `isGhost=false`로 빈슬롯을 만들므로, 빈 슬롯도 "참여중"으로 카운트됨

  ### 4.4 Low (개선 사항)

  #### P3-1. 승급/강등 실제 실행 로직 부재
  - `isPromotion()`, `isDemotion()`, `getZoneLabel()`은 UI 표시용 헬퍼만 존재
  - 실제 주차 전환 시 승급/강등을 처리하는 서버 로직 또는 클라이언트 로직이 없음
  - 다음 주에 어떤 티어 그룹에 배정되는지에 대한 명세 없음

  #### P3-2. 리그 히스토리 없음
  - 이전 주차 결과를 조회하는 기능이 없음
  - 승급/강등 이력 추적 불가

  #### P3-3. 실시간 업데이트 미지원
  - Pull-to-refresh 또는 수동 새로고침만 지원
  - Supabase Realtime(WebSocket) 미연동
  - 다른 유저가 점수를 업데이트해도 반영되지 않음

  #### P3-4. 오프라인 → 온라인 전환 시 데이터 싱크
  - 비로그인 상태에서 플레이한 점수를 로그인 후 리그에 반영하는 메커니즘 없음
  - `RankingService`의 SharedPreferences 데이터와 `LeagueService`의 Supabase 데이터 간 브리지 없음

  #### P3-5. RankingScreen `/ranking` 라우트 — 데드 코드 후보
  - `GtoLeagueBody`가 홈 탭에서 리그 UI를 제공하므로 `RankingScreen`은 중복
  - `app.dart`에 라우트 등록은 되어있으나, 어디서도 `Navigator.pushNamed('/ranking')`을 호출하는 코드 미확인

  ---

  ## 5. 관련 파일 목록

  | 카테고리 | 파일 경로 | 줄 수 |
  |---------|----------|------|
  | Model | `lib/data/models/tier.dart` | 81 |
  | Model | `lib/data/models/league_player.dart` | 70 |
  | Model | `lib/data/models/game_state.dart` | 90 |
  | Service (신규) | `lib/data/services/league_service.dart` | 299 |
  | Service (레거시) | `lib/data/services/ranking_service.dart` | 333 |
  | Service | `lib/data/services/supabase_service.dart` | 94 |
  | Provider | `lib/providers/game_providers.dart` | 32 |
  | Provider | `lib/providers/game_state_notifier.dart` | 194 |
  | UI (신규) | `lib/features/home/widgets/gto/gto_league_body.dart` | 722 |
  | UI (레거시) | `lib/features/ranking/ranking_screen.dart` | 314 |
  | UI | `lib/features/home/widgets/shiny_league_card.dart` | 207 |
  | UI | `lib/features/game_over/game_over_screen.dart` | 320 |
  | Navigation | `lib/features/home/gto_home_screen.dart` | 70 |
  | Routes | `lib/app.dart` | — |

  ---

  ## 6. 권장 조치 우선순위

  | 순위 | ID | 조치 | 난이도 |
  |-----|----|------|-------|
  | 1 | P0-2 | `_leagueJoined` static 플래그 제거 → 매 게임 종료 시 리그 갱신 보장 | Low |
  | 2 | P0-1 | RankingService/LeagueService 통합 또는 역할 명확 분리 | High |
  | 3 | P1-4 | `isGhost`/`isEmptySlot` 의미 정리 → 단일 enum으로 리팩터 | Medium |
  | 4 | P2-6 | 참여 인원 카운트를 `!p.isEmptySlot`으로 수정 | Low |
  | 5 | P1-1 | 빈 슬롯 정렬 전략 재설계 (하단 배치 또는 별도 섹션) | Medium |
  | 6 | P0-3 | Supabase RPC/테이블 스키마를 코드베이스에 포함 (마이그레이션 파일) | Medium |
  | 7 | P2-3 | 하드코딩 색상 → AppColors로 이전 | Low |
  | 8 | P3-1 | 승급/강등 실제 실행 로직 구현 | High |
  | 9 | P2-2 | GtoLeagueBody 위젯 분리 (카드별 별도 위젯 파일) | Medium |
  | 10 | P3-5 | RankingScreen 데드 코드 정리 | Low |
