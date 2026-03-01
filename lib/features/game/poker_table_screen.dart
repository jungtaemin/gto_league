import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/deep_stack_scenario.dart';
import '../../data/providers/deep_stack_data_provider.dart';
import '../../data/services/action_evaluator.dart';
import '../../data/services/omni_swipe_engine.dart';
import '../decorate/providers/decorate_provider.dart';
import '../../data/services/scenario_loader.dart';
import '../../data/services/bet_amount_helper.dart';
import '../../core/utils/haptic_manager.dart';
import '../../core/utils/sound_manager.dart';
import '../../core/utils/responsive.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'widgets/table_position_view.dart';
import 'widgets/poker_table/poker_table_widget.dart';
import 'widgets/poker_table/player_seat_widget.dart';
import 'widgets/poker_table/hero_card_display.dart';
import 'widgets/poker_table/action_button_bar.dart';
import 'widgets/poker_table/table_timer_widget.dart';
import 'widgets/poker_table/table_pot_display.dart';

/// 30BB GTO Training — Realistic Poker Table UI
///
/// Replaces the swipe-based OmniSwipeScreen with a button-based
/// 9-player oval table interface. Uses OmniSwipeEngine for game state.
class PokerTableScreen extends ConsumerStatefulWidget {
  const PokerTableScreen({super.key});

  @override
  ConsumerState<PokerTableScreen> createState() => _PokerTableScreenState();
}

class _PokerTableScreenState extends ConsumerState<PokerTableScreen> {
  static const _positions = [
    'UTG', 'UTG+1', 'UTG+2', 'LJ', 'HJ', 'CO', 'BU', 'SB', 'BB'
  ];

  /// Normalize scenario position names to match _positions array
  /// Data uses: UTG1, UTG2, BTN → we need: UTG+1, UTG+2, BU
  static String _normalizeScenarioPos(String pos) {
    switch (pos.toUpperCase()) {
      case 'UTG1': return 'UTG+1';
      case 'UTG2': return 'UTG+2';
      case 'BTN': return 'BU';
      default: return pos.toUpperCase();
    }
  }

  /// 화면 포지션명 → DB 포지션명 역변환
  static String _toDbPosition(String displayPos) {
    switch (displayPos) {
      case 'UTG+1': return 'UTG1';
      case 'UTG+2': return 'UTG2';
      case 'BU': return 'BTN';
      default: return displayPos;
    }
  }

  /// BTN 로테이션 순서 (히어로 포지션이 이 순서로 순환)
  /// BTN → CO → HJ → LJ → UTG+2 → UTG+1 → UTG → BB → SB → (repeat)
  static const _rotationOrder = [
    'BU', 'CO', 'HJ', 'LJ', 'UTG+2', 'UTG+1', 'UTG', 'BB', 'SB'
  ];

  // Scenario state
  List<DeepStackScenario> _scenarios = [];
  int _currentCardIndex = 0;
  int _rotationIndex = 0; // 현재 로테이션 위치 (0 = BTN)

  // Turn state
  bool _isMyTurn = false;
  bool _timerRunning = false;
  bool _timerPaused = false;

  // Feedback state
  bool _showFeedback = false;
  ActionGrade? _lastGrade;
  DeepStackScenario? _lastScenario;

  // Table state
  Map<String, String> _seatActions = {};
  Map<String, double> _seatBets = {};
  double _potSize = 1.5;

