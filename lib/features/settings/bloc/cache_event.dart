part of 'cache_bloc.dart';

/// Event of cache.
sealed class CacheEvent extends Equatable {
  const CacheEvent() : super();

  @override
  List<Object?> get props => [];
}

/// Required to calculate cache size.
final class CacheCalculateRequested extends CacheEvent {}

/// User requested to clear cache.
final class CacheClearCacheRequested extends CacheEvent {}
