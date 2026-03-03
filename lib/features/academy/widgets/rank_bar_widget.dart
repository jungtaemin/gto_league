import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class RankBarWidget extends StatelessWidget {
  final List<String>? highlightedRanks;

  const RankBarWidget({super.key, this.highlightedRanks});

  static const _ranks = [
    'A',
    'K',
    'Q',
    'J',
    '10',
    '9',
    '8',
    '7',
    '6',
    '5',
    '4',
    '3',
    '2',
  ];

  @override
  Widget build(BuildContext context) {
    final highlighted = highlightedRanks ?? [];

    return SizedBox(
      height: 40,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: _ranks.map((rank) {
            final isHighlighted = highlighted.contains(rank);
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 1.5),
              child: Container(
                width: 28,
                height: 32,
                decoration: BoxDecoration(
                  color:
                      isHighlighted ? AppColors.acidYellow : AppColors.darkGray,
                  borderRadius: BorderRadius.circular(6),
                ),
                alignment: Alignment.center,
                child: Text(
                  rank,
                  style: AppTextStyles.caption(
                    color: isHighlighted ? AppColors.pureBlack : Colors.white70,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
