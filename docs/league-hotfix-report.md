# 리그 시스템 핫픽스 & 최적화 리포트

## 요약

15인 스플릿 시즌 리그 시스템의 심각 버그 5건과 Supabase 무료 티어 최적화 3건을 수정함.

## 변경 파일 목록

| 파일 | 변경 유형 |
|------|-----------|
| `lib/data/services/league_service.dart` | H3, H4, H5, O1 수정 |
| `lib/features/game_over/game_over_screen.dart` | H1 수정 |
| `lib/features/home/widgets/gto/league/league_header.dart` | H2 수정 |
| `lib/features/home/widgets/gto/gto_league_body.dart` | H2, O2 수정 |
| `.github/workflows/supabase-keepalive.yml` | O3 신규 생성 |

---

## 심각 버그 수정 (H1-H5)

### H1: GameOverScreen build() 내 RPC 중복 호출

**문제**: `GameOverScreen`이 `ConsumerWidget`으로 구현되어 `build()` 메서드 안에서 `_joinLeagueAndUpdateScore()`를 호출. rebuild 시마다 Supabase RPC(`join_or_create_league` + `update_league_score`)가 중복 실행됨.

**수정**: 
- `ConsumerWidget` → `ConsumerStatefulWidget`으로 변환
- `_leagueOpsExecuted` boolean 가드 추가
- 리그 배정 로직을 `initState()`에서 1회만 실행

**BEFORE:**
```dart
class GameOverScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    _joinLeagueAndUpdateScore(context, ref, gameState.score); // ← rebuild마다 실행!
    return Scaffold(...);
  }
}
```

**AFTER:**
```dart
class GameOverScreen extends ConsumerStatefulWidget { ... }
class _GameOverScreenState extends ConsumerState<GameOverScreen> {
  bool _leagueOpsExecuted = false;

  @override
  void initState() {
    super.initState();
    _executeLeagueOps(); // ← 1회만 실행
  }
}
```

**영향**: 게임당 Supabase RPC 호출 2→2회 유지 (이전엔 rebuild 횟수만큼 무한 증가 가능)

---

### H2: FeverTimer 위젯 미사용 (죽은 코드 활성화)

**문제**: `fever_timer.dart` (64줄)가 생성되었지만 어디에서도 import/사용되지 않음. 피버 타임(<12시간) 펄스 애니메이션이 유저에게 보이지 않았음.

**수정**:
- `league_header.dart`에 `FeverTimer` import 및 사용
- `remainingText` String 파라미터 → `remainingDuration` Duration으로 변경
- subtitle 영역을 Row(seasonId + FeverTimer)로 교체
- `gto_league_body.dart`에서 중복 `_formatRemainingText()` 메서드 삭제

**BEFORE:**
```dart
// league_header.dart — 평범한 텍스트, 색상만 변경
Text('$seasonId · $remainingText',
  style: TextStyle(color: isFeverTime ? red : highlight));
```

**AFTER:**
```dart
// league_header.dart — FeverTimer 위젯으로 펄스 애니메이션
Row(children: [
  Text('$seasonId · ', style: TextStyle(color: highlight)),
  FeverTimer(remainingDuration: remainingDuration, isFeverTime: isFeverTime),
]);
```

**영향**: 피버 타임 시 텍스트가 빨간색으로 펄스 애니메이션 → 긴박감 UP

---

### H3: Supabase 에러 무음 실패 개선

**문제**: 모든 RPC 호출(4개 메서드)이 `catch → debugPrint → return null/void` 패턴. 에러 발생 시 유저/호출자에게 아무 정보도 전달하지 않음.

**수정**:
- `updateScore()` 반환 타입: `Future<void>` → `Future<bool>` (true=성공, false=실패)
- 모든 debugPrint 태그에 메서드명 포함: `[LeagueService:methodName]`
  - `[LeagueService:joinOrCreateLeague]`
  - `[LeagueService:updateScore]`
  - `[LeagueService:getCurrentGroupId]`
  - `[LeagueService:fetchLeagueRanking]`

**BEFORE:**
```dart
Future<void> updateScore(int score) async {
  ...
  catch (e) { debugPrint('[LeagueService] 점수 업데이트 실패: $e'); }
}
```

**AFTER:**
```dart
Future<bool> updateScore(int score) async {
  ...
  debugPrint('[LeagueService:updateScore] 점수 업데이트 완료: $score');
  return true;
  } catch (e) {
    debugPrint('[LeagueService:updateScore] 점수 업데이트 실패: $e');
    return false;
  }
}
```

---

### H4: 시즌 경계 레이스 컨디션

**문제**: `DateTime.now()`가 메서드 내에서 여러 번 호출됨. 목요일 23:59:59에 게임 종료 시 시즌 A/B 경계를 넘을 수 있음.

