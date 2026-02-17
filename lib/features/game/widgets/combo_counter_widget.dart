import 'package:flutter/material.dart';

/// 콤보 카운터 (Stitch V1 스타일)
class ComboCounterWidget extends StatelessWidget {
  final int combo;
  final bool isFeverMode;

  const ComboCounterWidget({
    super.key,
    required this.combo,
    required this.isFeverMode,
  });

  static const _gold = Color(0xFFFBBF24);
  static const _pink = Color(0xFFEC4899);
  static const _purple = Color(0xFF7C3AED);

  @override
  Widget build(BuildContext context) {
    if (combo == 0) return const SizedBox.shrink();

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: child),
      child: _buildComboContent(),
    );
  }

  Widget _buildComboContent() {
    if (isFeverMode) return _buildFeverBadge();
    if (combo >= 10) return _buildHighComboBadge();
    if (combo >= 5) return _buildMediumComboBadge();
    return _buildSmallComboBadge();
  }

  Widget _buildSmallComboBadge() {
    return Container(
      key: const ValueKey('small'),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.15)),
      ),
      child: Text(
        '🔥 x$combo',
        style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildMediumComboBadge() {
    return Container(
      key: const ValueKey('medium'),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: _gold.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _gold.withOpacity(0.4), width: 1.5),
        boxShadow: [BoxShadow(color: _gold.withOpacity(0.3), blurRadius: 8)],
      ),
      child: Text(
        '🔥 x$combo',
        style: TextStyle(color: _gold, fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildHighComboBadge() {
    return Container(
      key: const ValueKey('high'),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: _pink.withOpacity(0.15),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _pink.withOpacity(0.4), width: 2),
        boxShadow: [BoxShadow(color: _pink.withOpacity(0.4), blurRadius: 12)],
      ),
      child: Text(
        '🔥 x$combo',
        style: TextStyle(color: _pink, fontSize: 22, fontWeight: FontWeight.w900),
      ),
    );
  }

  Widget _buildFeverBadge() {
    return Container(
      key: const ValueKey('fever'),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [_purple, _pink]),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: _gold, width: 2),
        boxShadow: [
          BoxShadow(color: _purple.withOpacity(0.4), blurRadius: 12),
          BoxShadow(color: _pink.withOpacity(0.3), blurRadius: 8),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('🎰 FEVER!', style: TextStyle(color: _gold, fontSize: 20, fontWeight: FontWeight.w900)),
          Text('x$combo', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
