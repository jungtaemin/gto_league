# Codebase Analysis - Neo-Brutalist UI System

## 📊 프로젝트 구조 분석

### 디렉토리 구조
```
holdem_allin_fold/
├── lib/
│   ├── main.dart                    # 앱 진입점
│   ├── app.dart                     # 앱 설정
│   ├── core/
│   │   ├── widgets/                 # 재사용 가능한 위젯
│   │   │   ├── neo_brutalist_card.dart      (71줄)
│   │   │   ├── neo_brutalist_button.dart    (104줄)
│   │   │   ├── neon_text.dart               (61줄)
│   │   │   └── progress_bar.dart            (69줄)
│   │   └── theme/                   # 테마 시스템
│   │       ├── app_colors.dart              (45줄)
│   │       ├── app_shadows.dart             (35줄)
│   │       ├── app_text_styles.dart         (86줄)
│   │       └── app_theme.dart               (96줄)
│   ├── data/                        # 데이터 레이어
│   ├── features/                    # 화면/기능
│   │   ├── home/
│   │   ├── game/
│   │   ├── game_over/
│   │   ├── ranking/
│   │   ├── splash/
│   │   ├── onboarding/
│   │   └── privacy/
│   └── providers/                   # Riverpod 상태 관리
├── pubspec.yaml                     # 의존성
└── assets/                          # 리소스
    ├── sounds/
    └── db/
```

---

## 🎨 Design System Overview

### 1. Color System (app_colors.dart)

#### Neon Primary Colors (강조용)
| 색상 | 코드 | 용도 |
|------|------|------|
| neonPink | #FF006E | 주요 강조, 제목 |
| neonCyan | #00F5FF | 보조 강조, 진행률 |
| acidYellow | #FFE700 | CTA 버튼, 강조 |
| electricBlue | #0066FF | 추가 강조 |
| neonPurple | #BF00FF | 추가 강조 |
| acidGreen | #39FF14 | 추가 강조 |

#### Dark Backgrounds
| 색상 | 코드 | 용도 |
|------|------|------|
| deepBlack | #0A0A0A | 메인 배경 |
| darkGray | #1A1A1A | 카드/컨테이너 |
| midnightBlue | #0D1B2A | 변형 배경 |
| darkPurple | #1A0033 | 변형 배경 |

#### Monochrome
| 색상 | 코드 | 용도 |
|------|------|------|
| pureBlack | #000000 | 테두리, 텍스트 |
| pureWhite | #FFFFFF | 텍스트, 강조 |

#### 특수 함수
```dart
// Neon glow 효과 자동 생성
static List<BoxShadow> neonGlow(Color color, {double intensity = 0.6})
// → 20px blur + 10px blur 조합으로 발광 효과
```

---

### 2. Shadow System (app_shadows.dart)

#### Neo-Brutalism 특징: 블러 없는 하드 그림자

| 그림자 | 오프셋 | 용도 |
|--------|--------|------|
| hardShadow | 6px, 6px | 큰 요소 (카드) |
| hardShadowSmall | 4px, 4px | 중간 요소 (버튼) |
| hardShadowTiny | 2px, 2px | 작은 요소 |

**핵심**: `blurRadius: 0` (블러 없음)

---

### 3. Typography System (app_text_styles.dart)

#### Font Families
- **Display**: Black Han Sans (한글 최적화, 굵은 느낌)
- **Heading**: Jua (한글 최적화, 장난스러운 느낌)
- **Body**: Noto Sans KR (한글 최적화, 가독성)

#### Text Styles
| 스타일 | 크기 | 폰트 | 용도 |
|--------|------|------|------|
| display() | 48px | Black Han Sans | 메인 제목 |
| displayMedium() | 36px | Black Han Sans | 부제목 |
| heading() | 24px | Jua | 섹션 제목 |
| headingSmall() | 20px | Jua | 소제목 |
| body() | 16px | Noto Sans KR | 본문 |
| bodySmall() | 14px | Noto Sans KR | 작은 본문 |
| caption() | 12px | Noto Sans KR | 캡션 |
| button() | 18px | Jua | 버튼 텍스트 |

**특징**: display()에만 neon pink shadow 자동 적용

---

### 4. Theme System (app_theme.dart)

#### Material 3 Dark Theme
- **Primary**: neonPink
- **Secondary**: neonCyan
- **Tertiary**: acidYellow
- **Surface**: deepBlack
- **Error**: laserRed

#### 커스텀 설정
- **Card**: 2px white border, 12px radius
- **ElevatedButton**: 4px black border, acidYellow background
- **AppBar**: deepBlack background, centered title
- **BottomNavigationBar**: darkGray background, neonPink selected

---

## 🧩 Widget Components

### 1. NeoBrutalistCard (71줄)

**상태**: StatefulWidget
**상태 변수**: `_isPressed` (bool)

**주요 기능**:
- 4px black border
- Hard shadow (6px offset)
- Press animation (scale 0.95 → 1.0, 100ms, easeOut)
- Customizable: color, padding, borderRadius, width, height

**구현 패턴**:
```dart
GestureDetector(
  onTapDown/onTapUp/onTapCancel → setState(_isPressed)
  ↓
  AnimatedScale(scale: _isPressed ? 0.95 : 1.0)
  ↓
  Container(border + boxShadow + child)
)
```

