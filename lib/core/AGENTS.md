# AGENTS.md — lib/core/

Shared design system and utilities. Every screen/widget depends on this layer.

## Structure

```
core/
├── theme/
│   ├── app_colors.dart       # Color palette + glow/gradient helpers
│   ├── app_text_styles.dart   # Typography system (3 font families)
│   ├── app_shadows.dart       # Neo-Brutalist hard shadows + neon glow
│   └── app_theme.dart         # MaterialApp theme (Dialog, BottomSheet, etc.)
├── widgets/
│   ├── neo_brutalist_card.dart    # Container card with press/hover/idle-float
│   ├── neo_brutalist_button.dart  # CTA button with press animation, disabled state
│   ├── progress_bar.dart          # Game progress bar with shimmer + danger pulse
│   └── neon_text.dart             # Glowing text widget (optional animation/stroke)
└── utils/
    ├── haptic_manager.dart    # Static haptic feedback methods
    └── sound_manager.dart     # Static SFX player (preloadAll in main.dart)
```

## Theme API Reference

### AppColors (static)
```
Neon Primary:   neonPink(FF0099) neonCyan(00FFFF) acidYellow(FFEA00)
                electricBlue(2979FF) neonPurple(D500F9) acidGreen(00E676)
Supporting:     hotPink(FF1493) laserRed(FF1744) ultraViolet(651FFF) hotOrange(FF3D00)
Backgrounds:    deepBlack(050505) darkGray(121212) midnightBlue(020024) darkPurple(14002A)
Mono:           pureBlack(000000) pureWhite(FFFFFF)
Texture:        crtOverlay(0DFFFFFF) shadowBlack(80000000)

Methods:
  neonGlow(Color, {intensity=0.6}) → List<BoxShadow>  // 3-layer glow
  animatedGlow(Color, double animValue) → List<BoxShadow>
  neonGradient(Color start, Color end) → LinearGradient
  bananaGradient → const LinearGradient (acidYellow→hotOrange)
```

### AppTextStyles (static)
All methods accept optional `Color` param.

| Method | Size | Font | Default Color |
|--------|------|------|---------------|
| `display()` | 56px | Black Han Sans | white |
| `displayMedium()` | 40px | Black Han Sans | white |
| `heading()` | 28px | Jua | white |
| `headingSmall()` | 22px | Jua | white |
| `body()` | 16px | Noto Sans KR w600 | white |
| `bodySmall()` | 14px | Noto Sans KR w500 | white |
| `caption()` | 12px | Noto Sans KR w500 | white (0.8 opacity) |
| `button()` | 20px | Jua | black |
| `score()` | 64px | Black Han Sans | acidYellow |
| `tier()` | 14px | Black Han Sans | white |
| `factBomb()` | 26px | Jua | white |

### AppShadows (static)
```
hardShadow       → Offset(8,8), blur:0   // Primary Neo-Brutalist
hardShadowSmall  → Offset(6,6), blur:0
hardShadowTiny   → Offset(3,3), blur:0
layeredShadow    → Two-layer 3D effect

neonHardShadow(Color) → Offset(6,6), blur:0, colored
innerGlow(Color)       → blur:15, spread:-5  // Returns List<BoxShadow>, MUST spread (...)
```

**CRITICAL**: `innerGlow()` returns `List<BoxShadow>`. When placing inside another list:
```dart
boxShadow: [...AppShadows.innerGlow(color), ...otherShadows]  // SPREAD required
```

## Widget API Reference

### NeonText
```dart
NeonText(String text, {
  color: AppColors.neonPink,
  fontSize: 16, glowIntensity: 1.0,
  fontWeight, textAlign, maxLines, overflow, style,
  animated: false, strokeWidth: 0.0,
})
```
- Accepts `super.key` → works with `AnimatedSwitcher` via `key: ValueKey(x)`
- `animated: true` adds pulsing glow

### NeoBrutalistButton
```dart
NeoBrutalistButton({
  required onPressed,    // null = disabled state
  required label,
  icon, color: acidYellow, textColor: pureBlack,
  borderRadius: 12, padding, minWidth: 48, minHeight: 48,
  isPrimary: false, onPressDown,
})
```
- Min touch target 48×48 enforced
- Disabled: gray color, reduced shadow, no interaction

### NeoBrutalistCard
```dart
NeoBrutalistCard({
  required child,
  color: darkGray, padding, borderRadius: 12,
  onTap, width, height, glowColor,
  enableHoverEffect: false,
})
```
- Idle float animation (subtle scale pulse)
- Press: `AnimatedScale 0.92` for 100ms

### ProgressBar
```dart
ProgressBar({
  required value,        // 0.0–1.0
  color: neonCyan, backgroundColor: darkGray,
  height: 24, borderRadius: 8,
  showShimmer: false, label,
})
```

## Utils

### HapticManager (static)
- `light()`, `medium()`, `heavy()`, `selection()`, `success()`, `error()`

### SoundManager (static)
- `preloadAll()` — called once in main.dart
- `play(SoundType)` — enum: correct, wrong, snap, gameOver, timerTick, timerWarning, heartbeat, chipStack, slotMachine, levelUp
- Sound files: `assets/sounds/*.wav`

## Anti-Patterns

- **NEVER** use `Color(0x...)` directly → use `AppColors.*`
- **NEVER** use inline `TextStyle` → use `AppTextStyles.*`
- **NEVER** use `BoxShadow(blurRadius: X)` where X>0 for structural shadows → Neo-Brutalism = zero blur
- **NEVER** nest `List<BoxShadow>` without spread → `innerGlow()` returns a List
- **flutter_animate**: `shake()` does NOT have `amount` param → use `rotation: 0.05` or `offset: Offset(5,0)`
