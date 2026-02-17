# Wave 3 UI Implementation Guide

## 📖 문서 네비게이션

이 프로젝트의 Neo-Brutalist UI 시스템을 이해하기 위한 문서들입니다.

### 🚀 빠른 시작 (5분)
**→ [WAVE3_QUICK_START.md](./WAVE3_QUICK_START.md)**
- 색상 선택 방법
- 텍스트 스타일 선택 방법
- 위젯 조합 방법
- 완전한 예제 코드

### 🎨 전체 스타일 시스템 (30분)
**→ [STYLE_GUIDE.md](./STYLE_GUIDE.md)**
- 색상 팔레트 (Neon + Dark)
- Neo-Brutalist 설계 원칙
- 그림자 시스템
- 4개 핵심 위젯 상세 설명
- 타이포그래피 시스템
- 애니메이션 패턴
- 레이아웃 & 간격
- 컴포넌트 조합 예제

### 💻 코드 패턴 (20분)
**→ [IMPLEMENTATION_PATTERNS.md](./IMPLEMENTATION_PATTERNS.md)**
- Widget State Management 패턴
- Disabled State 패턴
- Decoration (Border + Shadow) 패턴
- Text Styling 패턴
- Animation 패턴 (flutter_animate)
- Color Usage 패턴
- Widget Constructor 패턴
- Null Safety 패턴
- 구현 체크리스트
- 금지 사항 (Anti-Patterns)

### 📊 코드베이스 분석 (15분)
**→ [CODEBASE_ANALYSIS.md](./CODEBASE_ANALYSIS.md)**
- 프로젝트 구조
- Design System 개요
- 각 위젯의 상세 분석
- 의존성 분석
- 애니메이션 패턴
- 상태 관리 패턴
- 설계 철학
- 통계 및 참고

---

## 🎯 사용 시나리오별 가이드

### 시나리오 1: 새로운 화면 만들기
1. **WAVE3_QUICK_START.md** 읽기 (5분)
2. **STYLE_GUIDE.md**의 "Component Composition Examples" 참고 (10분)
3. 코드 작성 시작
4. **IMPLEMENTATION_PATTERNS.md**의 체크리스트 확인

### 시나리오 2: 새로운 위젯 만들기
1. **CODEBASE_ANALYSIS.md**의 "Widget Components" 섹션 읽기
2. **IMPLEMENTATION_PATTERNS.md**의 "Widget State Management Pattern" 참고
3. 기존 위젯 코드 검토 (`lib/core/widgets/`)
4. 패턴 따라 구현

### 시나리오 3: 색상/스타일 변경
1. **STYLE_GUIDE.md**의 "Color Palette" 섹션 참고
2. **STYLE_GUIDE.md**의 "Typography System" 섹션 참고
3. `lib/core/theme/` 파일 수정

### 시나리오 4: 애니메이션 추가
1. **STYLE_GUIDE.md**의 "Animation Patterns" 섹션 참고
2. **IMPLEMENTATION_PATTERNS.md**의 "Animation Pattern" 섹션 참고
3. `flutter_animate` 패키지 사용 (ProgressBar 예제 참고)

---

## 🎨 Design System at a Glance

### Colors
```
배경:     deepBlack (#0A0A0A) / darkGray (#1A1A1A)
텍스트:   pureWhite (#FFFFFF) / pureBlack (#000000)
강조:     neonPink (#FF006E) / neonCyan (#00F5FF) / acidYellow (#FFE700)
```

### Typography
```
제목:     AppTextStyles.display() / heading()
본문:     AppTextStyles.body() / bodySmall()
버튼:     AppTextStyles.button()
```

### Components
```
카드:     NeoBrutalistCard
버튼:     NeoBrutalistButton
텍스트:   NeonText (glow 효과)
진행률:   ProgressBar (shimmer 효과)
```

### Shadows
```
큰 요소:  AppShadows.hardShadow (6px offset)
중간:     AppShadows.hardShadowSmall (4px offset)
작은:     AppShadows.hardShadowTiny (2px offset)
```

