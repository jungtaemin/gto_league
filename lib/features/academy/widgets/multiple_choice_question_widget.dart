import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:playing_cards/playing_cards.dart';
import '../models/question.dart';
import '../../../core/utils/haptic_manager.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import 'npc_speech_bubble.dart';
import 'playing_card_animation_area.dart';

class MultipleChoiceQuestionWidget extends StatefulWidget {
  final MultipleChoiceQuestion question;
  final ValueChanged<bool> onSelectAnswer;

  const MultipleChoiceQuestionWidget({
    super.key,
    required this.question,
    required this.onSelectAnswer,
  });

  @override
  State<MultipleChoiceQuestionWidget> createState() =>
      _MultipleChoiceQuestionWidgetState();
}

class _MultipleChoiceQuestionWidgetState
    extends State<MultipleChoiceQuestionWidget> {
  int? _selectedIndex;
  bool _hasSubmitted = false;
  String? _currentNpcDialogue;

  @override
  void initState() {
    super.initState();
    _currentNpcDialogue = widget.question.npcDialogue;
  }

  @override
  void didUpdateWidget(covariant MultipleChoiceQuestionWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.question.id != widget.question.id) {
      _selectedIndex = null;
      _hasSubmitted = false;
      _currentNpcDialogue = widget.question.npcDialogue;
    }
  }

  void _handleOptionTap(int index) {
    if (_hasSubmitted) return;

    HapticManager.swipe();
    setState(() {
      _selectedIndex = index;
    });
  }

  void _submit() async {
    if (_selectedIndex == null || _hasSubmitted) return;

    setState(() {
      _hasSubmitted = true;
    });

    final isCorrect = _selectedIndex == widget.question.correctOptionIndex;

    // Update NPC dialogue based on correctness
    if (isCorrect && widget.question.npcFeedbackCorrect != null) {
      setState(() {
        _currentNpcDialogue = widget.question.npcFeedbackCorrect;
      });
    } else if (!isCorrect && widget.question.npcFeedbackWrong != null) {
      setState(() {
        _currentNpcDialogue = widget.question.npcFeedbackWrong;
      });
    }

    if (isCorrect) {
      HapticManager.success();
    } else {
      HapticManager.wrong();
    }

    // 도장(O/X) 찍히는 연출을 감상할 수 있도록 1.2초 대기
    await Future.delayed(const Duration(milliseconds: 1200));

    widget.onSelectAnswer(isCorrect);
  }

  @override
  Widget build(BuildContext context) {
    final bool isCorrect = _selectedIndex == widget.question.correctOptionIndex;

    return Stack(
      alignment: Alignment.center,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // NPC Speech Bubble (if dialogue exists)
            if (_currentNpcDialogue != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: NpcSpeechBubble(
                  imagePath: 'assets/images/characters/char_2.webp',
                  dialogue: _currentNpcDialogue!,
                ),
              ),

            // 질문 텍스트 (NPC 대사가 없을 때만 표시)
            if (_currentNpcDialogue == null)
              Text(
                widget.question.instructionText,
                textAlign: TextAlign.center,
                style: AppTextStyles.headingSmall(),
              ).animate().fadeIn().slideY(begin: -0.2),

            const Spacer(flex: 1),

            // 시각 보조 (카드 표시 또는 애니메이션 뷰)
            if (widget.question.animationKey != null)
              PlayingCardAnimationArea(
                  animationKey: widget.question.animationKey!)
            else if (widget.question.displayCardLeft != null)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 140,
                    child: PlayingCardView(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4.0)),
                        card: widget.question.displayCardLeft!),
                  ).animate().scale(curve: Curves.easeOutBack),
                  if (widget.question.displayCardRight != null) ...[
                    const SizedBox(width: 24),
                    Text('VS',
                            style: AppTextStyles.heading(color: Colors.amber))
                        .animate()
                        .scale(delay: 200.ms, curve: Curves.elasticOut),
                    const SizedBox(width: 24),
                    SizedBox(
                      height: 140,
                      child: PlayingCardView(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4.0)),
                          card: widget.question.displayCardRight!),
                    ).animate().scale(delay: 100.ms, curve: Curves.easeOutBack),
                  ]
                ],
              ),

            const Spacer(flex: 1),

            // 4지선다 리스트
            ...List.generate(widget.question.options.length, (index) {
              final isSelected = _selectedIndex == index;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: InkWell(
                  onTap: () => _handleOptionTap(index),
                  borderRadius: BorderRadius.circular(16),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.blueAccent.withValues(alpha: 0.2)
                          : Colors.white10,
                      border: Border.all(
                        color:
                            isSelected ? Colors.blueAccent : Colors.transparent,
                        width: isSelected ? 3 : 1,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Text(
                        widget.question.options[index],
                        style: AppTextStyles.body(
                          color: isSelected ? Colors.blueAccent : Colors.white,
                        ),
                      ),
                    ),
                  ),
                ).animate().slideY(
                    begin: 0.5,
                    delay: (index * 100).ms,
                    curve: Curves.easeOutCubic),
              );
            }),

            const SizedBox(height: 16),

            // 제출 버튼
            AnimatedOpacity(
              opacity: _selectedIndex != null && !_hasSubmitted ? 1.0 : 0.4,
              duration: const Duration(milliseconds: 200),
              child: SizedBox(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selectedIndex != null
                        ? Colors.blueAccent
                        : Colors.grey[800],
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: (_selectedIndex != null && !_hasSubmitted)
                      ? _submit
                      : null,
                  child: Text('확인',
                      style: AppTextStyles.button(color: AppColors.pureWhite)),
                ),
              ),
            ),
          ],
        ),

        // O/X 정답 도장 연출 (제출 후에만 표시)
        if (_hasSubmitted && _selectedIndex != null)
          Positioned(
            top: MediaQuery.of(context).size.height * 0.25,
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(shape: BoxShape.circle, boxShadow: [
                  BoxShadow(
                    color: (isCorrect ? Colors.greenAccent : Colors.redAccent)
                        .withValues(alpha: 0.4),
                    blurRadius: 40,
                    spreadRadius: 20,
                  )
                ]),
                child: Icon(
                  isCorrect
                      ? Icons.check_circle_outline
                      : Icons.cancel_outlined,
                  size: 200,
                  color: isCorrect ? Colors.greenAccent : Colors.redAccent,
                ),
              )
                  .animate()
                  .scale(
                      begin: const Offset(2.0, 2.0),
                      end: const Offset(1.0, 1.0),
                      duration: 400.ms,
                      curve: Curves.easeOutBack)
                  .fadeIn(duration: 200.ms)
                  .shake(
                      hz: isCorrect ? 0 : 6,
                      curve: Curves.elasticOut), // 틀렸을 때만 심하게 흔들림
            ),
          ),
      ],
    );
  }
}
