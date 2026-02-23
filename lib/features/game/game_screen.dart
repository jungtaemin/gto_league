import 'widgets/defense_alert_banner.dart';
import 'package:flutter/material.dart';
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
import '../../providers/user_stats_provider.dart';

// Utils
import '../../core/utils/haptic_manager.dart';
import '../../core/utils/sound_manager.dart';
import '../../core/utils/music_manager.dart';
import '../../core/utils/responsive.dart'; // Import Responsive

// Widgets
import 'widgets/poker_card_widget.dart';
import 'widgets/swipe_feedback_overlay.dart';
import 'widgets/answer_result_overlay.dart';
import 'widgets/fact_bomb_bottom_sheet.dart';
import 'widgets/table_position_view.dart';

// Stitch Battle UI
import '../home/widgets/gto/gto_battle_background.dart';
import '../home/widgets/gto/gto_battle_header.dart';
import '../home/widgets/gto/gto_battle_timer_bar.dart';

class GameScreen extends ConsumerStatefulWidget {
  final bool isLeague;
  const GameScreen({super.key, this.isLeague = false});

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
  bool _lastWasFold = false;
  SwipeResult? _lastResult;
  CardQuestion? _lastQuestion;
  DateTime? _cardShownTime;
  double _dragProgress = 0.0;
  int _currentCardIndex = 0;

  // ─── Stitch Colors ──────────────────────────────
  static const _accentPurple = Color(0xFF7C3AED);
  static const _accentCyan = Color(0xFF22D3EE);
  static const _accentGold = Color(0xFFFBBF24);
  static const _accentRed = Color(0xFFEF4444);
  static const _accentGreen = Color(0xFF22C55E);

