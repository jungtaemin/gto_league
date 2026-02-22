import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/widgets/neon_text.dart';
import '../../../core/widgets/neo_brutalist_button.dart';

class FactBombBottomSheet extends StatefulWidget {
  final String factBombMessage;
  final String position;
  final String hand;
  final double evBb;
  final double evDiffBb;
  final VoidCallback onDismiss;

  const FactBombBottomSheet({
    super.key,
    required this.factBombMessage,
    required this.position,
    required this.hand,
    required this.evBb,
    required this.evDiffBb,
    required this.onDismiss,
  });

  @override
  State<FactBombBottomSheet> createState() => _FactBombBottomSheetState();
}

class _FactBombBottomSheetState extends State<FactBombBottomSheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _emojiScale;
  late Animation<Offset> _titleSlide;
  late Animation<double> _titleFade;
  late Animation<Offset> _msgSlide;
  late Animation<double> _msgFade;
  late Animation<double> _infoFade;
  late Animation<double> _btnFade;
  late Animation<Offset> _btnSlide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _emojiScale = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _controller,
          curve: const Interval(0.0, 0.4, curve: Curves.elasticOut)),
    );
    _titleFade = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.1, 0.5)),
    );
    _titleSlide = Tween(begin: const Offset(0, 0.5), end: Offset.zero).animate(
      CurvedAnimation(
          parent: _controller,
          curve: const Interval(0.1, 0.5, curve: Curves.easeOutBack)),
    );
    _msgFade = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.3, 0.7)),
    );
    _msgSlide = Tween(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(
          parent: _controller,
          curve: const Interval(0.3, 0.7, curve: Curves.easeOutBack)),
    );
    _infoFade = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.5, 0.8)),
    );
    _btnFade = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.7, 1.0)),
    );
    _btnSlide = Tween(begin: const Offset(0, 0.5), end: Offset.zero).animate(
      CurvedAnimation(
          parent: _controller,
          curve: const Interval(0.7, 1.0, curve: Curves.easeOutBack)),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Map<String, String> _getEvFeedback() {
    final diff = widget.evDiffBb.abs();
    if (diff < 0.1) {
      return {
        'title': '🤯 GTO도 뇌정지 스팟!',
        'comment':
            '[초박빙] 이 스팟은 프로들도 의견이 갈리는 마지널(Marginal) 영역입니다. 솔버(GTO) 조차 빈도를 섞어서 플레이하는 경우가 많습니다. 틀렸다고 자책하기보다는, 이 포지션에서 해당 핸드가 가지는 기댓값이 0에 가깝다는 점을 인지하는 것만으로도 훌륭합니다.'
      };
    } else if (diff < 0.2) {
      return {
        'title': '🔬 기가 막힌 분석력 부족!',
        'comment':
            '[초미세 릭(Leak)] 방향성은 좋았으나 디테일이 살짝 아쉽습니다. 포지션과 스택 사이즈를 고려할 때, 레인지의 끝자락(Bottom of range)에 걸친 핸드입니다. 장기적인 수익을 위해 콤보 선택을 한 단계 더 엄격하게 깎아보는 연습을 해보세요.'
      };
    } else if (diff < 0.3) {
      return {
        'title': '🤏 ㄲㅂ! 한 끗 차이!',
        'comment':
            '[아까운 실수] 한 끗 차이로 칩을 흘렸습니다. 이런 미세한 -EV 플레이가 누적되면 윈레이트(Win-rate) 하락의 원인이 됩니다. 본인의 타이트/루즈 기준점이 현재 상황과 맞지 않았는지 복기해보세요.'
      };
    } else if (diff < 0.4) {
      return {
        'title': '📉 소량의 빈틈 발견!',
        'comment':
            '[약한 손실] 얼핏 보면 정상적인 플레이 같지만, 수학적으로는 기댓값이 마이너스인 구간입니다. 프리플랍에서 이미 잃고 들어가는 칩의 가치가, 럭키로 이겼을 때의 보상보다 미세하게 더 큽니다.'
      };
    } else if (diff < 0.5) {
      return {
        'title': '🤨 콤보 다이어트 요망!',
        'comment':
            '[레인지 점검] 이 정도의 EV 차이는 본인의 프리플랍 레인지에 구멍이 있다는 것을 의미합니다. 수디드 커넥터 바텀이나 도미네잇 되기 쉬운 오프수트 핸드를 너무 루즈하게 플레이하고 있지 않은지 점검하세요.'
      };
    } else if (diff < 0.6) {
      return {
        'title': '🧐 고민해결 필요구간!',
        'comment':
            '[아쉬운 판단] 확실하게 수익이 나지 않는 핸드입니다. 홀덤은 잃지 않는 것이 수익을 내는 것만큼 중요합니다. 조금 더 안전하고 확실하게 +EV를 가져다주는 핸드 위주로 레인지를 재구성하세요.'
      };
    } else if (diff < 0.7) {
      return {
        'title': '⚠ 삐빅! 경고등 점등!',
        'comment':
            '[레인지 이탈] 정답 레인지에서 구조적으로 벗어났습니다. 해당 포지션에서 플레이해야 하는 기본 차트를 다시 한번 복습해야 합니다. 이 픽은 장기적으로 서서히 뱅크롤을 갉아먹습니다.'
      };
    } else if (diff < 0.8) {
      return {
        'title': '💸 칩이 줄줄 샙니다!',
        'comment':
            '[명백한 실수] 포지션의 불리함이나 스택 사이즈를 충분히 고려하지 않은 플레이입니다. 이 상황에서는 GTO 레인지상 확실한 결정(폴드 혹은 푸시)이 수학적으로 명백히 정해져 있는 구간입니다.'
      };
    } else if (diff < 0.9) {
      return {
        'title': '🤕 서서히 뼈 맞는 중...',
        'comment':
            '[치명타 직전] 뼈아픈 실수입니다. 이 정도의 기댓값 손실은 세션 내내 쌓아온 수익을 갉아먹습니다. 액션을 하기 전 조금만 더 진지하게 고민해보시길 바랍니다.'
      };
    } else if (diff < 1.0) {
      return {
        'title': '🛑 급발진 뇌동매매 주의보!',
        'comment':
            '[멘탈 점검] 완전한 급발진입니다. 감정적인 틸트(Tilt)가 섞여 있을 확률이 높습니다. 홀덤은 감정이 아닌 확률과 수학의 게임임을 다시 명심하세요. 근거 없는 액션은 계좌의 적입니다.'
      };
    } else {
      return {
        'title': '🚨 팝저씨 마인드 검거 완료!',
        'comment':
            '[최악의 결정] 절대 금지! 기도 메타로 게임을 하고 계십니다. 1 BB 이상의 프라플랍 EV 손실은 포커에서 돌이킬 수 없는 치명상입니다. 홀드 카드 두 장에 대한 미련을 당장 버리세요!'
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    final evFeedback = _getEvFeedback();
    final diff = widget.evDiffBb.abs();

    return SafeArea(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1F1F1F), Color(0xFF0F0F0F)],
              ),
              border: Border(
                top: BorderSide(
                    color: const Color(0xFFEF4444).withOpacity(0.5), width: 2),
              ),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(40)),
              boxShadow: const [
                BoxShadow(color: Color(0xFFFF003C), blurRadius: 30)
              ],
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Drag handle
                  Container(
                    width: 48,
                    height: 6,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Header Info (Hand & Position)
                  FadeTransition(
                    opacity: _titleFade,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 6, horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: AppColors.acidGreen.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          NeonText(
                            "포지션: ${widget.position}",
                            color: AppColors.acidGreen,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Text("|",
                                style: const TextStyle(
                                    color: Colors.grey, fontSize: 14)),
                          ),
                          NeonText(
                            "내 핸드: ${widget.hand}",
                            color: AppColors.neonCyan,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Warning Icon
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 60,
                        height: 30,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFEF4444).withOpacity(0.5),
                              blurRadius: 40,
                              spreadRadius: 20,
                            )
                          ],
                        ),
                      ),
                      Transform.scale(
                        scale: _emojiScale.value,
                        child: const Text("🧐", style: TextStyle(fontSize: 50)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Title (dynamic mapped)
                  SlideTransition(
                    position: _titleSlide,
                    child: FadeTransition(
                      opacity: _titleFade,
                      child: NeonText(
                        "고민해결 필요구간!",
                        color: const Color(0xFFEF4444),
                        fontSize: 26,
                        strokeWidth: 1.0,
                        glowIntensity: 2.5,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const SizedBox(height: 24),
                  const SizedBox(height: 24),

                  // EV Loss Box
                  FadeTransition(
                    opacity: _infoFade,
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B).withOpacity(0.8),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: const Color(0xFFEF4444).withOpacity(0.3)),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.5),
                              blurRadius: 10,
                              offset: const Offset(0, 5))
                        ],
                      ),
                      clipBehavior: Clip.hardEdge,
                      child: Column(
                        children: [
                          Container(
                            color: Colors.black.withOpacity(0.4),
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("예상 손실 (EV Loss)",
                                        style: TextStyle(
                                            color: Colors.grey[400],
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 4),
                                    NeonText(
                                      "-${diff.toStringAsFixed(2)} BB",
                                      color: const Color(0xFFEF4444),
                                      fontSize: 32,
                                      fontWeight: FontWeight.w900,
                                      glowIntensity: 1.0,
                                    ),
                                  ],
                                ),
                                Container(
                                    height: 40,
                                    width: 1,
                                    color: Colors.white.withOpacity(0.1)),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    const Text("확정 손실 발생!",
                                        style: TextStyle(
                                            color: Color(0xFFF87171),
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 4),
                                    Text("장기적 수익률 하락",
                                        style: TextStyle(
                                            color: Colors.grey[500],
                                            fontSize: 10)),
                                  ],
                                )
                              ],
                            ),
                          ),
                          Container(
                              height: 6,
                              decoration: const BoxDecoration(
                                  gradient: LinearGradient(colors: [
                                Color(0xFFB91C1C),
                                Color(0xFF7F1D1D)
                              ]))),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Robot Avatar
                  FadeTransition(
                    opacity: _msgFade,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: SizedBox(
                        width: 96,
                        height: 100,
                        child: Stack(
                          alignment: Alignment.bottomCenter,
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                        color: const Color(0xFF3B82F6)
                                            .withOpacity(0.2),
                                        blurRadius: 24,
                                        spreadRadius: 10)
                                  ]),
                            ),
                            Container(
                              width: 48,
                              height: 24,
                              decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(8)),
                                  border: Border.all(
                                      color: const Color(0xFF334155))),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const SizedBox(height: 4),
                                  Container(
                                      width: 4,
                                      height: 4,
                                      decoration: const BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle)),
                                ],
                              ),
                            ),
                            Positioned(
                              bottom: 12,
                              child: Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0F172A),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                      color: const Color(0xFF475569), width: 2),
                                  boxShadow: const [
                                    BoxShadow(
                                        color: Colors.black54,
                                        blurRadius: 10,
                                        offset: Offset(0, 10))
                                  ],
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Transform.rotate(
                                          angle: 0.2,
                                          child: Container(
                                              width: 20,
                                              height: 8,
                                              decoration: BoxDecoration(
                                                  color: const Color(0xFF22D3EE)
                                                      .withOpacity(0.5),
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                  boxShadow: const [
                                                    BoxShadow(
                                                        color:
                                                            Color(0xFF22D3EE),
                                                        blurRadius: 5)
                                                  ])),
                                        ),
                                        const SizedBox(width: 12),
                                        Transform.rotate(
                                          angle: -0.2,
                                          child: Container(
                                              width: 20,
                                              height: 8,
                                              decoration: BoxDecoration(
                                                  color: const Color(0xFF22D3EE)
                                                      .withOpacity(0.5),
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                  boxShadow: const [
                                                    BoxShadow(
                                                        color:
                                                            Color(0xFF22D3EE),
                                                        blurRadius: 5)
                                                  ])),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Container(
                                      width: 32,
                                      height: 8,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          border: const Border(
                                              top: BorderSide(
                                                  color: Color(0xFF22D3EE),
                                                  width: 2))),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Title & Educational Comment (dynamic mapped)
                  SlideTransition(
                    position: _msgSlide,
                    child: FadeTransition(
                      opacity: _msgFade,
                      child: Column(
                        children: [
                          NeonText(
                            evFeedback['title']!,
                            color: const Color(0xFFEF4444),
                            fontSize: 22,
                            strokeWidth: 1.0,
                            glowIntensity: 2.0,
                            fontWeight: FontWeight.w900,
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: AppColors.neonCyan.withOpacity(0.2)),
                            ),
                            child: Text(
                              evFeedback['comment']!,
                              style: AppTextStyles.body(
                                color: AppColors.pureWhite.withOpacity(0.9),
                              ).copyWith(fontSize: 15, height: 1.5),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Dismiss Button
                  SlideTransition(
                    position: _btnSlide,
                    child: FadeTransition(
                      opacity: _btnFade,
                      child: Container(
                        width: double.infinity,
                        height: 64,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [
                            Color(0xFFDC2626),
                            Color(0xFFEF4444)
                          ]),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            const BoxShadow(
                                color: Color(0xFF991B1B), offset: Offset(0, 4)),
                            BoxShadow(
                                color: const Color(0xFFEF4444).withOpacity(0.4),
                                blurRadius: 20,
                                offset: const Offset(0, 10))
                          ],
                        ),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text(
                            "뼈 맞고 다음 패 보기",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w900),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

Future<void> showFactBombModal(
  BuildContext context, {
  required String factBombMessage,
  required String position,
  required String hand,
  required double evBb,
  required double evDiffBb,
  required VoidCallback onDismiss,
}) {
  return showModalBottomSheet(
    context: context,
    isDismissible: false,
    enableDrag: false,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withOpacity(0.6),
    isScrollControlled: true,
    builder: (context) => FactBombBottomSheet(
      factBombMessage: factBombMessage,
      position: position,
      hand: hand,
      evBb: evBb,
      evDiffBb: evDiffBb,
      onDismiss: onDismiss,
    ),
  ).then((_) => onDismiss());
}
