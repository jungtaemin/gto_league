# Wave 3 Quick Start Guide

## 🚀 5분 안에 시작하기

### 1단계: 색상 선택
```dart
// 배경
AppColors.deepBlack        // 메인 배경
AppColors.darkGray         // 카드/컨테이너

// 텍스트
AppColors.pureWhite        // 기본 텍스트
AppColors.pureBlack        // 버튼 텍스트

// 강조
AppColors.neonPink         // 주요 강조
AppColors.neonCyan         // 보조 강조
AppColors.acidYellow       // CTA 버튼
```

### 2단계: 텍스트 스타일 선택
```dart
AppTextStyles.display()        // 48px 제목
AppTextStyles.heading()        // 24px 섹션 제목
AppTextStyles.body()           // 16px 본문
AppTextStyles.button()         // 18px 버튼
```

### 3단계: 위젯 조합
```dart
// 카드
NeoBrutalistCard(
  color: AppColors.darkGray,
  child: Text('Content', style: AppTextStyles.body()),
)

// 버튼
NeoBrutalistButton(
  onPressed: () => print('Clicked'),
  label: 'ACTION',
)

// Neon 텍스트
NeonText('TITLE', fontSize: 32, color: AppColors.neonPink)

// 진행률
ProgressBar(value: 0.65, color: AppColors.neonCyan)
```

---

## 📚 상세 가이드

| 문서 | 내용 |
|------|------|
| **STYLE_GUIDE.md** | 색상, 타이포그래피, 컴포넌트, 레이아웃 |
| **IMPLEMENTATION_PATTERNS.md** | 코드 패턴, 상태 관리, 애니메이션 |
| **WAVE3_QUICK_START.md** | 이 문서 (빠른 시작) |

---

## 🎨 색상 팔레트 한눈에

### Neon Colors (강조용)
```
neonPink (#FF006E)      - 주요 강조
neonCyan (#00F5FF)      - 보조 강조
acidYellow (#FFE700)    - CTA 버튼
electricBlue (#0066FF)  - 추가 강조
neonPurple (#BF00FF)    - 추가 강조
acidGreen (#39FF14)     - 추가 강조
laserRed (#FF073A)      - 에러/경고
```

### Dark Backgrounds
```
deepBlack (#0A0A0A)     - 메인 배경
darkGray (#1A1A1A)      - 카드/컨테이너
midnightBlue (#0D1B2A)  - 변형 배경
darkPurple (#1A0033)    - 변형 배경
```

### Monochrome
```
pureBlack (#000000)     - 테두리/텍스트
pureWhite (#FFFFFF)     - 텍스트/강조
```

---

## 🧩 컴포넌트 빠른 참조

### NeoBrutalistCard
```dart
NeoBrutalistCard(
  color: AppColors.darkGray,
  padding: const EdgeInsets.all(16),
  borderRadius: 12,
  onTap: () => print('Tapped'),
  width: 200,
  height: 150,
  child: Text('Content'),
)
```

### NeoBrutalistButton
```dart
NeoBrutalistButton(
  onPressed: () => print('Clicked'),
  label: 'BUTTON',
  icon: Icons.arrow_forward,
  color: AppColors.acidYellow,
  textColor: AppColors.pureBlack,
)
```

### NeonText
```dart
NeonText(
  'GLOWING TEXT',
  fontSize: 32,
  color: AppColors.neonPink,
  glowIntensity: 1.5,
)
```

### ProgressBar
```dart
ProgressBar(
  value: 0.65,
  color: AppColors.neonCyan,
  showShimmer: true,
  height: 24,
)
```

---

## 🎬 애니메이션 패턴

### Press Animation (모든 버튼/카드)
```dart
AnimatedScale(
  scale: _isPressed ? 0.95 : 1.0,
  duration: const Duration(milliseconds: 100),
  curve: Curves.easeOut,
  child: child,
)
```

### Shimmer Animation (ProgressBar)
```dart
.animate(
  onPlay: (controller) => showShimmer ? controller.repeat() : null,
).shimmer(
  duration: 1500.ms,
  color: Colors.white.withOpacity(0.3),
)
```

---