  // Animation
  Timer? _animationTimer;
  List<dynamic> _actionSteps = []; // List from parseActionSequence

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _startGame();
    });
  }

  @override
  void dispose() {
    _animationTimer?.cancel();
    super.dispose();
  }

  // ── Initialization ─────────────────────────────────────────────

  void _startGame() {
    ref.read(omniSwipeEngineProvider.notifier).startGame();
    _rotationIndex = 0; // BTN부터 시작
    _loadScenariosForCurrentRotation();
  }

  /// 현재 로테이션 포지션에 맞는 시나리오를 로드
  Future<void> _loadScenariosForCurrentRotation() async {
    try {
      final cache = await ref.read(deepStackDataProvider.future);
      if (!mounted) return;

      final heroDisplayPos = _rotationOrder[_rotationIndex % _rotationOrder.length];
      final heroDbPos = _toDbPosition(heroDisplayPos);

      // 현재 포지션에서 밸런스된 시나리오 1개만 로드 (매 핸드마다 포지션 회전)
      final scenarios = ScenarioLoader.loadBalancedScenariosForPosition(
        cache,
        position: heroDbPos,
        count: 1,
      );

      if (scenarios.isEmpty) {
        // 해당 포지션에 시나리오가 없으면 다음 포지션으로 넘어감
        debugPrint('No scenarios for $heroDbPos, skipping...');
        _rotationIndex++;
        _loadScenariosForCurrentRotation();
        return;
      }

      setState(() {
        _scenarios = scenarios;
        _currentCardIndex = 0;
      });
      _loadCurrentHand();
    } catch (e) {
      debugPrint('PokerTableScreen: Failed to load scenarios: $e');
    }
  }

  void _loadCurrentHand() {
    if (_scenarios.isEmpty || _currentCardIndex >= _scenarios.length) return;
    final scenario = _scenarios[_currentCardIndex];

    // Reset state
    _animationTimer?.cancel();
    setState(() {
      _seatActions = {};
      _seatBets = {'SB': 0.5, 'BB': 1.0};
      _potSize = 1.5;
      _isMyTurn = false;
      _timerRunning = false;
      _timerPaused = false;
    });

    // Parse action history
    _actionSteps = TablePositionView.parseActionSequence(scenario.actionHistory);

    // Build partial action history strings for incremental bet calculation
    // e.g., full = "UTG_F.UTG1_R.HJ_A" → step 0 = "UTG_F", step 1 = "UTG_F.UTG1_R", step 2 = "UTG_F.UTG1_R.HJ_A"
    final historyParts = scenario.actionHistory.split('.');
    
    // Animate steps sequentially (1 second per step for realistic online poker tempo)
    int stepIndex = 0;
    _animationTimer = Timer.periodic(const Duration(milliseconds: 1000), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (stepIndex < _actionSteps.length) {
        final step = _actionSteps[stepIndex];
        
        // Build partial history up to current step only
        final partialHistory = historyParts
            .take(stepIndex + 1)
            .join('.');
        
        final bets = BetAmountHelper.derivePlayerBets(partialHistory);
        final pot = BetAmountHelper.derivePotSize(partialHistory);
        
        setState(() {
          _seatActions[step.position] = step.action;
          _seatBets = bets;
          _potSize = pot;
        });
        stepIndex++;
      } else {
        timer.cancel();
        // All steps done — hero's turn
        setState(() {
          _isMyTurn = true;
          _timerRunning = true;
        });
      }
    });
  }

  // ── Action Processing ──────────────────────────────────────────

  void _processAction(String userAction) {
    if (!_isMyTurn || _currentCardIndex >= _scenarios.length) return;
    final scenario = _scenarios[_currentCardIndex];
    final grade = evaluateAction(userAction, scenario);

    ref.read(omniSwipeEngineProvider.notifier).processAnswer(grade);

    setState(() {
      _isMyTurn = false;
      _timerRunning = false;
      _timerPaused = true;
      _lastGrade = grade;
      _lastScenario = scenario;
      _showFeedback = true;
    });

    if (grade == ActionGrade.perfect || grade == ActionGrade.good) {
      HapticManager.correct();
      SoundManager.play(SoundType.correct);
    } else {
      HapticManager.wrong();
      SoundManager.play(SoundType.wrong);
    }

    // Auto-advance after feedback delay
    final delay = grade == ActionGrade.good ? 1500 : 900;
    Future.delayed(Duration(milliseconds: delay), () {
      if (mounted) _onFeedbackComplete();
    });
  }

  void _onTimerTimeout() {
    if (!_isMyTurn) return;
    // Timeout = treat as fold (worst action in most scenarios → BLUNDER)
    _processAction('fold');
  }

  void _onFeedbackComplete() {
    setState(() {
      _showFeedback = false;
      _timerPaused = false;
    });
    _advanceToNextHand();
  }

  void _advanceToNextHand() {
    final engine = ref.read(omniSwipeEngineProvider);
    if (engine.phase == OmniSwipePhase.gameOver ||
        engine.phase == OmniSwipePhase.victory) {
      Navigator.of(context).pop();
      return;
    }
    ref.read(omniSwipeEngineProvider.notifier).nextHand();

    // 매 핸드마다 BTN 한 칸 이동 (실제 홀덤과 동일)
    _rotationIndex++;
    _loadScenariosForCurrentRotation();
  }

  // ── Build ──────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final engineState = ref.watch(omniSwipeEngineProvider);

    // Loading state
    if (_scenarios.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.pokerTableBg,
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.pokerTableChipGold),
        ),
      );
    }

    final cardIdx = _currentCardIndex.clamp(0, _scenarios.length - 1);
    final currentScenario = _scenarios[cardIdx];

    return Scaffold(
      backgroundColor: Colors.black, // fallback behind image
      body: Stack(
        children: [
          // 1. Full-screen Table (background + seats)
          Positioned.fill(
            child: PokerTableWidget(
              heroSeatIndex: _positions.indexOf(_normalizeScenarioPos(currentScenario.position)),
              seatBuilder: (ctx, i, dir) => _buildSeat(ctx, i, dir, currentScenario),
              potDisplay: TablePotDisplay(
                potSize: _potSize,
                blindInfo: 'SB 0.5 / BB 1',
              ),
              timerWidget: TableTimerWidget(
                duration: 30,
                onTimeout: _onTimerTimeout,
                isRunning: _timerRunning,
                isPaused: _timerPaused,
              ),
            ),
          ),
          
          // 2. Feedback Overlay (covers table)
          if (_showFeedback) _buildFeedbackOverlay(context),

          // 3. Top HUD (over table)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: _buildHUD(context, engineState),
            ),
          ),

          // 4. Bottom Controls (Hero Cards + Action Buttons)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: EdgeInsets.only(bottom: context.w(2)), // Extra padding to prevent clipping
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Hero cards
                    HeroCardDisplay(
                      hand: currentScenario.hand,
                      position: _normalizeScenarioPos(currentScenario.position),
                    ),
                    SizedBox(height: context.w(1)),
                    // Action buttons
                    ActionButtonBar(
                      onFold: () => _processAction('fold'),
                      onCall: () => _processAction('call'),
                      onRaise: () => _processAction('raise'),
                      onAllin: () => _processAction('allin'),
                      isEnabled: _isMyTurn,
                      callAmount: _seatBets['BB'] != null
                          ? '${_seatBets['BB']!.toStringAsFixed(1)}BB'
                          : '1BB',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHUD(BuildContext context, OmniSwipeState engineState) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.w(3),
        vertical: context.w(2),
      ),
      child: Row(
        children: [
          // Back button
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Icon(
              Icons.arrow_back_ios,
              color: AppColors.pureWhite,
              size: context.w(5),
            ),
          ),
          SizedBox(width: context.w(2)),
          // Score
          Text(
            '${engineState.score}',
            style: AppTextStyles.heading(color: AppColors.pokerTableChipGold),
          ),
          const Spacer(),
          // Hearts (strikes remaining)
          Row(
            children: List.generate(3, (i) {
              final filled = i < engineState.strikesRemaining;
              return Icon(
                filled ? Icons.favorite : Icons.favorite_border,
                color: filled ? AppColors.pokerTableActionAllin : AppColors.pokerTableFoldGray,
                size: context.w(5),
              );
            }),
          ),
          SizedBox(width: context.w(2)),
          // Combo
          if (engineState.combo > 1)
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: context.w(2),
                vertical: context.w(0.5),
              ),
              decoration: BoxDecoration(
                color: AppColors.pokerTableChipGold.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(context.w(2)),
                border: Border.all(color: AppColors.pokerTableChipGold),
              ),
              child: Text(
                'x${engineState.combo}',
                style: AppTextStyles.bodySmall(color: AppColors.pokerTableChipGold),
              ),
            ),
          SizedBox(width: context.w(2)),
          // Hand count
          Text(
            '${engineState.currentHandIndex + 1}/${engineState.totalHands}',
            style: AppTextStyles.caption(),
          ),
        ],
      ),
    );
  }

  Widget _buildSeat(BuildContext context, int i, Offset centerDir, DeepStackScenario scenario) {
    final equippedUrl = ref.watch(equippedCharacterUrlProvider);
    final pos = _positions[i];
    final normalizedHeroPos = _normalizeScenarioPos(scenario.position);
    final isHeroSeat = pos == normalizedHeroPos;
    
    // Change LJ to MP for display logic only
    final displayPos = pos == 'LJ' ? 'MP' : pos;

    return PlayerSeatWidget(
      position: displayPos,
      seatIndex: i,
      action: _seatActions[pos],
      betAmount: _seatBets[pos],
      isHero: isHeroSeat,
      isCurrentTurn: _isMyTurn && isHeroSeat,
      avatarUrl: isHeroSeat ? equippedUrl : null,
      centerVector: centerDir,
    );
  }

  Widget _buildFeedbackOverlay(BuildContext context) {
    final grade = _lastGrade;
    final scenario = _lastScenario;
    if (grade == null) return const SizedBox.shrink();

    Color bgColor;
    String message;
    switch (grade) {
      case ActionGrade.perfect:
        bgColor = AppColors.pokerTableTimerSafe.withValues(alpha: 0.85);
        message = '굿 플레이!';
        break;
      case ActionGrade.good:
        bgColor = AppColors.pokerTableTimerWarning.withValues(alpha: 0.85);
        message = '괜찮아요';
        break;
      case ActionGrade.blunder:
        bgColor = AppColors.pokerTableTimerDanger.withValues(alpha: 0.85);
        message = '미스!';
        break;
    }

    return Positioned.fill(
      child: Container(
        color: bgColor,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              message,
              style: AppTextStyles.heading(),
            ),
            if (grade == ActionGrade.good && scenario != null) ...[
              SizedBox(height: context.w(4)),
              _buildFreqBars(context, scenario),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFreqBars(BuildContext context, DeepStackScenario scenario) {
    final freqs = [
      ('폴드', scenario.foldFreq, AppColors.pokerTableActionFold),
      ('콜', scenario.callFreq, AppColors.pokerTableActionCall),
      ('레이즈', scenario.raiseFreq, AppColors.pokerTableActionRaise),
      ('올인', scenario.allinFreq, AppColors.pokerTableActionAllin),
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.w(10)),
      child: Column(
        children: freqs.map((f) {
          final label = f.$1;
          final freq = f.$2;
          final color = f.$3;
          return Padding(
            padding: EdgeInsets.symmetric(vertical: context.w(1)),
            child: Row(
              children: [
                SizedBox(
                  width: context.w(12),
                  child: Text(label, style: AppTextStyles.caption()),
                ),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(context.w(1)),
                    child: LinearProgressIndicator(
                      value: freq / 100.0,
                      backgroundColor: AppColors.pokerTableFoldGray.withValues(alpha: 0.3),
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                      minHeight: context.w(3),
                    ),
                  ),
                ),
                SizedBox(width: context.w(2)),
                Text(
                  '$freq%',
                  style: AppTextStyles.caption(),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
