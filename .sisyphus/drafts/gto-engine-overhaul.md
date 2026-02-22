# Draft: GTO Engine Overhaul — HRC 마스터 DB + 100-Hand 서바이벌

## HRC JSON Tree Schema (확정 분석)

### Settings 구조 (15BB/settings.json)
- **9인 테이블**, 모든 플레이어 동일 스택 (15BB = 1500칩, BB=100)
- Blinds: [ante=100, SB=50, BB=100], BB_ANTE_BLIND_FIRST
- Push/Fold 전용 트리 (mode: "basic")

### 노드 스키마
```json
{
  "player": int,         // 0=UTG, 1=UTG+1, ..., 5=CO, 6=BU, 7=SB, 8=BB
  "street": 0,           // 항상 프리플랍
  "children": 2,         // Fold와 Raise/Call 두 가지
  "sequence": [           // 이 노드까지의 액션 히스토리
    {"player": 0, "type": "F", "amount": 0, "street": 0}
  ],
  "actions": [            // 가능한 액션
    {"type": "F", "amount": 0, "node": 2},      // Fold → 다음 노드
    {"type": "R", "amount": 1500, "node": 100}   // Push(All-in) → 다음 노드
  ],
  "hands": {              // 169개 핸드 콤보별 GTO 데이터
    "AKs": {
      "weight": 1.0,
      "played": [0.0, 1.0],   // [폴드 빈도, 푸시/콜 빈도]
      "evs": [15.0, 17.26]    // [폴드 EV, 푸시/콜 EV] (칩 단위)
    }
  }
}
```

### 3가지 상황 식별 로직 (트리 파싱)
1. **Open Push**: sequence에 "F"만 있음 → 모두 폴드, 내가 첫 액션
2. **Single-way 방어**: sequence에 "R" 1개 → 누가 푸시, 내가 콜/폴드
3. **Multi-way 방어**: sequence에 "R" + "C" 조합 → 2명 이상 엮인 팟

### Position 매핑 (9인)
| Player Index | Position |
|---|---|
| 0 | UTG |
| 1 | UTG+1 |
| 2 | UTG+2 |
| 3 | LJ |
| 4 | HJ |
| 5 | CO |
| 6 | BU |
| 7 | SB |
| 8 | BB |

### EV 해석
- `evs[0]` = 폴드 EV (sequence의 첫 번째 액션)
- `evs[1]` = 푸시/콜 EV (두 번째 액션)
- EV 손실 = max(evs) - 유저 선택 EV (BB 단위로 변환 필요)

### BB별 노드 수
- 각 BB 폴더에 수백 개 노드 존재 (7BB: ~254개)
- 노드 수는 가능한 액션 시퀀스의 수와 일치

## 기술 스택 (확인됨)
- **프레임워크**: Flutter/Dart
- **상태관리**: Riverpod (코드 생성 방식)
- **스와이프**: flutter_card_swiper 7.2.0
- **애니메이션**: flutter_animate 4.5.0
- **DB**: sqflite 2.4.1
- **디자인**: Neo-Brutalism + Neon ("Nano Banana" 스타일)
- **CSV 패키지**: csv 6.0.0 (제거 대상)

## 현재 상태 (AGENTS.md에서 확인)
- **치명적 갭**: 게임이 DeckGenerator(목업)를 사용중, GtoRepository(실제 SQLite)는 미연결
- **레거시 CSV**: gto_push_chart.csv, gto_call_chart.csv 존재
- **기존 리그 시스템**: league_service.dart 있음
- **기존 방어 경고**: defense_alert_banner.dart 존재

## Open Questions
- 파서 스크립트 언어: Python vs Node.js?
- 마스터 DB 포맷: JSON vs SQLite?
- 9인 vs 6인 테이블 — HRC 데이터는 9인 설정인데, 모든 포지션을 사용?
- Mixed strategy(혼합 전략) 핸드 처리: 무시? 확률적 출제?

## Scope (IN/OUT)
### IN
- Phase 1: HRC JSON 파서 스크립트 (Python/Node.js)
- Phase 2: 100-Hand 서바이벌 게임 루프
- Phase 3: 레거시 CSV 코드 완전 제거 + 신규 엔진 통합
- UI/UX: 레벨업 컷씬, 다이내믹 배경, HUD, 기습 경고, 스와이프 타격감

### OUT (TBD)
- 서버사이드 랭킹 연동
- 결제/광고 시스템 변경
- 온보딩 플로우 변경
