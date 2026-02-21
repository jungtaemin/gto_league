import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/bouncing_button.dart';
import '../../../providers/card_skin_provider.dart';
import '../../../providers/user_stats_provider.dart';
import '../../../data/models/card_skin.dart';
import '../../game/utils/card_style_manager.dart';
import 'package:playing_cards/playing_cards.dart';

// -- Preview Area --
class CardSkinPreviewArea extends ConsumerWidget {
  final CardSkin? previewSkin;

  const CardSkinPreviewArea({super.key, this.previewSkin});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(cardSkinProvider);
    final skin = previewSkin ?? state.equippedSkin;

    return Container(
      height: 320,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background Glow
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: skin.primaryColor.withOpacity(0.3),
                  blurRadius: 60,
                  spreadRadius: 20,
                ),
              ],
            ),
          )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scale(
                  begin: const Offset(0.9, 0.9),
                  end: const Offset(1.1, 1.1),
                  duration: 2.seconds),

          // 3D Rotating Card Representation
          _build3DCardPreview(skin),

          // Skin Name & Desc
          Positioned(
            bottom: 20,
            child: Column(
              children: [
                Text(
                  skin.name,
                  style: TextStyle(
                    color: skin.primaryColor,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                          color: skin.primaryColor.withOpacity(0.5),
                          blurRadius: 10)
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  skin.description,
                  style:
                      const TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _build3DCardPreview(CardSkin skin) {
    final cardStyle = CardStyleManager.getStyleFromSkin(skin);

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      transitionBuilder: (child, animation) {
        return ScaleTransition(
          scale: animation,
          child: FadeTransition(
            opacity: animation,
            child: RotationTransition(
              turns:
                  Tween<double>(begin: 0.8, end: 1.0).animate(animation),
              child: child,
            ),
          ),
        );
      },
      child: Transform(
        key: ValueKey(skin.id),
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.001)
          ..rotateX(0.1)
          ..rotateY(-0.1),
        alignment: Alignment.center,
        child: Container(
          width: 140,
          height: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: skin.primaryColor.withOpacity(0.6),
                blurRadius: 30,
                spreadRadius: 5,
                offset: const Offset(0, 5),
              ),
              BoxShadow(
                color: skin.secondaryColor.withOpacity(0.3),
                blurRadius: 15,
                spreadRadius: -2,
                offset: const Offset(0, -3),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Container(color: Colors.white),
                if (skin.cardFrontImagePath != null &&
                    skin.cardFrontImagePath!.isNotEmpty)
                  Image.asset(
                    skin.cardFrontImagePath!,
                    fit: BoxFit.cover,
                    cacheWidth: 300,
                  ),
                ColorFiltered(
                  colorFilter: ColorFilter.mode(
                    skin.frontBgColor.withOpacity(0.15),
                    BlendMode.multiply,
                  ),
                  child: PlayingCardView(
                    card: PlayingCard(Suit.spades, CardValue.ace),
                    style: cardStyle,
                    elevation: 0,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .moveY(
            begin: -5,
            end: 5,
            duration: 2.seconds,
            curve: Curves.easeInOutSine);
  }
}

// -- Grid Area --
class CardSkinGridArea extends ConsumerWidget {
  final CardSkin? previewSkin;
  final Function(CardSkin) onSelect;

  const CardSkinGridArea({
    super.key,
    required this.previewSkin,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(cardSkinProvider);
    final selectedSkin = previewSkin ?? state.equippedSkin;

    return Column(
      children: [
        // Grid
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 0.75,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: allCardSkins.length,
            itemBuilder: (context, index) {
              final skin = allCardSkins[index];
              final isOwned = state.isOwned(skin.id);
              final isEquipped = state.equippedSkinId == skin.id;
              final isSelected = selectedSkin.id == skin.id;

              return BouncingButton(
                onTap: () => onSelect(skin),
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected
                        ? skin.primaryColor.withOpacity(0.2)
                        : Colors.black45,
                    border: Border.all(
                      color: isEquipped
                          ? AppColors.acidGreen
                          : (isSelected
                              ? skin.primaryColor
                              : Colors.white24),
                      width: isEquipped || isSelected ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: Icon(skin.previewIcon,
                            color: isOwned
                                ? skin.primaryColor
                                : Colors.white38,
                            size: 40),
                      ),
                      if (!isOwned)
                        const Positioned(
                          top: 8,
                          right: 8,
                          child: Icon(Icons.lock,
                              color: Colors.white54, size: 16),
                        ),
                      if (isEquipped)
                        const Positioned(
                          top: 8,
                          left: 8,
                          child: Icon(Icons.check_circle,
                              color: AppColors.acidGreen, size: 16),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        // Action Button
        Container(
          padding: const EdgeInsets.all(16),
          color: AppColors.stitchDeepBlue.withOpacity(0.8),
          child: SafeArea(
            top: false,
            child: _buildActionButton(context, ref, state, selectedSkin),
          ),
        )
      ],
    );
  }

  Widget _buildActionButton(BuildContext context, WidgetRef ref,
      CardSkinState state, CardSkin selectedSkin) {
    final isOwned = state.isOwned(selectedSkin.id);
    final isEquipped = state.equippedSkinId == selectedSkin.id;

    if (isEquipped) {
      return SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white24,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12))),
          onPressed: null,
          child: const Text("장착중",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold)),
        ),
      );
    }

    if (isOwned) {
      return BouncingButton(
        onTap: () {
          ref.read(cardSkinProvider.notifier).equipSkin(selectedSkin.id);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text("${selectedSkin.name} 장착!"),
                backgroundColor: AppColors.acidGreen),
          );
        },
        child: Container(
          width: double.infinity,
          height: 50,
          decoration: BoxDecoration(
            color: AppColors.acidYellow,
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: const Text("장착하기",
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold)),
        ),
      );
    }

    return BouncingButton(
      onTap: () => _buySkin(context, ref, selectedSkin),
      child: Container(
        width: double.infinity,
        height: 50,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
              colors: [Colors.purpleAccent, Colors.deepPurple]),
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.monetization_on,
                color: AppColors.acidYellow, size: 20),
            const SizedBox(width: 8),
            Text("${selectedSkin.price} 칩 구매",
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Future<void> _buySkin(
      BuildContext context, WidgetRef ref, CardSkin skin) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.stitchDeepBlue,
        title:
            const Text("구매 확인", style: TextStyle(color: Colors.white)),
        content: Text("${skin.name}을(를) ${skin.price} 칩에 구매하시겠습니까?",
            style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("취소",
                style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.acidYellow),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("구매",
                style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await ref
          .read(userStatsProvider.notifier)
          .consumeChips(skin.price);
      if (success) {
        await ref.read(cardSkinProvider.notifier).unlockSkin(skin.id);
        if (context.mounted) {
          showDialog(
            context: context,
            barrierColor: Colors.black87,
            builder: (ctx) => Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.star_rounded,
                          color: AppColors.acidYellow, size: 80)
                      .animate(onPlay: (c) => c.repeat())
                      .scale(
                          begin: const Offset(1, 1),
                          end: const Offset(1.5, 1.5),
                          duration: 400.ms,
                          curve: Curves.easeInOut)
                      .fadeOut(duration: 400.ms),
                  const SizedBox(height: 20),
                  Text("${skin.name} 획득!",
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Black Han Sans'))
                      .animate()
                      .slideY(
                          begin: 1.0,
                          end: 0.0,
                          curve: Curves.easeOutBack,
                          duration: 600.ms)
                      .fadeIn(),
                ],
              ),
            ),
          );

          Future.delayed(const Duration(seconds: 2), () {
            if (context.mounted) Navigator.pop(context);
          });
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text("칩이 부족합니다!"),
                backgroundColor: AppColors.laserRed),
          );
        }
      }
    }
  }
}
