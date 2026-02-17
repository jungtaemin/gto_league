# Neo-Brutalist UI Style Guide - Wave 3 Reference

## 📋 Overview

이 문서는 **holdem_allin_fold** 프로젝트의 기존 Neo-Brutalist + Neon 스타일 시스템을 정리한 가이드입니다.
Wave 3 UI 작업 시 일관성 있는 디자인을 유지하기 위한 레퍼런스입니다.

---

## 🎨 Color Palette

### Neon Primary Colors
```dart
// lib/core/theme/app_colors.dart
static const Color neonPink = Color(0xFFFF006E);      // 주요 강조색
static const Color neonCyan = Color(0xFF00F5FF);      // 보조 강조색
static const Color acidYellow = Color(0xFFFFE700);    // 버튼/CTA
static const Color electricBlue = Color(0xFF0066FF);  // 추가 강조
static const Color neonPurple = Color(0xFFBF00FF);    // 추가 강조
static const Color acidGreen = Color(0xFF39FF14);     // 추가 강조
```

### Supporting Neon Colors
```dart
static const Color hotPink = Color(0xFFFF10F0);       // 변형 강조
static const Color laserRed = Color(0xFFFF073A);      // 에러/경고
static const Color ultraViolet = Color(0xFF8B00FF);   // 변형 강조
static const Color hotOrange = Color(0xFFFF6B35);     // 변형 강조
```

### Dark Backgrounds
```dart
static const Color deepBlack = Color(0xFF0A0A0A);     // 메인 배경
static const Color darkGray = Color(0xFF1A1A1A);      // 카드/컨테이너
static const Color midnightBlue = Color(0xFF0D1B2A);  // 변형 배경
static const Color darkPurple = Color(0xFF1A0033);    // 변형 배경
```

### Monochrome
```dart
static const Color pureBlack = Color(0xFF000000);     // 테두리/텍스트
static const Color pureWhite = Color(0xFFFFFFFF);     // 텍스트/강조
```

### 사용 패턴
```dart
// 1. 기본 색상 참조
Container(
  color: AppColors.deepBlack,
  child: Text('Hello', style: TextStyle(color: AppColors.pureWhite)),
)

// 2. Neon Glow 효과 (자동 생성)
Container(
  decoration: BoxDecoration(
    color: AppColors.neonCyan,
    boxShadow: AppColors.neonGlow(AppColors.neonCyan, intensity: 0.6),
  ),
)
```

---

## 🔲 Neo-Brutalist Design System

### 핵심 특징
1. **4px Black Border** - 모든 주요 요소에 적용
2. **Hard Shadow** - 블러 없는 직선적 그림자 (6px offset)
3. **High Contrast** - 명확한 색상 대비
4. **Geometric Forms** - 직각과 원형의 조합

### Shadow System

```dart
// lib/core/theme/app_shadows.dart

// 1. Hard Shadow (기본)
static const List<BoxShadow> hardShadow = [
  BoxShadow(
    color: Colors.black,
    offset: Offset(6, 6),
    blurRadius: 0,      // ← 블러 없음 (Neo-Brutalism)
    spreadRadius: 0,
  ),
];

// 2. Hard Shadow Small (작은 요소)
static const List<BoxShadow> hardShadowSmall = [
  BoxShadow(
    color: Colors.black,
    offset: Offset(4, 4),
    blurRadius: 0,
    spreadRadius: 0,
  ),
];

// 3. Hard Shadow Tiny (매우 작은 요소)
static const List<BoxShadow> hardShadowTiny = [
  BoxShadow(
    color: Colors.black,
    offset: Offset(2, 2),
    blurRadius: 0,
    spreadRadius: 0,
  ),
];
```

### 사용 패턴
```dart
// 큰 카드
Container(
  decoration: BoxDecoration(
    color: AppColors.darkGray,
    border: Border.all(color: AppColors.pureBlack, width: 4),
    borderRadius: BorderRadius.circular(12),
    boxShadow: AppShadows.hardShadow,  // 6px offset
  ),
)

// 작은 버튼
Container(
  decoration: BoxDecoration(
    color: AppColors.acidYellow,
    border: Border.all(color: AppColors.pureBlack, width: 4),
    borderRadius: BorderRadius.circular(8),
    boxShadow: AppShadows.hardShadowSmall,  // 4px offset
  ),
)
```

---

## 🧩 Widget Components

### 1. NeoBrutalistCard
**위치**: `lib/core/widgets/neo_brutalist_card.dart`

**특징**:
- 4px black border
- Hard shadow (6px offset)
- Press animation (scale 0.95 → 1.0, 100ms)
- Customizable color, padding, border radius