---

## 📁 File Structure

```
holdem_allin_fold/
├── lib/
│   ├── core/
│   │   ├── widgets/          ← 4개 핵심 위젯
│   │   │   ├── neo_brutalist_card.dart
│   │   │   ├── neo_brutalist_button.dart
│   │   │   ├── neon_text.dart
│   │   │   └── progress_bar.dart
│   │   └── theme/            ← 테마 시스템
│   │       ├── app_colors.dart
│   │       ├── app_shadows.dart
│   │       ├── app_text_styles.dart
│   │       └── app_theme.dart
│   └── features/             ← 화면들
│       ├── home/
│       ├── game/
│       ├── game_over/
│       ├── ranking/
│       ├── splash/
│       ├── onboarding/
│       └── privacy/
├── WAVE3_QUICK_START.md      ← 빠른 시작 (5분)
├── STYLE_GUIDE.md            ← 전체 스타일 (30분)
├── IMPLEMENTATION_PATTERNS.md ← 코드 패턴 (20분)
├── CODEBASE_ANALYSIS.md      ← 코드베이스 분석 (15분)
└── README_WAVE3.md           ← 이 파일
```

---

## ✅ Wave 3 Implementation Checklist

### 준비 단계
- [ ] 이 README 읽기
- [ ] WAVE3_QUICK_START.md 읽기
- [ ] 기존 위젯 코드 검토 (`lib/core/widgets/`)
- [ ] 테마 시스템 이해 (`lib/core/theme/`)

### 구현 단계
- [ ] 새 화면/위젯 구조 설계
- [ ] AppColors 사용 (하드코딩 금지)
- [ ] AppTextStyles 사용 (커스텀 TextStyle 금지)
- [ ] 4px black border + hard shadow 적용
- [ ] Press animation 추가 (AnimatedScale)
- [ ] Null safety 확보

### 검증 단계
- [ ] 모든 화면에서 일관된 스타일 확인
- [ ] 다크 배경에서 텍스트 가독성 확인
- [ ] 애니메이션 부드러움 확인
- [ ] 모바일 화면 크기에서 레이아웃 확인
- [ ] IMPLEMENTATION_PATTERNS.md의 체크리스트 확인

---

## 🚀 Quick Commands

### 문서 검색
```bash
# 색상 찾기
grep -r "AppColors\." lib/core/theme/

# 텍스트 스타일 찾기
grep -r "AppTextStyles\." lib/core/theme/

# 그림자 찾기
grep -r "AppShadows\." lib/core/widgets/

# 위젯 사용 예제 찾기
grep -r "NeoBrutalistCard\|NeoBrutalistButton" lib/features/
```

### 코드 생성
```bash
# 새 화면 생성 (템플릿)
flutter create --template=screen lib/features/my_feature/my_screen.dart

# 의존성 확인
flutter pub get

# 빌드
flutter build apk
```

---

## 🎓 Learning Path

### 초급 (1시간)
1. WAVE3_QUICK_START.md 읽기
2. 간단한 화면 만들기 (카드 + 버튼)
3. 색상 변경해보기

### 중급 (2시간)
1. STYLE_GUIDE.md 읽기
2. 복잡한 화면 만들기 (여러 카드 + 진행률)
3. 커스텀 애니메이션 추가

### 고급 (3시간)
1. IMPLEMENTATION_PATTERNS.md 읽기
2. 새로운 위젯 만들기
3. CODEBASE_ANALYSIS.md 읽기
4. 전체 시스템 이해

---

## 🔗 External Resources

