import 'tier.dart';

/// Represents a player in the league
class LeaguePlayer {
  final String id;
  final String nickname;
  final int score;
  final Tier tier;
  final int rank;
  final bool isGhost;

  const LeaguePlayer({
    required this.id,
    required this.nickname,
    required this.score,
    required this.tier,
    required this.rank,
    required this.isGhost,
  });

  /// Create a copy of this player with optional field overrides
  LeaguePlayer copyWith({
    String? id,
    String? nickname,
    int? score,
    Tier? tier,
    int? rank,
    bool? isGhost,
  }) {
    return LeaguePlayer(
      id: id ?? this.id,
      nickname: nickname ?? this.nickname,
      score: score ?? this.score,
      tier: tier ?? this.tier,
      rank: rank ?? this.rank,
      isGhost: isGhost ?? this.isGhost,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LeaguePlayer &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          nickname == other.nickname &&
          score == other.score &&
          tier == other.tier &&
          rank == other.rank &&
          isGhost == other.isGhost;

  @override
  int get hashCode =>
      id.hashCode ^
      nickname.hashCode ^
      score.hashCode ^
      tier.hashCode ^
      rank.hashCode ^
      isGhost.hashCode;

  @override
  String toString() =>
      'LeaguePlayer(id: $id, nickname: $nickname, score: $score, tier: $tier, rank: $rank, isGhost: $isGhost)';
}