**수정**: 각 public 메서드 진입 시 `final now = DateTime.now()` 한 번만 캡처, 모든 SeasonHelper 호출에 동일한 `now` 전달.

**수정된 메서드:**
- `joinOrCreateLeague()` — line 45: `final now = DateTime.now();`
- `getCurrentGroupId()` — line 104: `final now = DateTime.now();`
- `fetchLeagueRanking()` — line 128: `final now = DateTime.now();`
- `generateLocalLeague()` — line 181: `final now = DateTime.now();`

---

### H5: 봇 점수 비결정적 (새로고침마다 변동)

**문제**: `_fillWithPacemakerBots()` 내부에서 `DateTime.now()`를 호출하여 `elapsedRatio` 계산. 호출 시점마다 밀리초 차이로 봇 점수가 미세하게 달라짐.

**수정**: `_fillWithPacemakerBots()`에 `DateTime now` 파라미터 추가. 내부 `DateTime.now()` 제거.

**BEFORE:**
```dart
void _fillWithPacemakerBots(List<LeaguePlayer> players, String groupId, Tier leagueTier) {
  final seasonId = SeasonHelper.getSeasonId(DateTime.now());   // ← 매번 다름!
  final elapsedRatio = SeasonHelper.getElapsedRatio(DateTime.now()); // ← 매번 다름!
}
```

**AFTER:**
```dart
void _fillWithPacemakerBots(List<LeaguePlayer> players, String groupId, Tier leagueTier, DateTime now) {
  final seasonId = SeasonHelper.getSeasonId(now);       // ← 호출자가 전달한 고정값
  final elapsedRatio = SeasonHelper.getElapsedRatio(now); // ← 동일 시점
}
```

---

## Supabase 무료 티어 최적화 (O1-O3)

### O1: SELECT 컬럼 최적화 (Egress 절감)

**문제**: `fetchLeagueRanking()`에서 사용하지 않는 `avatar_url`, `updated_at` 컬럼까지 SELECT → 불필요한 데이터 전송.

**수정**:
```dart
// BEFORE:
.select('user_id, score, updated_at, profiles!inner(username, avatar_url, tier)')

// AFTER:
.select('user_id, score, profiles!inner(username, tier)')
```

**예상 절감**: 응답 사이즈 ~30% 감소 (avatar_url이 가장 큰 문자열 필드)

---

### O2: 클라이언트 캐시 60초

**문제**: 리그 탭 진입/탭 전환마다 Supabase REST API 2회 호출 (getCurrentGroupId + fetchLeagueRanking).

**수정**: `gto_league_body.dart`에 60초 클라이언트 캐시 추가.
- `_lastFetchTime`, `_cachedPlayers`, `_cachedGroupId` 필드 추가
- `_loadLeague({bool force = false})` — force=false면 60초 내 캐시 반환
- Pull-to-refresh → `_loadLeague(force: true)` — 캐시 무시

**예상 절감**: 리그 탭 반복 진입 시 API 호출 70-80% 감소

---

### O3: Supabase Keep-Alive GitHub Action

**문제**: Supabase 무료 티어는 1주 비활성 시 프로젝트 자동 중지. 소프트런치 기간 유저 유실 위험.

**수정**: `.github/workflows/supabase-keepalive.yml` 생성
- 매 3일 09:00 UTC cron 실행
- Supabase REST 엔드포인트에 curl ping
- Repository Secrets: `SUPABASE_URL`, `SUPABASE_ANON_KEY`
- 수동 트리거(`workflow_dispatch`) 지원

---

## 검증 결과

```
flutter analyze lib/ → 0 errors
(269 info/warning — 전부 기존 withOpacity deprecation + scope 외 unused imports)
```

## 미변경 사항 (의도적 제외)

- `withOpacity()` 전역 마이그레이션 — 리그 파일 외 scope 밖
- `ranking_screen.dart` / `ranking_service.dart` 오류 — 이전 리팩터링에서 삭제 예정이었던 파일
- `game_over_screen.dart`의 하드코딩 색상 (`Color(0xFF1E293B)`) — league/ scope 밖
- Supabase Realtime/WebSocket — 금지 제약사항
- 자동 새로고침 타이머/폴링 — Pull-to-refresh만 허용

---

## Supabase 무료 티어 사용량 예측 (최적화 후)

| DAU | 월간 예상 Egress | 무료 한도 (5GB) 대비 | 판정 |
|-----|-----------------|---------------------|------|
| 100 | ~260MB | 5.2% | ✅ 안전 |
| 500 | ~1.3GB | 26% | ✅ 안전 |
| 1,000 | ~2.6GB | 52% | ⚠️ 주의 |
| 3,000+ | ~7.8GB+ | 156%+ | ❌ Pro 필요 |

> O1(SELECT 최적화) + O2(60초 캐시) 적용 후 기존 대비 ~30-50% egress 절감 예상.
