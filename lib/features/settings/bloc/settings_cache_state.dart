part of 'settings_cache_bloc.dart';

/// Status of caching
enum SettingsCacheStatus {
  /// Initial.
  initial,

  /// Calculating cache size.
  calculating,

  /// Clearing cache files.
  clearing,

  /// Operation succeed.
  success,
}

/// State of cache.
@MappableClass()
class SettingsCacheState with SettingsCacheStateMappable {
  /// Constructor.
  const SettingsCacheState({
    this.status = SettingsCacheStatus.initial,
    this.cacheSize = 0,
  });

  /// Status.
  final SettingsCacheStatus status;

  /// Calculated cache file size.
  final int cacheSize;
}
