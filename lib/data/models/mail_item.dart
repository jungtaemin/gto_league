/// Mail type enumeration for categorizing mail items
enum MailType {
  system,
  event,
  compensation,
  announcement,
}

/// Factory constructor to parse MailType from string
extension MailTypeExtension on MailType {
  static MailType fromString(String value) {
    return MailType.values.firstWhere(
      (type) => type.name == value,
      orElse: () => MailType.system,
    );
  }

  String toJson() => name;
}

/// Represents a mail item from the user's mailbox
class MailItem {
  final String id;
  final String userId;
  final MailType type;
  final String title;
  final String body;
  final int? rewardChips;
  final int? rewardEnergy;
  final bool isRead;
  final DateTime? claimedAt;
  final DateTime createdAt;
  final DateTime? expiresAt;

  const MailItem({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.body,
    this.rewardChips,
    this.rewardEnergy,
    required this.isRead,
    this.claimedAt,
    required this.createdAt,
    this.expiresAt,
  });

  /// Create a MailItem from JSON
  factory MailItem.fromJson(Map<String, dynamic> json) {
    return MailItem(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      type: MailTypeExtension.fromString(json['type'] as String),
      title: json['title'] as String,
      body: json['body'] as String,
      rewardChips: json['reward_chips'] as int?,
      rewardEnergy: json['reward_energy'] as int?,
      isRead: json['is_read'] as bool,
      claimedAt: json['claimed_at'] != null
          ? DateTime.tryParse(json['claimed_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      expiresAt: json['expires_at'] != null
          ? DateTime.tryParse(json['expires_at'] as String)
          : null,
    );
  }

  /// Convert this MailItem to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'type': type.toJson(),
      'title': title,
      'body': body,
      'reward_chips': rewardChips,
      'reward_energy': rewardEnergy,
      'is_read': isRead,
      'claimed_at': claimedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'expires_at': expiresAt?.toIso8601String(),
    };
  }

  /// Create a copy of this mail item with optional field overrides
  MailItem copyWith({
    String? id,
    String? userId,
    MailType? type,
    String? title,
    String? body,
    int? rewardChips,
    int? rewardEnergy,
    bool? isRead,
    DateTime? claimedAt,
    DateTime? createdAt,
    DateTime? expiresAt,
  }) {
    return MailItem(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      title: title ?? this.title,
      body: body ?? this.body,
      rewardChips: rewardChips ?? this.rewardChips,
      rewardEnergy: rewardEnergy ?? this.rewardEnergy,
      isRead: isRead ?? this.isRead,
      claimedAt: claimedAt ?? this.claimedAt,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }

  /// Whether this mail has been claimed
  bool get isClaimed => claimedAt != null;

  /// Whether this mail has expired
  bool get isExpired =>
      expiresAt != null && DateTime.now().isAfter(expiresAt!);

  /// Whether this mail contains a reward
  bool get hasReward => (rewardChips ?? 0) > 0 || (rewardEnergy ?? 0) > 0;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MailItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          userId == other.userId &&
          type == other.type &&
          title == other.title &&
          body == other.body &&
          rewardChips == other.rewardChips &&
          rewardEnergy == other.rewardEnergy &&
          isRead == other.isRead &&
          claimedAt == other.claimedAt &&
          createdAt == other.createdAt &&
          expiresAt == other.expiresAt;

  @override
  int get hashCode =>
      id.hashCode ^
      userId.hashCode ^
      type.hashCode ^
      title.hashCode ^
      body.hashCode ^
      rewardChips.hashCode ^
      rewardEnergy.hashCode ^
      isRead.hashCode ^
      claimedAt.hashCode ^
      createdAt.hashCode ^
      expiresAt.hashCode;

  @override
  String toString() =>
      'MailItem(id: $id, userId: $userId, type: $type, title: $title, body: $body, rewardChips: $rewardChips, rewardEnergy: $rewardEnergy, isRead: $isRead, claimedAt: $claimedAt, createdAt: $createdAt, expiresAt: $expiresAt)';
}
