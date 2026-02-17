import 'package:flutter/material.dart';

class GtoLeagueBody extends StatelessWidget {
  const GtoLeagueBody({super.key});

  // ─── Colors ─────────────────────────────────────────
  static const _bgDark = Color(0xFF0F0C29);
  static const _bgIndigo = Color(0xFF1E1B4B);
  static const _gold = Color(0xFFFBBF24);
  static const _goldDark = Color(0xFFD97706);
  static const _cyan = Color(0xFF22D3EE);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── 1. Refresh Timer ──
          const SizedBox(height: 12),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.refresh, color: Colors.white54, size: 12),
                  const SizedBox(width: 6),
                  Text(
                    '새로고침: 28초 후 가능',
                    style: TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // ── 2. Title Row ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [Color(0xFFFDE68A), Color(0xFFD97706)],
                      ).createShader(bounds),
                      child: const Text(
                        '9-Max 리그',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '시즌 3 • 라운드 12',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.blue.shade200,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.group, color: Colors.green.shade400, size: 14),
                      const SizedBox(width: 4),
                      const Text(
                        '14,203명 참여중',
                        style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── 3. Tier Icons (Horizontal Scroll) ──
          SizedBox(
            height: 80,
            child: ListView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildTierIcon('🐟', '피쉬', const Color(0xFF60A5FA), false),
                _buildTierIcon('🐴', '당나귀', const Color(0xFFA3E635), true), // ME
                _buildTierIcon('☎️', '콜링', const Color(0xFFF472B6), false),
                _buildTierIcon('🍺', '레귤러', const Color(0xFFFCD34D), false),
                _buildTierIcon('⚙️', '그라인더', const Color(0xFF94A3B8), false),
                _buildTierIcon('🦈', '샤크', const Color(0xFF22D3EE), false),
                _buildTierIcon('🤖', 'GTO', const Color(0xFFC084FC), false),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // ── 4. Promotion Zone Header ──
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF78350F).withOpacity(0.9),
                  Colors.transparent,
                ],
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.arrow_upward, color: _gold, size: 14),
                const SizedBox(width: 6),
                Text(
                  '승급 존 (TOP 7)',
                  style: TextStyle(
                    color: _gold,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ),

          // ── 5. Rank Cards – Promotion Zone ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                _buildPromotionCard(1, 'AAKKQQJJ', '2,450p', isKing: true),
                const SizedBox(height: 8),
                _buildPromotionCard(2, 'RiverRat99', '2,120p'),
                const SizedBox(height: 8),
                _buildPromotionCard(3, 'GTO_Wizard', '1,980p'),
                const SizedBox(height: 8),

                // ── 6. ME Card (Special) ──
                _buildMeCard(4, 'PokerFace_K', '1,850p'),
                const SizedBox(height: 8),

                _buildPromotionCard(5, 'BluffMaster', '1,720p', opacity: 0.9),
                const SizedBox(height: 8),
                _buildPromotionCard(6, 'FoldOrDie', '1,690p', opacity: 0.8),
                const SizedBox(height: 8),
                _buildPromotionCard(7, 'LuckySeven', '1,650p', opacity: 0.8),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // ── 7. Promotion Line Divider ──
          _buildDividerLine('승급 라인', _gold, Icons.arrow_upward),
          const SizedBox(height: 8),

          // ── 8. Safe Zone Cards ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                _buildGlassCard(8, 'JustChilling', '1,500p', opacity: 0.7),
                const SizedBox(height: 8),
                _buildGlassCard(9, 'NoLimitHoldem', '1,480p', opacity: 0.6),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // ── 9. Dots separator ──
          _buildDotsSeparator(Colors.grey),
          const SizedBox(height: 8),

          // ── 10. Pre-demotion card ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildGlassCard(23, 'SafeZoneEnded', '1,100p', opacity: 0.6),
          ),
          const SizedBox(height: 8),

          // ── 11. Demotion Line Divider ──
          _buildDividerLine('강등 라인', Colors.red.shade400, Icons.arrow_downward),
          const SizedBox(height: 8),

          // ── 12. Demotion Zone Cards ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                _buildDemotionCard(24, 'DangerZone', '1,050p'),
                const SizedBox(height: 8),
                _buildDemotionCard(25, 'GoingDown', '1,020p', opacity: 0.9),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // ── 13. Red dots separator ──
          _buildDotsSeparator(Colors.red),
          const SizedBox(height: 8),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildDemotionCard(30, 'ByeBye', '890p', opacity: 0.8),
          ),
          const SizedBox(height: 16),

          // ── 14. Last Updated ──
          Center(
            child: Text(
              '마지막 업데이트: 14:02:35',
              style: TextStyle(color: Colors.white24, fontSize: 10, fontFamily: 'monospace'),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════
  // HELPER WIDGETS
  // ═══════════════════════════════════════════════════

  Widget _buildTierIcon(String emoji, String label, Color color, bool isActive) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: isActive ? 56 : 48,
            height: isActive ? 56 : 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [color.withOpacity(0.8), color.withOpacity(0.4)],
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isActive ? _gold : Colors.white.withOpacity(0.2),
                width: isActive ? 2 : 1,
              ),
              boxShadow: isActive
                  ? [BoxShadow(color: color.withOpacity(0.5), blurRadius: 15, spreadRadius: 2)]
                  : [BoxShadow(color: Colors.black26, blurRadius: 6)],
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Center(child: Text(emoji, style: TextStyle(fontSize: isActive ? 28 : 22))),
                if (isActive)
                  Positioned(
                    top: -8,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: _gold,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text('나', style: TextStyle(color: Colors.black, fontSize: 8, fontWeight: FontWeight.w900)),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: isActive ? 11 : 10,
              color: isActive ? _gold : Colors.white38,
              fontWeight: isActive ? FontWeight.w900 : FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromotionCard(int rank, String name, String points, {bool isKing = false, double opacity = 1.0}) {
    return Opacity(
      opacity: opacity,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFFFACC15).withOpacity(0.15),
              const Color(0xFFFACC15).withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _gold.withOpacity(rank == 1 ? 0.3 : 0.15)),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 32,
              child: Text(
                '$rank',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: rank == 1 ? 20 : 16,
                  fontWeight: FontWeight.w900,
                  fontStyle: FontStyle.italic,
                  color: rank <= 3 ? _gold : Colors.white54,
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Avatar placeholder
            Container(
              width: rank == 1 ? 40 : 36,
              height: rank == 1 ? 40 : 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Colors.indigo.shade300, Colors.purple.shade400],
                ),
                border: Border.all(
                  color: rank == 1 ? _gold : _gold.withOpacity(0.5),
                  width: rank == 1 ? 2 : 1,
                ),
              ),
              child: Center(
                child: Text(name[0], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
              ),
            ),
            if (isKing) ...[
              const SizedBox(width: 2),
            ],
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            name,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: rank == 1 ? FontWeight.bold : FontWeight.w500,
                            ),
                          ),
                          if (isKing) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                              decoration: BoxDecoration(
                                color: _gold,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text('왕', style: TextStyle(color: Colors.black, fontSize: 8, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ],
                      ),
                      Text(
                        points,
                        style: TextStyle(
                          color: rank <= 3 ? _gold : const Color(0xFFFDE68A).withOpacity(0.8),
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  if (rank == 1) ...[
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: 0.95,
                        minHeight: 4,
                        backgroundColor: Colors.white.withOpacity(0.1),
                        valueColor: AlwaysStoppedAnimation<Color>(_gold),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMeCard(int rank, String name, String points) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _cyan, width: 2),
        boxShadow: [
          BoxShadow(color: _cyan.withOpacity(0.3), blurRadius: 10, spreadRadius: 2),
          BoxShadow(color: _cyan.withOpacity(0.15), blurRadius: 20, spreadRadius: 5),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          SizedBox(
            width: 32,
            child: Text(
              '$rank',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                fontStyle: FontStyle.italic,
                color: _cyan,
                shadows: [Shadow(color: _cyan.withOpacity(0.8), blurRadius: 5)],
              ),
            ),
          ),
          const SizedBox(width: 8),
          // ME avatar
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                  ),
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [BoxShadow(color: Colors.black38, blurRadius: 8)],
                ),
                child: const Center(
                  child: Text('P', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
              Positioned(
                top: -4,
                left: -4,
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: _cyan,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text('나', style: TextStyle(color: Colors.white, fontSize: 7, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900),
                    ),
                    Row(
                      children: [
                        Icon(Icons.arrow_upward, color: _cyan.withOpacity(0.8), size: 12),
                        const SizedBox(width: 2),
                        Text(
                          points,
                          style: TextStyle(color: _cyan.withOpacity(0.9), fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(fontSize: 10, color: Colors.white38),
                        children: [
                          const TextSpan(text: '승급까지 '),
                          TextSpan(text: '안전권', style: TextStyle(color: _gold, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    Text('승률: 54%', style: TextStyle(fontSize: 10, color: Colors.white24)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassCard(int rank, String name, String points, {double opacity = 1.0}) {
    return Opacity(
      opacity: opacity,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.07),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 32,
              child: Text(
                '$rank',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white38),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey.shade700,
              ),
              child: Center(
                child: Text(name[0], style: const TextStyle(color: Colors.white54, fontWeight: FontWeight.bold, fontSize: 12)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(name, style: TextStyle(color: Colors.white38, fontSize: 14)),
                  Text(points, style: TextStyle(color: Colors.white30, fontSize: 12, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDemotionCard(int rank, String name, String points, {double opacity = 1.0}) {
    return Opacity(
      opacity: opacity,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFFF87171).withOpacity(0.05),
              const Color(0xFFF87171).withOpacity(0.15),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 32,
              child: Text(
                '$rank',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red.shade300.withOpacity(0.8)),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.red.shade900.withOpacity(0.4),
                border: Border.all(color: Colors.red.shade900.withOpacity(0.5)),
              ),
              child: Center(
                child: Text(name[0], style: TextStyle(color: Colors.white54, fontWeight: FontWeight.bold, fontSize: 12)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(name, style: const TextStyle(color: Colors.white60, fontSize: 14)),
                  Text(points, style: TextStyle(color: Colors.red.shade300, fontSize: 12, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDividerLine(String label, Color color, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.transparent, color, Colors.transparent],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: _bgDark,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withOpacity(0.5)),
              boxShadow: [BoxShadow(color: color.withOpacity(0.3), blurRadius: 10)],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: color, size: 14),
                const SizedBox(width: 4),
                Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDotsSeparator(Color color) {
    return Center(
      child: Opacity(
        opacity: 0.4,
        child: Column(
          children: List.generate(3, (_) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Container(
              width: 4,
              height: 4,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
          )),
        ),
      ),
    );
  }
}
