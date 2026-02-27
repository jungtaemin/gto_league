import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/deep_stack_scenario.dart';
import '../../data/models/card_question.dart';
import '../../data/providers/deep_stack_data_provider.dart';
import '../../data/services/action_evaluator.dart';
import '../../data/services/omni_swipe_engine.dart';

import '../../core/utils/haptic_manager.dart';
import '../../core/utils/sound_manager.dart';
import '../../core/utils/responsive.dart';
import '../../core/theme/app_colors.dart';

import 'widgets/omni_swipe_feedback_overlay.dart';
import 'widgets/cross_gauge_overlay.dart';
import 'widgets/blunder_shake_overlay.dart';
import 'widgets/answer_result_overlay.dart';
import 'widgets/poker_card_widget.dart';
import 'widgets/table_position_view.dart';

/// 30BB Omni-Swipe 4-direction game screen.
///
/// Uses [OmniSwipeEngine] for game state management and
/// [DeepStackDataProvider] for scenario loading.
///
/// 4-way swipe mapping:
/// - Left  → FOLD
/// - Right → RAISE
/// - Up    → ALL-IN
/// - Down  → CALL
///
/// Evaluation grades:
/// - PERFECT → [AnswerResultOverlay]
/// - GOOD    → [CrossGaugeOverlay]
/// - BLUNDER → [BlunderShakeOverlay]
class OmniSwipeScreen extends ConsumerStatefulWidget {
  const OmniSwipeScreen({super.key});

  @override
  ConsumerState<OmniSwipeScreen> createState() => _OmniSwipeScreenState();
}

