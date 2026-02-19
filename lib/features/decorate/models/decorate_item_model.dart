class DecorateItem {
  final String id;
  final String type; // 'character', 'frame', 'card_skin', 'title'
  final String name;
  final String assetUrl;
  final String rarity;
  final Map<String, dynamic> metadata;

  DecorateItem({
    required this.id,
    required this.type,
    required this.name,
    required this.assetUrl,
    required this.rarity,
    required this.metadata,
  });

  factory DecorateItem.fromJson(Map<String, dynamic> json) {
    return DecorateItem(
      id: json['id'] as String,
      type: json['type'] as String,
      name: json['name'] as String,
      assetUrl: json['asset_url'] as String,
      rarity: json['rarity'] as String? ?? 'common',
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
    );
  }
}

class UserEquipped {
  final String userId;
  final String? characterId;
  final String? frameId;
  final String? cardSkinId;
  final String? titleId;

  UserEquipped({
    required this.userId,
    this.characterId,
    this.frameId,
    this.cardSkinId,
    this.titleId,
  });
  
  factory UserEquipped.fromJson(Map<String, dynamic> json) {
     return UserEquipped(
      userId: json['user_id'] as String,
      characterId: json['character_id'] as String?,
      frameId: json['frame_id'] as String?,
      cardSkinId: json['card_skin_id'] as String?,
      titleId: json['title_id'] as String?,
    );
  }

  UserEquipped copyWith({
    String? characterId,
    String? frameId,
    String? cardSkinId,
    String? titleId,
  }) {
    return UserEquipped(
      userId: userId,
      characterId: characterId ?? this.characterId,
      frameId: frameId ?? this.frameId,
      cardSkinId: cardSkinId ?? this.cardSkinId,
      titleId: titleId ?? this.titleId,
    );
  }
}
