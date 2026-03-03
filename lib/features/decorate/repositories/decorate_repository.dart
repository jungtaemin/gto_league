import 'dart:developer' as developer;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/decorate_item_model.dart';

class DecorateRepository {
  final SupabaseClient _client;

  DecorateRepository(this._client);

  /// Fetch all available decorate items
  Future<List<DecorateItem>> getDecorateItems() async {
    // 1. 오직 'AI 로봇'과 '텍사스 잭' 캐릭터만 사용하도록 DB fetch 스킵 및 덮어쓰기
    final items = <DecorateItem>[
      DecorateItem(
        id: 'char_texas_jack',
        type: 'character',
        name: '텍사스 잭',
        assetUrl: 'assets/images/characters/char_2.webp',
        rarity: 'epic',
        metadata: {'price': 0, 'desc': '안티그래비티 홀덤 아카데미의 마스코트 텍사스 잭입니다.'},
      ),
      DecorateItem(
        id: 'char_robot',
        type: 'character',
        name: 'AI 로봇',
        assetUrl: 'assets/images/characters/char_robot.webp',
        rarity: 'common',
        metadata: {'price': 0, 'desc': '안티그래비티 AI 로봇입니다.'},
      ),
    ];
    return items;
  }

  /// Fetch user owned items (returns list of item IDs)
  Future<List<String>> getUserItemIds(String userId) async {
    List<String> owned = [];
    try {
      final response = await _client
          .from('user_items')
          .select('item_id')
          .eq('user_id', userId);
      final data = response as List<dynamic>;
      owned = data.map((e) => e['item_id'] as String).toList();
    } catch (_) {}

    // Default items always owned
    if (!owned.contains('char_robot')) owned.add('char_robot');
    if (!owned.contains('char_texas_jack')) owned.add('char_texas_jack');
    if (!owned.contains('skin_card_default')) owned.add('skin_card_default');
    
    return owned;
  }

  /// Fetch user's currently equipped items
  Future<UserEquipped?> getUserEquipped(String userId) async {
    try {
      final response = await _client
          .from('user_equipped')
          .select()
          .eq('user_id', userId)
          .maybeSingle(); 
      
      if (response != null) {
        final equipped = UserEquipped.fromJson(response);
        // DB에 데이터가 있으면 로컬 덮어쓰기 (DB가 최신이라 가정)
        _saveEquippedToLocal(userId, equipped);
        return equipped;
      }
    } catch (_) {}

    // DB 조회가 실패했거나(catch), 데이터가 아예 없는 경우(null)
    // 로컬 캐시에서 복원 시도
    final localEquipped = await _loadEquippedFromLocal(userId);
    if (localEquipped != null) return localEquipped;

    // 로컬 캐시조차 없으면 완전 초기 상태 반환
    return UserEquipped(
        userId: userId, 
        characterId: 'char_robot',
        cardSkinId: 'skin_card_default',
    );
  }

  /// Equip an item
  /// [itemId] can be null to unequip
  /// [type] determines which column to update: 'character', 'frame', 'card_skin', 'title'
  Future<void> equipItem(String userId, String type, String? itemId) async {
    final columnMap = {
      'character': 'character_id',
      'frame': 'frame_id',
      'card_skin': 'card_skin_id',
      'title': 'title_id',
    };

    final columnName = columnMap[type];
    if (columnName == null) throw Exception('Invalid item type: $type');

    // ★ 로컬 캐시 먼저 저장 (Supabase 실패와 무관하게 반드시 실행)
    final current = await _loadEquippedFromLocal(userId) ?? 
        UserEquipped(userId: userId, characterId: 'char_robot', cardSkinId: 'skin_card_default');
    UserEquipped updated = current;
    if (type == 'character') updated = updated.copyWith(characterId: itemId);
    if (type == 'frame') updated = updated.copyWith(frameId: itemId);
    if (type == 'card_skin') updated = updated.copyWith(cardSkinId: itemId);
    if (type == 'title') updated = updated.copyWith(titleId: itemId);
    await _saveEquippedToLocal(userId, updated);

    // Supabase 업데이트 (실패해도 로컬의 장착 정보는 이미 저장됨)
    try {
      final existingParams = {
        columnName: itemId,
        'updated_at': DateTime.now().toIso8601String(),
      };

      final response = await _client
          .from('user_equipped')
          .update(existingParams)
          .eq('user_id', userId)
          .select();

      if ((response as List).isEmpty) {
        await _client.from('user_equipped').insert({
          'user_id': userId,
          columnName: itemId,
        });
      }
    } catch (_) {
      // Supabase 실패해도 로컬 캐시로 충분
    }
  }

  Future<void> purchaseItem(String userId, String itemId) async {
    // Implement purchase persistence
    try {
      await _client.from('user_items').insert({
        'user_id': userId,
        'item_id': itemId,
      });
    } catch (_) {
      // Mock or error
    }
  }

  // =============================================
  // SharedPreferences 기반 로컬 캐시 (영속화)
  // =============================================
  static const _keyPrefix = 'equipped_';

  Future<void> _saveEquippedToLocal(String userId, UserEquipped eq) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_keyPrefix$userId';
    await prefs.setString('${key}_character', eq.characterId ?? '');
    await prefs.setString('${key}_frame', eq.frameId ?? '');
    await prefs.setString('${key}_card_skin', eq.cardSkinId ?? '');
    await prefs.setString('${key}_title', eq.titleId ?? '');
  }

  Future<UserEquipped?> _loadEquippedFromLocal(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_keyPrefix$userId';
    final charId = prefs.getString('${key}_character');
    if (charId == null || charId.isEmpty) return null; // 저장된 적 없음

    return UserEquipped(
      userId: userId,
      characterId: charId.isNotEmpty ? charId : 'char_robot',
      frameId: _nonEmpty(prefs.getString('${key}_frame')),
      cardSkinId: _nonEmpty(prefs.getString('${key}_card_skin')) ?? 'skin_card_default',
      titleId: _nonEmpty(prefs.getString('${key}_title')),
    );
  }

  String? _nonEmpty(String? s) => (s != null && s.isNotEmpty) ? s : null;
}
