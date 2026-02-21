import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import 'models/decorate_item_model.dart';
import 'providers/decorate_provider.dart';
import 'widgets/decorate_preview_area.dart';
import 'widgets/decorate_item_grid.dart';
import '../../providers/user_stats_provider.dart';
import 'widgets/card_skin_decorate_tab.dart';
import '../../data/models/card_skin.dart';

class DecoratePage extends ConsumerStatefulWidget {
  const DecoratePage({super.key});

  @override
  ConsumerState<DecoratePage> createState() => _DecoratePageState();
}

class _DecoratePageState extends ConsumerState<DecoratePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DecorateItem? _previewItem;
  CardSkin? _previewCardSkin;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        // Reset preview when changing tabs
        setState(() {
          _previewItem = null;
          _previewCardSkin = null;
        });
      }
    });

    // Load data on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(decorateProvider.notifier).loadData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onSelect(DecorateItem item) {
    setState(() {
      _previewItem = item;
    });
  }

  Future<void> _onBuy(DecorateItem item) async {
    // Show confirmation dialog standard mobile game style
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.stitchDeepBlue,
        title: Text("구매 확인", style: const TextStyle(color: Colors.white)),
        content: Text("${item.name}을(를) ${item.price} 칩에 구매하시겠습니까?", 
          style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("취소", style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.acidYellow),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("구매", style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final statsNotifier = ref.read(userStatsProvider.notifier);
      final decorateNotifier = ref.read(decorateProvider.notifier);
      
      final success = await decorateNotifier.purchaseItem(item, statsNotifier);
      
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("${item.name} 구매 완료!"),
              backgroundColor: AppColors.acidGreen,
            ),
          );
          // Auto equip? Or just let user equip.
          // Mobile game standard: often stays in preview, user clicks equip.
        } else {
           ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("칩이 부족합니다!"),
              backgroundColor: AppColors.laserRed,
            ),
          );
        }
      }
    }
  }

  void _onEquip(DecorateItem item) {
    ref.read(decorateProvider.notifier).equipItem(item.type, item.id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("${item.name} 장착!", style: const TextStyle(color: Colors.black)),
        backgroundColor: AppColors.acidYellow,
        duration: const Duration(milliseconds: 1000),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final decorateState = ref.watch(decorateProvider);
    final allItems = decorateState.allItems;
    final ownedIds = decorateState.ownedItemIds;
    final equipped = decorateState.equipped;

    // Loading State
    if (decorateState.isLoading && allItems.isEmpty) {
      return const Scaffold(
        backgroundColor: AppColors.stitchDarkBG,
        body: Center(
            child:
                CircularProgressIndicator(color: AppColors.acidYellow)),
      );
    }

    final categories = ['character', 'frame', 'card_skin', 'title'];
    final currentCategory = categories[_tabController.index];

    return Scaffold(
      backgroundColor: Colors.black54, // Semi-transparent to see background but read text
      body: Column(
        children: [
          // 1. Top Preview Area
          if (currentCategory == 'card_skin')
            CardSkinPreviewArea(previewSkin: _previewCardSkin)
          else
            DecoratePreviewArea(
              equipped: equipped,
              allItems: allItems,
              activeTab: currentCategory,
              previewItem: _previewItem,
              ownedIds: ownedIds,
              onBuy: _onBuy,
              onEquip: _onEquip,
            ),

          // 2. Tab Bar
          Container(
            color: AppColors.stitchDeepBlue,
            child: TabBar(
              controller: _tabController,
              indicatorColor: AppColors.acidYellow,
              labelColor: AppColors.acidYellow,
              unselectedLabelColor: Colors.white54,
              indicatorWeight: 3,
              labelStyle: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 13),
              tabs: const [
                Tab(icon: Icon(Icons.person), text: "캐릭터"),
                Tab(icon: Icon(Icons.crop_square), text: "프레임"),
                Tab(icon: Icon(Icons.style), text: "카드"),
                Tab(icon: Icon(Icons.stars), text: "칭호"),
              ],
            ),
          ),

          // 3. Grid Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildGridForCategory(ref, 'character', allItems,
                    ownedIds, equipped?.characterId),
                _buildGridForCategory(ref, 'frame', allItems, ownedIds,
                    equipped?.frameId),
                CardSkinGridArea(
                  previewSkin: _previewCardSkin,
                  onSelect: (skin) {
                    setState(() {
                      _previewCardSkin = skin;
                    });
                  },
                ),
                _buildGridForCategory(ref, 'title', allItems, ownedIds,
                    equipped?.titleId),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridForCategory(
    WidgetRef ref,
    String category,
    List<DecorateItem> allItems,
    List<String> ownedIds,
    String? equippedId,
  ) {
    final filteredItems =
        allItems.where((item) => item.type == category).toList();

    if (filteredItems.isEmpty) {
      return const Center(
          child: Text("이 카테고리에 아이템이 없습니다.",
              style: TextStyle(color: Colors.white54)));
    }

    return DecorateItemGrid(
      items: filteredItems,
      ownedIds: ownedIds,
      equippedId: equippedId,
      selectedId: _previewItem?.type == category ? _previewItem?.id : null,
      onSelect: _onSelect,
    );
  }
}
