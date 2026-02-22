import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/gto_scenario.dart';

// ---------------------------------------------------------------------------
// GTO Data Cache — Per-BB-level lazy loading
// ---------------------------------------------------------------------------

/// In-memory cache of parsed GTO scenarios for a single BB level.
///
/// Instead of loading the entire ~29 MB master database at once (which causes
/// OOM on emulators and low-memory devices), we split the data into per-BB
/// JSON files (~5–6 MB each) and load only the level currently needed.
class GtoDataCache {
  /// All loaded scenarios for this BB level.
  final List<GtoScenario> scenarios;

  final Map<String, List<GtoScenario>> _byScenarioType;
  final Map<String, List<GtoScenario>> _byPosition;

  GtoDataCache._({
    required this.scenarios,
    required Map<String, List<GtoScenario>> byScenarioType,
    required Map<String, List<GtoScenario>> byPosition,
  })  : _byScenarioType = byScenarioType,
        _byPosition = byPosition;

  /// Build a [GtoDataCache] from a flat list of scenarios.
  factory GtoDataCache.from(List<GtoScenario> scenarios) {
    final byScenarioType = <String, List<GtoScenario>>{};
    final byPosition = <String, List<GtoScenario>>{};

    for (final scenario in scenarios) {
      (byScenarioType[scenario.scenarioType] ??= []).add(scenario);
      (byPosition[scenario.position] ??= []).add(scenario);
    }

    return GtoDataCache._(
      scenarios: scenarios,
      byScenarioType: byScenarioType,
      byPosition: byPosition,
    );
  }

  /// All scenarios matching the given [scenarioType].
  List<GtoScenario> getByScenarioType(String scenarioType) {
    return _byScenarioType[scenarioType] ?? const [];
  }

  /// All scenarios matching the given [position].
  List<GtoScenario> getByPosition(String position) {
    return _byPosition[position] ?? const [];
  }

  /// Available scenario types in the dataset.
  Set<String> get availableScenarioTypes => _byScenarioType.keys.toSet();

  /// Available positions in the dataset.
  Set<String> get availablePositions => _byPosition.keys.toSet();
}

// ---------------------------------------------------------------------------
// Isolate-safe JSON parsing
// ---------------------------------------------------------------------------

/// Top-level function for [compute] — parses raw JSON string into scenarios.
///
/// Runs on a separate isolate to avoid blocking the UI thread.
List<GtoScenario> _parseGtoJson(String jsonString) {
  final jsonData = json.decode(jsonString) as Map<String, dynamic>;
  final scenariosJson = jsonData['scenarios'] as List<dynamic>;

  return scenariosJson
      .map((e) => GtoScenario.fromJson(e as Map<String, dynamic>))
      .toList();
}

// ---------------------------------------------------------------------------
// Per-BB-level Provider (family)
// ---------------------------------------------------------------------------

/// Loads and caches GTO scenarios for a specific BB level.
///
/// Each BB level is stored in a separate JSON file (~5–6 MB) to prevent
/// OOM crashes caused by loading the entire 29 MB master database at once.
///
/// Usage:
/// ```dart
/// final cache = await ref.read(gtoBbLevelProvider(15).future);
/// final scenarios = cache.scenarios;
/// ```
final gtoBbLevelProvider =
    FutureProvider.family<GtoDataCache, int>((ref, bbLevel) async {
  final path = 'assets/db/gto_bb$bbLevel.json';

  debugPrint('[GtoDataProvider] Loading BB$bbLevel from $path...');

  final jsonString = await rootBundle.loadString(path);

  // Parse on a background isolate to avoid janking the UI.
  final scenarios = await compute(_parseGtoJson, jsonString);

  debugPrint(
    '[GtoDataProvider] Loaded ${scenarios.length} scenarios for BB$bbLevel',
  );

  return GtoDataCache.from(scenarios);
});

// ---------------------------------------------------------------------------
// Legacy full-load provider (kept for backward compatibility)
// ---------------------------------------------------------------------------

/// Loads the FULL GTO master database from JSON assets (~29 MB).
///
/// **⚠️ WARNING**: This can cause OOM on emulators and low-memory devices.
/// Prefer [gtoBbLevelProvider] for per-level loading.
///
/// Kept for backward compatibility with code that expects the full dataset.
final gtoDataCacheProvider = FutureProvider<GtoDataCache>((ref) async {
  final jsonString =
      await rootBundle.loadString('assets/db/gto_master_db.json');

  // Parse on a background isolate to avoid janking the UI.
  final scenarios = await compute(_parseGtoJson, jsonString);

  debugPrint(
    '[GtoDataProvider] Loaded ${scenarios.length} scenarios (full)',
  );

  return GtoDataCache.from(scenarios);
});
