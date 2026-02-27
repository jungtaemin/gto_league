import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Models
import '../../data/models/card_question.dart';
import '../../data/models/swipe_result.dart';

// Engine & Data
import '../../data/services/deep_run_engine.dart';
import '../../data/services/deep_run_question_generator.dart';
import '../../data/providers/gto_data_provider.dart';
import '../../data/services/timer_service.dart';

// Utils
import '../../core/utils/haptic_manager.dart';
import '../../core/utils/sound_manager.dart';
import '../../core/utils/music_manager.dart';
import '../../core/utils/responsive.dart';
import '../../core/theme/app_colors.dart';

// Deep Run Widgets
import 'widgets/deep_run_background.dart';
import 'widgets/deep_run_hud.dart';
import 'widgets/level_up_cutscene.dart';
import 'widgets/ev_diff_overlay.dart';
import 'widgets/active_bb_chip.dart';

// Shared Widgets
import 'widgets/poker_card_widget.dart';
import 'widgets/swipe_feedback_overlay.dart';
import 'widgets/answer_result_overlay.dart';
import 'widgets/defense_alert_banner.dart';
import 'widgets/fact_bomb_bottom_sheet.dart';
import 'widgets/table_position_view.dart';
import 'widgets/combo_strike_overlay.dart';

/// 50-Hand Deep Run Survival mode screen.
///
/// Uses [DeepRunEngine] for game state management and
/// [GtoDataProvider] + [DeepRunQuestionGenerator] for question generation.
///
/// Flow:
/// 1. Start game → load deck for level 1
/// 2. Swipe cards → engine processes answers
/// 3. Level up → cutscene → load next deck
/// 4. Game over / Victory → navigate to results
class DeepRunScreen extends ConsumerStatefulWidget {
  const DeepRunScreen({super.key});

  @override
  ConsumerState<DeepRunScreen> createState() => _DeepRunScreenState();
}

class _DeepRunScreenState extends ConsumerState<DeepRunScreen> {
  late CardSwiperController _swiperController;
  final DeepRunQuestionGenerator _questionGenerator =
      DeepRunQuestionGenerator();

  List<CardQuestion> _currentDeck = [];
  int _currentCardIndex = 0;
  bool _isDisabled = false;
  bool _showAnswerResult = false;
  bool _showFloatingScore = false;
  bool _lastAnswerCorrect = true;
  bool _lastWasFold = false;
  bool _showEvDiff = false;
  double _lastEvDiff = 0.0;
  double _dragProgress = 0.0;
  bool _showStartCutscene = true;
  bool _showHardModeCutscene = false;
  DateTime? _cardShownTime;
  SwipeResult? _lastResult;
  CardQuestion? _lastQuestion;

