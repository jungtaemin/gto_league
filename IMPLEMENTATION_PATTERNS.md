# Implementation Patterns - Wave 3 Code Reference

## 🔍 기존 코드 패턴 분석

### 1. Widget State Management Pattern

#### NeoBrutalistCard & NeoBrutalistButton 공통 패턴
```dart
class _NeoBrutalistCardState extends State<NeoBrutalistCard> {
  bool _isPressed = false;  // ← 단순 상태 관리

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // 1. 탭 다운: 상태 변경
      onTapDown: widget.onTap != null ? (_) => setState(() => _isPressed = true) : null,
      
      // 2. 탭 업: 상태 복원 + 콜백 실행
      onTapUp: widget.onTap != null ? (_) {
        setState(() => _isPressed = false);
        widget.onTap?.call();
      } : null,
      
      // 3. 탭 취소: 상태 복원
      onTapCancel: widget.onTap != null ? () => setState(() => _isPressed = false) : null,
      
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut,
        child: Container(/* ... */),
      ),
    );
  }
}
```

**핵심 포인트**:
- `_isPressed` 불린 플래그로 상태 관리
- `onTap != null` 체크로 null-safety 확보
- `AnimatedScale`로 부드러운 애니메이션
- GestureDetector의 3가지 콜백 모두 처리

---

### 2. Disabled State Pattern

#### NeoBrutalistButton에서 사용
```dart
class _NeoBrutalistButtonState extends State<NeoBrutalistButton> {
  @override
  Widget build(BuildContext context) {
    // 1. 활성화 여부 판단
    final isEnabled = widget.onPressed != null;
    
    // 2. 활성화 상태에 따른 색상 결정
    final effectiveColor = isEnabled ? widget.color : AppColors.darkGray;
    final effectiveTextColor = isEnabled ? widget.textColor : AppColors.darkGray.withOpacity(0.5);
    
    return GestureDetector(
      // 3. 비활성화 시 탭 이벤트 무시
      onTapDown: isEnabled ? (_) => setState(() => _isPressed = true) : null,
      onTapUp: isEnabled ? (_) {
        setState(() => _isPressed = false);
        widget.onPressed?.call();
      } : null,
      onTapCancel: isEnabled ? () => setState(() => _isPressed = false) : null,
      
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.elasticOut,
        child: Container(
          decoration: BoxDecoration(
            color: effectiveColor,
            boxShadow: isEnabled ? AppShadows.hardShadow : AppShadows.hardShadowSmall,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.icon != null) Icon(widget.icon, color: effectiveTextColor),
              Text(widget.label, style: TextStyle(color: effectiveTextColor)),
            ],
          ),
        ),
      ),
    );
  }
}
```

**핵심 포인트**:
- `onPressed != null`로 활성화 여부 판단
- 색상, 그림자, 상호작용 모두 상태에 따라 변경
- 비활성화 시에도 시각적 피드백 제공 (회색 + 작은 그림자)

---

### 3. Decoration Pattern (Border + Shadow)

#### 표준 Neo-Brutalist 데코레이션
```dart
// 큰 요소 (카드)
decoration: BoxDecoration(
  color: AppColors.darkGray,
  border: Border.all(
    color: AppColors.pureBlack,
    width: 4,  // ← 4px 검은 테두리 (필수)
  ),
  borderRadius: BorderRadius.circular(12),
  boxShadow: AppShadows.hardShadow,  // ← 6px offset, 블러 없음
),

// 작은 요소 (버튼)
decoration: BoxDecoration(
  color: AppColors.acidYellow,
  border: Border.all(
    color: AppColors.pureBlack,
    width: 4,
  ),
  borderRadius: BorderRadius.circular(8),
  boxShadow: AppShadows.hardShadowSmall,  // ← 4px offset
),

// Neon 효과가 필요한 경우
decoration: BoxDecoration(
  color: AppColors.neonCyan,
  border: Border.all(color: AppColors.pureBlack, width: 4),
  borderRadius: BorderRadius.circular(12),
  boxShadow: AppColors.neonGlow(AppColors.neonCyan, intensity: 0.6),
),
```

**핵심 포인트**:
- 항상 4px 검은 테두리 사용
- 크기에 따라 적절한 shadow 선택
- Neon 색상에는 `AppColors.neonGlow()` 사용

---

### 4. Text Styling Pattern

#### AppTextStyles 사용 (필수)
```dart
// ❌ 금지: 하드코딩된 스타일
Text(
  'Title',
  style: TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  ),
)

// ✅ 권장: AppTextStyles 사용
Text(
  'Title',
  style: AppTextStyles.heading(color: AppColors.pureWhite),
)

// ✅ 색상만 변경
Text(
  'Neon Title',
  style: AppTextStyles.heading(color: AppColors.neonPink),
)

// ✅ NeonText 위젯 사용 (자동 glow)
NeonText(
  'GLOWING TITLE',
  fontSize: 24,
  color: AppColors.neonPink,
)
```

**사용 가능한 스타일**:
- `AppTextStyles.display()` - 48px, Black Han Sans
- `AppTextStyles.displayMedium()` - 36px, Black Han Sans
- `AppTextStyles.heading()` - 24px, Jua
- `AppTextStyles.headingSmall()` - 20px, Jua
- `AppTextStyles.body()` - 16px, Noto Sans KR
- `AppTextStyles.bodySmall()` - 14px, Noto Sans KR
- `AppTextStyles.caption()` - 12px, Noto Sans KR
- `AppTextStyles.button()` - 18px, Jua (버튼용)

