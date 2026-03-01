import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:playing_cards/playing_cards.dart';
import '../models/question.dart';
import '../../../core/utils/haptic_manager.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import 'npc_speech_bubble.dart';

class ConceptQuestionWidget extends StatefulWidget {
  final ConceptQuestion question;
  final VoidCallback onContinue;

  const ConceptQuestionWidget({
    super.key,
    required this.question,
    required this.onContinue,
  });

  @override
  State<ConceptQuestionWidget> createState() => _ConceptQuestionWidgetState();
}

class _ConceptQuestionWidgetState extends State<ConceptQuestionWidget> {
  // --- hole_cards_deal state ---
  bool _holeCardsFlipped = false;

  // --- best_five_highlight state ---
  bool _bestFiveHighlighted = false;

  @override
  void initState() {
    super.initState();

    if (widget.question.animationKey == 'hole_cards_deal') {
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) setState(() => _holeCardsFlipped = true);
      });
    }

    if (widget.question.animationKey == 'best_five_highlight') {
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) setState(() => _bestFiveHighlighted = true);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final question = widget.question;
    final hasNpc = question.npcDialogue != null;

    // --- Backward compatibility: original layout when no NPC ---
    if (!hasNpc) {
      return _buildOriginalLayout(question);
    }

    // --- NPC-enhanced layout ---
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 1) NPC Speech Bubble
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: NpcSpeechBubble(
                    imagePath: question.npcImageAsset ??
                        'assets/images/characters/char_2.png',
                    dialogue: question.npcDialogue!,
                    isVisible: true,
                  ),
                ),

                const SizedBox(height: 24),

                // 2) Animation area
                _buildAnimationArea(question),

                const SizedBox(height: 24),

                // 3) Core summary text (styled highlight box)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.darkGray,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: Colors.white24, width: 1),
                  ),
                  child: Text(
                    question.instructionText,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.body(color: Colors.white70),
                  ),
                ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2),
              ],
            ),
          ),
        ),

        // 4) Continue button
        _buildContinueButton(),
      ],
    );
  }

  // ===================================================================
  // ORIGINAL LAYOUT — unchanged for backward compatibility
  // ===================================================================
  Widget _buildOriginalLayout(ConceptQuestion question) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 애니메이션 연출 영역 (추후 Rive/Lottie 교체 가능)
                _buildAnimationArea(question),

                const SizedBox(height: 48),

                // 설명 텍스트
                Text(
                  question.instructionText,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.heading(),
                ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2),
              ],
            ),
          ),
        ),

        // 하단 계속하기 버튼
        _buildContinueButton(),
      ],
    );
  }

  // ===================================================================
  // ANIMATION AREA — shared by both layouts
  // ===================================================================
  Widget _buildAnimationArea(ConceptQuestion question) {
    if (question.animationKey == 'shuffle') {
      return const Icon(Icons.style_rounded,
              size: 120, color: Colors.blueAccent)
          .animate(onPlay: (controller) => controller.repeat())
          .shimmer(duration: 1.seconds)
          .shakeX(duration: 500.ms, hz: 4);
    }

    if (question.animationKey == 'two_to_five') {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.rectangle, size: 60, color: Colors.orange)
              .animate()
              .slideY(
                  begin: 1.0,
                  duration: 400.ms,
                  curve: Curves.easeOutBack),
          const SizedBox(width: 8),
          const Icon(Icons.rectangle, size: 60, color: Colors.orange)
              .animate()
              .slideY(
                  begin: 1.0,
                  duration: 450.ms,
                  curve: Curves.easeOutBack),
          const SizedBox(width: 24),
          const Icon(Icons.arrow_forward_rounded,
              color: Colors.white, size: 32),
          const SizedBox(width: 24),
          ...List.generate(
            5,
            (index) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: const Icon(Icons.rectangle_outlined,
                      size: 40, color: Colors.greenAccent)
                  .animate()
                  .scale(
                      delay: (200 + index * 100).ms,
                      curve: Curves.elasticOut),
            ),
          ),
        ],
      );
    }

    // --- NEW: hole_cards_deal ---
    if (question.animationKey == 'hole_cards_deal') {
      return _buildHoleCardsDeal();
    }

    // --- NEW: community_cards_reveal ---
    if (question.animationKey == 'community_cards_reveal') {
      return _buildCommunityCardsReveal();
    }

    // --- NEW: best_five_highlight ---
    if (question.animationKey == 'best_five_highlight') {
      return _buildBestFiveHighlight();
    }

    // --- NEW: face_cards_reveal (Phase 2) ---
    if (question.animationKey == 'face_cards_reveal') {
      final faceCards = [
        PlayingCard(Suit.spades, CardValue.ace),
        PlayingCard(Suit.hearts, CardValue.king),
        PlayingCard(Suit.diamonds, CardValue.queen),
        PlayingCard(Suit.clubs, CardValue.jack),
      ];
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(faceCards.length, (i) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: SizedBox(
              width: 60,
              height: 84,
              child: PlayingCardView(card: faceCards[i]),
            )
                .animate()
                .scale(
                  delay: (i * 200).ms,
                  curve: Curves.easeOutBack,
                ),
          );
        }),
      );
    }

    // --- NEW: number_cards_staircase (Phase 2) ---
    if (question.animationKey == 'number_cards_staircase') {
      final numberValues = [
        CardValue.ten,
        CardValue.nine,
        CardValue.eight,
        CardValue.seven,
        CardValue.six,
        CardValue.five,
        CardValue.four,
        CardValue.three,
        CardValue.two,
      ];
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(numberValues.length, (i) {
            return Padding(
              padding: EdgeInsets.only(top: i * 4.0, left: i == 0 ? 0 : 2),
              child: SizedBox(
                width: 40,
                height: 56,
                child: PlayingCardView(
                  card: PlayingCard(Suit.hearts, numberValues[i]),
                ),
              ).animate().fadeIn(delay: (i * 80).ms),
            );
          }),
        ),
      );
    }

    // Default fallback
    return const Icon(Icons.lightbulb_outline_rounded,
            size: 100, color: Colors.yellow)
        .animate()
        .scale(curve: Curves.elasticOut);
  }

  // ===================================================================
  // hole_cards_deal: 2 cards slide in, flip face-up after 800ms
  // ===================================================================
  Widget _buildHoleCardsDeal() {
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
            child: PlayingCardView(
              card: c,
              showBack: !_holeCardsFlipped,
            ),
          )
              .animate()
              .slideX(begin: 1.0, duration: 400.ms)
              .then()
              .flipH(delay: 800.ms, duration: 400.ms),
        );
      }).toList(),
    );
  }

  // ===================================================================
  // community_cards_reveal: 5 cards, flop-turn-river sequence
  // ===================================================================
  Widget _buildCommunityCardsReveal() {
    final cards = [
      PlayingCard(Suit.hearts, CardValue.ten),
      PlayingCard(Suit.clubs, CardValue.jack),
      PlayingCard(Suit.diamonds, CardValue.queen),
      PlayingCard(Suit.spades, CardValue.three),
      PlayingCard(Suit.hearts, CardValue.seven),
    ];

    // Flip delays: flop (0-2) staggered at 600/700/800ms, turn (3) at 1200ms, river (4) at 1600ms
    final flipDelays = [600, 700, 800, 1200, 1600];

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(cards.length, (i) {
        return Padding(
          padding: const EdgeInsets.all(3),
          child: SizedBox(
            width: 55,
            height: 77,
            child: PlayingCardView(
              card: cards[i],
              showBack: true,
            ),
          ).animate().flipH(
                delay: flipDelays[i].ms,
                duration: 400.ms,
              ),
        );
      }),
    );
  }

  // ===================================================================
  // best_five_highlight: 7 cards, best 5 brighten, 2 dim
  // ===================================================================
  Widget _buildBestFiveHighlight() {
    // 2 hole cards + 5 community cards = 7 total
    final cards = [
      PlayingCard(Suit.spades, CardValue.ace),
      PlayingCard(Suit.hearts, CardValue.king),
      PlayingCard(Suit.hearts, CardValue.ten),
      PlayingCard(Suit.clubs, CardValue.jack),
      PlayingCard(Suit.diamonds, CardValue.queen),
      PlayingCard(Suit.spades, CardValue.three),
      PlayingCard(Suit.hearts, CardValue.seven),
    ];

    // Indices 5,6 (three♠, seven♥) dim out as "not in best 5"
    const dimIndices = {5, 6};

    return Wrap(
      alignment: WrapAlignment.center,
      children: List.generate(cards.length, (i) {
        final isDim = dimIndices.contains(i);
        return Padding(
          padding: const EdgeInsets.all(3),
          child: AnimatedOpacity(
            opacity: _bestFiveHighlighted && isDim ? 0.3 : 1.0,
            duration: const Duration(milliseconds: 500),
            child: SizedBox(
              width: 50,
              height: 70,
              child: PlayingCardView(
                card: cards[i],
                showBack: false,
              ),
            ),
          ),
        );
      }),
    );
  }

  // ===================================================================
  // CONTINUE BUTTON — shared
  // ===================================================================
  Widget _buildContinueButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blueAccent,
          foregroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 8,
        ),
        onPressed: () {
          HapticManager.swipe();
          widget.onContinue();
        },
        child: Text('잘 알겠어요!',
            style: AppTextStyles.button()),
      ),
    ).animate().fadeIn(delay: 1.seconds).scale(curve: Curves.easeOutBack);
  }
}
