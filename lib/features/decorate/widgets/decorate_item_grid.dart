import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../models/decorate_item_model.dart';

class DecorateItemGrid extends StatelessWidget {
  final List<DecorateItem> items;
  final List<String> ownedIds;
  final String? equippedId;
  final Function(String) onEquip;

  const DecorateItemGrid({
    super.key,
    required this.items,
    required this.ownedIds,
    this.equippedId,
    required this.onEquip,
  });

  @override
  Widget build(BuildContext context) {
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
        childAspectRatio: 0.8,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final isOwned = ownedIds.contains(item.id);
        final isEquipped = item.id == equippedId;

        return _buildItemCard(context, item, isOwned, isEquipped)
            .animate()
            .fadeIn(delay: (50 * index).ms)
            .slideY(begin: 0.2, end: 0);
      },
    );
  }

  Widget _buildItemCard(
      BuildContext context, DecorateItem item, bool isOwned, bool isEquipped) {
    final rarityColor = _rarityColor(item.rarity);

    return GestureDetector(
      onTap: () {
        if (isOwned) {
          onEquip(item.id);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text("아직 보유하지 않은 아이템입니다!"),
                backgroundColor: AppColors.laserRed),
          );
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: AppColors.darkGray,
          borderRadius: BorderRadius.circular(16),
          border: isEquipped
              ? Border.all(color: AppColors.acidYellow, width: 2)
              : Border.all(color: Colors.white10),
          boxShadow: isEquipped
              ? [
                  BoxShadow(
                      color: AppColors.acidYellow.withOpacity(0.4),
                      blurRadius: 8)
                ]
              : [],
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
                    child: _buildItemVisual(item),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      vertical: 6, horizontal: 8),
                  decoration: const BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.vertical(
                        bottom: Radius.circular(14)),
                  ),
                  child: Text(
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
                ),
              ],
            ),

            // Lock Overlay for not-owned items
            if (!isOwned)
              Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: Icon(Icons.lock_rounded,
                      color: Colors.white54, size: 28),
                ),
              ),

            // Equipped Badge
            if (isEquipped)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: AppColors.acidYellow,
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
                    BoxShadow(
                        color: rarityColor.withOpacity(0.6), blurRadius: 4)
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemVisual(DecorateItem item) {
    // Use icon-based visual since we don't have real network images
    IconData icon;
    Color color;

    switch (item.type) {
      case 'character':
        icon = Icons.person;
        color = AppColors.neonPink;
        break;
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
        icon = Icons.help;
        color = Colors.grey;
    }

    // Try to parse color from metadata
    final metaColor = _parseColor(item.metadata['color'] as String?);
    if (metaColor != null) color = metaColor;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: color.withOpacity(0.1),
      ),
      child: Center(
        child: Icon(icon, color: color, size: 40),
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
