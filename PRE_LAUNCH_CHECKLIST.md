# 🚀 15BB 시드권 사냥꾼 — 실행 전 체크리스트

> 마지막 업데이트: 2026-02-17
> `flutter analyze lib/` → **0 issues** ✅

---

## 📋 목차

1. [필수 환경 설정](#1-필수-환경-설정)
2. [크리티컬 코드 수정](#2-크리티컬-코드-수정)
3. [AndroidManifest 설정](#3-androidmanifest-설정)
4. [에셋 현황](#4-에셋-현황)
5. [출시 전 교체 항목](#5-출시-전-교체-항목)
6. [빌드 & 테스트](#6-빌드--테스트)
7. [스토어 제출 준비](#7-스토어-제출-준비)

---

## 1. 필수 환경 설정

### 1-1. JDK 설치 (APK 빌드 필수)

현재 상태: ❌ **JDK 미설치 → APK 빌드 불가**

```
1. JDK 17 다운로드: https://adoptium.net/temurin/releases/
   (또는 Android Studio 설치 시 포함된 JBR 사용)

2. 환경변수 설정:
   - JAVA_HOME = C:\Program Files\Eclipse Adoptium\jdk-17.x.x
   - PATH에 %JAVA_HOME%\bin 추가

3. 확인:
   java -version
   → openjdk version "17.x.x" 이상
```

### 1-2. Android Studio (권장)

현재 상태: ❌ **미설치**

```
1. 다운로드: https://developer.android.com/studio
2. 설치 시 Android SDK + SDK Tools + JBR 자동 포함
3. Flutter 플러그인 + Dart 플러그인 설치
4. Android 에뮬레이터 생성 (API 34 권장)
```

> **참고**: JDK만 별도 설치해도 `flutter build apk`는 가능하지만,
> 에뮬레이터 디버깅과 프로파일링을 위해 Android Studio 권장.

### 1-3. Flutter Doctor 확인

```bash
flutter doctor
```

모든 항목 ✅ 또는 [!] 가 Android toolchain만 남도록.

---

## 2. 크리티컬 코드 수정

### 2-1. ⚠️ 게임 덱이 Mock 데이터 사용 중

**현재 문제**: `game_screen.dart`에서 `DeckGenerator().generateDeck(50)`을 호출하는데,
이 `DeckGenerator`는 **하드코딩된 핸드 목록으로 모의 질문을 생성**한다.
실제 GTO CSV 데이터를 사용하는 `GtoRepository.getDeckForSession()`은 호출되지 않는다.

**영향**: 게임은 플레이 가능하지만, **실제 GTO Nash Equilibrium 데이터가 아닌 Mock EV 값**이 사용됨.

**수정 방법**:

```dart
// lib/features/game/game_screen.dart

// 변경 전 (현재):
void _generateDeck() {
  final generator = DeckGenerator();
  _deck = generator.generateDeck(50);
  _cardShownTime = DateTime.now();
}

// 변경 후 (GTO DB 사용):
// 1. import 추가
import '../../data/repositories/gto_repository.dart';
import '../../data/services/database_helper.dart';

// 2. _generateDeck를 async로 변경
Future<void> _generateDeck() async {
  final repo = GtoRepository();
  _deck = await repo.getDeckForSession(50);
  if (mounted) {
    setState(() {
      _cardShownTime = DateTime.now();
    });
  }
}

// 3. initState에서 호출 방식 변경
@override
void initState() {
  super.initState();
  _swiperController = CardSwiperController();
  _initGame();
}

Future<void> _initGame() async {
  await DatabaseHelper.instance.initDatabase();
  await _generateDeck();
  if (mounted) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(timerProvider.notifier).start();
    });
  }
}
```

**우선순위**: 🔴 높음 — 이걸 안 하면 GTO 정확도 보장 불가

### 2-2. DB 초기화 누락

`main.dart`에서 `DatabaseHelper.instance.initDatabase()`가 호출되지 않는다.
위 2-1 수정에서 game_screen initState에 포함시키거나,
main.dart에서 앱 시작 시 초기화:

```dart
// lib/main.dart
import 'data/services/database_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  SoundManager.preloadAll();
  await DatabaseHelper.instance.initDatabase(); // ← 추가
  runApp(const ProviderScope(child: App()));
}
```

**우선순위**: 🔴 높음

---

## 3. AndroidManifest 설정

파일: `android/app/src/main/AndroidManifest.xml`

### 3-1. AdMob Application ID (필수)

현재 상태: ❌ **누락 — 앱 크래시 원인**

`google_mobile_ads` 패키지는 앱 시작 시 이 메타데이터를 읽는다.
없으면 **런타임 크래시** 발생.

```xml
<application
    android:label="15BB 시드권 사냥꾼"
    android:name="${applicationName}"
    android:icon="@mipmap/ic_launcher">

    <!-- ✅ AdMob App ID (테스트용) -->
    <meta-data
        android:name="com.google.android.gms.ads.APPLICATION_ID"
        android:value="ca-app-pub-3940256099942544~3347511713"/>

    <!-- 기존 activity 태그들... -->
</application>
```

> ⚠️ 위 값은 **Google 공식 테스트 App ID**. 출시 시 실제 ID로 교체 필수.

**우선순위**: 🔴 높음 — 이거 없으면 앱 실행 자체가 안 됨

### 3-2. 앱 이름 변경

```xml
<!-- 변경 전 -->
android:label="holdem_allin_fold"

<!-- 변경 후 -->
android:label="15BB 시드권 사냥꾼"
```

**우선순위**: 🟡 중간

### 3-3. 인터넷 권한 (확인)

Flutter 디버그 빌드는 자동 포함하지만, 명시적으로 추가 권장:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <!-- 인터넷 (AdMob, Supabase, Google Fonts) -->
    <uses-permission android:name="android.permission.INTERNET"/>

    <application ...>
```

**우선순위**: 🟡 중간

---

## 4. 에셋 현황

### 4-1. 사운드 파일 ✅

`assets/sounds/` — **10개 전부 존재**

| 파일 | 용도 | 상태 |
|------|------|------|
| `correct.wav` | 정답 시 | ✅ |
| `wrong.wav` | 오답 시 | ✅ |
| `snap.wav` | 2초 내 정답 (스냅 보너스) | ✅ |
| `gameOver.wav` | 게임 오버 | ✅ |
| `timerTick.wav` | 타이머 틱 | ✅ |
| `timerWarning.wav` | 타이머 만료 | ✅ |
| `heartbeat.wav` | 하트 관련 | ✅ |
| `chipStack.wav` | 칩 효과음 | ✅ |
| `slotMachine.wav` | 슬롯 효과음 | ✅ |
| `levelUp.wav` | 레벨업 | ✅ |

> **확인 필요**: 각 파일이 실제 오디오 데이터를 포함하는지 (0바이트 더미가 아닌지).
> 더미 파일이면 무료 효과음 사이트에서 교체: https://freesound.org/ 또는 https://pixabay.com/sound-effects/

### 4-2. GTO 데이터베이스 ✅

`assets/db/` — **2개 CSV 존재**

| 파일 | 용도 | 상태 |
|------|------|------|
| `gto_push_chart.csv` | Push/Fold 레인지 | ✅ |
| `gto_call_chart.csv` | Call/Fold 레인지 (디펜스) | ✅ |

> **확인 필요**: CSV 내용이 올바른 GTO 데이터인지 검증.
> 예상 컬럼: `position, hand, stack_bb, action, ev_bb, chart_type [, opponent_position]`

### 4-3. 폰트 ℹ️

`assets/fonts/` — **비어있음** (정상)

앱은 `google_fonts` 패키지를 사용하여 런타임에 폰트 다운로드:
- Black Han Sans (제목)
- Jua (버튼/서브타이틀)
- Noto Sans KR (본문)

> **주의**: 첫 실행 시 인터넷 연결 필요. 오프라인 지원이 필요하면:
> 1. https://fonts.google.com 에서 TTF 다운로드
> 2. `assets/fonts/` 에 배치
> 3. `pubspec.yaml`에 fonts 섹션 추가
> 4. `google_fonts` → 직접 `TextStyle(fontFamily: ...)` 로 변경

### 4-4. 앱 아이콘

현재 상태: 기본 Flutter 아이콘 🔵

**교체 방법 (flutter_launcher_icons 패키지 사용)**:

```yaml
# pubspec.yaml 에 추가
dev_dependencies:
  flutter_launcher_icons: ^0.14.1

flutter_launcher_icons:
  android: true
  ios: true
  image_path: "assets/icon/app_icon.png"  # 1024x1024 PNG 준비
```

```bash
dart run flutter_launcher_icons
```

**우선순위**: 🟡 중간 (출시 전 필수)

---

## 5. 출시 전 교체 항목

### 5-1. AdMob ID 교체

| 항목 | 현재 (테스트) | 출시 시 |
|------|--------------|--------|
| App ID (Manifest) | `ca-app-pub-3940256099942544~3347511713` | AdMob 콘솔에서 발급 |
| Rewarded Android | `ca-app-pub-3940256099942544/5224354917` | AdMob 콘솔에서 발급 |
| Rewarded iOS | `ca-app-pub-3940256099942544/1712485313` | AdMob 콘솔에서 발급 |

파일: `lib/data/services/ad_service.dart` (라인 10-12)

```
1. https://admob.google.com 가입
2. 앱 등록
3. 보상형 광고 유닛 생성
4. 위 3개 ID 교체
```

### 5-2. Supabase 연동 (선택 — $0 서버)

현재 상태: 스캐폴드만 구현 (`ranking_service.dart`의 `syncScoreToCloud`가 debugPrint만 출력)

```
1. https://supabase.com 프로젝트 생성 (무료 플랜)
2. scores 테이블 생성:
   CREATE TABLE scores (
     id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
     user_id TEXT NOT NULL,
     score INT NOT NULL,
     tier TEXT NOT NULL,
     date DATE NOT NULL,
     UNIQUE(user_id, date)
   );
3. lib/main.dart에 Supabase 초기화:
   await Supabase.initialize(
     url: 'YOUR_SUPABASE_URL',
     anonKey: 'YOUR_ANON_KEY',
   );
4. ranking_service.dart의 syncScoreToCloud / fetchCloudGhosts 구현
```

**우선순위**: 🟢 낮음 (로컬 전용으로도 완전히 동작)

### 5-3. Application ID 확인

파일: `android/app/build.gradle`

```gradle
applicationId = "com.antigravity.holdem_allin_fold"
```

Play Store 제출 시 이 ID가 고유해야 한다. 변경이 필요하면 빌드 전에 수정.

### 5-4. 앱 버전

파일: `pubspec.yaml` (라인 19)

```yaml
version: 1.0.0+1  # 출시 시 적절히 설정
```

---

## 6. 빌드 & 테스트

### 6-1. 빌드 명령어

```bash
# 디버그 APK
flutter build apk --debug

# 릴리즈 APK (서명 필요)
flutter build apk --release

# App Bundle (Play Store 제출용)
flutter build appbundle --release
```

### 6-2. 릴리즈 서명 설정

`android/app/build.gradle`에서 현재:
```gradle
release {
    signingConfig = signingConfigs.debug  // ← 테스트용
}
```

출시용 키스토어 생성:
```bash
keytool -genkey -v -keystore ~/holdem-release-key.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias holdem
```

`android/key.properties` 파일 생성:
```properties
storePassword=비밀번호
keyPassword=비밀번호
keyAlias=holdem
storeFile=경로/holdem-release-key.jks
```

`android/app/build.gradle` 수정:
```gradle
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile file(keystoreProperties['storeFile'])
            storePassword keystoreProperties['storePassword']
        }
    }
    buildTypes {
        release {
            signingConfig signingConfigs.release
        }
    }
}
```

> ⚠️ `key.properties`와 `.jks` 파일은 **절대 Git에 커밋하지 말 것**.

### 6-3. 기능 테스트 체크리스트

| # | 테스트 항목 | 확인 |
|---|-----------|------|
| 1 | 첫 실행 → 온보딩 3단계 표시 | ☐ |
| 2 | 온보딩 완료 → 홈 화면 진입 | ☐ |
| 3 | 재실행 → 온보딩 스킵, 바로 홈 | ☐ |
| 4 | ALL-IN 버튼 → 게임 시작 | ☐ |
| 5 | 카드 좌/우 스와이프 동작 | ☐ |
| 6 | 정답 시 ✅ 오버레이 + 점수 증가 | ☐ |
| 7 | 오답 시 ❌ 오버레이 + 팩트폭탄 모달 | ☐ |
| 8 | 오답 시 하트 -1 | ☐ |
| 9 | 하트 0 → 게임 오버 화면 | ☐ |
| 10 | 타이머 15초 카운트다운 동작 | ☐ |
| 11 | 타이머 만료 → 자동 폴드 | ☐ |
| 12 | 타임뱅크 사용 → +30초 | ☐ |
| 13 | 콤보 카운터 증가/리셋 | ☐ |
| 14 | 스냅 보너스 (2초 내 정답) 표시 | ☐ |
| 15 | 게임오버 → "다시 하기" → 새 게임 | ☐ |
| 16 | 게임오버 → "하트 충전" → 광고 재생 → 하트 충전 → 게임 복귀 | ☐ |
| 17 | 게임오버 → "홈으로" → 홈 화면 | ☐ |
| 18 | 홈 → 리그 순위 → 9인 리그 표시 | ☐ |
| 19 | 리그 새로고침 → 고스트 재생성 | ☐ |
| 20 | 홈 → 정보 → 개인정보 처리방침 | ☐ |
| 21 | 사운드 재생 (correct/wrong/snap/gameOver) | ☐ |
| 22 | 햅틱 피드백 동작 | ☐ |
| 23 | 디펜스 모드 카드 (CALL 차트) 표시 | ☐ |
| 24 | 50장 덱 소진 → 게임 오버 | ☐ |
| 25 | 티어 변경 (점수 기반) | ☐ |

---

## 7. 스토어 제출 준비

### 필요 에셋

| 항목 | 사양 | 상태 |
|------|------|------|
| 앱 아이콘 | 1024×1024 PNG | ☐ 미준비 |
| 피처 그래픽 | 1024×500 PNG | ☐ 미준비 |
| 스크린샷 (폰) | 최소 2장, 16:9 또는 9:16 | ☐ 미준비 |
| 앱 설명 (한국어) | 4000자 이내 | ☐ 미준비 |
| 짧은 설명 | 80자 이내 | ☐ 미준비 |
| 개인정보 처리방침 URL | 웹 호스팅 필요 | ☐ 미준비 |
| 콘텐츠 등급 | Play Console 설문 작성 | ☐ 미준비 |

### 콘텐츠 등급 참고

- 포커 관련 앱이지만 **실제 돈 거래 없음** (교육/퍼즐 카테고리)
- 광고 포함 (보상형)
- 개인정보 수집 최소 (UUID, 점수, 닉네임)

---

## 📊 요약: 우선순위별 작업

### 🔴 즉시 (앱 실행 불가)
1. JDK 설치
2. AndroidManifest에 AdMob App ID 추가
3. game_screen → GtoRepository 연결 (Mock → Real DB)
4. main.dart에 DatabaseHelper 초기화

### 🟡 출시 전 필수
5. 앱 이름 변경 ("15BB 시드권 사냥꾼")
6. 앱 아이콘 교체
7. 릴리즈 서명 키 생성
8. AdMob 실제 ID 교체
9. 사운드 파일 품질 확인

### 🟢 선택/나중에
10. Supabase 연동
11. 오프라인 폰트 번들링
12. 스토어 에셋 준비
13. iOS 빌드 설정

---

*이 문서는 프로젝트 루트에 `PRE_LAUNCH_CHECKLIST.md`로 저장됨.*
