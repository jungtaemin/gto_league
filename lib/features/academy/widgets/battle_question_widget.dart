import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:playing_cards/playing_cards.dart';
import '../models/question.dart';
import '../../../core/utils/haptic_manager.dart';

class BattleQuestionWidget extends StatefulWidget {
  final BattleQuestion question;
  final ValueChanged<bool> onBattleComplete;

  const BattleQuestionWidget({
    super.key,
    required this.question,
    required this.onBattleComplete,
  });

  @override
  State<BattleQuestionWidget> createState() => _BattleQuestionWidgetState();
}

class _BattleQuestionWidgetState extends State<BattleQuestionWidget> {
  bool _isBattleStarted = false;
  bool _showAiCards = false;
  bool _showReversal = false;

  void _startBattle() async {
    if (_isBattleStarted) return;

    HapticManager.snap(); // 카오스/긴장감 부여
    setState(() {
      _isBattleStarted = true;
    });

    // 1. 긴장감 딜레이 (1초)
    await Future.delayed(const Duration(milliseconds: 800));

    // 2. 상대 패 오픈
    setState(() {
      _showAiCards = true;
    });
    HapticManager.snap();

    // 역전승 연출 체크!
    if (widget.question.isUserWinner && widget.question.isReversal) {
      await Future.delayed(const Duration(milliseconds: 500));
      HapticManager.success(); // 강한 햅틱
      setState(() {
        _showReversal = true;
      });
      await Future.delayed(const Duration(milliseconds: 1500)); // 보면서 환호할 시간
    } else {
      // 3. 일반적인 우승 결과 대기 (1.2초)
      await Future.delayed(const Duration(milliseconds: 1200));
    }

    // 4. 콜백 호출
    widget.onBattleComplete(widget.question.isUserWinner);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 역전승 텍스트 오버레이 느낌
        if (_showReversal)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: [Colors.redAccent, Colors.orangeAccent]),
                borderRadius: BorderRadius.circular(16)),
            child: const Text('⚡ 리버 극적 역전승! ⚡',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        fontStyle: FontStyle.italic))
                .animate()
                .scale(
                    begin: const Offset(0.1, 0.1),
                    end: const Offset(1.1, 1.1),
                    duration: 600.ms,
                    curve: Curves.elasticOut)
                .shimmer(duration: 1.seconds, color: Colors.yellow),
          ),

        const SizedBox(height: 16),
        // 지시문 텍스트
        Text(
          widget.question.instructionText,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ).animate().fadeIn().slideY(begin: -0.2),

        const Spacer(flex: 1),

        // AI 영역 (상단)
        Column(
          children: [
            const Text('AI (상대방)',
                style: TextStyle(
                    color: Colors.white54, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: widget.question.aiHoleCards
                  .map((c) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: SizedBox(
                          width: 60,
                          height: 84,
                          child: PlayingCardView(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4.0)),
                              card: c,
                              showBack: !_showAiCards),
                        )
                            .animate(target: _showAiCards ? 1 : 0)
                            .flipH(duration: 400.ms),
                      ))
                  .toList(),
            ),
          ],
        ).animate().slideY(begin: -0.5, curve: Curves.easeOutBack),

        const SizedBox(height: 16),

        // 커뮤니티 카드 존 (중앙)
        if (widget.question.communityCards.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: widget.question.communityCards
                  .map((c) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2.0),
                        child: SizedBox(
                          width: 50,
                          height: 70,
                          child: PlayingCardView(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4.0)),
                              card: c),
                        )
                            .animate()
                            .scale(delay: 200.ms, curve: Curves.easeOutBack),
                      ))
                  .toList(),
            ),
          )
        else
          const Text('VS',
                  style: TextStyle(
                      color: Colors.amber,
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      fontStyle: FontStyle.italic))
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scale(
                  begin: const Offset(1, 1),
                  end: const Offset(1.1, 1.1),
                  duration: 1.seconds),

        const SizedBox(height: 16),

        // 유저 영역 (하단)
        Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: widget.question.userHoleCards
                  .map((c) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: SizedBox(
                          width: 70,
                          height: 98,
                          child: PlayingCardView(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4.0)),
                              card: c),
                        ),
                      ))
                  .toList(),
            ).animate().slideY(begin: 0.5, curve: Curves.easeOutBack),
            const SizedBox(height: 8),
            const Text('내 카드',
                style: TextStyle(
                    color: Colors.greenAccent,
                    fontWeight: FontWeight.w900,
                    fontSize: 18)),
          ],
        ),

        const Spacer(flex: 2),

        // 승부하기 버튼
        AnimatedOpacity(
          opacity: _isBattleStarted ? 0.0 : 1.0,
          duration: const Duration(milliseconds: 300),
          child: SizedBox(
            height: 64,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                elevation: 12,
                shadowColor: Colors.redAccent.withOpacity(0.5),
              ),
              onPressed: _isBattleStarted ? null : _startBattle,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.flash_on_rounded, color: Colors.yellow, size: 32),
                  SizedBox(width: 8),
                  Text('승부하기!',
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: Colors.white)),
                ],
              ),
            ),
          ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(
              begin: const Offset(1.0, 1.0),
              end: const Offset(1.05, 1.05),
              duration: 2.seconds),
        ),
      ],
    );
  }
}
