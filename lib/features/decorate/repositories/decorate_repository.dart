import 'dart:developer' as developer;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/decorate_item_model.dart';

class DecorateRepository {
  final SupabaseClient _client;

  DecorateRepository(this._client);

  /// Fetch all available decorate items
  Future<List<DecorateItem>> getDecorateItems() async {
    List<DecorateItem> items = [];
    try {
      final response = await _client
          .from('decorate_items')
          .select()
          .order('created_at', ascending: false);
      final data = response as List<dynamic>;
      items = data.map((e) => DecorateItem.fromJson(e)).toList();
    } catch (e) {
      developer.log('Supabase fetch failed, using mock data: $e');
    }

    // Inject Mock Data
    final mockItems = [
      DecorateItem(
        id: 'char_f1',
        type: 'character',
        name: '포커 플레이어',
        assetUrl: 'assets/images/characters/char_f1.png',
        rarity: 'common',
        metadata: {'price': 0, 'desc': '귀여운 포커 플레이어입니다.'},
      ),
      DecorateItem(
        id: 'char_f2',
        type: 'character',
        name: '카지노 딜러',
        assetUrl: 'assets/images/characters/char_f2.png',
        rarity: 'rare',
        metadata: {'price': 500, 'desc': '우아한 카지노 딜러입니다.'},
      ),
      DecorateItem(
        id: 'char_f3',
        type: 'character',
        name: '사이버 해커',
        assetUrl: 'assets/images/characters/char_f3.png',
        rarity: 'epic',
        metadata: {'price': 2000, 'desc': '쿨한 분위기의 사이버펑크 해커입니다.'},
      ),
      DecorateItem(
        id: 'char_m1',
        type: 'character',
        name: '프로 포커',
        assetUrl: 'assets/images/characters/char_m1.png',
        rarity: 'common',
        metadata: {'price': 0, 'desc': '정장을 차려입은 핸섬한 프로입니다.'},
      ),
      DecorateItem(
        id: 'char_m2',
        type: 'character',
        name: '카지노 마스터',
        assetUrl: 'assets/images/characters/char_m2.png',
        rarity: 'rare',
        metadata: {'price': 500, 'desc': '카지노를 주름잡는 마스터입니다.'},
      ),
      DecorateItem(
        id: 'char_m3',
        type: 'character',
        name: '사이버 용병',
        assetUrl: 'assets/images/characters/char_m3.png',
        rarity: 'legendary',
        metadata: {'price': 5000, 'desc': '거친 매력의 사이버 용병입니다.'},
      ),
      // Card Skins
      DecorateItem(
        id: 'skin_card_default',
        type: 'card_skin',
        name: 'Classic White',
        assetUrl: '',
        rarity: 'common',
        metadata: {'price': 0, 'desc': 'Standard casino deck.'},
      ),
      DecorateItem(
        id: 'skin_card_modern',
        type: 'card_skin',
        name: 'Midnight Black',
        assetUrl: '',
        rarity: 'rare',
        metadata: {'price': 1000, 'desc': 'Sleek dark mode cards.'},
      ),
      DecorateItem(
        id: 'skin_card_neon',
        type: 'card_skin',
        name: 'Cyber Neon',
        assetUrl: '',
        rarity: 'epic',
        metadata: {'price': 1000, 'desc': 'Glowing futuristic deck.'},
      ),
    ];

    // Merge: Put mock items first or verify duplicates
    // For now, just add them if not present
    for (var mock in mockItems) {
      if (!items.any((i) => i.id == mock.id)) {
        items.insert(0, mock);
      }
    }
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
    if (!owned.contains('char_f1')) owned.add('char_f1');
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
        characterId: 'char_f1',
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
