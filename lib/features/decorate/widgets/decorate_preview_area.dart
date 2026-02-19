import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../models/decorate_item_model.dart';

class DecoratePreviewArea extends ConsumerWidget {
  final UserEquipped? equipped;
  final List<DecorateItem> allItems;
  final String activeTab; // 'character', 'frame', 'card_skin', 'title'

  const DecoratePreviewArea({
    super.key,
    required this.equipped,
    required this.allItems,
    required this.activeTab,
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
    final character = _getItem(equipped?.characterId);
    final frame = _getItem(equipped?.frameId);
    final title = _getItem(equipped?.titleId);

    return Container(
      height: 280,
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
          // Background Radial Glow based on tab
          if (activeTab == 'character')
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 0.8,
                    colors: [
                      AppColors.neonPink.withOpacity(0.15),
                      Colors.transparent,
                    ],
                  ),
                ),
              )
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .scale(
                    begin: const Offset(0.9, 0.9),
                    end: const Offset(1.1, 1.1),
                    duration: 2000.ms,
                  ),
            ),
          if (activeTab == 'frame')
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 0.8,
                    colors: [
                      AppColors.neonCyan.withOpacity(0.15),
                      Colors.transparent,
                    ],
                  ),
                ),
              )
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .scale(
                    begin: const Offset(0.9, 0.9),
                    end: const Offset(1.1, 1.1),
                    duration: 2500.ms,
                  ),
            ),
          if (activeTab == 'card_skin')
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 0.8,
                    colors: [
                      AppColors.electricBlue.withOpacity(0.15),
                      Colors.transparent,
                    ],
                  ),
                ),
              )
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .scale(
                    begin: const Offset(0.9, 0.9),
                    end: const Offset(1.1, 1.1),
                    duration: 2200.ms,
                  ),
            ),
          if (activeTab == 'title')
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 0.8,
                    colors: [
                      AppColors.acidYellow.withOpacity(0.15),
                      Colors.transparent,
                    ],
                  ),
                ),
              )
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .scale(
                    begin: const Offset(0.9, 0.9),
                    end: const Offset(1.1, 1.1),
                    duration: 1800.ms,
                  ),
            ),

          // Character Silhouette
          Positioned(
            bottom: 20,
            child: _buildCharacter(character),
          ),

          // Title Badge
          if (title != null)
            Positioned(
              top: 50,
              child: _buildTitle(title)
                  .animate()
                  .fadeIn(duration: 500.ms)
                  .slideY(
                    begin: -0.5,
                    end: 0,
                    duration: 500.ms,
                    curve: Curves.easeOutBack,
                  ),
            ),

          // Frame Avatar (top-left)
          Positioned(
            left: 20,
            top: 30,
            child: _buildFrameAvatar(frame, character),
          ),

          // Card Skin Mini Preview (bottom-right)
          if (activeTab == 'card_skin')
            Positioned(
              right: 20,
              bottom: 40,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: AppColors.neonCyan.withOpacity(0.5)),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.style, color: AppColors.neonCyan, size: 32),
                    SizedBox(height: 4),
                    Text("카드 스킨",
                        style:
                            TextStyle(color: Colors.white, fontSize: 10)),
                  ],
                ),
              ).animate().shake(duration: 500.ms),
            ),

          // Active Tab Label
          Positioned(
            top: 10,
            right: 16,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black45,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: AppColors.acidYellow.withOpacity(0.3)),
              ),
              child: Text(
                _tabLabel(activeTab),
                style: const TextStyle(
                  color: AppColors.acidYellow,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _tabLabel(String tab) {
    switch (tab) {
      case 'character':
        return '캐릭터 미리보기';
      case 'frame':
        return '프레임 미리보기';
      case 'card_skin':
        return '카드 스킨 미리보기';
      case 'title':
        return '칭호 미리보기';
      default:
        return '';
    }
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

    // Use a colored icon placeholder with name
    final color = _parseColor(item.metadata['color'] as String?);
    return Column(
      children: [
        Container(
          width: 120,
          height: 160,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: (color ?? AppColors.neonPink).withOpacity(0.2),
            border: Border.all(
                color: (color ?? AppColors.neonPink).withOpacity(0.5),
                width: 2),
            boxShadow: [
              BoxShadow(
                  color: (color ?? AppColors.neonPink).withOpacity(0.3),
                  blurRadius: 20),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.person, size: 80, color: color ?? AppColors.neonPink),
              const SizedBox(height: 8),
              Text(
                item.name,
                style: TextStyle(
                  color: color ?? Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    )
        .animate()
        .fadeIn()
        .scale(duration: 400.ms, curve: Curves.easeOutBack);
  }

  Widget _buildTitle(DecorateItem item) {
    final color = _parseColor(item.metadata['color'] as String?);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color ?? AppColors.acidYellow,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
              color: (color ?? AppColors.acidYellow).withOpacity(0.5),
              blurRadius: 10),
        ],
      ),
      child: Text(
        item.name,
        style: TextStyle(
          color: color ?? AppColors.acidYellow,
          fontWeight: FontWeight.bold,
          fontSize: 18,
          shadows: [
            Shadow(
                color: color ?? AppColors.acidYellow, blurRadius: 4),
          ],
        ),
      ),
    );
  }

  Widget _buildFrameAvatar(
      DecorateItem? frame, DecorateItem? character) {
    final charColor =
        _parseColor(character?.metadata['color'] as String?);

    return SizedBox(
      width: 80,
      height: 80,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Inner Avatar
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
              child: character != null
                  ? Icon(Icons.person,
                      color: charColor ?? AppColors.neonPink, size: 36)
                  : const Icon(Icons.person,
                      color: Colors.white54, size: 36),
            ),
          ),

          // Frame Overlay
          if (frame != null)
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.acidYellow, width: 3),
                boxShadow: [
                  BoxShadow(
                      color: AppColors.acidYellow.withOpacity(0.4),
                      blurRadius: 8),
                ],
              ),
            ),
        ],
      ),
    )
        .animate(target: activeTab == 'frame' ? 1 : 0)
        .scale(
            end: const Offset(1.2, 1.2),
            duration: 300.ms,
            curve: Curves.easeOut);
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
