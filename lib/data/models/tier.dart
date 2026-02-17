/// Tier enum representing player skill levels in Hold'em All-In Fold
enum Tier {
  fish,
  donkey,
  callingStation,
  pubReg,
  grinder,
  shark,
  gtoMachine;

  /// Emoji representation of the tier
  String get emoji {
    return switch (this) {
      Tier.fish => '🐟',
      Tier.donkey => '🫏',
      Tier.callingStation => '📞',
      Tier.pubReg => '🍺',
      Tier.grinder => '⚙️',
      Tier.shark => '🦈',
      Tier.gtoMachine => '🤖',
    };
  }

  /// Display name in Korean
  String get displayName {
    return switch (this) {
      Tier.fish => '방수',
      Tier.donkey => '동키',
      Tier.callingStation => '콜링 스테이션',
      Tier.pubReg => '펍 레귤러',
      Tier.grinder => '그라인더',
      Tier.shark => '샤크',
      Tier.gtoMachine => 'GTO 머신',
    };
  }

  /// Minimum score required for this tier
  int get minScore {
    return switch (this) {
      Tier.fish => 0,
      Tier.donkey => 100,
      Tier.callingStation => 300,
      Tier.pubReg => 600,
      Tier.grinder => 1000,
      Tier.shark => 1500,
      Tier.gtoMachine => 2000,
    };
  }

  /// Maximum score for this tier (exclusive for next tier)
  int get maxScore {
    return switch (this) {
      Tier.fish => 99,
      Tier.donkey => 299,
      Tier.callingStation => 599,
      Tier.pubReg => 999,
      Tier.grinder => 1499,
      Tier.shark => 1999,
      Tier.gtoMachine => 999999,
    };
  }

  /// Get tier from score
  static Tier fromScore(int score) {
    if (score < 100) return Tier.fish;
    if (score < 300) return Tier.donkey;
    if (score < 600) return Tier.callingStation;
    if (score < 1000) return Tier.pubReg;
    if (score < 1500) return Tier.grinder;
    if (score < 2000) return Tier.shark;
    return Tier.gtoMachine;
  }
}
