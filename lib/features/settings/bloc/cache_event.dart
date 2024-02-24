part of 'cache_bloc.dart';

/// Event of cache.
@MappableClass()
sealed class CacheEvent with CacheEventMappable {
  const CacheEvent() : super();
}

/// Required to calculate cache size.
@MappableClass()
final class CacheCalculateRequested extends CacheEvent
    with CacheCalculateRequestedMappable {}

/// User requested to clear cache.
@MappableClass()
final class CacheClearCacheRequested extends CacheEvent
    with CacheClearCacheRequestedMappable {}
