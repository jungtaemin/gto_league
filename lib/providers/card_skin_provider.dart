import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/models/card_skin.dart';
class CardSkinState {
  final List<String> ownedSkinIds;
  final String equippedSkinId;

  const CardSkinState({
    this.ownedSkinIds = const ['basic'],
    this.equippedSkinId = 'basic',
  });

  CardSkin get equippedSkin => allCardSkins.firstWhere(
    (skin) => skin.id == equippedSkinId,
    orElse: () => allCardSkins.first,
  );

  bool isOwned(String skinId) => ownedSkinIds.contains(skinId);

  CardSkinState copyWith({
    List<String>? ownedSkinIds,
    String? equippedSkinId,
  }) {
    return CardSkinState(
      ownedSkinIds: ownedSkinIds ?? this.ownedSkinIds,
      equippedSkinId: equippedSkinId ?? this.equippedSkinId,
    );
  }
}

class CardSkinNotifier extends StateNotifier<CardSkinState> {
  static const _ownedKey = 'owned_card_skins';
  static const _equippedKey = 'equipped_card_skin';
  
  CardSkinNotifier() : super(const CardSkinState()) {
    _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final owned = prefs.getStringList(_ownedKey) ?? ['basic'];
    final equipped = prefs.getString(_equippedKey) ?? 'basic';
    state = CardSkinState(ownedSkinIds: owned, equippedSkinId: equipped);
  }

  Future<void> equipSkin(String id) async {
    if (!state.ownedSkinIds.contains(id)) return;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_equippedKey, id);
    
    state = state.copyWith(equippedSkinId: id);
  }

  Future<void> unlockSkin(String id) async {
    if (state.ownedSkinIds.contains(id)) return;
    
    final newOwned = [...state.ownedSkinIds, id];
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_ownedKey, newOwned);
    
    state = state.copyWith(ownedSkinIds: newOwned);
  }
}

final cardSkinProvider = StateNotifierProvider<CardSkinNotifier, CardSkinState>((ref) {
  return CardSkinNotifier();
});
