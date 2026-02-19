import 'dart:developer' as developer;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/decorate_item_model.dart';

class DecorateRepository {
  final SupabaseClient _client;

  DecorateRepository(this._client);

  /// Fetch all available decorate items
  Future<List<DecorateItem>> getDecorateItems() async {
    final response = await _client
        .from('decorate_items')
        .select()
        .order('created_at', ascending: false);
    
    final data = response as List<dynamic>;
    return data.map((e) => DecorateItem.fromJson(e)).toList();
  }

  /// Fetch user owned items (returns list of item IDs)
  Future<List<String>> getUserItemIds(String userId) async {
    final response = await _client
        .from('user_items')
        .select('item_id')
        .eq('user_id', userId);
    
    final data = response as List<dynamic>;
    return data.map((e) => e['item_id'] as String).toList();
  }

  /// Fetch user's currently equipped items
  Future<UserEquipped?> getUserEquipped(String userId) async {
    try {
      final response = await _client
          .from('user_equipped')
          .select()
          .eq('user_id', userId)
          .maybeSingle(); // Returns null if not found
      
      if (response == null) return null;
      return UserEquipped.fromJson(response);
    } catch (e) {
      // Handle error or return null
      developer.log('Error fetching user equipped: $e', name: 'DecorateRepo');
      return null;
    }
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
}