---

### 5. Animation Pattern (flutter_animate)

#### ProgressBar의 Shimmer 애니메이션
```dart
// 기본 구조
Container(
  decoration: BoxDecoration(
    color: color,
    boxShadow: AppColors.neonGlow(color, intensity: 0.4),
  ),
).animate(
  onPlay: (controller) => showShimmer ? controller.repeat() : null,
).shimmer(
  duration: showShimmer ? 1500.ms : 0.ms,
  color: Colors.white.withOpacity(0.3),
)
```

**flutter_animate 사용 패턴**:
```dart
// 1. 기본 애니메이션
widget.animate().fadeIn(duration: 500.ms)

// 2. 반복 애니메이션
widget.animate(onPlay: (controller) => controller.repeat())
  .shimmer(duration: 1500.ms)

// 3. 조건부 애니메이션
.animate(
  onPlay: (controller) => condition ? controller.repeat() : null,
).shimmer(duration: 1500.ms)

// 4. 여러 효과 조합
widget.animate()
  .fadeIn(duration: 300.ms)
  .then()
  .scale(duration: 500.ms)
```

---

### 6. Color Usage Pattern

#### AppColors 사용 (필수)
```dart
// ❌ 금지: 하드코딩된 색상
Container(
  color: Color(0xFF1A1A1A),
  child: Text('Text', style: TextStyle(color: Color(0xFFFFFFFF))),
)

// ✅ 권장: AppColors 사용
Container(
  color: AppColors.darkGray,
  child: Text('Text', style: TextStyle(color: AppColors.pureWhite)),
)

// ✅ Neon glow 효과
Container(
  decoration: BoxDecoration(
    color: AppColors.neonCyan,
    boxShadow: AppColors.neonGlow(AppColors.neonCyan, intensity: 0.6),
  ),
)

// ✅ 투명도 조정
Container(
  color: AppColors.neonPink.withOpacity(0.1),  // 배경
  child: Text('Text', style: TextStyle(color: AppColors.neonPink)),
)
```

**색상 선택 가이드**:
- **배경**: `deepBlack`, `darkGray`, `midnightBlue`, `darkPurple`
- **텍스트**: `pureWhite`, `pureBlack`
- **강조**: `neonPink`, `neonCyan`, `acidYellow`, `electricBlue`, `neonPurple`, `acidGreen`
- **에러**: `laserRed`

---

### 7. Widget Constructor Pattern

#### 필수 vs 선택 파라미터
```dart
class NeoBrutalistCard extends StatefulWidget {
  // 필수 파라미터
  final Widget child;
  
  // 선택 파라미터 (기본값 포함)
  final Color color;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final VoidCallback? onTap;
  final double? width;
  final double? height;

  const NeoBrutalistCard({
    super.key,
    required this.child,  // ← 필수
    this.color = AppColors.darkGray,  // ← 기본값
    this.padding,  // ← null 가능
    this.borderRadius = 12,
    this.onTap,
    this.width,
    this.height,
  });
}
```

**패턴**:
- `required` 파라미터는 최소화 (child만)
- 색상, 크기, 스타일은 선택 파라미터로 (기본값 제공)
- 콜백은 nullable (`VoidCallback?`)

---

### 8. Null Safety Pattern

#### 안전한 콜백 처리
```dart
// ❌ 위험: null 체크 없음
onTap: widget.onTap != null ? (_) => widget.onTap!.call() : null,

// ✅ 안전: null 체크 + 조건부 처리
onTap: widget.onTap != null ? (_) {
  setState(() => _isPressed = false);
  widget.onTap?.call();  // ← ?. 사용
} : null,

// ✅ 더 간단한 방식
onTap: widget.onTap != null ? (_) => widget.onTap!() : null,
```

---

## 📋 Wave 3 구현 체크리스트

### 새로운 위젯 만들 때
- [ ] `StatefulWidget` 상속 (상호작용 필요 시)
- [ ] `_isPressed` 상태 추가
- [ ] GestureDetector + AnimatedScale 조합
- [ ] 4px black border + hard shadow 적용
- [ ] AppColors 사용
- [ ] AppTextStyles 사용
- [ ] null-safety 확보

### 새로운 화면 만들 때
- [ ] 배경색: `AppColors.deepBlack` 또는 `AppColors.darkGray`
- [ ] 제목: `AppTextStyles.display()` 또는 `AppTextStyles.heading()`
- [ ] 본문: `AppTextStyles.body()`
- [ ] 버튼: `NeoBrutalistButton` 사용
- [ ] 카드: `NeoBrutalistCard` 사용
- [ ] 강조 텍스트: `NeonText` 사용
- [ ] 진행률: `ProgressBar` 사용

### 색상 조합 권장
```dart
// 배경 + 텍스트
AppColors.deepBlack + AppColors.pureWhite  // 기본
AppColors.darkGray + AppColors.pureWhite   // 카드

// 배경 + 강조
AppColors.deepBlack + AppColors.neonPink   // 주요
AppColors.deepBlack + AppColors.neon
