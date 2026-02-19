import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import 'models/decorate_item_model.dart';
import 'providers/decorate_provider.dart';
import 'widgets/decorate_preview_area.dart';
import 'widgets/decorate_item_grid.dart';

class DecoratePage extends ConsumerStatefulWidget {
  const DecoratePage({super.key});

  @override
  ConsumerState<DecoratePage> createState() => _DecoratePageState();
}

class _DecoratePageState extends ConsumerState<DecoratePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {});
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
      backgroundColor: AppColors.stitchDarkBG,
      body: Column(
        children: [
          // 1. Top Preview Area
          DecoratePreviewArea(
            equipped: equipped,
            allItems: allItems,
            activeTab: currentCategory,
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
                _buildGridForCategory(ref, 'card_skin', allItems,
                    ownedIds, equipped?.cardSkinId),
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
      onEquip: (itemId) {
        ref.read(decorateProvider.notifier).equipItem(category, itemId);
      },
    );
  }
}
