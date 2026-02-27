// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'deep_stack_data_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Loads and caches the 30BB deep stack GTO database from gzip-compressed JSON.
///
/// Uses `master_30bb.json.gz` (3.8 MB) instead of the uncompressed version
/// (20.5 MB) for smaller app bundle size.
///
/// Decompression and JSON parsing run on a background isolate via [compute]
/// to avoid janking the UI thread.

@ProviderFor(deepStackData)
final deepStackDataProvider = DeepStackDataProvider._();

/// Loads and caches the 30BB deep stack GTO database from gzip-compressed JSON.
///
/// Uses `master_30bb.json.gz` (3.8 MB) instead of the uncompressed version
/// (20.5 MB) for smaller app bundle size.
///
/// Decompression and JSON parsing run on a background isolate via [compute]
/// to avoid janking the UI thread.

final class DeepStackDataProvider extends $FunctionalProvider<
        AsyncValue<DeepStackCache>, DeepStackCache, FutureOr<DeepStackCache>>
    with $FutureModifier<DeepStackCache>, $FutureProvider<DeepStackCache> {
  /// Loads and caches the 30BB deep stack GTO database from gzip-compressed JSON.
  ///
  /// Uses `master_30bb.json.gz` (3.8 MB) instead of the uncompressed version
  /// (20.5 MB) for smaller app bundle size.
  ///
  /// Decompression and JSON parsing run on a background isolate via [compute]
  /// to avoid janking the UI thread.
  DeepStackDataProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'deepStackDataProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$deepStackDataHash();

  @$internal
  @override
  $FutureProviderElement<DeepStackCache> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<DeepStackCache> create(Ref ref) {
    return deepStackData(ref);
  }
}

String _$deepStackDataHash() => r'3df321e28c9dfff4788c21bc09620ad4f3f71bee';
