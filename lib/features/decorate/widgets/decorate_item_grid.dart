import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:playing_cards/playing_cards.dart';
import '../../../core/theme/app_colors.dart';
import '../models/decorate_item_model.dart';
import 'character_display_widget.dart';
import '../providers/decorate_provider.dart';
import '../../../providers/user_stats_provider.dart';
import '../../game/utils/card_style_manager.dart';

class DecorateItemGrid extends ConsumerWidget {
  final List<DecorateItem> items;
  final List<String> ownedIds;
  final String? equippedId;
  final String? selectedId;
  final Function(DecorateItem) onSelect;

  const DecorateItemGrid({
    super.key,
    required this.items,
    required this.ownedIds,
    this.equippedId,
    this.selectedId,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (items.isEmpty) {
      return const Center(
        child: Text("아이템이 없습니다.",
            style: TextStyle(color: Colors.white54)),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.75,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final isOwned = ownedIds.contains(item.id);
        final isEquipped = item.id == equippedId;
        final isSelected = item.id == selectedId;

        return _buildItemCard(context, ref, item, isOwned, isEquipped, isSelected)
            .animate()
            .fadeIn(delay: (50 * index).ms)
            .slideY(begin: 0.2, end: 0);
      },
    );
  }

  Widget _buildItemCard(BuildContext context, WidgetRef ref, DecorateItem item,
      bool isOwned, bool isEquipped, bool isSelected) {
    final rarityColor = _rarityColor(item.rarity);

    return GestureDetector(
      onTap: () => onSelect(item),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected 
              ? AppColors.stitchDeepBlue.withOpacity(0.8) 
              : AppColors.darkGray,
          borderRadius: BorderRadius.circular(16),
          border: isSelected
              ? Border.all(color: AppColors.acidYellow, width: 2) // Selection Highlight
              : (isEquipped 
                  ? Border.all(color: AppColors.acidGreen, width: 1.5) // Equipped but not selected
                  : Border.all(color: Colors.white10)),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                      color: AppColors.acidYellow.withOpacity(0.4),
                      blurRadius: 10)
                ]
              : (isEquipped
                  ? [BoxShadow(color: AppColors.acidGreen.withOpacity(0.3), blurRadius: 5)]
                  : []),
        ),
        child: Stack(
          children: [
            // Item content
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: _buildItemVisual(item, isOwned),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                  decoration: const BoxDecoration(
                    color: Colors.black26,
                    borderRadius:
                        BorderRadius.vertical(bottom: Radius.circular(14)),
                  ),
                  child: Column(
                    children: [
                      Text(
                        item.name,
                        style: TextStyle(
                          color: isOwned ? Colors.white : Colors.white38,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (!isOwned)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.monetization_on,
                                  size: 10, color: AppColors.acidYellow),
                              const SizedBox(width: 2),
                              Text(
                                '${item.price}',
                                style: const TextStyle(
                                    color: AppColors.acidYellow, fontSize: 10),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),

            // Lock Overlay
            if (!isOwned)
              Positioned(
                top: 8,
                right: 8,
                child: const Icon(Icons.lock, color: Colors.white38, size: 16),
              ),

            // Equipped Badge
            if (isEquipped)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: AppColors.acidGreen,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, size: 12, color: Colors.black),
                ),
              ),

            // Rarity Indicator
            Positioned(
              top: 8,
              left: 8,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: rarityColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: rarityColor.withOpacity(0.6), blurRadius: 4)
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemVisual(DecorateItem item, bool isOwned) {
    if (item.type == 'character') {
      return Center(
        child: CharacterDisplayWidget(
          characterId: item.id,
          size: 80,
          isLocked: !isOwned,
        ),
      );
    } else if (item.type == 'card_skin') {
      // Use PlayingCardView to preview the skin
      // Show Ace of Spades as preview
      return Center(
        child: AspectRatio(
          aspectRatio: 2.5 / 3.5,
          child: PlayingCardView(
            card: PlayingCard(Suit.spades, CardValue.ace),
            style: const PlayingCardViewStyle(),
            showBack: false, // Show face
            elevation: 4,
          ),
        ),
      );
    }

    // Fallback for other types
    IconData icon;
    Color color;

    switch (item.type) {
      case 'frame':
        icon = Icons.crop_square;
        color = AppColors.neonCyan;
        break;
      case 'card_skin':
        icon = Icons.style;
        color = AppColors.electricBlue;
        break;
      case 'title':
        icon = Icons.stars;
        color = AppColors.acidYellow;
        break;
      default:
        icon = Icons.category;
        color = Colors.grey;
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: color.withOpacity(0.1),
      ),
      child: Center(
        child: Icon(icon, color: isOwned ? color : Colors.grey, size: 40),
      ),
    );
  }

  Color _rarityColor(String rarity) {
    switch (rarity) {
      case 'legendary':
        return AppColors.neonPurple;
      case 'epic':
        return AppColors.neonPink;
      case 'rare':
        return AppColors.neonCyan;
      case 'common':
      default:
        return Colors.grey;
    }
  }

  void _showPurchaseDialog(
      BuildContext context, WidgetRef ref, DecorateItem item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.stitchDeepBlue,
        title: Text("Unlock ${item.name}?",
            style: const TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 100,
              width: 100,
              child: _buildItemVisual(item, true), // Show as if owned in dialog
            ),
            const SizedBox(height: 16),
            Text(
              "Price: ${item.price} Chips",
              style: const TextStyle(color: AppColors.acidYellow, fontSize: 18),
            ),
            const SizedBox(height: 8),
            const Text(
              "Unlock this style to use in game.",
              style: TextStyle(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.acidYellow),
            onPressed: () async {
              Navigator.pop(context); // Close dialog first
              
              final statsNotifier = ref.read(userStatsProvider.notifier);
              final decorateNotifier = ref.read(decorateProvider.notifier);
              
              final success = await decorateNotifier.purchaseItem(item, statsNotifier);
              
              if (context.mounted) {
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("${item.name} unlocked!"),
                      backgroundColor: AppColors.acidGreen,
                    ),
                  );
                } else {
                   ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Not enough chips!"),
                      backgroundColor: AppColors.laserRed,
                    ),
                  );
                }
              }
            },
            child: const Text("Purchase", style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }
}
