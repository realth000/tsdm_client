part of 'settings_cache_bloc.dart';

/// Status of caching
enum SettingsCacheStatus {
  /// Initial.
  initial,

  /// Calculating cache size.
  calculating,

  /// Clearing cache files.
  clearing,

  /// Info succeed.
  loaded,

  /// Clear action finished.
  cleared,
}

/// State of cache.
@MappableClass()
class SettingsCacheState with SettingsCacheStateMappable {
  /// Constructor.
  const SettingsCacheState({
    this.status = SettingsCacheStatus.initial,
    this.storageInfo,
    this.clearInfo = CacheClearInfo.defaultCacheClearInfo,
  });

  /// Status.
  final SettingsCacheStatus status;

  /// Calculated cache info.
  final CacheStorageInfo? storageInfo;

  /// What kind of cache to clear.
  final CacheClearInfo clearInfo;
}