  @override
  void initState() {
    super.initState();
    _swiperController = CardSwiperController();
    MusicManager.play(MusicType.game);
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
      if (mounted) {
        ref.read(timerProvider.notifier).start();
        ref.read(gameStateProvider.notifier).setLeagueMode(widget.isLeague);
        // League mode: 1 life (instant death)
        if (widget.isLeague) {
          ref.read(gameStateProvider.notifier).setHearts(1);
        }
        // Set defense mode for first card
        if (deck.isNotEmpty) {
          ref.read(gameStateProvider.notifier)
              .setDefenseMode(deck.first.chartType.toUpperCase() == 'CALL');
        }
      }
    });
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
    
    ref.read(gameStateProvider.notifier).processAnswer(result);
    
    setState(() {
      _showAnswerResult = true;
      _lastAnswerCorrect = isCorrect;
      _lastWasFold = (direction == CardSwiperDirection.left);
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
      ref.read(timerProvider.notifier).pause();
    }
    
    if (_isDisabled) {
      setState(() => _isDisabled = false);
    }

    // Update current card index
    if (currentIndex != null) {
      setState(() => _currentCardIndex = currentIndex);
    }
    
    if (currentIndex != null && currentIndex < _deck.length) {
      final nextQuestion = _deck[currentIndex];
      ref.read(gameStateProvider.notifier)
          .setDefenseMode(nextQuestion.chartType.toUpperCase() == 'CALL');
    }

    if (currentIndex == null || currentIndex >= _deck.length - 1) {
      Future.delayed(const Duration(milliseconds: 1200), () {
        if (mounted) _navigateToGameOver();
      });
    }
    
    return true;
  }

  void _onAnswerResultComplete() {
    setState(() => _showAnswerResult = false);
    final result = _lastResult;
    final question = _lastQuestion;
    if (result != null && !result.isCorrect && result.factBombMessage != null && question != null) {
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
      _restartTimerForNextCard();
    }
  }

  void _onFactBombDismissed() {
    _restartTimerForNextCard();
    if (ref.read(gameStateProvider).hearts <= 0) {
      _navigateToGameOver();
    }
  }

  void _navigateToGameOver() {
    ref.read(timerProvider.notifier).stop();
    SoundManager.play(SoundType.gameOver);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/game-over', arguments: {'mode': widget.isLeague ? 'league' : 'training'});
      }
    });
  }

  void _restartTimerForNextCard() {
    _cardShownTime = DateTime.now();
    final combo = ref.read(gameStateProvider).combo;
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
    final gameState = ref.watch(gameStateProvider);
    final timerState = ref.watch(timerProvider);
    final userStats = ref.watch(userStatsProvider); // Fetch user stats

    ref.listen(timerProvider, (previous, next) {
      if (next.phase == TimerPhase.expired && previous?.phase != TimerPhase.expired) {
        _handleTimerExpired();
      }
    });

    if (_deck.isEmpty) {
      return const Scaffold(
        body: GtoBattleBackground(), // Use new background for loading too
      );
    }

    // Current card for info display
    final cardIdx = _currentCardIndex.clamp(0, _deck.length - 1);
    final currentQ = _deck[cardIdx];
    final maxDuration = ref.read(timerProvider.notifier).currentDuration;
    final timerProgress = (timerState.seconds / maxDuration).clamp(0.0, 1.0);

    return Scaffold(
      body: Stack(
        children: [
          const GtoBattleBackground(),
          
          SafeArea(
            child: Column(
              children: [
                // 1. Header (Glassmorphism)
                GtoBattleHeader(
                  gameState: gameState, 
                  question: currentQ,
                  tierName: userStats.tier.displayName,
                  currentScore: gameState.score, // Use GameState score for real-time game progress
                  rank: 4203, // Mock rank for now as requested (or use userStats.rank if available)
                ),
                
                // 2. Timer Bar (Shimmer)
                GtoBattleTimerBar(
                  progress: timerProgress, 
                  secondsLeft: timerState.seconds.toInt()
                ),
                
                // Defense Mode Alert
                if (gameState.isDefenseMode)
                  DefenseAlertBanner(
                    opponentPosition: currentQ.opponentPosition ?? 'UTG',
                    actionHistory: currentQ.actionHistory,
                  ),

                SizedBox(height: context.h(4)),

                // 3. Pro Table Visualization
                TablePositionView(
                  heroPosition: currentQ.position,
                  opponentPosition: currentQ.opponentPosition,
                  isDefenseMode: gameState.isDefenseMode,
                  actionHistory: currentQ.actionHistory,
                ),

                // 4. Card Area (Swiper) - fills remaining space
                Expanded(
                  child: Stack(
                    children: [
                      CardSwiper(
                        controller: _swiperController,
                        cardsCount: _deck.length,
                        numberOfCardsDisplayed: 1,
                        onSwipe: _onSwipe,
                        onSwipeDirectionChange: _onSwipeDirectionChange,
                        isDisabled: _isDisabled,
                        allowedSwipeDirection: const AllowedSwipeDirection.symmetric(horizontal: true),
                        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                        cardBuilder: (context, index, horizontalOffsetPercentage, verticalOffsetPercentage) {
                          return PokerCardWidget(question: _deck[index]);
                        },
                      ),
                      
                      SwipeFeedbackOverlay(dragProgress: _dragProgress),
                      
                      AnswerResultOverlay(
                        isCorrect: _lastAnswerCorrect,
                        isVisible: _showAnswerResult,
                        wasFold: _lastWasFold,
                        onComplete: _onAnswerResultComplete,
                      ),
                      
                      if (_showSnapBonus) _buildSnapBonusOverlay(),
                    ],
                  ),
                ),

                // 5. Footer (Original Buttons)
                SizedBox(height: context.h(4)),
                _buildBottomBar(context, gameState),
                SizedBox(height: context.h(8)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════
  // SNAP BONUS OVERLAY
  // ═══════════════════════════════════════════════
  Widget _buildSnapBonusOverlay() {
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) setState(() => _showSnapBonus = false);
    });
    return Positioned.fill(
      child: IgnorePointer(
        child: Center(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: context.w(24), vertical: context.h(12)),
            decoration: BoxDecoration(
              color: _accentGold.withOpacity(0.9),
              borderRadius: BorderRadius.circular(context.r(16)),
              boxShadow: [BoxShadow(color: _accentGold.withOpacity(0.6), blurRadius: context.r(20))],
            ),
            child: Text(
              '⚡ SNAP BONUS! ⚡',
              style: TextStyle(color: Colors.black, fontSize: context.sp(22), fontWeight: FontWeight.w900),
            ),
          ),
        ),
      ),
    );
  }

  // Restored Footer
  Widget _buildBottomBar(BuildContext context, GameState state) {
    final isDefense = state.isDefenseMode;
    final rightLabel = isDefense ? '콜' : '올인';
    final rightColor = isDefense ? const Color(0xFF3B82F6) : _accentGreen;
    final rightIcon = isDefense ? '✓' : '→';
    
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.w(24)),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Fold button
              Row(
                children: [
                  Container(
                    width: context.w(48),
                    height: context.w(48),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _accentRed.withOpacity(0.15),
                      border: Border.all(color: _accentRed.withOpacity(0.3)),
                    ),
                    child: Center(
                      child: Text('✕', style: TextStyle(color: const Color(0xFFEF4444), fontSize: context.sp(20), fontWeight: FontWeight.bold)),
                    ),
                  ),
                  SizedBox(width: context.w(10)),
                  Text('폴드', style: TextStyle(color: const Color(0xFFEF4444), fontSize: context.sp(18), fontWeight: FontWeight.w900)),
                ],
              ),

              // Time bank conditionally based on league mode
              if (state.isLeague && state.timeBankCount > 0)
                GestureDetector(
                  onTap: () {
                    final success = ref.read(gameStateProvider.notifier).useTimeBank();
                    if (success) {
                      ref.read(timerProvider.notifier).addTime(15);
                      HapticManager.swipe();
                      SoundManager.play(SoundType.chipStack);
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: context.w(14), vertical: context.h(8)),
                    decoration: BoxDecoration(
                      color: _accentGold.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(context.r(20)),
                      border: Border.all(color: _accentGold.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Text('🪙', style: TextStyle(fontSize: context.sp(16))),
                        SizedBox(width: context.w(6)),
                        Text('×${state.timeBankCount}', style: TextStyle(color: _accentGold, fontSize: context.sp(14), fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),

              // All-in / Call button
              Row(
                children: [
                  Text(rightLabel, style: TextStyle(color: rightColor, fontSize: context.sp(18), fontWeight: FontWeight.w900)),
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
                      child: Text(rightIcon, style: TextStyle(color: rightColor, fontSize: context.sp(20), fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: context.h(8)),
          Text(
            isDefense ? '← 폴드 | 콜 →' : '← 스와이프하여 결정하세요 →',
            style: TextStyle(color: Colors.white24, fontSize: context.sp(11)),
          ),
        ],
      ),
    );
  }
}