**사용 예**:
```dart
NeoBrutalistCard(
  color: AppColors.darkGray,
  padding: const EdgeInsets.all(16),
  borderRadius: 12,
  onTap: () => print('Tapped'),
  child: Text('Card Content'),
)

// 크기 지정
NeoBrutalistCard(
  width: 200,
  height: 150,
  color: AppColors.neonPink.withOpacity(0.1),
  child: Center(child: Text('Custom Size')),
)
```

**구현 패턴**:
```dart
class _NeoBrutalistCardState extends State<NeoBrutalistCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.onTap != null ? (_) => setState(() => _isPressed = true) : null,
      onTapUp: widget.onTap != null ? (_) {
        setState(() => _isPressed = false);
        widget.onTap?.call();
      } : null,
      onTapCancel: widget.onTap != null ? () => setState(() => _isPressed = false) : null,
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut,
        child: Container(
          decoration: BoxDecoration(
            color: widget.color,
            border: Border.all(color: AppColors.pureBlack, width: 4),
            borderRadius: BorderRadius.circular(widget.borderRadius),
            boxShadow: AppShadows.hardShadow,
          ),
          child: widget.child,
        ),
      ),
    );
  }
}
```

---

### 2. NeoBrutalistButton
**위치**: `lib/core/widgets/neo_brutalist_button.dart`

**특징**:
- 4px black border + hard shadow
- Acid Yellow 기본 배경
- Bounce animation (Curves.elasticOut, 150ms)
- Disabled state (회색 + 비활성)
- 최소 크기: 48x48dp (Android 접근성)

**사용 예**:
```dart
// 기본 버튼
NeoBrutalistButton(
  onPressed: () => print('Clicked'),
  label: 'PLAY GAME',
)

// 커스텀 색상
NeoBrutalistButton(
  onPressed: () => print('Clicked'),
  label: 'FOLD',
  color: AppColors.laserRed,
  textColor: AppColors.pureWhite,
)

// 아이콘 포함
NeoBrutalistButton(
  onPressed: () => print('Clicked'),
  label: 'CONTINUE',
  icon: Icons.arrow_forward,
)

// 비활성 상태
NeoBrutalistButton(
  onPressed: null,  // null = disabled
  label: 'DISABLED',
)
```

**구현 패턴**:
```dart
class _NeoBrutalistButtonState extends State<NeoBrutalistButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isEnabled = widget.onPressed != null;
    final effectiveColor = isEnabled ? widget.color : AppColors.darkGray;
    
    return GestureDetector(
      onTapDown: isEnabled ? (_) => setState(() => _isPressed = true) : null,
      onTapUp: isEnabled ? (_) {
        setState(() => _isPressed = false);
        widget.onPressed?.call();
      } : null,
      onTapCancel: isEnabled ? () => setState(() => _isPressed = false) : null,
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.elasticOut,  // ← 탄성 애니메이션
        child: Container(
          decoration: BoxDecoration(
            color: effectiveColor,
            border: Border.all(color: AppColors.pureBlack, width: 4),
            borderRadius: BorderRadius.circular(widget.borderRadius),
            boxShadow: isEnabled ? AppShadows.hardShadow : AppShadows.hardShadowSmall,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.icon != null) Icon(widget.icon),
              Text(widget.label),
            ],
          ),
        ),
      ),
    );
  }
}
```

---

### 3. NeonText
**위치**: `lib/core/widgets/neon_text.dart`

**특징**:
- 자동 neon glow 그림자 효과
- 색상, fontSize, glowIntensity 커스터마이징
- 모든 Text 위젯 속성 지원

**사용 예**:
```dart
// 기본 neon pink
NeonText(
  'HOLDEM',
  fontSize: 48,
  color: AppColors.neonPink,
)

// 커스텀 glow
NeonText(
  'NEON CYAN',
  fontSize: 32,
  color: AppColors.neonCyan,
  glowIntensity: 1.5,  // 더 강한 glow
)

// 텍스트 정렬
NeonText(
  'CENTERED',
  fontSize: 24,
  color: AppColors.acidYellow,
  textAlign: TextAlign.center,
  maxLines: 2,
)
```

**구현 패턴**:
```dart
class NeonText extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: (style ?? const TextStyle()).copyWith(
        color: color,
        fontSize: fontSize,
        shadows: [
          Shadow(
            color: color,
            blurRadius: 20 * glowIntensity,  // 주 glow
            offset: Offset.zero,
          ),
          Shadow(
            color: color.withOpacity(0.5),
            blurRadius: 10 * glowIntensity,  // 보조 glow
            offset: Offset.zero,
          ),
        ],
      ),
    );
  }
}
```

---

### 4. ProgressBar
**위치**: `lib/core/widgets/progress_bar.dart`

**특징**:
- Neon 색상 진행률 표시
- 4px black border (Neo-Brutalism)
- 선택적 shimmer 애니메이션 (flutter_animate)
- 값 범위: 0.0 ~ 1.0

**사용 예
