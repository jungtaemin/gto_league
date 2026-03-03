import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:playing_cards/playing_cards.dart';
import 'package:video_player/video_player.dart';
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

  // --- video player state ---
  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;

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

    if (widget.question.videoAsset != null) {
      _videoController = VideoPlayerController.asset(widget.question.videoAsset!)
        ..initialize().then((_) {
          if (mounted) {
            setState(() {
              _isVideoInitialized = true;
            });
            _videoController!.setLooping(false);
            _videoController!.play();
          }
        });
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
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
                        'assets/images/characters/char_2.webp',
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

                const SizedBox(height: 24), // 기존 48에서 24로 줄임 (오버플로우 방지)

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
    if (question.videoAsset != null) {
      if (_isVideoInitialized && _videoController != null) {
        return ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.45, // 기존 0.55에서 0.45로 줄여서 확실히 오버플로우 방지
          ),
          child: AspectRatio(
            aspectRatio: _videoController!.value.aspectRatio,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.acidYellow.withOpacity(0.5), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.acidYellow.withOpacity(0.3),
                    blurRadius: 15,
                    spreadRadius: 2,
                  )
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: VideoPlayer(_videoController!),
              ),
            ),
          ),
        ).animate().fadeIn(duration: 500.ms).scale(begin: const Offset(0.9, 0.9));
      } else {
        return const SizedBox(
          height: 200,
          child: Center(
            child: CircularProgressIndicator(color: AppColors.acidYellow),
          ),
        );
      }
    }

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

    // --- NEW: intro_shuffle_epic ---
    if (question.animationKey == 'intro_shuffle_epic') {
      return _buildIntroShuffleEpic();
    }

    // --- NEW: intro_seven_cards_epic ---
    if (question.animationKey == 'intro_seven_cards_epic') {
      return _buildIntroSevenCardsEpic();
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

    // --- NEW P2: kicker_explain_view (무승부 설명) ---
    if (question.animationKey == 'kicker_explain_view') {
      final myCards = [PlayingCard(Suit.spades, CardValue.ace), PlayingCard(Suit.hearts, CardValue.two)];
      final oppCards = [PlayingCard(Suit.diamonds, CardValue.ace), PlayingCard(Suit.clubs, CardValue.king)];
      
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 나 (A, 2)
              Column(
                children: [
                  const Text("나 (A, 2)", style: TextStyle(color: Colors.white, fontSize: 14)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      SizedBox(width: 50, height: 70, child: PlayingCardView(card: myCards[0]))
                          .animate().slideX(begin: 1.0, duration: 400.ms, curve: Curves.easeIn)
                          .shakeX(delay: 500.ms, hz: 4), // A 부딪힘
                      const SizedBox(width: 4),
                      SizedBox(width: 50, height: 70, child: PlayingCardView(card: myCards[1]))
                          .animate().scale(delay: 1.2.seconds, curve: Curves.elasticOut), // 2 부각
                    ],
                  ),
                ],
              ),
              const SizedBox(width: 20),
              // VS
              const Text("VS").animate().scale(delay: 400.ms, duration: 200.ms),
              const SizedBox(width: 20),
              // 상대 (A, K)
              Column(
                children: [
                  const Text("상대 (A, K)", style: TextStyle(color: Colors.white, fontSize: 14)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      SizedBox(width: 50, height: 70, child: PlayingCardView(card: oppCards[0]))
                          .animate().slideX(begin: -1.0, duration: 400.ms, curve: Curves.easeIn)
                          .shakeX(delay: 500.ms, hz: 4), // A 부딪힘
                      const SizedBox(width: 4),
                      SizedBox(width: 50, height: 70, child: PlayingCardView(card: oppCards[1]))
                          .animate().scale(delay: 1.2.seconds, curve: Curves.elasticOut)
                          .shimmer(delay: 1.5.seconds, color: Colors.amber), // K 승리 부각
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      );
    }

    // --- NEW: Single Giant Cards for A, K, Q, J ---
    if (['single_card_A', 'single_card_K', 'single_card_Q', 'single_card_J'].contains(question.animationKey)) {
      CardValue value;
      Suit suit;
      switch (question.animationKey) {
        case 'single_card_A': value = CardValue.ace; suit = Suit.spades; break;
        case 'single_card_K': value = CardValue.king; suit = Suit.hearts; break;
        case 'single_card_Q': value = CardValue.queen; suit = Suit.diamonds; break;
        case 'single_card_J': value = CardValue.jack; suit = Suit.clubs; break;
        default: value = CardValue.ace; suit = Suit.spades;
      }
      return Center(
        child: SizedBox(
          width: 140, // 기존 카드들(60~70)보다 훨씬 큰 임팩트용 사이즈
          height: 196,
          child: PlayingCardView(
            card: PlayingCard(suit, value),
            showBack: false,
          ),
        )
        .animate()
        .scale(
          begin: const Offset(0.3, 0.3),
          end: const Offset(1.0, 1.0),
          curve: Curves.elasticOut,
          duration: 800.ms,
        )
        .shimmer(delay: 800.ms, duration: 1.seconds)
        .shake(delay: 1.8.seconds, hz: 3, curve: Curves.easeInOut),
      );
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
      
      // 화면 너비를 고려해 카드가 조금씩 겹치면서 아래로 내려가는 진정한 계단식 연출
      return Container(
        height: 180, // 계단이 내려갈 충분한 세로 공간 확보
        alignment: Alignment.topCenter,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(numberValues.length, (i) {
                return Transform.translate(
                  offset: Offset(i == 0 ? 0 : -10.0 * i, i * 8.0),
                  child: SizedBox(
                    width: 50,
                    height: 70,
                    child: PlayingCardView(
                      card: PlayingCard(Suit.hearts, numberValues[i]),
                      showBack: false,
                      elevation: 4.0, // 겹칠 때 입체감 부여
                    ),
                  )
                  .animate()
                  .slideY(
                    begin: -1.0, 
                    end: 0, 
                    curve: Curves.bounceOut, 
                    duration: 600.ms, 
                    delay: (i * 150).ms // 하나씩 순차적으로 떨어짐
                  )
                  .fadeIn(duration: 300.ms, delay: (i * 150).ms),
                );
              }),
            ),
          ),
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
  // intro_shuffle_epic: Epic intro shuffle (Riffle Shuffle)
  // ===================================================================
  Widget _buildIntroShuffleEpic() {
    // 딜러 셔플(Riffle Shuffle) 연출용 10장 데크
    final leftDeck = [
      PlayingCard(Suit.spades, CardValue.ace),
      PlayingCard(Suit.hearts, CardValue.nine),
      PlayingCard(Suit.diamonds, CardValue.seven),
      PlayingCard(Suit.clubs, CardValue.ten),
      PlayingCard(Suit.hearts, CardValue.king),
    ];
    final rightDeck = [
      PlayingCard(Suit.hearts, CardValue.jack),
      PlayingCard(Suit.spades, CardValue.eight),
      PlayingCard(Suit.clubs, CardValue.three),
      PlayingCard(Suit.diamonds, CardValue.queen),
      PlayingCard(Suit.spades, CardValue.ten),
    ];

    return SizedBox(
      height: 160,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background glow
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.amber.withValues(alpha: 0.2),
                  blurRadius: 30,
                  spreadRadius: 10,
                )
              ],
            ),
          ).animate(onPlay: (controller) => controller.repeat(reverse: true))
           .scale(begin: const Offset(0.9, 0.9), end: const Offset(1.1, 1.1), duration: 2.seconds),
           
          // Left Deck (가장자리에서 중앙으로 슬라이드)
          ...List.generate(leftDeck.length, (i) {
            return Positioned(
              child: SizedBox(
                width: 50,
                height: 70,
                child: PlayingCardView(card: leftDeck[i], showBack: true),
              )
              .animate(onPlay: (controller) => controller.repeat(reverse: true))
              // 시작: 완쪽 바깥에 살짝 기울어진 뭉치
              .slideX(
                begin: -2.0, 
                end: 0,
                duration: 400.ms, 
                delay: (i * 80).ms, // 한 장씩 드르륵 겹치며 진입
                curve: Curves.easeInQuint
              )
              .rotate(
                begin: -0.2,
                end: 0,
                duration: 400.ms,
                delay: (i * 80).ms,
              )
              // 중앙 병합 후 잠깐 대기
              .then(delay: 500.ms)
              // 다시 스쿼시 & 스트레치로 섞이는 느낌
              .scale(
                begin: const Offset(1, 1),
                end: const Offset(0.8, 1.1),
                duration: 200.ms
              )
              // 끝: 사라짐
              .fadeOut(duration: 200.ms),
            );
          }),

          // Right Deck (반대쪽 가장자리에서 중앙으로 슬라이드)
          ...List.generate(rightDeck.length, (i) {
            return Positioned(
              child: SizedBox(
                width: 50,
                height: 70,
                child: PlayingCardView(card: rightDeck[i], showBack: true),
              )
              .animate(onPlay: (controller) => controller.repeat(reverse: true))
              // 시작: 오른쪽 바깥에 살짝 기울어진 뭉치
              .slideX(
                begin: 2.0, 
                end: 0,
                duration: 400.ms, 
                // 왼쪽 패와 교차(인터리빙) 되도록 타이밍 살짝 어긋나게
                delay: (i * 80 + 40).ms, 
                curve: Curves.easeInQuint
              )
              .rotate(
                begin: 0.2,
                end: 0,
                duration: 400.ms,
                delay: (i * 80 + 40).ms,
              )
              // 중앙 병합 후 잠깐 대기 (마지막 카드 끝나는 타이밍 맞춤)
              .then(delay: (500 - 40).ms)
              // 다시 스쿼시 & 스트레치로 섞이는 느낌
              .scale(
                begin: const Offset(1, 1),
                end: const Offset(0.8, 1.1),
                duration: 200.ms
              )
              // 끝: 사라짐
              .fadeOut(duration: 200.ms),
            );
          }),
        ],
      ),
    );
  }

  // ===================================================================
  // intro_seven_cards_epic: 2 hole cards + 5 community cards explosion
  // ===================================================================
  Widget _buildIntroSevenCardsEpic() {
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
                width: 45,
                height: 63,
                child: PlayingCardView(card: communityCards[i], showBack: false),
              )
              .animate()
              .scale(
                delay: (800 + i * 150).ms, 
                curve: Curves.elasticOut,
                begin: const Offset(0, 0),
                end: const Offset(1, 1)
              )
              .shimmer(delay: 2000.ms, duration: 1.seconds),
            );
          }),
        ),
        const SizedBox(height: 24),
        // Hole cards (Bottom, Larger)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(holeCards.length, (i) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: SizedBox(
                width: 70,
                height: 98,
                child: PlayingCardView(card: holeCards[i], showBack: false),
              )
              .animate()
              .slideY(
                begin: 2.0, 
                duration: 600.ms, 
                curve: Curves.easeOutBack,
                delay: (i * 200).ms
              )
              .rotate(
                begin: i == 0 ? -0.1 : 0.1, 
                end: 0, 
                duration: 400.ms, 
                delay: (i * 200).ms
              )
              .shimmer(delay: 2000.ms, duration: 1.seconds),
            );
          }),
        ),
      ],
    );
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
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blueAccent,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 8,
        ),
        onPressed: () {
          HapticManager.swipe();
          widget.onContinue();
        },
        child: Text(widget.question.customButtonText ?? '잘 알겠어요!',
            style: AppTextStyles.button()),
      ),
    ).animate().fadeIn(delay: 1.seconds).scale(curve: Curves.easeOutBack);
  }
}
