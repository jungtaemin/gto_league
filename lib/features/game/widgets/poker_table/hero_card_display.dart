import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:playing_cards/playing_cards.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../data/models/poker_hand.dart';
import '../../../../providers/card_skin_provider.dart';
import '../../utils/card_style_manager.dart';

/// Displays the hero's 2 hole cards below the poker table.
///
/// Shows 2 cards side by side with slight rotation and a position badge.
/// Uses the existing playing_cards package + CardSkin system.
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

    final cardWidth = context.percentW(16);
    final cardHeight = context.percentW(24);
    final overlap = context.percentW(3);

    PokerHand? pokerHand;
    try {
      pokerHand = PokerHand.fromNotation(hand);
    } catch (_) {
      pokerHand = null;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Two cards side by side with overlap
        SizedBox(
          width: cardWidth * 2 - overlap,
          height: cardHeight,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Left card (rotated -5°)
              Positioned(
                left: 0,
                child: Transform.rotate(
                  angle: -0.087,
                  child: pokerHand != null
                      ? _buildCard(
                          context,
                          _parseCard(pokerHand.rank1, _getSuitChar(pokerHand, 0)),
                          cardStyle,
                          currentSkin,
                          cardWidth,
                          cardHeight,
                        )
                      : _buildFaceDownCard(context, cardWidth, cardHeight),
                ),
              ),
              // Right card (rotated +5°)
              Positioned(
                right: 0,
                child: Transform.rotate(
                  angle: 0.087,
                  child: pokerHand != null
                      ? _buildCard(
                          context,
                          _parseCard(pokerHand.rank2, _getSuitChar(pokerHand, 1)),
                          cardStyle,
                          currentSkin,
                          cardWidth,
                          cardHeight,
                        )
                      : _buildFaceDownCard(context, cardWidth, cardHeight),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: context.w(2)),
        // Position badge
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: context.w(3),
            vertical: context.w(1),
          ),
          decoration: BoxDecoration(
            color: AppColors.pokerTableWoodBorder.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(context.w(2)),
            border: Border.all(
              color: AppColors.pokerTableChipGold.withValues(alpha: 0.6),
            ),
          ),
          child: Text(
            position == 'LJ' ? 'MP' : position,
            style: TextStyle(
              color: AppColors.pokerTableChipGold,
              fontSize: context.sp(12),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCard(
    BuildContext context,
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
          BoxShadow(
            color: AppColors.pokerTableBg.withValues(alpha: 0.8),
            blurRadius: 8,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(width * 0.08),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Container(color: Colors.white),
            if (skin.cardFrontImagePath != null &&
                skin.cardFrontImagePath!.isNotEmpty)
              Image.asset(
                skin.cardFrontImagePath!,
                fit: BoxFit.cover,
                cacheWidth: 300,
              ),
            ColorFiltered(
              colorFilter: ColorFilter.mode(
                skin.frontBgColor.withValues(alpha: 0.15),
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
    );
  }

  Widget _buildFaceDownCard(BuildContext context, double width, double height) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.pokerTableFelt,
        borderRadius: BorderRadius.circular(width * 0.08),
        border: Border.all(color: AppColors.pokerTableWoodBorder),
      ),
    );
  }

  String _getSuitChar(PokerHand hand, int index) {
    const allSuits = ['♠', '♥', '♦', '♣'];
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
