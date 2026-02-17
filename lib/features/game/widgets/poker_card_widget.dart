import 'package:flutter/material.dart';
import '../../../data/models/card_question.dart';
import '../../../data/models/poker_hand.dart';

/// Stitch V1 스타일 포커 카드 위젯
/// 실제 카드 모양 (둥근 모서리, 랭크+수트 큰 표시)
class PokerCardWidget extends StatelessWidget {
  final CardQuestion question;

  const PokerCardWidget({super.key, required this.question});

  // ─── Stitch Colors ──────
  static const _accentPurple = Color(0xFF7C3AED);
  static const _accentRed = Color(0xFFEF4444);

  // ─── 수트별 고정 색상 ──────
  static const _redSuit = Color(0xFFDC2626);   // ♥♦ 빨간색
  static const _blackSuit = Color(0xFF1F2937); // ♠♣ 진한 검정 (흰 배경에서 잘 보임)

  @override
  Widget build(BuildContext context) {
    final pokerHand = PokerHand.fromNotation(question.hand);
    final isDefense = question.chartType == 'CALL';
    final suits = _generateSuits(pokerHand);
    final suit1 = suits[0];
    final suit2 = suits[1];

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2D2668), Color(0xFF1E1B4B), Color(0xFF15133A)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.15), width: 1),
        boxShadow: [
          BoxShadow(color: _accentPurple.withOpacity(0.3), blurRadius: 20, spreadRadius: 2),
          const BoxShadow(color: Colors.black38, blurRadius: 12, offset: Offset(0, 6)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // Subtle highlight gradient
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withOpacity(0.05),
                      Colors.transparent,
                      Colors.black.withOpacity(0.1),
                    ],
                  ),
                ),
              ),
            ),

            // Main Content
            Column(
              children: [
                // Top section: Defense alert (if applicable)
                if (isDefense && question.opponentPosition != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: _accentRed.withOpacity(0.8),
                    ),
                    child: Text(
                      '🚨 ${question.opponentPosition} 올인! 방어하라!',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w800),
                    ),
                  ),

                const Spacer(),

                // ── Card Display Area ──
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildPlayingCard(pokerHand.rank1, suit1),
                    const SizedBox(width: 16),
                    _buildPlayingCard(pokerHand.rank2, suit2),
                  ],
                ),

                const SizedBox(height: 20),

                // Hand Name
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: Text(
                    '현재 핸드: ${question.hand}',
                    style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ),

                const SizedBox(height: 8),

                // Stack Info
                Text(
                  '유효 스택: ${question.stackBb.toStringAsFixed(0)}BB',
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),

                if (isDefense && question.opponentPosition != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    '상대방: ${question.opponentPosition} Open',
                    style: const TextStyle(color: Colors.white38, fontSize: 11),
                  ),
                ],

                const Spacer(),

                // Bottom Position Badge
                Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [_accentPurple.withOpacity(0.6), _accentPurple.withOpacity(0.3)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _accentPurple.withOpacity(0.4)),
                  ),
                  child: Text(
                    question.position,
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 실제 트럼프 카드 모양의 미니카드
  Widget _buildPlayingCard(String rank, String suit) {
    final isRed = suit == '♥' || suit == '♦';
    // 핵심 수정: 흰 배경 위에서 항상 잘 보이는 색상 사용
    final suitColor = isRed ? _redSuit : _blackSuit;

    return Container(
      width: 100,
      height: 140,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 10, offset: const Offset(2, 4)),
          BoxShadow(color: _accentPurple.withOpacity(0.2), blurRadius: 15, spreadRadius: 1),
        ],
      ),
      child: Stack(
        children: [
          // Top-left rank + suit
          Positioned(
            top: 8,
            left: 10,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(rank, style: TextStyle(color: suitColor, fontSize: 20, fontWeight: FontWeight.w900, height: 1.0)),
                Text(suit, style: TextStyle(color: suitColor, fontSize: 16)),
              ],
            ),
          ),
          // Center large suit
          Center(
            child: Text(suit, style: TextStyle(color: suitColor.withOpacity(0.85), fontSize: 52)),
          ),
          // Bottom-right rank + suit (inverted)
          Positioned(
            bottom: 8,
            right: 10,
            child: Transform.rotate(
              angle: 3.14159,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(rank, style: TextStyle(color: suitColor, fontSize: 20, fontWeight: FontWeight.w900, height: 1.0)),
                  Text(suit, style: TextStyle(color: suitColor, fontSize: 16)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 핸드 표기법에 따라 고정 수트 매핑 (깜박임 없음, 4가지 수트 전부 사용)
  /// - Suited(s): 같은 수트 → 핸드 첫 글자 기반으로 수트 결정
  /// - Offsuit(o): 다른 수트 → 첫 카드/두번째 카드 다른 계열
  /// - Pair: 다른 수트 (♠♥ 고정)
  List<String> _generateSuits(PokerHand hand) {
    // 4가지 수트 순환 매핑: 핸드 첫 번째 랭크 기준
    final allSuits = ['♠', '♥', '♦', '♣'];
    final rankIndex = _rankToIndex(hand.rank1);

    if (hand.isSuited) {
      // Suited → 두 카드 같은 수트, 랭크에 따라 수트 결정
      final suitIdx = rankIndex % 4;
      return [allSuits[suitIdx], allSuits[suitIdx]];
    } else {
      // Offsuit / Pair → 두 카드 다른 수트, 고정 매핑
      final suit1Idx = rankIndex % 4;
      final suit2Idx = (rankIndex + 1) % 4;
      return [allSuits[suit1Idx], allSuits[suit2Idx]];
    }
  }

  /// 랭크를 인덱스로 변환 (결정적 수트 매핑용)
  int _rankToIndex(String rank) {
    const ranks = ['A', 'K', 'Q', 'J', 'T', '9', '8', '7', '6', '5', '4', '3', '2'];
    final idx = ranks.indexOf(rank);
    return idx >= 0 ? idx : 0;
  }
}
