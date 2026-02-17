# AGENTS.md — holdem_allin_fold (Root)

## What This Is

Flutter mobile game: "15BB 시드권 사냥꾼" — Tinder-style Push/Fold poker trainer.
Swipe RIGHT = PUSH (All-In), LEFT = FOLD. GTO Nash Equilibrium correctness.
Neo-Brutalism + Neon aesthetic ("Nano Banana" design language).
Korean holdem pub audience. MZ Gen-Z visual style.

## Architecture

Hybrid feature-based + layer-based. 42 dart files. No barrel files.

```
lib/
├── main.dart              # Entry: bindings, MobileAds, SoundManager.preloadAll
├── app.dart               # MaterialApp, 7 named routes, AppTheme
├── core/                  # Shared design system + utilities
│   ├── theme/             # AppColors, AppTextStyles, AppShadows, AppTheme
│   ├── widgets/           # NeoBrutalistCard/Button, ProgressBar, NeonText
│   └── utils/             # HapticManager, SoundManager
├── data/                  # Data layer
│   ├── models/            # 7 data classes (GameState, CardQuestion, PokerHand, etc.)
│   ├── services/          # Business logic (Timer, Deck, Ad, Ranking, Database)
│   └── repositories/      # GtoRepository (GTO data access — EXISTS but UNUSED by game)
├── features/              # Screen modules (1 screen per dir)
│   ├── game/              # Main game loop + 7 widget files in widgets/
│   ├── game_over/         # GameOverScreen (ad refill, score submit)
│   ├── home/              # HomeScreen (main menu)
│   ├── ranking/           # RankingScreen (ghost league table)
│   ├── splash/            # SplashScreen (first-launch → onboarding detection)
│   ├── onboarding/        # OnboardingScreen (3-step tutorial PageView)
│   ├── privacy/           # PrivacyScreen (Korean privacy policy)
│   └── settings/          # EMPTY — placeholder
└── providers/             # Riverpod state management
    ├── game_state_notifier.dart   # @Riverpod(keepAlive: true) — scoring, hearts, fever
    ├── game_state_notifier.g.dart # Generated
    └── game_providers.dart        # adServiceProvider, rankingServiceProvider
```

## Routes

| Route | Screen | Notes |
|-------|--------|-------|
| `/` | SplashScreen | First-launch check → `/onboarding` or `/home` |
| `/onboarding` | OnboardingScreen | 3-step tutorial, shown once |
| `/home` | HomeScreen | Main menu |
| `/game` | GameScreen | Core gameplay loop |
| `/ranking` | RankingScreen | Ghost league standings |
| `/game-over` | GameOverScreen | Score display, ad refill, ranking submit |
| `/privacy` | PrivacyScreen | Korean privacy policy |

## State Management

- **Riverpod** with code generation (`riverpod_annotation`)
- `gameStateNotifierProvider` — `@Riverpod(keepAlive: true)`: scoring, hearts, combo, fever, tier
- `timerProvider` — `StateNotifierProvider<TimerNotifier, double>`: countdown clock
- `adServiceProvider` — `Provider<AdService>`: rewarded ad lifecycle
- `rankingServiceProvider` — `Provider<RankingService>`: ghost ranking + Supabase scaffold

## Tech Stack

| Dep | Purpose |
|-----|---------|
| flutter_riverpod 2.6.1 | State management |
| riverpod_annotation | Code generation for providers |
| flutter_card_swiper 7.2.0 | Tinder-style card swipe |
| flutter_animate 4.5.0 | Declarative animations |
| google_fonts 6.2.1 | Black Han Sans, Jua, Noto Sans KR |
| sqflite 2.4.1 | Local SQLite for GTO data |
| supabase_flutter 2.8.0 | Backend (scaffold only, $0 server) |
| google_mobile_ads 5.3.0 | AdMob rewarded ads |
| audioplayers 6.1.0 | Sound effects |
| shared_preferences 2.3.4 | First-launch flag |

## Conventions

### MUST follow:
- **AppColors only** — NO hardcoded `Color(0x...)` anywhere
- **AppTextStyles only** — NO inline `TextStyle(fontSize: ...)` 
- **Neo-Brutalism**: 4px black border + hard shadow (zero blur) on all major elements
- **File naming**: snake_case (`game_screen.dart`, `timer_service.dart`)
- **Class naming**: PascalCase. Screens=`{Feature}Screen`, Services=`{Domain}Service`, Notifiers=`{Domain}Notifier`
- **Imports**: Semantic grouping (Flutter SDK → packages → local), no barrel files
- **Null safety**: Always `?.` operator, never force-unwrap
- **`debugPrint()`** — NEVER `print()`
- **`super.key`** in constructors — NEVER `Key? key` parameter

### MUST NOT:
- `as any`, `@ts-ignore` equivalents (no `dynamic` types)
- Empty catch blocks
- Hardcoded colors or text styles
- Blurred shadows (blur must be 0 for Neo-Brutalism, except glow effects)
- `print()` statements
- Modify `*.g.dart` generated files

### Animation Durations:
- Press feedback: 100ms
- Hover/transition: 200ms
- Entrance: 400ms
- Idle pulse: 1500ms
- Danger pulse: 300ms (repeat)

### Widget Patterns:
- Interactive widgets: `_isPressed` bool + `GestureDetector` + `AnimatedScale(scale: _isPressed ? 0.92 : 1.0)`
- Riverpod screens: `ConsumerStatefulWidget` (need lifecycle) or `ConsumerWidget` (stateless)
- Entrance animations: `.animate().fadeIn(400.ms).slideY(begin: 0.05, 400.ms)`

## Critical Gaps (Pre-Launch)

1. **Game uses DeckGenerator (mock), NOT GtoRepository (real SQLite)** — must wire before launch
2. **AndroidManifest.xml missing AdMob App ID meta-data** — will crash at runtime
3. **No JDK installed** — APK build blocked (code is clean, `flutter analyze` passes)
4. **Supabase not connected** — ranking_service has TODO comments for real integration

## Build & Verify

```bash
# Analyze (MUST pass with 0 issues before any PR/merge)
flutter analyze lib/

# Run code generation (after modifying @riverpod annotated files)
dart run build_runner build --delete-conflicting-outputs

# Tests
flutter test
```

## Design Persona

"20대 여자인 초고수 모바일게임 디자이너" — MZ Gen-Z aesthetic.
Nano Banana style: bright neon, playful, retro-futuristic, dynamic animations.
All UI work MUST follow this persona's design sensibility.