## 📐 레이아웃 간격

```dart
const double spacing4 = 4;      // 미니
const double spacing8 = 8;      // 작음
const double spacing12 = 12;    // 기본
const double spacing16 = 16;    // 표준
const double spacing24 = 24;    // 큼
const double spacing32 = 32;    // 매우 큼
const double spacing48 = 48;    // 섹션
```

---

## ✅ 구현 체크리스트

### 새 화면 만들 때
- [ ] 배경: `AppColors.deepBlack`
- [ ] 제목: `AppTextStyles.display()` 또는 `AppTextStyles.heading()`
- [ ] 본문: `AppTextStyles.body()`
- [ ] 버튼: `NeoBrutalistButton`
- [ ] 카드: `NeoBrutalistCard`
- [ ] 강조: `NeonText` 또는 `AppColors.neonGlow()`

### 새 위젯 만들 때
- [ ] `StatefulWidget` 상속
- [ ] `_isPressed` 상태 추가
- [ ] GestureDetector + AnimatedScale
- [ ] 4px black border
- [ ] Hard shadow (AppShadows)
- [ ] AppColors 사용
- [ ] AppTextStyles 사용

---

## 🚫 금지 사항

```dart
// ❌ 하드코딩된 색상
Color(0xFF1A1A1A)

// ❌ 커스텀 TextStyle
TextStyle(fontSize: 24, fontWeight: FontWeight.bold)

// ❌ 블러 있는 그림자
BoxShadow(blurRadius: 10)

// ❌ 테두리 없는 카드
Container(color: AppColors.darkGray)

// ❌ 애니메이션 없는 버튼
GestureDetector(onTap: () => {})
```

---

## 📁 파일 위치

```
lib/
├── core/
│   ├── widgets/
│   │   ├── neo_brutalist_card.dart
│   │   ├── neo_brutalist_button.dart
│   │   ├── neon_text.dart
│   │   └── progress_bar.dart
│   └── theme/
│       ├── app_colors.dart
│       ├── app_shadows.dart
│       ├── app_text_styles.dart
│       └── app_theme.dart
└── features/
    ├── home/
    ├── game/
    ├── game_over/
    ├── ranking/
    ├── splash/
    ├── onboarding/
    └── privacy/
```

---

## 🎯 예제: 완전한 화면

```dart
import 'package:flutter/material.dart';
import 'package:holdem_allin_fold/core/widgets/neo_brutalist_card.dart';
import 'package:holdem_allin_fold/core/widgets/neo_brutalist_button.dart';
import 'package:holdem_allin_fold/core/widgets/neon_text.dart';
import 'package:holdem_allin_fold/core/theme/app_colors.dart';
import 'package:holdem_allin_fold/core/theme/app_text_styles.dart';

class ExampleScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.deepBlack,
      appBar: AppBar(
        title: Text('Example', style: AppTextStyles.heading()),
        backgroundColor: AppColors.deepBlack,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 제목
            NeonText(
              'WAVE 3 EXAMPLE',
              fontSize: 48,
              color: AppColors.neonPink,
            ),
            const SizedBox(height: 32),
            
            // 카드
            NeoBrutalistCard(
              color: AppColors.darkGray,
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Text(
                    'Card Title',
                    style: AppTextStyles.heading(color: AppColors.neonCyan),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Card content goes here',
                    style: AppTextStyles.body(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // 버튼 그룹
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                NeoBrutalistButton(
                  onPressed: () => print('Action 1'),
                  label: 'ACTION 1',
                  color: AppColors.acidYellow,
                ),
                NeoBrutalistButton(
                  onPressed: () => print('Action 2'),
                  label: 'ACTION 2',
                  color: AppColors.neonCyan,
                  textColor: AppColors.pureBlack,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## 🔗 관련 문서

- [STYLE_GUIDE.md](./STYLE_GUIDE.md) - 전체 스타일 시스템
- [IMPLEMENTATION_PATTERNS.md](./IMPLEMENTATION_PATTERNS.md) - 코드 패턴
- [pubspec.yaml](./pubspec.yaml) - 의존성

---

**Last Updated**: 2026-02-16
**Version**: 1.0
