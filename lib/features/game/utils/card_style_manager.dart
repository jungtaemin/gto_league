import 'package:flutter/material.dart';
import 'package:playing_cards/playing_cards.dart';
import '../../../data/models/card_skin.dart';

class CardStyleManager {
  static PlayingCardViewStyle getStyleFromSkin(CardSkin skin) {
    return PlayingCardViewStyle(
      cardBackgroundColor: Colors.transparent, // 카드를 투명하게 만들어서 배경이 뒤로 가도록 설정
      cardBackContentBuilder: (context) {
        if (skin.cardBackImagePath != null && skin.cardBackImagePath!.isNotEmpty) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              skin.cardBackImagePath!,
              fit: BoxFit.cover,
            ),
          );
        }
        // 이미지가 없을 때의 기본(현재) 렌더링
        return Container(
          decoration: BoxDecoration(
            color: skin.backBgColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: skin.backPatternColor, width: 2),
            boxShadow: [
              BoxShadow(
                color: skin.backPatternColor.withValues(alpha: 0.5),
                blurRadius: 10,
              )
            ],
          ),
          child: Center(
            child: Icon(skin.previewIcon, color: skin.backPatternColor, size: 40),
          ),
        );
      },
      suitStyles: {
        Suit.spades: _suitStyle("♠", skin.primaryColor),
        Suit.hearts: _suitStyle("♥", skin.secondaryColor),
        Suit.diamonds: _suitStyle("♦", skin.secondaryColor),
        Suit.clubs: _suitStyle("♣", skin.primaryColor),
      },
    );
  }

  static SuitStyle _suitStyle(String symbol, Color color) {
    return SuitStyle(
      builder: (context) => FittedBox(
        fit: BoxFit.fitHeight,
        child: ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: [color, color], // opacity 없이 가장 진하게
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(bounds),
          child: Text(
            symbol,
            style: TextStyle(
              color: Colors.white, // ShaderMask color base
              shadows: [
                Shadow(
                  color: color, // shadow도 가장 진하게
                  blurRadius: 5,
                  offset: const Offset(1, 1),
                ),
                Shadow(
                  color: Colors.black.withOpacity(0.8), // 검은색 그림자를 진하게 추가해 시인성 확보
                  blurRadius: 5,
                  offset: const Offset(1, 1),
                )
              ],
            ),
          ),
        ),
      ),
      style: TextStyle(
        color: color,
        fontWeight: FontWeight.w900,
        fontFamily: 'Roboto', // Ensures crisp rendering for values like 'A', 'K'
        shadows: [
          Shadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 4,
            offset: const Offset(1, 1),
          )
        ],
      ),
    );
  }
}
