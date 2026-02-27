import 'dart:convert' show jsonDecode, utf8;
import 'dart:io' show GZipCodec;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/deep_stack_scenario.dart';

part 'deep_stack_data_provider.g.dart';

// ── Deep Stack Cache ──────────────────────────────────────────

/// In-memory cache of parsed 30BB deep stack scenarios.
///
/// Built from `master_30bb.json.gz` (3.8 MB gzip → ~7,258 scenarios).
class DeepStackCache {
  /// All loaded scenarios from the 30BB master database.
  final List<DeepStackScenario> scenarios;
  
  /// Scenarios where the correct action (highest frequency) is 'fold'.
  final List<DeepStackScenario> foldScenarios;
  
  /// Scenarios where the correct action is 'call', 'raise', or 'allin'.
  final List<DeepStackScenario> actionScenarios;

  final Map<String, List<DeepStackScenario>> _byPosition;
  final Map<String, List<DeepStackScenario>> _byNodeKey;

  DeepStackCache._({
    required this.scenarios,
    required this.foldScenarios,
    required this.actionScenarios,
    required Map<String, List<DeepStackScenario>> byPosition,
    required Map<String, List<DeepStackScenario>> byNodeKey,
  })  : _byPosition = byPosition,
        _byNodeKey = byNodeKey;

  /// Build a [DeepStackCache] from a flat list of scenarios.
  factory DeepStackCache.from(List<DeepStackScenario> scenarios) {
    final byPosition = <String, List<DeepStackScenario>>{};
    final byNodeKey = <String, List<DeepStackScenario>>{};
    final foldScenarios = <DeepStackScenario>[];
    final actionScenarios = <DeepStackScenario>[];

    for (final scenario in scenarios) {
      if (scenario.dominantAction == 'fold') {
        foldScenarios.add(scenario);
      } else {
        actionScenarios.add(scenario);
      }

      (byPosition[scenario.position] ??= []).add(scenario);

      final nodeKey = scenario.actionHistory.isEmpty
          ? scenario.position
          : '${scenario.actionHistory}__${scenario.position}';
      (byNodeKey[nodeKey] ??= []).add(scenario);
    }

    return DeepStackCache._(
      scenarios: scenarios,
      foldScenarios: foldScenarios,
      actionScenarios: actionScenarios,
      byPosition: byPosition,
      byNodeKey: byNodeKey,
    );
  }

  /// All scenarios for a given hero [position].
  List<DeepStackScenario> getByPosition(String position) {
    return _byPosition[position] ?? const [];
  }

  /// All scenarios for a specific node key (e.g. 'UTG' or 'UTG_F__UTG1').
  List<DeepStackScenario> getByNodeKey(String nodeKey) {
    return _byNodeKey[nodeKey] ?? const [];
  }

  /// Available positions in the dataset.
  Set<String> get availablePositions => _byPosition.keys.toSet();

  /// Available node keys in the dataset.
  Set<String> get availableNodeKeys => _byNodeKey.keys.toSet();
}

// ── Isolate-safe JSON Parsing ─────────────────────────────────

/// Top-level function for [compute] — parses decompressed JSON bytes
/// into [DeepStackScenario] list.
///
/// Runs on a separate isolate to avoid blocking the UI thread.
List<DeepStackScenario> _parseDeepStackJson(String jsonStr) {
  final jsonMap = jsonDecode(jsonStr) as Map<String, dynamic>;
  final nodes = jsonMap['nodes'] as Map<String, dynamic>;
  final scenarios = <DeepStackScenario>[];

  for (final nodeEntry in nodes.entries) {
    final nodeKey = nodeEntry.key;
    final hands = nodeEntry.value as Map<String, dynamic>;

    for (final handEntry in hands.entries) {
      final freqs = (handEntry.value as List<dynamic>).cast<int>();
      scenarios.add(
        DeepStackScenario.fromNodeEntry(handEntry.key, freqs, nodeKey),
      );
    }
  }

  return scenarios;
}

// ── Provider ──────────────────────────────────────────────────

/// Loads and caches the 30BB deep stack GTO database from gzip-compressed JSON.
///
/// Uses `master_30bb.json.gz` (3.8 MB) instead of the uncompressed version
/// (20.5 MB) for smaller app bundle size.
///
/// Decompression and JSON parsing run on a background isolate via [compute]
/// to avoid janking the UI thread.
@Riverpod(keepAlive: true)
Future<DeepStackCache> deepStackData(Ref ref) async {
  debugPrint('[DeepStackDataProvider] Loading master_30bb.json.gz...');

  // Load gzip-compressed bytes from the asset bundle.
  final compressedData = await rootBundle.load('assets/db/master_30bb.json.gz');
  final compressedBytes = compressedData.buffer.asUint8List();

  // Decompress gzip → raw bytes → UTF-8 string.
  final decompressedBytes = GZipCodec().decode(compressedBytes);
  final jsonStr = utf8.decode(decompressedBytes);

  // Parse on a background isolate to avoid blocking UI.
  final scenarios = await compute(_parseDeepStackJson, jsonStr);

  debugPrint(
    '[DeepStackDataProvider] Loaded ${scenarios.length} scenarios',
  );

  return DeepStackCache.from(scenarios);
}
