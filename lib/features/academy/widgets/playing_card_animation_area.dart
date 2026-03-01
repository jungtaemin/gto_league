import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:playing_cards/playing_cards.dart';

class PlayingCardAnimationArea extends StatelessWidget {
  final String animationKey;

  const PlayingCardAnimationArea({super.key, required this.animationKey});

  @override
  Widget build(BuildContext context) {
    if (animationKey == 'hole_cards_view') {
      return _buildHoleCardsView();
    }
    if (animationKey == 'community_cards_view') {
      return _buildCommunityCardsView();
    }
    if (animationKey == 'seven_cards_view') {
      return _buildSevenCardsView();
    }
    // --- NEW P2 ---
    if (animationKey == 'kicker_battle_view') {
      return _buildKickerBattleView();
    }
    if (animationKey == 'ace_dominant_view') {
      return _buildAceDominantView();
    }
    return const SizedBox.shrink();
  }

  Widget _buildHoleCardsView() {
    final cards = [
      PlayingCard(Suit.spades, CardValue.ace),
      PlayingCard(Suit.hearts, CardValue.king),
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: cards.map((c) {
        return Padding(
          padding: const EdgeInsets.all(8),
          child: SizedBox(
            width: 70,
            height: 98,
            child: PlayingCardView(card: c, showBack: false),
          )
          .animate()
          .slideY(begin: -2.0, duration: 400.ms, curve: Curves.easeOutBack)
          .rotate(begin: -0.1, end: 0, delay: 200.ms, duration: 200.ms),
        );
      }).toList(),
    );
  }

  Widget _buildCommunityCardsView() {
    final cards = [
      PlayingCard(Suit.hearts, CardValue.ten),
      PlayingCard(Suit.clubs, CardValue.jack),
      PlayingCard(Suit.diamonds, CardValue.queen),
      PlayingCard(Suit.spades, CardValue.three),
      PlayingCard(Suit.hearts, CardValue.seven),
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(cards.length, (i) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: SizedBox(
            width: 55,
            height: 77,
            child: PlayingCardView(card: cards[i], showBack: false),
          )
          .animate()
          .scale(
            delay: (i * 100).ms, 
            duration: 400.ms, 
            curve: Curves.elasticOut,
            begin: const Offset(0, 0),
            end: const Offset(1, 1)
          ),
        );
      }),
    );
  }

  Widget _buildSevenCardsView() {
    final holeCards = [
      PlayingCard(Suit.spades, CardValue.ace),
      PlayingCard(Suit.hearts, CardValue.king),
    ];
    final communityCards = [
      PlayingCard(Suit.hearts, CardValue.ten),
      PlayingCard(Suit.clubs, CardValue.jack),
      PlayingCard(Suit.diamonds, CardValue.queen),
      PlayingCard(Suit.spades, CardValue.three),
      PlayingCard(Suit.hearts, CardValue.seven),
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Community cards (Top)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(communityCards.length, (i) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: SizedBox(
                width: 35,
                height: 49,
                child: PlayingCardView(card: communityCards[i], showBack: false),
              )
              .animate()
              .scale(
                delay: (i * 100).ms, 
                curve: Curves.elasticOut,
                begin: const Offset(0, 0),
                end: const Offset(1, 1)
              ),
            );
          }),
        ),
        const SizedBox(height: 12), // 높이 축소
        // Hole cards (Bottom, Larger)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(holeCards.length, (i) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: SizedBox(
                width: 55,
                height: 77,
                child: PlayingCardView(card: holeCards[i], showBack: false),
              )
              .animate()
              .slideY(
                begin: 1.0, 
                duration: 600.ms, 
                curve: Curves.easeOutBack,
                delay: (500 + i * 200).ms
              )
              .rotate(
                begin: i == 0 ? -0.1 : 0.1, 
                end: 0, 
                duration: 400.ms, 
                delay: (500 + i * 200).ms
              ),
            );
          }),
        ),
      ],
    );
  }

  // ===================================================================
  // Phase 2: Kicker Battle View (J, 9 vs J, 4)
  // ===================================================================
  Widget _buildKickerBattleView() {
    final myCards = [PlayingCard(Suit.hearts, CardValue.jack), PlayingCard(Suit.spades, CardValue.nine)];
    final oppCards = [PlayingCard(Suit.diamonds, CardValue.jack), PlayingCard(Suit.clubs, CardValue.four)];
    return _build2vs2CardView("나 (J, 9)", myCards, "상대 (J, 4)", oppCards, highlightMySecond: true);
  }

  // ===================================================================
  // Phase 2: Ace Dominant View (A, 2 vs K, Q)
  // ===================================================================
  Widget _buildAceDominantView() {
    final myCards = [PlayingCard(Suit.spades, CardValue.ace), PlayingCard(Suit.hearts, CardValue.two)];
    final oppCards = [PlayingCard(Suit.hearts, CardValue.king), PlayingCard(Suit.diamonds, CardValue.queen)];
    return _build2vs2CardView("나 (A, 2)", myCards, "상대 (K, Q)", oppCards, myFirstScaleBounce: true);
  }

  // ===================================================================
  // Helper for 2 vs 2 Player/Opponent battles
  // ===================================================================
  Widget _build2vs2CardView(String myLabel, List<PlayingCard> myCards, String oppLabel, List<PlayingCard> oppCards, {bool highlightMySecond = false, bool myFirstScaleBounce = false}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 나
            Column(
              children: [
                Text(myLabel, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    SizedBox(width: 45, height: 63, child: PlayingCardView(card: myCards[0], showBack: false))
                      .animate()
                      .slideX(begin: -1.0, duration: 400.ms, curve: Curves.easeIn)
                      .shimmer(delay: myFirstScaleBounce ? 800.ms : 0.ms, color: myFirstScaleBounce ? Colors.amber : null)
                      .scale(delay: myFirstScaleBounce ? 600.ms : 0.ms, end: myFirstScaleBounce ? const Offset(1.3, 1.3) : const Offset(1,1), curve: Curves.elasticOut), 
                    const SizedBox(width: 4),
                    SizedBox(width: 45, height: 63, child: PlayingCardView(card: myCards[1], showBack: false))
                      .animate().slideY(begin: 1.0, duration: 400.ms, delay: 200.ms)
                      .shimmer(delay: highlightMySecond ? 1.seconds : 0.ms, color: highlightMySecond ? Colors.amber : null)
                      .scale(delay: highlightMySecond ? 800.ms : 0.ms, begin: const Offset(1,1), end: highlightMySecond ? const Offset(1.2, 1.2) : const Offset(1,1)), 
                  ],
                ),
              ],
            ),
            const SizedBox(width: 16),
            // VS
            const Text("VS").animate().fadeIn(delay: 600.ms).scale(curve: Curves.elasticOut),
            const SizedBox(width: 16),
            // 상대
            Column(
              children: [
                Text(oppLabel, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    SizedBox(width: 45, height: 63, child: PlayingCardView(card: oppCards[0], showBack: false))
                      .animate().slideX(begin: 1.0, duration: 400.ms, curve: Curves.easeIn),
                    const SizedBox(width: 4),
                    SizedBox(width: 45, height: 63, child: PlayingCardView(card: oppCards[1], showBack: false))
                      .animate().slideY(begin: 1.0, duration: 400.ms, delay: 200.ms),
                  ],
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
