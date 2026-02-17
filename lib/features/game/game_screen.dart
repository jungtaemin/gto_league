import 'dart:math' show min;
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
import '../../providers/game_providers.dart';

// Utils
import '../../core/utils/haptic_manager.dart';
import '../../core/utils/sound_manager.dart';

// Widgets
import 'widgets/poker_card_widget.dart';
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
      ref.read(gameStateNotifierProvider.notifier)
          .setDefenseMode(nextQuestion.chartType == 'CALL');
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
        onDismiss: _onFactBombDismissed,
      );
    } else {
      _restartTimerForNextCard();
    }
  }

  void _onFactBombDismissed() {
    _restartTimerForNextCard();
    if (ref.read(gameStateNotifierProvider).hearts <= 0) {
      _navigateToGameOver();
    }
  }

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
        body: Container(
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(0, -0.3),
              radius: 1.2,
              colors: [Color(0xFF4338CA), Color(0xFF1E1B4B), Color(0xFF0B0A1A)],
            ),
          ),
          child: const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: Color(0xFF7C3AED), strokeWidth: 3),
                SizedBox(height: 16),
                Text('로딩 중...', style: TextStyle(color: Colors.white54, fontSize: 14)),
              ],
            ),
          ),
        ),
      );
    }

    // Current card for info display
    final cardIdx = _currentCardIndex.clamp(0, _deck.length - 1);
    final currentQ = _deck[cardIdx];

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.3),
            radius: 1.2,
            colors: [Color(0xFF4338CA), Color(0xFF1E1B4B), Color(0xFF0B0A1A)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 8),

              // ── 1. Top Bar: Position + Hearts + Score ──
              _buildTopBar(gameState, currentQ),
              const SizedBox(height: 12),

              // ── 2. Timer Bar ──
              _buildTimerBar(timerState),
              const SizedBox(height: 16),

              // ── 3. Card Area ──
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
                      _buildSnapBonusOverlay(),
                  ],
                ),
              ),

              // ── 4. Hand Info ──
              _buildHandInfo(currentQ),
              const SizedBox(height: 8),

              // ── 5. Bottom Swipe Hints ──
              _buildBottomBar(gameState),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════
  // STITCH DESIGN: TOP BAR
  // ═══════════════════════════════════════════════
  Widget _buildTopBar(GameState state, CardQuestion q) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // Position Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF7C3AED), Color(0xFF6D28D9)],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: _accentPurple.withOpacity(0.4), blurRadius: 10)],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('현재 포지션', style: TextStyle(color: Colors.white60, fontSize: 9, fontWeight: FontWeight.w500)),
                const SizedBox(height: 2),
                Text(
                  q.position,
                  style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 1),
                ),
              ],
            ),
          ),

          const Spacer(),

          // Hearts
          Row(
            children: List.generate(5, (index) {
              final isActive = index < state.hearts;
              return Padding(
                padding: const EdgeInsets.only(right: 3),
                child: Icon(
                  isActive ? Icons.favorite : Icons.favorite_border,
                  color: isActive ? _accentRed : Colors.white24,
                  size: 20,
                ),
              );
            }),
          ),
          const SizedBox(width: 12),

          // Score
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Row(
              children: [
                Icon(Icons.bolt, color: _accentGold, size: 16),
                const SizedBox(width: 4),
                Text(
                  '${state.score}',
                  style: TextStyle(color: _accentGold, fontSize: 16, fontWeight: FontWeight.w900),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════
  // STITCH DESIGN: TIMER BAR
  // ═══════════════════════════════════════════════
  Widget _buildTimerBar(TimerState timerState) {
    final isCritical = timerState.phase == TimerPhase.critical;
    final isExpired = timerState.phase == TimerPhase.expired;
    final maxDuration = ref.read(timerProvider.notifier).currentDuration;
    final progress = (timerState.seconds / maxDuration).clamp(0.0, 1.0);

    Color barColor;
    if (isExpired) {
      barColor = _accentRed;
    } else if (isCritical) {
      barColor = _accentRed;
    } else {
      barColor = _accentCyan;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('남은 시간', style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.w500)),
              Text(
                '${timerState.seconds.toStringAsFixed(0)}s',
                style: TextStyle(
                  color: isCritical ? _accentRed : Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Container(
            height: 6,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(3),
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: progress,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isCritical
                          ? [_accentRed, _accentRed.withOpacity(0.7)]
                          : [_accentCyan, const Color(0xFF818CF8)],
                    ),
                    borderRadius: BorderRadius.circular(3),
                    boxShadow: [BoxShadow(color: barColor.withOpacity(0.5), blurRadius: 6)],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════
  // STITCH DESIGN: HAND INFO
  // ═══════════════════════════════════════════════
  Widget _buildHandInfo(CardQuestion q) {
    final isDefense = q.chartType == 'CALL';
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.07),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Text(
            '현재 핸드: ${q.hand}',
            style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            '유효 스택: ${q.stackBb.toStringAsFixed(0)}BB',
            style: TextStyle(color: Colors.white54, fontSize: 12),
          ),
          if (isDefense && q.opponentPosition != null) ...[
            const SizedBox(height: 4),
            Text(
              '상대방: ${q.opponentPosition} Open',
              style: TextStyle(color: _accentRed.withOpacity(0.8), fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ],
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════
  // STITCH DESIGN: BOTTOM BAR (FOLD/ALL-IN)
  // ═══════════════════════════════════════════════
  Widget _buildBottomBar(GameState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Fold button
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _accentRed.withOpacity(0.15),
                      border: Border.all(color: _accentRed.withOpacity(0.3)),
                    ),
                    child: const Center(
                      child: Text('✕', style: TextStyle(color: Color(0xFFEF4444), fontSize: 20, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text('폴드', style: TextStyle(color: Color(0xFFEF4444), fontSize: 18, fontWeight: FontWeight.w900)),
                ],
              ),

              // Time bank
              if (state.timeBankCount > 0)
                GestureDetector(
                  onTap: () {
                    final success = ref.read(gameStateNotifierProvider.notifier).useTimeBank();
                    if (success) {
                      ref.read(timerProvider.notifier).addTime(30);
                      HapticManager.swipe();
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: _accentGold.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: _accentGold.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        const Text('🪙', style: TextStyle(fontSize: 16)),
                        const SizedBox(width: 6),
                        Text('×${state.timeBankCount}', style: TextStyle(color: _accentGold, fontSize: 14, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),

              // All-in button
              Row(
                children: [
                  const Text('올인', style: TextStyle(color: Color(0xFF22C55E), fontSize: 18, fontWeight: FontWeight.w900)),
                  const SizedBox(width: 10),
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _accentGreen.withOpacity(0.15),
                      border: Border.all(color: _accentGreen.withOpacity(0.3)),
                    ),
                    child: const Center(
                      child: Text('→', style: TextStyle(color: Color(0xFF22C55E), fontSize: 20, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '← 스와이프하여 결정하세요 →',
            style: TextStyle(color: Colors.white24, fontSize: 11),
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
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: _accentGold.withOpacity(0.9),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: _accentGold.withOpacity(0.6), blurRadius: 20)],
            ),
            child: const Text(
              '⚡ SNAP BONUS! ⚡',
              style: TextStyle(color: Colors.black, fontSize: 22, fontWeight: FontWeight.w900),
            ),
          ),
        ),
      ),
    );
  }
}
