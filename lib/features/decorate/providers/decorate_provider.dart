import 'dart:developer' as developer;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../../../data/services/supabase_service.dart';
import '../models/decorate_item_model.dart';
import '../repositories/decorate_repository.dart';

// Dependency Injection
final decorateRepositoryProvider = Provider<DecorateRepository>((ref) {
  return DecorateRepository(SupabaseService.client);
});

// State classes
class DecorateState {
  final List<DecorateItem> allItems;
  final List<String> ownedItemIds;
  final UserEquipped? equipped;
  final bool isLoading;

  DecorateState({
    this.allItems = const [],
    this.ownedItemIds = const [],
    this.equipped,
    this.isLoading = false,
  });

  DecorateState copyWith({
    List<DecorateItem>? allItems,
    List<String>? ownedItemIds,
    UserEquipped? equipped,
    bool? isLoading,
  }) {
    return DecorateState(
      allItems: allItems ?? this.allItems,
      ownedItemIds: ownedItemIds ?? this.ownedItemIds,
      equipped: equipped ?? this.equipped,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

// Controller
class DecorateController extends StateNotifier<DecorateState> {
  final DecorateRepository _repository;
  final String? _userId;

  DecorateController(this._repository, this._userId) : super(DecorateState()) {
    if (_userId != null) {
      loadData();
    }
  }

  Future<void> loadData() async {
    final userId = _userId;
    if (userId == null) return;
    
    state = state.copyWith(isLoading: true);
    try {
      final items = await _repository.getDecorateItems();
      final owned = await _repository.getUserItemIds(userId);
      final equipped = await _repository.getUserEquipped(userId);

      state = state.copyWith(
        allItems: items,
        ownedItemIds: owned,
        equipped: equipped ?? UserEquipped(userId: userId),
        isLoading: false,
      );
    } catch (e) {
      developer.log('Load decorate error: $e', name: 'DecorateProvider');
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> equipItem(String type, String itemId) async {
    final userId = _userId;
    if (userId == null) return;

    // Optimistic UI Update
    final oldEquipped = state.equipped;
    UserEquipped? newEquipped = oldEquipped;

    if (type == 'character') newEquipped = newEquipped?.copyWith(characterId: itemId);
    if (type == 'frame') newEquipped = newEquipped?.copyWith(frameId: itemId);
    if (type == 'card_skin') newEquipped = newEquipped?.copyWith(cardSkinId: itemId);
    if (type == 'title') newEquipped = newEquipped?.copyWith(titleId: itemId);

    state = state.copyWith(equipped: newEquipped);

    try {
      await _repository.equipItem(userId, type, itemId);
    } catch (e) {
      // Revert on error
      developer.log('Equip error: $e', name: 'DecorateProvider');
      state = state.copyWith(equipped: oldEquipped);
    }
  }
}

final decorateProvider = StateNotifierProvider<DecorateController, DecorateState>((ref) {
  final repo = ref.watch(decorateRepositoryProvider);
  final user = SupabaseService.currentUser;
  return DecorateController(repo, user?.id);
});