  @override
  void initState() {
    super.initState();
    _swiperController = CardSwiperController();
    MusicManager.play(MusicType.game);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _startGame();
    });
  }

  @override
  void dispose() {
    ref.read(timerProvider.notifier).stop();
    _swiperController.dispose();
    super.dispose();
  }

  // ── Initialization ────────────────────────────────────────────

  void _startGame() {
    ref.read(deepRunEngineProvider.notifier).startGame();
    _loadDeckForCurrentLevel();
  }

  Future<void> _loadDeckForCurrentLevel() async {
    try {
      final engine = ref.read(deepRunEngineProvider);
      final bbLevel = engine.currentBbLevel;
      final cache = await ref.read(gtoBbLevelProvider(bbLevel).future);
      final isHardMode = engine.isHardMode;
      final deck = _questionGenerator.generateDeck(
        bbLevel: bbLevel,
        scenarios: cache.scenarios,
        evDiffBbThreshold: isHardMode ? 0.7 : null,
        overridePushCount: isHardMode ? 7 : null,
        overrideDefenseCount: isHardMode ? 3 : null,
      );

      if (!mounted) return;

      setState(() {
        _currentDeck = deck;
        _currentCardIndex = 0;
        _cardShownTime = DateTime.now();
      });

      // Re-create swiper controller for the new deck.
      _swiperController.dispose();
      _swiperController = CardSwiperController();

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _currentDeck.isNotEmpty && !_showStartCutscene) {
          ref.read(timerProvider.notifier).start();
        }
      });
    } catch (e) {
      debugPrint('[DeepRunScreen] Failed to load deck: $e');
    }
  }

  // ── Swipe Handling ────────────────────────────────────────────

  bool _onSwipe(
    int previousIndex,
    int? currentIndex,
    CardSwiperDirection direction,
  ) {
    final question = _currentDeck[previousIndex];
    final userAction =
        direction == CardSwiperDirection.right ? 'PUSH' : 'FOLD';

    final isCorrect = userAction == question.correctAction ||
        (userAction == 'PUSH' && question.correctAction == 'CALL');

    final isSnap = _cardShownTime != null &&
        DateTime.now().difference(_cardShownTime!).inMilliseconds < 2000;

    final result = SwipeResult(
      isCorrect: isCorrect,
      isSnap: isSnap && isCorrect,
      pointsEarned: 0,
      evDiff: question.evBb,
      factBombMessage: isCorrect ? null : _generateFactBomb(question),
    );

    // Feed answer to Deep Run Engine.
    ref.read(deepRunEngineProvider.notifier).answerQuestion(
          isCorrect: isCorrect,
          isMixed: question.isMixed,
          question: question,
        );

    setState(() {
      _showAnswerResult = true;
      _lastAnswerCorrect = isCorrect;
      _lastWasFold = (direction == CardSwiperDirection.left);
      _lastResult = result;
      _lastQuestion = question;
      _showFloatingScore = isCorrect;
    });

    if (isSnap && isCorrect) {
      SoundManager.play(SoundType.snap);
    }

    if (isCorrect) {
      HapticManager.correct();
      SoundManager.play(SoundType.correct);
    } else {
      HapticManager.wrong();
      SoundManager.play(SoundType.wrong);
      ref.read(timerProvider.notifier).pause();

      // Show EV loss stamp.
      if (question.evDiffBb < 0) {
        setState(() {
          _showEvDiff = true;
          _lastEvDiff = question.evDiffBb;
        });
      }
    }

    if (_isDisabled) {
      setState(() => _isDisabled = false);
    }

    if (currentIndex != null) {
      setState(() => _currentCardIndex = currentIndex);
    }

    // Check if deck is exhausted (but engine handles level-up logic).
    if (currentIndex == null || currentIndex >= _currentDeck.length - 1) {
      // Engine will transition state; we handle in the ref.listen callback.
    }

    return true;
  }

  void _handleTimerExpired() {
    if (_isDisabled) return;
    setState(() => _isDisabled = true);
    HapticManager.wrong();
    SoundManager.play(SoundType.timerWarning);
    Future.delayed(const Duration(milliseconds: 50), () {
      if (mounted) {
        _swiperController.swipe(CardSwiperDirection.left);
      }
    });
  }

  void _onSwipeDirectionChange(
    CardSwiperDirection horizontalDirection,
    CardSwiperDirection verticalDirection,
  ) {
    setState(() {
      if (horizontalDirection == CardSwiperDirection.left) {
        _dragProgress = -0.8;
      } else if (horizontalDirection == CardSwiperDirection.right) {
        _dragProgress = 0.8;
      } else {
        _dragProgress = 0.0;
      }
    });
  }

  // ── Answer Result Flow ────────────────────────────────────────

  void _onAnswerResultComplete() {
    setState(() {
      _showAnswerResult = false;
      _showFloatingScore = false;
    });

    final result = _lastResult;
    final question = _lastQuestion;

    if (result != null &&
        !result.isCorrect &&
        result.factBombMessage != null &&
        question != null) {
      if (!mounted) return;
      showFactBombModal(
        context,
        factBombMessage: result.factBombMessage!,
        position: question.position,
        hand: question.hand,
        evBb: question.evBb,
        evDiffBb: question.evDiffBb,
        onDismiss: _onFactBombDismissed,
      );
    } else {
      _advanceAfterAnswer();
    }
  }

  void _onFactBombDismissed() {
    _advanceAfterAnswer();
  }

  void _advanceAfterAnswer() {
    final engineState = ref.read(deepRunEngineProvider);

    if (engineState.phase == DeepRunPhase.gameOver ||
        engineState.phase == DeepRunPhase.victory) {
      _navigateToGameOver();
      return;
    }

    if (engineState.phase == DeepRunPhase.levelUp) {
      // Cutscene will render via build(); no action needed here.
      ref.read(timerProvider.notifier).stop();
      return;
    }

    if (engineState.phase == DeepRunPhase.hardModeTransition) {
      ref.read(timerProvider.notifier).stop();
      setState(() => _showHardModeCutscene = true);
      return;
    }

    // Normal progression — restart timer for next card.
    _restartTimerForNextCard();
  }

  void _onLevelUpComplete() {
    ref.read(deepRunEngineProvider.notifier).completeLevelUp();
    _loadDeckForCurrentLevel();
  }

  void _onHardModeCutsceneComplete() {
    setState(() => _showHardModeCutscene = false);
    ref.read(deepRunEngineProvider.notifier).startHardMode();
    ref.read(timerProvider.notifier).setBaseDuration(12.0);
    _loadDeckForCurrentLevel();
  }

  void _navigateToGameOver() {
    ref.read(timerProvider.notifier).stop();
    SoundManager.play(SoundType.gameOver);
    HapticManager.gameOver();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/game-over');
      }
    });
  }

  void _restartTimerForNextCard() {
    _cardShownTime = DateTime.now();
    final engineState = ref.read(deepRunEngineProvider);
    ref.read(timerProvider.notifier).startWithCombo(engineState.combo);
  }

  void _onEvDiffComplete() {
    setState(() => _showEvDiff = false);
  }

  // ── Helpers ───────────────────────────────────────────────────

  int _bbLevelForLevel(int level) {
    switch (level) {
      case 1:
        return 15;
      case 2:
        return 12;
      case 3:
        return 10;
      case 4:
        return 7;
      case 5:
        return 5;
      default:
        return 15;
    }
  }

  String _generateFactBomb(CardQuestion question) {
    if (question.correctAction == 'PUSH' ||
        question.correctAction == 'CALL') {
      return '🐔 쫄보 마인드 검거! ${question.position}에서 ${question.hand}를 '
          '버린다고요? ${question.evBb.abs().toStringAsFixed(1)} BB 수익을 '
          '허공에 버리셨습니다!';
    } else {
      return '🚨 펍저씨 마인드 검거! ${question.position}에서 ${question.hand} '
          '올인은 ${question.evBb.abs().toStringAsFixed(1)} BB의 확정 손실입니다!';
    }
  }

  // ── Build ─────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final engineState = ref.watch(deepRunEngineProvider);
    final timerState = ref.watch(timerProvider);
    final asyncCache = ref.watch(gtoBbLevelProvider(engineState.currentBbLevel));

    // Timer expiry listener.
    ref.listen(timerProvider, (previous, next) {
      if (next.phase == TimerPhase.expired &&
          previous?.phase != TimerPhase.expired) {
        _handleTimerExpired();
      }
    });

    // Loading state — waiting for GTO data.
    if (asyncCache.isLoading || _currentDeck.isEmpty) {
      return Scaffold(
        body: Stack(
          children: [
            DeepRunBackground(currentLevel: engineState.currentLevel, isHardMode: engineState.isHardMode),
            const Center(child: CircularProgressIndicator()),
          ],
        ),
      );
    }

    // Error state.
    if (asyncCache.hasError) {
      return Scaffold(
        body: Center(
          child: Text('데이터 로드 실패: ${asyncCache.error}'),
        ),
      );
    }

    final cardIdx = _currentCardIndex.clamp(0, _currentDeck.length - 1);
    final currentQ = _currentDeck[cardIdx];
    final maxDuration = ref.read(timerProvider.notifier).currentDuration;
    final timerProgress =
        (timerState.seconds / maxDuration).clamp(0.0, 1.0);
    final isDefense =
        currentQ.chartType == 'call' || currentQ.chartType == 'CALL';

    return Scaffold(
      body: Stack(
        children: [
          // 0. Dynamic Background
          DeepRunBackground(currentLevel: engineState.currentLevel, isHardMode: engineState.isHardMode),

          SafeArea(
            child: Column(
              children: [
                // 1. Deep Run HUD (Hearts + Progress + Status)
                DeepRunHud(
                  strikesRemaining: engineState.strikesRemaining,
                  score: engineState.score,
                  combo: engineState.combo,
                  currentLevel: engineState.currentLevel,
                  bbLevel: engineState.currentBbLevel,
                  isHardMode: engineState.isHardMode,
                ),

                // 2. Timer Bar
                _buildTimerBar(context, timerProgress, timerState.seconds),

                // 3. Defense Alert
                if (isDefense)
                  DefenseAlertBanner(
                    opponentPosition: currentQ.opponentPosition ?? 'UTG',
                    actionHistory: currentQ.actionHistory,
                  ),

                SizedBox(height: context.h(4)),

                // 4. Table Position
                TablePositionView(
                  heroPosition: currentQ.position,
                  opponentPosition: currentQ.opponentPosition,
                  isDefenseMode: isDefense,
                  actionHistory: currentQ.actionHistory,
                ),

                // 5. Card Swiper + Overlays
                Expanded(
                  child: Stack(
                    children: [
                      // Active BB Chip (in the background, aligned bottom)
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: EdgeInsets.only(bottom: context.h(24)),
                          child: ActiveBbChip(
                            bbLevel: engineState.currentBbLevel,
                            theme: AppColors.getLevelTheme(engineState.currentLevel),
                          ),
                        ),
                      ),

                      CardSwiper(
                        controller: _swiperController,
                        cardsCount: _currentDeck.length,
                        numberOfCardsDisplayed: 1,
                        onSwipe: _onSwipe,
                        onSwipeDirectionChange: _onSwipeDirectionChange,
                        isDisabled: _isDisabled ||
                            engineState.phase != DeepRunPhase.playing ||
                            _showStartCutscene,
                        allowedSwipeDirection:
                            const AllowedSwipeDirection.symmetric(
                          horizontal: true,
                        ),
                        padding: EdgeInsets.zero,
                        cardBuilder: (context, index,
                            horizontalOffsetPercentage,
                            verticalOffsetPercentage) {
                          return PokerCardWidget(
                            question: _currentDeck[index],
                          );
                        },
                      ),

                      SwipeFeedbackOverlay(dragProgress: _dragProgress),

                      AnswerResultOverlay(
                        isCorrect: _lastAnswerCorrect,
                        isVisible: _showAnswerResult,
                        wasFold: _lastWasFold,
                        onComplete: _onAnswerResultComplete,
                      ),

                      EvDiffOverlay(
                        evDiffBb: _lastEvDiff,
                        isVisible: _showEvDiff,
                        onComplete: _onEvDiffComplete,
                      ),

                      // K-Casual Exploding Combo Overlay
                      if (_showFloatingScore)
                        ComboStrikeOverlay(
                          isVisible: _showFloatingScore,
                          combo: engineState.combo,
                          earnedPoints: 0,
                          isFever: false,
                          isSnap: false,
                        ),
                    ],
                  ),
                ),

                // 6. Footer
                SizedBox(height: context.h(4)),
                _buildBottomBar(context, isDefense),
                SizedBox(height: context.h(8)),
              ],
            ),
          ),

          // 7. Level-Up Cutscene Overlay
          if (_showStartCutscene)
            LevelUpCutscene(
              newLevel: 1,
              newBbLevel: 15,
              isGameStart: true,
              onComplete: () {
                if (mounted) {
                  setState(() => _showStartCutscene = false);
                  ref.read(timerProvider.notifier).start();
                }
              },
            )
          else if (engineState.phase == DeepRunPhase.levelUp)
            LevelUpCutscene(
              newLevel: engineState.currentLevel + 1,
              newBbLevel: _bbLevelForLevel(engineState.currentLevel + 1),
              onComplete: _onLevelUpComplete,
            )
          else if (_showHardModeCutscene)
            LevelUpCutscene(
              newLevel: 1,
              newBbLevel: 15,
              isHardModeEntry: true,
              onComplete: _onHardModeCutsceneComplete,
            ),
        ],
      ),
    );
  }

  // ── Sub-widgets ───────────────────────────────────────────────

  Widget _buildTimerBar(
    BuildContext context,
    double progress,
    double secondsLeft,
  ) {
    final barColor = progress > 0.5
        ? const Color(0xFF22D3EE)
        : progress > 0.25
            ? const Color(0xFFFBBF24)
            : const Color(0xFFEF4444);

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: context.w(16),
        vertical: context.h(4),
      ),
      child: Container(
        height: context.h(6),
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(context.r(3)),
        ),
        child: FractionallySizedBox(
          alignment: Alignment.centerLeft,
          widthFactor: progress.clamp(0.0, 1.0),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: barColor,
              boxShadow: [
                BoxShadow(
                  color: barColor.withOpacity(0.5),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, bool isDefense) {
    final rightLabel = isDefense ? '콜' : '올인';
    final rightColor =
        isDefense ? const Color(0xFF3B82F6) : const Color(0xFF22C55E);
    final rightIcon = isDefense ? '✓' : '→';

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.w(24)),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Fold
              Row(
                children: [
                  Container(
                    width: context.w(48),
                    height: context.w(48),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFEF4444).withOpacity(0.15),
                      border: Border.all(
                        color: const Color(0xFFEF4444).withOpacity(0.3),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '✕',
                        style: TextStyle(
                          color: const Color(0xFFEF4444),
                          fontSize: context.sp(20),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: context.w(10)),
                  Text(
                    '폴드',
                    style: TextStyle(
                      color: const Color(0xFFEF4444),
                      fontSize: context.sp(18),
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),

              // All-in / Call
              Row(
                children: [
                  Text(
                    rightLabel,
                    style: TextStyle(
                      color: rightColor,
                      fontSize: context.sp(18),
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(width: context.w(10)),
                  Container(
                    width: context.w(48),
                    height: context.w(48),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: rightColor.withOpacity(0.15),
                      border: Border.all(color: rightColor.withOpacity(0.3)),
                    ),
                    child: Center(
                      child: Text(
                        rightIcon,
                        style: TextStyle(
                          color: rightColor,
                          fontSize: context.sp(20),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: context.h(8)),
          Text(
            isDefense ? '← 폴드 | 콜 →' : '← 스와이프하여 결정하세요 →',
            style: TextStyle(
              color: Colors.white24,
              fontSize: context.sp(11),
            ),
          ),
        ],
      ),
    );
  }
}
