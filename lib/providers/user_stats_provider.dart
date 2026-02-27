import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../data/services/supabase_service.dart';
import '../data/models/tier.dart';

/// ──────────────────────────────────────────────
/// 🔋 에너지 시스템 (0원 아키텍처)
/// ──────────────────────────────────────────────
/// - 서버: spend_energy_with_recovery RPC만 호출 (소모 시)
/// - 클라이언트: 순수 계산으로 타이머/에너지 표시
/// - DB 변경 없이 20분마다 1씩 자동 충전 '계산'
/// ──────────────────────────────────────────────

/// 유저 스탯 상태
class UserStats {
  final int chips;
  final int energy;      // DB에 저장된 시점의 에너지
  final int maxEnergy;
  final Tier tier;
  final DateTime? lastEnergySync; // 마지막 에너지 변경 시점 (서버 기준)
  final int xp;
  final int level;

  static const int recoveryRate = 20; // 분 단위

  const UserStats({
    this.chips = 0,
    this.energy = 10,
    this.maxEnergy = 10,
    this.tier = Tier.fish,
    this.lastEnergySync,
    this.xp = 0,
    this.level = 1,
  });

  UserStats copyWith({
    int? chips,
    int? energy,
    int? maxEnergy,
    Tier? tier,
    DateTime? lastEnergySync,
    int? xp,
    int? level,
  }) {
    return UserStats(
      chips: chips ?? this.chips,
      energy: energy ?? this.energy,
      maxEnergy: maxEnergy ?? this.maxEnergy,
      tier: tier ?? this.tier,
      lastEnergySync: lastEnergySync ?? this.lastEnergySync,
      xp: xp ?? this.xp,
      level: level ?? this.level,
    );
  }

  /// 🔑 핵심: 현재 실제 에너지 (DB값 + 시간 경과분 회복)
  int get calculatedEnergy {
    if (lastEnergySync == null || energy >= maxEnergy) return energy;
    final elapsed = DateTime.now().difference(lastEnergySync!);
    final recovered = elapsed.inMinutes ~/ recoveryRate;
    return (energy + recovered).clamp(0, maxEnergy);
  }

  /// 다음 충전까지 남은 시간 (초 단위 정밀)
  Duration? get timeUntilNextRefill {
    if (calculatedEnergy >= maxEnergy || lastEnergySync == null) return null;

    final elapsed = DateTime.now().difference(lastEnergySync!);
    const interval = Duration(minutes: recoveryRate);
    final remainder = elapsed.inSeconds % interval.inSeconds;
    final remaining = interval.inSeconds - remainder;
    return Duration(seconds: remaining);
  }

  /// 에너지가 MAX인지
  bool get isEnergyFull => calculatedEnergy >= maxEnergy;
}

/// ──────────────────────────────────────────────
/// StateNotifier: 서버 ↔ 클라이언트 동기화
/// ──────────────────────────────────────────────
class UserStatsNotifier extends StateNotifier<UserStats> {
  UserStatsNotifier() : super(const UserStats()) {
    loadFromServer();
    _startDisplayTimer();
  }

  Timer? _displayTimer;

  @override
  void dispose() {
    _displayTimer?.cancel();
    super.dispose();
  }

