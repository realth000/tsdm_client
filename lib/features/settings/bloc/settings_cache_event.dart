part of 'settings_cache_bloc.dart';

/// Event of cache.
@MappableClass()
sealed class SettingsCacheEvent with SettingsCacheEventMappable {
  const SettingsCacheEvent() : super();
}

/// Required to calculate cache size.
@MappableClass()
final class SettingsCacheCalculateRequested extends SettingsCacheEvent
    with SettingsCacheCalculateRequestedMappable {}

/// User requested to clear cache.
@MappableClass()
final class SettingsCacheClearCacheRequested extends SettingsCacheEvent
    with SettingsCacheClearCacheRequestedMappable {}
