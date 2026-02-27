import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:playing_cards/playing_cards.dart';
import '../models/question.dart';
import '../../../core/utils/haptic_manager.dart';

class MultipleChoiceQuestionWidget extends StatefulWidget {
  final MultipleChoiceQuestion question;
  final ValueChanged<bool> onSelectAnswer;

  const MultipleChoiceQuestionWidget({
    super.key,
    required this.question,
    required this.onSelectAnswer,
  });

  @override
  State<MultipleChoiceQuestionWidget> createState() => _MultipleChoiceQuestionWidgetState();
}

class _MultipleChoiceQuestionWidgetState extends State<MultipleChoiceQuestionWidget> {
  int? _selectedIndex;
  bool _hasSubmitted = false;

  void _handleOptionTap(int index) {
    if (_hasSubmitted) return;
    
    HapticManager.swipe();
    setState(() {
      _selectedIndex = index;
    });
  }

  void _submit() {
    if (_selectedIndex == null || _hasSubmitted) return;

    setState(() {
      _hasSubmitted = true;
    });

    final isCorrect = _selectedIndex == widget.question.correctOptionIndex;
    widget.onSelectAnswer(isCorrect);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 16),
        // 질문 텍스트
        Text(
          widget.question.instructionText,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ).animate().fadeIn().slideY(begin: -0.2),

        const Spacer(flex: 1),

        // 시각 보조 (카드 표시)
        if (widget.question.displayCardLeft != null)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 140,
                child: PlayingCardView(card: widget.question.displayCardLeft!),
              ).animate().scale(curve: Curves.easeOutBack),
              
              if (widget.question.displayCardRight != null) ...[
                const SizedBox(width: 24),
                const Text('VS', style: TextStyle(color: Colors.amber, fontSize: 32, fontStyle: FontStyle.italic, fontWeight: FontWeight.w900))
                  .animate().scale(delay: 200.ms, curve: Curves.elasticOut),
                const SizedBox(width: 24),
                SizedBox(
                  height: 140,
                  child: PlayingCardView(card: widget.question.displayCardRight!),
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
                  color: isSelected ? Colors.blueAccent.withOpacity(0.2) : Colors.white10,
                  border: Border.all(
                    color: isSelected ? Colors.blueAccent : Colors.transparent,
                    width: isSelected ? 3 : 1,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    widget.question.options[index],
                    style: TextStyle(
                      color: isSelected ? Colors.blueAccent : Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ).animate().slideY(begin: 0.5, delay: (index * 100).ms, curve: Curves.easeOutCubic),
          );
        }),

        const SizedBox(height: 16),
        
        // 제출 버튼
        AnimatedOpacity(
          opacity: _selectedIndex != null ? 1.0 : 0.4,
          duration: const Duration(milliseconds: 200),
          child: SizedBox(
            height: 56,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _selectedIndex != null ? Colors.blueAccent : Colors.grey[800],
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: _selectedIndex != null ? _submit : null,
              child: const Text('확인', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ),
        ),
      ],
    );
  }
}
