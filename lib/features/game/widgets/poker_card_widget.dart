import 'package:flutter/material.dart';
import '../../../../core/utils/responsive.dart';
import '../../../data/models/card_question.dart';
import '../../../data/models/poker_hand.dart';
import '../../home/widgets/gto/stitch_colors.dart';

/// Stitch V1 스타일 포커 카드 위젯
/// 반응형: 화면 크기에 따라 카드 사이즈 자동 조정
class PokerCardWidget extends StatelessWidget {
  final CardQuestion question;

  const PokerCardWidget({super.key, required this.question});

  // ─── 수트별 고정 색상 ──────
  static const _redSuit = Color(0xFFDC2626);   // ♥♦ 빨간색
  static const _blackSuit = Color(0xFF1F2937); // ♠♣ 진한 검정

  @override
  Widget build(BuildContext context) {
    final pokerHand = PokerHand.fromNotation(question.hand);
    final suits = _generateSuits(pokerHand);
    
    // 반응형 사이즈 계산 (context.w 기반)
    // 기존 400px 기준 로직을 responsive.dart (375px 기준) 로 변환
    // 카드 크기 비율 유지
    final cardWidth = context.w(130);
    final cardHeight = context.w(195); // 1.5 aspect ratio approx
    final stackHeight = context.w(280).clamp(200.0, 350.0);
    final cardOffset = context.w(35);
    
    // 폰트 스케일링
    final rankSize = context.sp(28);
    final suitSize = context.sp(20);
    final bigSuitSize = context.sp(70);

    return Center(
      child: SizedBox(
        height: stackHeight,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            // Hit-test용 투명 배경 (두 카드 사이 빈 공간에서도 스와이프 가능하게)
            const Positioned.fill(
              child: ColoredBox(color: Colors.transparent),
            ),
            // Left Card (Rotated -6 deg)
            Positioned(
              left: cardOffset,
              child: Transform.rotate(
                angle: -0.1,
                child: _buildLargeCard(context, pokerHand.rank1, suits[0], cardWidth, cardHeight, rankSize, suitSize, bigSuitSize),
              ),
            ),
            // Right Card (Rotated +6 deg)
            Positioned(
              right: cardOffset,
              child: Transform.rotate(
                angle: 0.1,
                child: _buildLargeCard(context, pokerHand.rank2, suits[1], cardWidth, cardHeight, rankSize, suitSize, bigSuitSize),
              ),
            ),

            // Hand Info Badge (Floating below)
            Positioned(
              bottom: -context.h(30),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: context.w(20), vertical: context.h(6)),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(context.r(30)),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("현재 핸드:", style: TextStyle(color: StitchColors.slate300, fontSize: context.sp(11), fontWeight: FontWeight.bold)),
                    SizedBox(width: context.w(6)),
                    Text(question.hand, style: TextStyle(
                      fontFamily: 'Black Han Sans', color: Colors.white, fontSize: context.sp(16), letterSpacing: 1.0,
                    )),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLargeCard(BuildContext context, String rank, String suit, double cardWidth, double cardHeight, double rankSize, double suitSize, double bigSuitSize) {
    final isRed = suit == '♥' || suit == '♦';
    final suitColor = isRed ? _redSuit : _blackSuit;
    
    return Container(
      width: cardWidth,
      height: cardHeight,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(context.r(14)),
        boxShadow: [
          const BoxShadow(color: Colors.black26, blurRadius: 15, offset: Offset(0, 10)),
          BoxShadow(color: Colors.white.withOpacity(0.5), blurRadius: 0, spreadRadius: 0, offset: const Offset(0, 0)),
        ],
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.95),
            Colors.white.withOpacity(0.8),
            Colors.white.withOpacity(0.9),
          ],
        ),
      ),
      child: Stack(
        children: [
          // Gloss Shine
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(context.r(14)),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(0.8),
                    Colors.transparent,
                    Colors.white.withOpacity(0.2),
                  ],
                  stops: const [0.0, 0.4, 1.0],
                ),
              ),
            ),
          ),
          
          // Top Left
          Positioned(
            top: context.h(10), left: context.w(10),
            child: Column(
              children: [
                Text(rank, style: TextStyle(color: suitColor, fontSize: rankSize, fontFamily: 'Black Han Sans', height: 1.0)),
                Text(suit, style: TextStyle(color: suitColor, fontSize: suitSize)),
              ],
            ),
          ),
          
          // Center Big Suit
          Center(
            child: Text(suit, style: TextStyle(color: suitColor.withOpacity(0.9), fontSize: bigSuitSize)),
          ),
          
          // Bottom Right (Inverted)
          Positioned(
            bottom: context.h(10), right: context.w(10),
            child: Transform.rotate(
              angle: 3.14159,
              child: Column(
                children: [
                  Text(rank, style: TextStyle(color: suitColor, fontSize: rankSize, fontFamily: 'Black Han Sans', height: 1.0)),
                  Text(suit, style: TextStyle(color: suitColor, fontSize: suitSize)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 핸드 표기법에 따라 고정 수트 매핑
  List<String> _generateSuits(PokerHand hand) {
    final allSuits = ['♠', '♥', '♦', '♣'];
    final rankIndex = _rankToIndex(hand.rank1);

    if (hand.isSuited) {
      final suitIdx = rankIndex % 4;
      return [allSuits[suitIdx], allSuits[suitIdx]];
    } else {
      final suit1Idx = rankIndex % 4;
      final suit2Idx = (rankIndex + 1) % 4;
      return [allSuits[suit1Idx], allSuits[suit2Idx]];
    }
  }

  int _rankToIndex(String rank) {
    const ranks = ['A', 'K', 'Q', 'J', 'T', '9', '8', '7', '6', '5', '4', '3', '2'];
    final idx = ranks.indexOf(rank);
    return idx >= 0 ? idx : 0;
  }
}
