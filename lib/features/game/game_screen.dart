import 'dart:math' show min;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Models
import '../../data/models/card_question.dart';
import '../../data/models/swipe_result.dart';
import '../../data/models/game_state.dart';

// Services
import '../../data/services/timer_service.dart';

// Repositories
import '../../data/repositories/gto_repository.dart';

// Providers
import '../../providers/game_state_notifier.dart';
import '../../providers/game_providers.dart';

// Utils
import '../../core/utils/haptic_manager.dart';
import '../../core/utils/sound_manager.dart';

// Theme
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/widgets/neon_text.dart';
// Widgets
import 'widgets/poker_card_widget.dart';
import 'widgets/action_clock_widget.dart';
import 'widgets/snap_bonus_widget.dart';
import 'widgets/combo_counter_widget.dart';
import 'widgets/swipe_feedback_overlay.dart';
import 'widgets/answer_result_overlay.dart';
import 'widgets/fact_bomb_bottom_sheet.dart';

class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  late CardSwiperController _swiperController;
  List<CardQuestion> _deck = [];
  bool _isDisabled = false;
  bool _showSnapBonus = false;
  bool _showAnswerResult = false;
  bool _lastAnswerCorrect = true;
  SwipeResult? _lastResult;
  CardQuestion? _lastQuestion;
  DateTime? _cardShownTime;
  double _dragProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _swiperController = CardSwiperController();
    _initGame();
  }

  @override
  void dispose() {
    ref.read(timerProvider.notifier).stop();
    _swiperController.dispose();
    super.dispose();
  }

  Future<void> _initGame() async {
    final repo = GtoRepository();
    final deck = await repo.getDeckForSession(50);
    if (!mounted) return;
    setState(() {
      _deck = deck;
      _cardShownTime = DateTime.now();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) ref.read(timerProvider.notifier).start();
    });
  }

  void _handleTimerExpired() {
    if (_isDisabled) return;
    
    setState(() => _isDisabled = true);
    HapticManager.wrong();
    SoundManager.play(SoundType.timerWarning);
    
    // Auto-fold after delay
    Future.delayed(const Duration(milliseconds: 50), () {
      if (mounted) {
        _swiperController.swipe(CardSwiperDirection.left);
      }
    });
  }

  bool _onSwipe(
    int previousIndex,
    int? currentIndex,
    CardSwiperDirection direction,
  ) {
    final question = _deck[previousIndex];
    final userAction = direction == CardSwiperDirection.right ? 'PUSH' : 'FOLD';
    
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
    
    ref.read(gameStateNotifierProvider.notifier).processAnswer(result);
    
    // Show answer result overlay
    setState(() {
      _showAnswerResult = true;
      _lastAnswerCorrect = isCorrect;
      _lastResult = result;
      _lastQuestion = question;
    });
    
    if (isSnap && isCorrect) {
      setState(() => _showSnapBonus = true);
      SoundManager.play(SoundType.snap);
    }
    
    if (isCorrect) {
      HapticManager.correct();
      SoundManager.play(SoundType.correct);
    } else {
      HapticManager.wrong();
      SoundManager.play(SoundType.wrong);
      // Pause timer — will resume after fact bomb modal dismissed
      ref.read(timerProvider.notifier).pause();
    }
    
    if (_isDisabled) {
      setState(() => _isDisabled = false);
    }
    
    // T24: Update defense mode for the NEXT card
    if (currentIndex != null && currentIndex < _deck.length) {
      final nextQuestion = _deck[currentIndex];
      ref.read(gameStateNotifierProvider.notifier)
          .setDefenseMode(nextQuestion.chartType == 'CALL');
    }

    // Deck exhaustion: if no more cards, end game
    if (currentIndex == null || currentIndex >= _deck.length - 1) {
      Future.delayed(const Duration(milliseconds: 1200), () {
        if (mounted) _navigateToGameOver();
      });
    }
    
    return true;
  }

  /// Called when answer result overlay animation completes.
  void _onAnswerResultComplete() {
    setState(() => _showAnswerResult = false);
    
    final result = _lastResult;
    final question = _lastQuestion;
    
    // If incorrect and has fact bomb → show modal
    if (result != null && !result.isCorrect && result.factBombMessage != null && question != null) {
      if (!mounted) return;
      showFactBombModal(
        context,
        factBombMessage: result.factBombMessage!,
        position: question.position,
        hand: question.hand,
        evBb: question.evBb,
        onDismiss: _onFactBombDismissed,
      );
    } else {
      // Correct answer or no fact bomb → restart timer normally
      _restartTimerForNextCard();
    }
  }

  /// Called when fact bomb modal is dismissed.
  void _onFactBombDismissed() {
    _restartTimerForNextCard();
    
    // Check game over after fact bomb is dismissed
    if (ref.read(gameStateNotifierProvider).hearts <= 0) {
      _navigateToGameOver();
    }
  }

  /// Submit score and navigate to game over screen.
  void _navigateToGameOver() {
    final score = ref.read(gameStateNotifierProvider).score;
    ref.read(rankingServiceProvider).submitScore(score);
    ref.read(timerProvider.notifier).stop();
    SoundManager.play(SoundType.gameOver);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/game-over');
      }
    });
  }

  /// Restart timer for the next card (resume after pause or fresh start).
  void _restartTimerForNextCard() {
    _cardShownTime = DateTime.now();
    final combo = ref.read(gameStateNotifierProvider).combo;
    ref.read(timerProvider.notifier).startWithCombo(combo);
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

  String _generateFactBomb(CardQuestion question) {
    if (question.correctAction == 'PUSH' || question.correctAction == 'CALL') {
      return '🐔 쫄보 마인드 검거! ${question.position}에서 ${question.hand}를 버린다고요? ${question.evBb.abs().toStringAsFixed(1)} BB 수익을 허공에 버리셨습니다!';
    } else {
      return '🚨 펍저씨 마인드 검거! ${question.position}에서 ${question.hand} 올인은 ${question.evBb.abs().toStringAsFixed(1)} BB의 확정 손실입니다!';
    }
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameStateNotifierProvider);
    final timerState = ref.watch(timerProvider);

    ref.listen(timerProvider, (previous, next) {
      if (next.phase == TimerPhase.expired && previous?.phase != TimerPhase.expired) {
        _handleTimerExpired();
      }
    });

    if (_deck.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.deepBlack,
        body: Center(
          child: const NeonText(
            'LOADING...',
            color: AppColors.neonCyan,
            fontSize: 24,
            animated: true,
          ).animate(onPlay: (c) => c.repeat(reverse: true))
              .fadeIn(duration: 400.ms)
              .scale(begin: const Offset(0.95, 0.95), end: const Offset(1.0, 1.0), duration: 1500.ms),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.deepBlack,
      body: SafeArea(
        child: Column(
          children: [
            ActionClockWidget(
              seconds: timerState.seconds,
              phase: timerState.phase,
              maxDuration: ref.read(timerProvider.notifier).currentDuration,
            ),
            const SizedBox(height: 8),
            
            _buildStatusBar(gameState),
            const SizedBox(height: 8),
            
            Expanded(
              child: Stack(
                children: [
                  CardSwiper(
                    controller: _swiperController,
                    cardsCount: _deck.length,
                    numberOfCardsDisplayed: min(3, _deck.length),
                    onSwipe: _onSwipe,
                    onSwipeDirectionChange: _onSwipeDirectionChange,
                    isDisabled: _isDisabled,
                    allowedSwipeDirection: const AllowedSwipeDirection.symmetric(horizontal: true),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    cardBuilder: (context, index, horizontalOffsetPercentage, verticalOffsetPercentage) {
                      return PokerCardWidget(question: _deck[index]);
                    },
                  ),
                  
                  SwipeFeedbackOverlay(dragProgress: _dragProgress),
                  
                  AnswerResultOverlay(
                    isCorrect: _lastAnswerCorrect,
                    isVisible: _showAnswerResult,
                    onComplete: _onAnswerResultComplete,
                  ),
                  
                  if (_showSnapBonus)
                    SnapBonusWidget(
                      isVisible: _showSnapBonus,
                      onComplete: () => setState(() => _showSnapBonus = false),
                    ),
                ],
              ),
            ),
            
            _buildBottomBar(gameState),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBar(GameState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: List.generate(5, (index) {
              final isActive = index < state.hearts;
              return Padding(
                padding: const EdgeInsets.only(right: 4.0),
                child: Container(
                  decoration: BoxDecoration(
                    boxShadow: isActive
                        ? AppColors.neonGlow(AppColors.neonPink, intensity: 0.3)
                        : [],
                  ),
                  child: Icon(
                    isActive ? Icons.favorite : Icons.favorite_border,
                    color: isActive ? AppColors.neonPink : AppColors.darkGray,
                    size: 24,
                  ),
                ).animate(target: isActive ? 0 : 1).shake(duration: 300.ms),
              );
            }),
          ),
          
          Row(
            children: [
              ComboCounterWidget(
                combo: state.combo,
                isFeverMode: state.isFeverMode,
              ),
              const SizedBox(width: 16),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) => 
                  ScaleTransition(scale: animation, child: child),
                child: NeonText(
                  '${state.score}',
                  key: ValueKey(state.score),
                  color: AppColors.acidYellow,
                  fontSize: 28,
                  glowIntensity: 0.8,
                  strokeWidth: 1.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(GameState state) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                const NeonText('← FOLD', color: AppColors.laserRed, fontSize: 12, glowIntensity: 0.3),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Text('|', style: AppTextStyles.caption(color: AppColors.darkGray)),
                ),
                const NeonText('ALL-IN →', color: AppColors.acidGreen, fontSize: 12, glowIntensity: 0.3),
              ],
            ),
          ),
          
          GestureDetector(
            onTap: state.timeBankCount > 0 
              ? () {
                  final success = ref.read(gameStateNotifierProvider.notifier).useTimeBank();
                  if (success) {
                    ref.read(timerProvider.notifier).addTime(30);
                    HapticManager.swipe();
                  }
                }
              : null,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: state.timeBankCount > 0 ? AppColors.darkGray : AppColors.pureBlack,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: state.timeBankCount > 0 ? AppColors.acidYellow : AppColors.darkGray,
                  width: 2,
                ),
                boxShadow: state.timeBankCount > 0 
                  ? [...AppShadows.neonHardShadow(AppColors.acidYellow), ...AppColors.neonGlow(AppColors.acidYellow, intensity: 0.3)]
                  : [],
              ),
              child: Row(
                children: [
                  const Text('🪙', style: TextStyle(fontSize: 18)),
                  const SizedBox(width: 6),
                  NeonText(
                    '×${state.timeBankCount}',
                    color: state.timeBankCount > 0 ? AppColors.acidYellow : AppColors.darkGray,
                    fontSize: 16,
                    glowIntensity: state.timeBankCount > 0 ? 0.8 : 0.0,
                  ),
                ],
              ),
            ),
          ).animate(
            target: state.timeBankCount > 0 ? 1 : 0,
          ).scale(begin: const Offset(0.95, 0.95), end: const Offset(1.0, 1.0)),
        ],
      ),
    );
  }
}