  /// 1초마다 UI 갱신 (state를 터치해서 리빌드 트리거)
  void _startDisplayTimer() {
    _displayTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!state.isEnergyFull) {
        // state를 동일 값으로 재설정 → Riverpod이 리빌드 트리거
        state = state.copyWith();
      }
    });
  }

  /// 서버에서 유저 스탯 로드
  Future<void> loadFromServer() async {
    if (!SupabaseService.isLoggedIn) return;

    try {
      final userId = SupabaseService.currentUser!.id;
      final data = await SupabaseService.client
          .from('profiles')
          .select('chips, energy, max_energy, tier, last_energy_sync, xp, level')
          .eq('id', userId)
          .single();

      state = UserStats(
        chips: (data['chips'] as int?) ?? 0,
        energy: (data['energy'] as int?) ?? 10,
        maxEnergy: (data['max_energy'] as int?) ?? 10,
        tier: Tier.fromName((data['tier'] as String?) ?? 'fish'),
        lastEnergySync: data['last_energy_sync'] != null
            ? DateTime.parse(data['last_energy_sync'])
            : DateTime.now(),
        xp: (data['xp'] as int?) ?? 0,
        level: (data['level'] as int?) ?? 1,
      );
    } catch (e) {
      debugPrint('UserStats load failed: $e');
    }
  }

  /// ⚡ 에너지 소모 (RPC 호출 → 서버가 충전+소모+시간 보정 원자적 처리)
  /// 성공하면 true, 에너지 부족이면 false
  Future<bool> consumeEnergy() async {
    if (!SupabaseService.isLoggedIn) return false;

    try {
      final userId = SupabaseService.currentUser!.id;
      final response = await SupabaseService.client
          .rpc('spend_energy_with_recovery', params: {'u_id': userId});

      final result = response as Map<String, dynamic>;
      final success = result['success'] as bool;
      final remaining = result['remaining_energy'] as int;
      final maxEn = result['max_energy'] as int;

      // RPC 결과로 로컬 상태 즉시 반영
      state = state.copyWith(
        energy: remaining,
        maxEnergy: maxEn,
        lastEnergySync: success ? DateTime.now() : state.lastEnergySync,
      );

      // RPC 후 정확한 sync 시간을 위해 서버 데이터 재로드
      if (success) {
        // 비동기로 정확한 last_energy_sync를 서버에서 가져옴
        _reloadSyncTime();
      }

      return success;
    } catch (e) {
      debugPrint('consumeEnergy RPC failed: $e');
      return false;
    }
  }

  /// RPC 후 정확한 last_energy_sync를 서버에서 재로드
  Future<void> _reloadSyncTime() async {
    try {
      final userId = SupabaseService.currentUser!.id;
      final data = await SupabaseService.client
          .from('profiles')
          .select('energy, last_energy_sync, max_energy')
          .eq('id', userId)
          .single();

      state = state.copyWith(
        energy: (data['energy'] as int?) ?? state.energy,
        maxEnergy: (data['max_energy'] as int?) ?? state.maxEnergy,
        lastEnergySync: data['last_energy_sync'] != null
            ? DateTime.parse(data['last_energy_sync'])
            : state.lastEnergySync,
      );
    } catch (e) {
      debugPrint('Sync time reload failed: $e');
    }
  }

  /// 칩 추가 (게임 클리어 보상 등)
  Future<void> addChips(int amount) async {
    final newChips = state.chips + amount;
    state = state.copyWith(chips: newChips);
    _syncChips(newChips);
  }

  /// 칩 소모 (상점 구매 등)
  /// 성공 시 true, 칩 부족 시 false 반환
  Future<bool> consumeChips(int amount) async {
    if (state.chips < amount) {
      return false;
    }
    final newChips = state.chips - amount;
    state = state.copyWith(chips: newChips);
    await _syncChips(newChips);
    return true;
  }

  Future<void> _syncChips(int newChips) async {
    if (SupabaseService.isLoggedIn) {
      try {
        await SupabaseService.client
            .from('profiles')
            .update({'chips': newChips})
            .eq('id', SupabaseService.currentUser!.id);
      } catch (e) {
        debugPrint('Chips update failed: $e');
      }
    }
  }

  /// XP 보상 획득 및 레벨업 체크
  Future<void> addXp(int amount) async {
    int newXp = state.xp + amount;
    int newLevel = state.level;
    
    // 단순한 레벨업 로직 (예: 100XP당 1레벨업)
    while (newXp >= 100) {
      newLevel++;
      newXp -= 100;
    }

    state = state.copyWith(xp: newXp, level: newLevel);
    await _syncXpLevel(newXp, newLevel);
  }

  Future<void> _syncXpLevel(int xp, int level) async {
    if (SupabaseService.isLoggedIn) {
      try {
        await SupabaseService.client
            .from('profiles')
            .update({'xp': xp, 'level': level})
            .eq('id', SupabaseService.currentUser!.id);
      } catch (e) {
        debugPrint('XP/Level update failed: $e');
      }
    }
  }


  /// 행동력 리필 (광고 시청 보상 등)
  Future<void> refillEnergy() async {
    state = state.copyWith(energy: state.maxEnergy);

    if (SupabaseService.isLoggedIn) {
      try {
        await SupabaseService.client
            .from('profiles')
            .update({'energy': state.maxEnergy, 'last_energy_sync': DateTime.now().toIso8601String()})
            .eq('id', SupabaseService.currentUser!.id);
      } catch (e) {
        debugPrint('Energy refill failed: $e');
      }
    }
  }
}

/// UserStats 글로벌 프로바이더
final userStatsProvider = StateNotifierProvider<UserStatsNotifier, UserStats>((ref) {
  return UserStatsNotifier();
});
