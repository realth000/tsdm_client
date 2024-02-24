part of 'cache_bloc.dart';

/// Status of caching
enum CacheStatus {
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
class CacheState with CacheStateMappable {
  /// Constructor.
  const CacheState({
    this.status = CacheStatus.initial,
    this.cacheSize = 0,
  });

  /// Status.
  final CacheStatus status;

  /// Calculated cache file size.
  final int cacheSize;
}