### Flutter Documentation
- [Flutter Widgets](https://flutter.dev/docs/development/ui/widgets)
- [Flutter Animation](https://flutter.dev/docs/development/ui/animations)
- [Material Design 3](https://m3.material.io/)

### Packages Used
- [flutter_animate](https://pub.dev/packages/flutter_animate) - Animations
- [google_fonts](https://pub.dev/packages/google_fonts) - Typography
- [flutter_riverpod](https://pub.dev/packages/flutter_riverpod) - State Management

---

## 💡 Tips & Tricks

### 색상 선택 팁
- 배경은 항상 `deepBlack` 또는 `darkGray` 사용
- 강조는 neon 색상 중 하나 선택 (최대 2-3개)
- 텍스트는 `pureWhite` 또는 `pureBlack` 사용

### 애니메이션 팁
- 모든 상호작용 요소에 press animation 추가
- 카드: 100ms, easeOut (부드러운)
- 버튼: 150ms, elasticOut (탄성)

### 레이아웃 팁
- 간격은 항상 4의 배수 사용 (4, 8, 12, 16, 24, 32, 48)
- Border radius는 8 또는 12 사용
- 최소 터치 크기: 48x48dp

### 성능 팁
- StatelessWidget 선호 (가능하면)
- 불필요한 rebuild 피하기
- 큰 리스트는 ListView.builder 사용

---

## 🐛 Troubleshooting

### 문제: 텍스트가 보이지 않음
**해결**: 배경색과 텍스트 색상 대비 확인
```dart
// ❌ 나쁜 예
Container(
  color: AppColors.pureWhite,
  child: Text('Text', style: TextStyle(color: AppColors.pureWhite)),
)

// ✅ 좋은 예
Container(
  color: AppColors.deepBlack,
  child: Text('Text', style: TextStyle(color: AppColors.pureWhite)),
)
```

### 문제: 버튼이 반응하지 않음
**해결**: onPressed 콜백 확인
```dart
// ❌ 나쁜 예
NeoBrutalistButton(
  onPressed: null,  // ← 비활성화됨
  label: 'BUTTON',
)

// ✅ 좋은 예
NeoBrutalistButton(
  onPressed: () => print('Clicked'),
  label: 'BUTTON',
)
```

### 문제: 애니메이션이 끊김
**해결**: 상태 관리 확인
```dart
// ❌ 나쁜 예
GestureDetector(
  onTap: () => print('Tapped'),  // ← 애니메이션 없음
  child: Container(),
)

// ✅ 좋은 예
GestureDetector(
  onTapDown: (_) => setState(() => _isPressed = true),
  onTapUp: (_) {
    setState(() => _isPressed = false);
    onPressed?.call();
  },
  child: AnimatedScale(
    scale: _isPressed ? 0.95 : 1.0,
    duration: const Duration(milliseconds: 100),
    curve: Curves.easeOut,
    child: Container(),
  ),
)
```

---

## 📞 Support

### 문서 관련 질문
- STYLE_GUIDE.md 참고
- IMPLEMENTATION_PATTERNS.md 참고
- CODEBASE_ANALYSIS.md 참고

### 코드 관련 질문
- `lib/core/widgets/` 기존 위젯 코드 검토
- `lib/core/theme/` 테마 시스템 검토
- `lib/features/` 화면 구현 예제 검토

---

## 📝 Document Versions

| 문서 | 버전 | 업데이트 | 라인 |
|------|------|---------|------|
| WAVE3_QUICK_START.md | 1.0 | 2026-02-16 | 333 |
| STYLE_GUIDE.md | 1.0 | 2026-02-16 | 356 |
| IMPLEMENTATION_PATTERNS.md | 1.0 | 2026-02-16 | 350 |
| CODEBASE_ANALYSIS.md | 1.0 | 2026-02-16 | 400+ |
| README_WAVE3.md | 1.0 | 2026-02-16 | 이 파일 |

**Total Documentation**: 1,400+ 라인

---

## 🎉 Ready to Start?

1. **5분 빠른 시작**: [WAVE3_QUICK_START.md](./WAVE3_QUICK_START.md)
2. **30분 상세 학습**: [STYLE_GUIDE.md](./STYLE_GUIDE.md)
3. **코드 작성 시작**: 새 화면/위젯 만들기
4. **검증**: IMPLEMENTATION_PATTERNS.md 체크리스트 확인

---

**Happy Coding! 🚀**

**Last Updated**: 2026-02-16
**Version**: 1.0
