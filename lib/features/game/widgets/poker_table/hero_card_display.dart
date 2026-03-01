import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:playing_cards/playing_cards.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../data/models/poker_hand.dart';
import '../../../../providers/card_skin_provider.dart';
import '../../utils/card_style_manager.dart';

/// Displays the hero's 2 hole cards below the poker table.
///
/// Refactored to match the full "Decorate" custom card style used in Omni Swipe.
class HeroCardDisplay extends ConsumerWidget {
  /// Hand notation string (e.g., 'AKs', '77', 'T9o')
  final String hand;

  /// Hero's position (e.g., 'BU', 'SB', 'BB')
  final String position;

  const HeroCardDisplay({
    super.key,
    required this.hand,
    required this.position,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final skinState = ref.watch(cardSkinProvider);
    final currentSkin = skinState.equippedSkin;
    final cardStyle = CardStyleManager.getStyleFromSkin(currentSkin);

    // 적당한 크기 — 읽기 쉬우면서 테이블을 가리지 않음
    final cardWidth = context.w(70);
    final cardHeight = context.w(95);
    final gap = context.w(6); // 카드 사이 간격

    PokerHand? pokerHand;
    try {
      pokerHand = PokerHand.fromNotation(hand);
    } catch (_) {
      pokerHand = null;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 두 카드를 나란히 배치 (겹치지 않음)
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Left Card
            pokerHand != null
                ? _buildDecoratedCard(
                    _parseCard(pokerHand.rank1, _getSuitChar(pokerHand, 0)),
                    cardStyle,
                    currentSkin,
                    cardWidth,
                    cardHeight,
                  )
                : _buildFaceDownCard(context, cardWidth, cardHeight),
            SizedBox(width: gap),
            // Right Card
            pokerHand != null
                ? _buildDecoratedCard(
                    _parseCard(pokerHand.rank2, _getSuitChar(pokerHand, 1)),
                    cardStyle,
                    currentSkin,
                    cardWidth,
                    cardHeight,
                  )
                : _buildFaceDownCard(context, cardWidth, cardHeight),
          ],
        ),
        SizedBox(height: context.w(4)),
        // Position badge
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: context.w(8),
            vertical: context.w(2),
          ),
          decoration: BoxDecoration(
            color: AppColors.pokerTableWoodBorder.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(context.w(6)),
            border: Border.all(
              color: AppColors.pokerTableChipGold.withValues(alpha: 0.8),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            position == 'LJ' ? 'MP' : position,
            style: TextStyle(
              color: AppColors.pokerTableChipGold,
              fontSize: context.sp(14),
              fontWeight: FontWeight.w900,
              letterSpacing: 1.0,
            ),
          ),
        ),
      ],
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
            // 카드 기본 바탕색
            Container(color: Colors.white),

            // 커스텀 뒷배경
            if (skin.cardFrontImagePath != null && skin.cardFrontImagePath!.isNotEmpty)
              Image.asset(
                skin.cardFrontImagePath!,
                fit: BoxFit.cover,
                cacheWidth: 300,
              ),

            // 카드 커스텀 텍스트 렌더링 (아주 크고 선명하게)
            _buildCustomCardContent(card, width, height),
          ],
        ),
      ),
    ).animate(onPlay: (c) => c.repeat(reverse: true))
     .moveY(begin: -3, end: 3, duration: 2.seconds, curve: Curves.easeInOutSine);
  }

  Widget _buildCustomCardContent(PlayingCard card, double width, double height) {
    final isRed = card.suit == Suit.hearts || card.suit == Suit.diamonds;
    // 너무 밝은 빨강 대신 보기에 편안하고 고급스러운 레드 / 다크 그레이 톤
    final color = isRed ? const Color(0xFFD32F2F) : const Color(0xFF1E1E1E);
    final suitStr = _suitToChar(card.suit);
    final rankStr = _rankToString(card.value);

    // 텍스트 외곽선 및 그림자 효과 (어떤 스킨에서도 잘 보이도록)
    final textShadows = [
      Shadow(
        offset: const Offset(1, 1),
        blurRadius: 1,
        color: Colors.black.withOpacity(0.5),
      ),
    ];

    return Stack(
      children: [
        // 우측 하단: 크고 은은한 심볼 워터마크 (너무 크지 않게 조정)
        Positioned(
          bottom: -height * 0.05,
          right: -width * 0.1,
          child: Text(
            suitStr,
            style: TextStyle(
              fontSize: height * 0.65, // 기존 0.85에서 0.65로 축소
              color: color.withOpacity(0.08),
              height: 1.0,
            ),
          ),
        ),
        // 좌측 상단: 매우 큰 숫자 + 명확한 문양 배치
        Positioned(
          top: height * 0.06, // 위쪽 여백 살짝 조절
          left: width * 0.12, // 왼쪽 여백 살짝 조절
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                rankStr,
                style: TextStyle(
                  fontSize: height * 0.30, // 0.36에서 0.30으로 폰트 크기 약간 축소
                  fontWeight: FontWeight.w900,
                  fontFamily: 'Roboto', 
                  color: color,
                  height: 1.0,
                  letterSpacing: -1.0,
                  shadows: textShadows, // 그림자 추가로 가독성 및 입체감 극대화
                ),
              ),
              const SizedBox(height: 2), // 숫자와 기호 사이 간격 살짝 띄움
              Text(
                suitStr,
                style: TextStyle(
                  fontSize: height * 0.24, // 기호도 0.28에서 0.24로 약간 축소
                  color: color,
                  height: 1.0,
                  shadows: textShadows,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _suitToChar(Suit suit) {
    switch (suit) {
      case Suit.spades: return '♠';
      case Suit.hearts: return '♥';
      case Suit.diamonds: return '♦';
      case Suit.clubs: return '♣';
      default: return '';
    }
  }

  String _rankToString(CardValue value) {
    switch (value) {
      case CardValue.ace: return 'A';
      case CardValue.king: return 'K';
      case CardValue.queen: return 'Q';
      case CardValue.jack: return 'J';
      case CardValue.ten: return '10'; // T 대신 10 으로 표시 (가독성 향상)
      case CardValue.nine: return '9';
      case CardValue.eight: return '8';
      case CardValue.seven: return '7';
      case CardValue.six: return '6';
      case CardValue.five: return '5';
      case CardValue.four: return '4';
      case CardValue.three: return '3';
      case CardValue.two: return '2';
      default: return '';
    }
  }

  Widget _buildFaceDownCard(BuildContext context, double width, double height) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.pokerTableFelt,
        borderRadius: BorderRadius.circular(width * 0.08),
        border: Border.all(color: AppColors.pokerTableWoodBorder, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
    );
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
