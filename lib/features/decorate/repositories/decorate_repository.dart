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
        id: 'char_robot',
        type: 'character',
        name: 'GTO Robot',
        assetUrl: 'assets/images/gto_robot.png',
        rarity: 'common',
        metadata: {'price': 0, 'desc': 'Standard Issue GTO Droid'},
      ),
      DecorateItem(
        id: 'char_ninja',
        type: 'character',
        name: 'Ninja Girl',
        assetUrl: 'assets/images/ninja_girl.png',
        rarity: 'epic',
        metadata: {'price': 10000, 'desc': 'Silent but deadly.'},
      ),
      DecorateItem(
        id: 'char_spacemarine',
        type: 'character',
        name: 'Space Marine',
        assetUrl: 'assets/images/space_marine.png',
        rarity: 'legendary',
        metadata: {'price': 5000, 'color': '#00FFFF', 'desc': 'Elite soldier of the galaxy.'},
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
