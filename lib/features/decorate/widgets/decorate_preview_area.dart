import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:playing_cards/playing_cards.dart';
import '../../../core/theme/app_colors.dart';
import '../../game/utils/card_style_manager.dart';
import '../models/decorate_item_model.dart';
import 'character_display_widget.dart';

class DecoratePreviewArea extends ConsumerWidget {
  final UserEquipped? equipped;
  final List<DecorateItem> allItems;
  final String activeTab; // 'character', 'frame', 'card_skin', 'title'
  final DecorateItem? previewItem;
  final List<String> ownedIds;
  final Function(DecorateItem) onBuy;
  final Function(DecorateItem) onEquip;

  const DecoratePreviewArea({
    super.key,
    required this.equipped,
    required this.allItems,
    required this.activeTab,
    this.previewItem,
    required this.ownedIds,
    required this.onBuy,
    required this.onEquip,
  });

  DecorateItem? _getItem(String? id) {
    if (id == null) return null;
    try {
      return allItems.firstWhere((element) => element.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Logic: If activeTab matches type, use previewItem if available, else equipped
    final character = (activeTab == 'character' && previewItem != null)
        ? previewItem
        : _getItem(equipped?.characterId);
    
    final frame = (activeTab == 'frame' && previewItem != null)
        ? previewItem
        : _getItem(equipped?.frameId);
        
    final title = (activeTab == 'title' && previewItem != null)
        ? previewItem
        : _getItem(equipped?.titleId);

    // Card skin is handled separately in rendering, but logically same
    final cardSkin = (activeTab == 'card_skin' && previewItem != null)
        ? previewItem
        : _getItem(equipped?.cardSkinId);

    return Container(
      height: 320, // Increased height for button
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.stitchDeepBlue,
            AppColors.stitchVoid,
          ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.neonPurple.withOpacity(0.2),
            blurRadius: 20,
            spreadRadius: 0,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background Radial Glow based on active tab
          _buildBackgroundGlow(),

          // Character Silhouette
          Positioned(
            bottom: 60, // Moved up for button
            child: _buildCharacter(character),
          ),

          // Title Badge
          if (title != null)
            Positioned(
              top: 50,
              child: _buildTitle(title)
                  .animate(key: ValueKey(title.id)) // Animate on change
                  .fadeIn(duration: 500.ms)
                  .slideY(begin: -0.5, end: 0, curve: Curves.easeOutBack),
            ),

          // Frame Avatar (top-left)
          Positioned(
            left: 20,
            top: 30,
            child: _buildFrameAvatar(frame, character),
          ),

          // Card Skin Preview (Center-Right or Center)
          if (activeTab == 'card_skin' && cardSkin != null)
             Positioned(
              right: 20,
              bottom: 80,
              child: _buildCardPreview(cardSkin),
            ),

          // Active Tab Label
          Positioned(
            top: 10,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black45,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _getTabColor(activeTab).withOpacity(0.5)),
              ),
              child: Text(
                _tabLabel(activeTab),
                style: TextStyle(
                  color: _getTabColor(activeTab),
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // ACTION BUTTON AREA
          if (previewItem != null)
            Positioned(
              bottom: 20,
              child: _buildActionButton(context, previewItem!),
            ),
        ],
      ),
    );
  }

  Widget _buildBackgroundGlow() {
    Color glowColor = _getTabColor(activeTab);
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 0.8,
            colors: [
              glowColor.withOpacity(0.15),
              Colors.transparent,
            ],
          ),
        ),
      )
      .animate(onPlay: (c) => c.repeat(reverse: true))
      .scale(begin: const Offset(0.9, 0.9), end: const Offset(1.1, 1.1), duration: 2000.ms),
    );
  }

  Color _getTabColor(String tab) {
    switch (tab) {
      case 'character': return AppColors.neonPink;
      case 'frame': return AppColors.neonCyan;
      case 'card_skin': return AppColors.electricBlue;
      case 'title': return AppColors.acidYellow;
      default: return Colors.white;
    }
  }

  String _tabLabel(String tab) {
    switch (tab) {
      case 'character': return '캐릭터 미리보기';
      case 'frame': return '프레임 미리보기';
      case 'card_skin': return '카드 스킨 미리보기';
      case 'title': return '칭호 미리보기';
      default: return '';
    }
  }

  Widget _buildActionButton(BuildContext context, DecorateItem item) {
    bool isOwned = ownedIds.contains(item.id);
    // bool isEquipped... (handled by DecoratePage logic, we just show buttons)
    
    // Check if already equipped? 
    // We can check against equipped IDs but easier to just show "Equipped" state if matched.
    bool isEquipped = false;
    if (activeTab == 'character' && equipped?.characterId == item.id) isEquipped = true;
    if (activeTab == 'frame' && equipped?.frameId == item.id) isEquipped = true;
    if (activeTab == 'title' && equipped?.titleId == item.id) isEquipped = true;
    if (activeTab == 'card_skin' && equipped?.cardSkinId == item.id) isEquipped = true;

    if (isEquipped) {
       return Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: AppColors.acidGreen),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle, color: AppColors.acidGreen),
            SizedBox(width: 8),
            Text("장착 중", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
      );
    }

    if (isOwned) {
      return GestureDetector(
        onTap: () => onEquip(item),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.acidGreen,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(color: AppColors.acidGreen.withOpacity(0.5), blurRadius: 15),
            ],
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("장착하기", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
        ).animate(onPlay: (c) => c.repeat(reverse: true)).shimmer(duration: 2.seconds, delay: 1.seconds),
      );
    } else {
      // Purchase Button
      return GestureDetector(
        onTap: () => onBuy(item),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.acidYellow,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(color: AppColors.acidYellow.withOpacity(0.5), blurRadius: 15),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.lock_open, color: Colors.black, size: 20),
              const SizedBox(width: 8),
              Text("해금하기 (${item.price} 칩)", 
                  style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
        ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(duration: 2.seconds, begin: const Offset(0.95, 0.95), end: const Offset(1.0, 1.0)),
      );
    }
  }

  Widget _buildCardPreview(DecorateItem item) {
    return Container(
      width: 120, // 2.5 * 48
      decoration: BoxDecoration(
        boxShadow: [BoxShadow(color: AppColors.electricBlue.withOpacity(0.3), blurRadius: 20)],
      ),
      child: AspectRatio(
        aspectRatio: 2.5 / 3.5,
        child: PlayingCardView(
            card: PlayingCard(Suit.spades, CardValue.ace),
            style: const PlayingCardViewStyle(),
            showBack: false,
            elevation: 10,
          ),
      ),
    ).animate(key: ValueKey(item.id)).scale(duration: 300.ms, curve: Curves.easeOutBack);
  }

  Widget _buildCharacter(DecorateItem? item) {
    if (item == null) {
      return Opacity(
        opacity: 0.3,
        child: Column(
          children: [
            const Icon(Icons.person, size: 160, color: Colors.white),
            const SizedBox(height: 4),
            Text("캐릭터 미장착",
                style: TextStyle(
                    color: Colors.white.withOpacity(0.3), fontSize: 12)),
          ],
        ),
      );
    }

    final color = _parseColor(item.metadata['color'] as String?);
    
    // If it's Space Marine or known large assets, use CharacterDisplayWidget
    return CharacterDisplayWidget(
      characterId: item.id,
      size: 200, // Large preview
      isLocked: false, // We show full preview even if locked
    ).animate(key: ValueKey(item.id)).fadeIn().scale(duration: 400.ms, curve: Curves.easeOutBack);
  }

  Widget _buildTitle(DecorateItem item) {
    final color = _parseColor(item.metadata['color'] as String?);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.8),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: color ?? AppColors.acidYellow,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
              color: (color ?? AppColors.acidYellow).withOpacity(0.5),
              blurRadius: 15),
        ],
      ),
      child: Text(
        item.name,
        style: TextStyle(
          color: color ?? AppColors.acidYellow,
          fontWeight: FontWeight.bold,
          fontSize: 22,
          shadows: [
            Shadow(
                color: color ?? AppColors.acidYellow, blurRadius: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildFrameAvatar(
      DecorateItem? frame, DecorateItem? character) {
    // Similar to previous implementation but scaled
    // ...
    final charColor = _parseColor(character?.metadata['color'] as String?);
    return SizedBox(
      width: 80,
      height: 80,
      child: Stack(
        alignment: Alignment.center,
        children: [
             Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black,
              border: Border.all(
                  color: (charColor ?? Colors.white24), width: 2),
            ),
            child: ClipOval(
              child: CharacterDisplayWidget(characterId: character?.id ?? 'char_robot', size: 60),
            ),
          ),
          if (frame != null)
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.acidYellow, width: 3),
                 boxShadow: [
                  BoxShadow(color: AppColors.acidYellow.withOpacity(0.4), blurRadius: 8),
                ],
              ),
            ),
        ],
      ),
    ).animate(target: activeTab == 'frame' ? 1 : 0).scale(end: const Offset(1.2, 1.2));
  }

  Color? _parseColor(String? hexStr) {
    if (hexStr == null || hexStr.isEmpty) return null;
    try {
      final hex = hexStr.replaceAll('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    } catch (_) {
      return null;
    }
  }
}