class _OmniSwipeScreenState extends ConsumerState<OmniSwipeScreen>
    with SingleTickerProviderStateMixin {
  List<DeepStackScenario> _scenarios = [];
  int _currentCardIndex = 0;
  final bool _isDisabled = false;

  // ── Custom swipe state ─────────────────────────────────────────
  Offset _dragOffset = Offset.zero;
  bool _isDragging = false;
  late AnimationController _resetController;
  late Animation<Offset> _resetAnimation;
  static const double _swipeThreshold = 80.0; // 80px – much more reasonable

  // Drag progress for OmniSwipeFeedbackOverlay
  double _horizontalProgress = 0.0;
  double _verticalProgress = 0.0;

  // Answer result overlay (PERFECT judgment)
  bool _showAnswerResult = false;
  bool _lastAnswerCorrect = true;
  bool _lastWasFold = false;

  // Cross gauge overlay (GOOD judgment)
  bool _showCrossGauge = false;
  DeepStackScenario? _lastScenario;

  // Blunder shake overlay
  bool _showBlunderShake = false;

  @override
  void initState() {
    super.initState();
    _resetController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _resetAnimation = Tween<Offset>(begin: Offset.zero, end: Offset.zero)
        .animate(CurvedAnimation(
      parent: _resetController,
      curve: Curves.easeOutBack,
    ));
    _resetController.addListener(() {
      setState(() => _dragOffset = _resetAnimation.value);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _startGame();
    });
  }

  @override
  void dispose() {
    _resetController.dispose();
    super.dispose();
  }

  // ── Initialization ────────────────────────────────────────────

  void _startGame() {
    ref.read(omniSwipeEngineProvider.notifier).startGame();
    _loadScenarios();
  }

  Future<void> _loadScenarios() async {
    try {
      final cache = await ref.read(deepStackDataProvider.future);
      if (!mounted) return;
      
      final random = math.Random();
      final foldScenarios = List<DeepStackScenario>.from(cache.foldScenarios)..shuffle(random);
      final actionScenarios = List<DeepStackScenario>.from(cache.actionScenarios)..shuffle(random);
      
      final gameScenarios = <DeepStackScenario>[];
      double actionWeight = 0.4;
      
      int foldIndex = 0;
      int actionIndex = 0;
      
      // Build a balanced queue of 50 scenarios
      for (int i = 0; i < 50; i++) {
        bool pickAction = random.nextDouble() < actionWeight;
        
        DeepStackScenario selected;
        // Resolve selection with fallbacks
        if (pickAction && actionIndex < actionScenarios.length) {
          selected = actionScenarios[actionIndex++];
        } else if (!pickAction && foldIndex < foldScenarios.length) {
          selected = foldScenarios[foldIndex++];
        } else if (foldIndex < foldScenarios.length) {
          selected = foldScenarios[foldIndex++];
        } else if (actionIndex < actionScenarios.length) {
          selected = actionScenarios[actionIndex++];
        } else {
          break; // Empty pools
        }
        
        gameScenarios.add(selected);
        
        // Dynamic weight adjustment for the *next* draw
        // If this one was a fold, increase the chance of pulling an action next
        if (selected.dominantAction == 'fold') {
          actionWeight = math.min(0.9, actionWeight + 0.15);
        } else {
          actionWeight = 0.4; // Reset to baseline
        }
      }

      setState(() {
        _scenarios = gameScenarios;
        _currentCardIndex = 0;
      });
    } catch (e) {
      debugPrint('[OmniSwipeScreen] Failed to load scenarios: $e');
    }
  }

  // ── Swipe Handling (Custom 4-direction) ─────────────────────────

  /// Determine dominant swipe direction by comparing abs(dx) vs abs(dy)
  String _getSwipeDirection(Offset offset) {
    final dx = offset.dx;
    final dy = offset.dy;

    if (dx.abs() > dy.abs()) {
      // Horizontal dominant
      return dx < 0 ? 'fold' : 'raise';
    } else {
      // Vertical dominant
      return dy < 0 ? 'allin' : 'call';
    }
  }

  void _onDragStart(DragStartDetails details) {
    if (_isDisabled) return;
    final engineState = ref.read(omniSwipeEngineProvider);
    if (engineState.phase != OmniSwipePhase.playing) return;
    _resetController.stop();
    setState(() => _isDragging = true);
  }

  void _onDragUpdate(DragUpdateDetails details) {
    if (!_isDragging) return;
    setState(() {
      _dragOffset += details.delta;
      // Update feedback overlay progress
      _horizontalProgress = (_dragOffset.dx / _swipeThreshold).clamp(-1.0, 1.0);
      _verticalProgress = (_dragOffset.dy / _swipeThreshold).clamp(-1.0, 1.0);
    });
  }

  void _onDragEnd(DragEndDetails details) {
    if (!_isDragging) return;
    _isDragging = false;

    final distance = _dragOffset.distance;
    if (distance > _swipeThreshold) {
      // Swipe detected – determine direction
      final userAction = _getSwipeDirection(_dragOffset);
      _processSwipe(userAction);
    }

    // Animate card back to center
    _resetAnimation = Tween<Offset>(
      begin: _dragOffset,
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _resetController,
      curve: Curves.easeOutBack,
    ));
    _resetController.forward(from: 0);

    setState(() {
      _horizontalProgress = 0.0;
      _verticalProgress = 0.0;
    });
  }

  void _processSwipe(String userAction) {
    if (_currentCardIndex >= _scenarios.length) return;
    final scenario = _scenarios[_currentCardIndex];

    final grade = evaluateAction(userAction, scenario);

    debugPrint('--- OMNI SWIPE ---');
    debugPrint('Hand: ${scenario.hand} at ${scenario.position}');
    debugPrint('Freqs: F=${scenario.foldFreq}, C=${scenario.callFreq}, R=${scenario.raiseFreq}, A=${scenario.allinFreq}');
    debugPrint('Action: $userAction | Grade: $grade');
    debugPrint('------------------');

    ref.read(omniSwipeEngineProvider.notifier).processAnswer(grade);

    setState(() {
      _lastScenario = scenario;
      if (grade == ActionGrade.perfect) {
        _showAnswerResult = true;
        _lastAnswerCorrect = true;
        _lastWasFold = (userAction == 'fold');
        HapticManager.correct();
        SoundManager.play(SoundType.correct);
      } else if (grade == ActionGrade.good) {
        _showCrossGauge = true;
        HapticManager.correct();
        SoundManager.play(SoundType.correct);
      } else {
        _showBlunderShake = true;
        HapticManager.wrong();
        SoundManager.play(SoundType.wrong);
      }

      // Advance card index
      if (_currentCardIndex < _scenarios.length - 1) {
        _currentCardIndex++;
      }
    });
  }


  // ── Answer Result Flow ────────────────────────────────────────

  void _onAnswerResultComplete() {
    setState(() => _showAnswerResult = false);
    _advanceToNextHand();
  }

  void _onCrossGaugeComplete() {
    setState(() => _showCrossGauge = false);
    _advanceToNextHand();
  }

  void _onBlunderShakeComplete() {
    setState(() => _showBlunderShake = false);
    _advanceToNextHand();
  }

  void _advanceToNextHand() {
    final engine = ref.read(omniSwipeEngineProvider);
    if (engine.phase == OmniSwipePhase.gameOver ||
        engine.phase == OmniSwipePhase.victory) {
      // Navigate to game over - for now just pop back
      Navigator.of(context).pop();
      return;
    }
    ref.read(omniSwipeEngineProvider.notifier).nextHand();
  }

  // ── Build ─────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final engineState = ref.watch(omniSwipeEngineProvider);
    final asyncCache = ref.watch(deepStackDataProvider);

    // Loading state
    if (asyncCache.isLoading || _scenarios.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.leagueBgDark,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // Error state
    if (asyncCache.hasError) {
      return Scaffold(
        backgroundColor: AppColors.leagueBgDark,
        body: Center(
          child: Text('데이터 로드 실패: ${asyncCache.error}'),
        ),
      );
    }

    final cardIdx = _currentCardIndex.clamp(0, _scenarios.length - 1);
    final currentScenario = _scenarios[cardIdx];

    return Scaffold(
      backgroundColor: AppColors.leagueBgDark,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                // HUD: Score + Strikes + Combo
                _buildHud(context, engineState),

                SizedBox(height: context.h(8)),

                // Poker table with positions
                TablePositionView(
                  heroPosition: currentScenario.position,
                  isDefenseMode: false,
                  actionHistory: currentScenario.actionHistory,
                ),

                SizedBox(height: context.h(4)),
                // Card Swiper + Overlays
                Expanded(
                  child: Stack(
                    children: [
                      // Custom 4-direction swipe card
                      GestureDetector(
                        onPanStart: _onDragStart,
                        onPanUpdate: _onDragUpdate,
                        onPanEnd: _onDragEnd,
                        child: Center(
                          child: Transform.translate(
                            offset: _dragOffset,
                            child: Transform.rotate(
                              angle: _dragOffset.dx * 0.001, // subtle rotation
                              child: _currentCardIndex < _scenarios.length
                                  ? PokerCardWidget(
                                      question: _toCardQuestion(
                                          _scenarios[_currentCardIndex]),
                                    )
                                  : const SizedBox.shrink(),
                            ),
                          ),
                        ),
                      ),

                      // 4-way feedback overlay
                      OmniSwipeFeedbackOverlay(
                        horizontalProgress: _horizontalProgress,
                        verticalProgress: _verticalProgress,
                      ),

                      // PERFECT result overlay
                      AnswerResultOverlay(
                        isCorrect: _lastAnswerCorrect,
                        isVisible: _showAnswerResult,
                        wasFold: _lastWasFold,
                        onComplete: _onAnswerResultComplete,
                      ),

                      // GOOD cross gauge overlay
                      CrossGaugeOverlay(
                        isVisible: _showCrossGauge,
                        foldFreq: _lastScenario?.foldFreq ?? 0,
                        callFreq: _lastScenario?.callFreq ?? 0,
                        raiseFreq: _lastScenario?.raiseFreq ?? 0,
                        allinFreq: _lastScenario?.allinFreq ?? 0,
                        onComplete: _onCrossGaugeComplete,
                      ),

                      // BLUNDER shake overlay
                      BlunderShakeOverlay(
                        isVisible: _showBlunderShake,
                        onComplete: _onBlunderShakeComplete,
                      ),
                    ],
                  ),
                ),

                SizedBox(height: context.h(4)),

                // 4-way direction guide at bottom
                _buildDirectionGuide(context),

                SizedBox(height: context.h(8)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Sub-widgets ───────────────────────────────────────────────

  Widget _buildHud(BuildContext context, OmniSwipeState engineState) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: context.w(16),
        vertical: context.h(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back button
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
              size: context.w(20),
            ),
          ),
          // Score
          Text(
            '${engineState.score}',
            style: TextStyle(
              fontFamily: 'Black Han Sans',
              fontSize: context.sp(28),
              color: AppColors.leaguePromotionGold,
            ),
          ),
          // Strikes as hearts
          Row(
            children: List.generate(
              3,
              (i) => Padding(
                padding: EdgeInsets.only(left: context.w(4)),
                child: Icon(
                  i < engineState.strikesRemaining
                      ? Icons.favorite
                      : Icons.favorite_border,
                  color: i < engineState.strikesRemaining
                      ? const Color(0xFFEF4444)
                      : Colors.white24,
                  size: context.w(22),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScenarioInfo(
      BuildContext context, DeepStackScenario scenario) {
    final engineState = ref.read(omniSwipeEngineProvider);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.w(16)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 30BB badge
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: context.w(10),
              vertical: context.h(3),
            ),
            decoration: BoxDecoration(
              color: AppColors.leaguePromotionGold.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(context.r(8)),
              border: Border.all(color: AppColors.leaguePromotionGold.withValues(alpha: 0.4)),
            ),
            child: Text(
              '30BB',
              style: TextStyle(
                fontFamily: 'Black Han Sans',
                fontSize: context.sp(12),
                color: AppColors.leaguePromotionGold,
              ),
            ),
          ),
          // Hand count
          Text(
            '${engineState.currentHandIndex + 1} / ${engineState.totalHands}',
            style: TextStyle(
              fontSize: context.sp(12),
              color: Colors.white54,
            ),
          ),
          // Combo
          if (engineState.combo > 0)
            Text(
              '🔥 x${engineState.combo}',
              style: TextStyle(
                fontFamily: 'Black Han Sans',
                fontSize: context.sp(14),
                color: const Color(0xFFFBBF24),
              ),
            )
          else
            const SizedBox.shrink(),
        ],
      ),
    );
  }
  /// Convert [DeepStackScenario] to [CardQuestion] for [PokerCardWidget].
  CardQuestion _toCardQuestion(DeepStackScenario scenario) {
    return CardQuestion(
      position: scenario.position,
      hand: scenario.hand,
      stackBb: 30.0,
      correctAction: scenario.dominantAction.toUpperCase(),
      evBb: 0.0,
      chartType: 'push',
      bbLevel: 30,
    );
  }

  Widget _buildDirectionGuide(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.w(16)),
      child: Column(
        children: [
          // Top label (ALL-IN)
          Text(
            '⬆️ 올인',
            style: TextStyle(
              color: const Color(0xFFFBBF24),
              fontSize: context.sp(12),
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: context.h(4)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '⬅️ 폴드',
                style: TextStyle(
                  color: const Color(0xFFEF4444),
                  fontSize: context.sp(12),
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '레이즈 ➡️',
                style: TextStyle(
                  color: const Color(0xFF2979FF),
                  fontSize: context.sp(12),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: context.h(4)),
          Text(
            '⬇️ 콜',
            style: TextStyle(
              color: const Color(0xFF22C55E),
              fontSize: context.sp(12),
              fontWeight: FontWeight.bold,
            ),
          ),
          // Vertical swipe produces no card rotation — this is intentional
        ],
      ),
    );
  }
}