**사용 예**:
```dart
NeoBrutalistCard(
  color: AppColors.darkGray,
  padding: const EdgeInsets.all(16),
  borderRadius: 12,
  onTap: () => print('Tapped'),
  child: Text('Content'),
)
```

---

### 2. NeoBrutalistButton (104줄)

**상태**: StatefulWidget
**상태 변수**: `_isPressed` (bool)

**주요 기능**:
- 4px black border + hard shadow
- Acid Yellow 기본 배경
- Bounce animation (scale 0.95 → 1.0, 150ms, elasticOut)
- Disabled state (회색 + 비활성)
- 최소 크기: 48x48dp (Android 접근성)
- 선택적 아이콘

**구현 패턴**:
```dart
final isEnabled = widget.onPressed != null;
final effectiveColor = isEnabled ? widget.color : AppColors.darkGray;

GestureDetector(
  onTapDown/onTapUp/onTapCancel → setState(_isPressed) [if isEnabled]
  ↓
  AnimatedScale(scale: _isPressed ? 0.95 : 1.0, curve: elasticOut)
  ↓
  Container(
    constraints: BoxConstraints(minWidth: 48, minHeight: 48),
    decoration: BoxDecoration(color: effectiveColor, border, shadow),
    child: Row(icon + label)
  )
)
```

**사용 예**:
```dart
NeoBrutalistButton(
  onPressed: () => print('Clicked'),
  label: 'FOLD',
  icon: Icons.close,
  color: AppColors.laserRed,
  textColor: AppColors.pureWhite,
)
```

---

### 3. NeonText (61줄)

**상태**: StatelessWidget (상태 없음)

**주요 기능**:
- 자동 neon glow 그림자 효과
- 2단계 glow (20px blur + 10px blur)
- Customizable: color, fontSize, glowIntensity
- 모든 Text 위젯 속성 지원

**구현 패턴**:
```dart
Text(
  text,
  style: (style ?? const TextStyle()).copyWith(
    color: color,
    fontSize: fontSize,
    shadows: [
      Shadow(color: color, blurRadius: 20 * glowIntensity),
      Shadow(color: color.withOpacity(0.5), blurRadius: 10 * glowIntensity),
    ],
  ),
)
```

**사용 예**:
```dart
NeonText(
  'HOLDEM',
  fontSize: 48,
  color: AppColors.neonPink,
  glowIntensity: 1.5,
)
```

---

### 4. ProgressBar (69줄)

**상태**: StatelessWidget (상태 없음)

**주요 기능**:
- Neon 색상 진행률 표시
- 4px black border (Neo-Brutalism)
- 선택적 shimmer 애니메이션 (flutter_animate)
- 값 범위: 0.0 ~ 1.0 (자동 clamp)

**구현 패턴**:
```dart
Container(
  border: 4px black,
  child: ClipRRect(
    child: Stack(
      FractionallySizedBox(widthFactor: clampedValue)
        .animate(onPlay: showShimmer ? controller.repeat() : null)
        .shimmer(duration: 1500.ms)
    )
  )
)
```

**사용 예**:
```dart
ProgressBar(
  value: 0.65,
  color: AppColors.neonCyan,
  showShimmer: true,
  height: 24,
)
```

---

## 📦 Dependencies

### 핵심 패키지
```yaml
flutter_animate: ^4.5.0        # Shimmer & animation effects
google_fonts: ^6.2.1           # Typography
flutter_riverpod: ^2.6.1       # State management
flutter_card_swiper: ^7.2.0    # Card swiping
```

### flutter_animate 사용 패턴
```dart
// ProgressBar에서만 사용
.animate(onPlay: (controller) => showShimmer ? controller.repeat() : null)
.shimmer(duration: 1500.ms, color: Colors.white.withOpacity(0.3))
```

---

## 🎬 Animation Patterns

### 1. Press Animation (모든 상호작용 요소)
```dart
AnimatedScale(
  scale: _isPressed ? 0.95 : 1.0,
  duration: const Duration(milliseconds: 100),  // 카드
  // duration: const Duration(milliseconds: 150),  // 버튼
  curve: Curves.easeOut,  // 카드
  // curve: Curves.elasticOut,  // 버튼 (탄성)
  child: child,
)
```

**특징**:
- 카드: 100ms, easeOut (부드러운)
- 버튼: 150ms, elasticOut (탄성, 튀는 느낌)

### 2. Shimmer Animation (flutter_animate)
```dart
.animate(
  onPlay: (controller) => showShimmer ? controller.repeat() : null,
).shimmer(
  duration: 1500.ms,
  color: Colors.white.withOpacity(0.3),
)
```

---

## 🔄 State Management Pattern

### 간단한 상태 관리 (Widget 레벨)
```dart
class _NeoBrutalistCardState extends State<NeoBrutalistCard> {
  bool _isPressed = false;  // ← 단순 불린 플래그
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap?.call();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        child: child,
      ),
    );
  }
}
```

### 복잡한 상태 관리 (Riverpod)
```dart
// lib/providers/ 디렉토리에서 관리
// 현재 구현되지 않음 (필요 시 추가)
```

---

## 📐 Layout & Spacing Conventions

### 표준 간격 (권장)
```dart
const double spacing4 = 4;      // 미니 간격
const double spacing8 = 8;      // 작은 간격
const double spacing12 = 12;    // 기본 간격
const double spacing16 = 16;    // 표준 간격
const double spacing24 = 24;    // 큰 간격
const 
