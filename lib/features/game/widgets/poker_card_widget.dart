import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:playing_cards/playing_cards.dart';
import '../../../../core/utils/responsive.dart';
import '../../../data/models/card_question.dart';
import '../../../data/models/poker_hand.dart';
import '../../../providers/card_skin_provider.dart';
import '../utils/card_style_manager.dart';
import '../../home/widgets/gto/stitch_colors.dart';

/// Stitch V1 스타일 포커 카드 위젯 (Refactored to use playing_cards)
/// 반응형: 화면 크기에 따라 카드 사이즈 자동 조정
class PokerCardWidget extends ConsumerWidget {
  final CardQuestion question;

  const PokerCardWidget({super.key, required this.question});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pokerHand = PokerHand.fromNotation(question.hand);
    
    // Watch equipped skin from new CardSkinSystem
    final skinState = ref.watch(cardSkinProvider);
    final currentSkin = skinState.equippedSkin;
    final cardStyle = CardStyleManager.getStyleFromSkin(currentSkin);

    // 반응형 사이즈 계산
    final cardWidth = context.w(130);
    final cardHeight = context.w(195); // 1.5 aspect ratio approx
    final stackHeight = context.w(280).clamp(200.0, 350.0);
    final cardOffset = context.w(35);

    return SizedBox.expand(
      child: ColoredBox(
        color: Colors.transparent, // 투명 배경으로 전체 영역 클릭/스와이프 감지
        child: Center(
          child: SizedBox(
            height: stackHeight,
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                // Hit-test용 투명 배경
                const Positioned.fill(
                  child: ColoredBox(color: Colors.transparent),
                ),
                // Left Card
                Positioned(
                  left: cardOffset,
                  child: Transform.rotate(
                    angle: -0.1,
                    child: _buildDecoratedCard(
                      _parseCard(pokerHand.rank1, _getSuitChar(pokerHand, 0)),
                      cardStyle,
                      currentSkin,
                      cardWidth,
                      cardHeight,
                    ),
                  ),
                ),
                // Right Card
                Positioned(
                  right: cardOffset,
                  child: Transform.rotate(
                    angle: 0.1,
                    child: _buildDecoratedCard(
                      _parseCard(pokerHand.rank2, _getSuitChar(pokerHand, 1)),
                      cardStyle,
                      currentSkin,
                      cardWidth,
                      cardHeight,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDecoratedCard(
    PlayingCard card,
    PlayingCardViewStyle style,
    dynamic skin,
    double width,
    double height,
  ) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(width * 0.08),
        boxShadow: [
          // 스킨 전용 기본 아우라
          BoxShadow(
            color: skin.primaryColor.withOpacity(0.6),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 5),
          ),
          // 은은한 후광
          BoxShadow(
            color: skin.secondaryColor.withOpacity(0.3),
            blurRadius: 10,
            spreadRadius: -2,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(width * 0.08),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // 카드 기본 바탕색 (투명 카드의 베이스 컬러)
            Container(color: Colors.white),

            // 커스텀 뒷배경(워터마크) - 투명도 1.0으로 글씨 아래에 배치
            if (skin.cardFrontImagePath != null && skin.cardFrontImagePath!.isNotEmpty)
              Image.asset(
                skin.cardFrontImagePath!,
                fit: BoxFit.cover,
                cacheWidth: 300,
              ),

            // 틴트 효과 및 카드 내용(투명 배경)
            ColorFiltered(
              colorFilter: ColorFilter.mode(
                skin.frontBgColor.withOpacity(0.15),
                BlendMode.multiply,
              ),
              child: PlayingCardView(
                card: card,
                style: style,
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    ).animate(onPlay: (c) => c.repeat(reverse: true))
     .moveY(begin: -3, end: 3, duration: 2.seconds, curve: Curves.easeInOutSine);
  }



  String _getSuitChar(PokerHand hand, int index) {
     final allSuits = ['♠', '♥', '♦', '♣'];
     final rankIndex = _rankToIndex(hand.rank1); 
     
     int suitIdx;
     if (hand.isSuited) {
       suitIdx = rankIndex % 4;
     } else {
       if (index == 0) {
         suitIdx = rankIndex % 4;
       } else {
         suitIdx = (rankIndex + 1) % 4;
       }
     }
     return allSuits[suitIdx];
  }

  int _rankToIndex(String rank) {
    const ranks = ['A', 'K', 'Q', 'J', 'T', '9', '8', '7', '6', '5', '4', '3', '2'];
    final idx = ranks.indexOf(rank);
    return idx >= 0 ? idx : 0;
  }

  PlayingCard _parseCard(String rankStr, String suitStr) {
    return PlayingCard(_parseSuit(suitStr), _parseRank(rankStr));
  }

  Suit _parseSuit(String suitStr) {
    switch (suitStr) {
      case '♠': return Suit.spades;
      case '♥': return Suit.hearts;
      case '♦': return Suit.diamonds;
      case '♣': return Suit.clubs;
      default: return Suit.spades;
    }
  }

  CardValue _parseRank(String rankStr) {
    switch (rankStr) {
      case 'A': return CardValue.ace;
      case 'K': return CardValue.king;
      case 'Q': return CardValue.queen;
      case 'J': return CardValue.jack;
      case 'T': return CardValue.ten;
      case '9': return CardValue.nine;
      case '8': return CardValue.eight;
      case '7': return CardValue.seven;
      case '6': return CardValue.six;
      case '5': return CardValue.five;
      case '4': return CardValue.four;
      case '3': return CardValue.three;
      case '2': return CardValue.two;
      default: return CardValue.two;
    }
  }
}
