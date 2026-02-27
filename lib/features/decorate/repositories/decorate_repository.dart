import 'dart:developer' as developer;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/decorate_item_model.dart';

class DecorateRepository {
  final SupabaseClient _client;

  DecorateRepository(this._client);

  /// Fetch all available decorate items
  Future<List<DecorateItem>> getDecorateItems() async {
    // 1. 오직 'AI 로봇' 캐릭터만 사용하도록 DB fetch 스킵 및 덮어쓰기
    final items = <DecorateItem>[
      DecorateItem(
        id: 'char_robot',
        type: 'character',
        name: 'AI 로봇',
        assetUrl: 'assets/images/characters/char_robot.png',
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
      
      if (response != null) return UserEquipped.fromJson(response);
    } catch (_) {}

    // Default equipped
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

    // Upsert: Try to update, if not exists, insert
    // Note: upsert in Supabase usually requires all non-nullable fields or PK.
    // For specific column update, we check existence first or use upsert with all fields.
    // Simpler approach: Try to update, if row count 0, insert.
    
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
      // Insert new row if not exists
      await _client.from('user_equipped').insert({
        'user_id': userId,
        columnName: itemId,
      });
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
}
