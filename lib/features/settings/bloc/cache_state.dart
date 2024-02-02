part of 'cache_bloc.dart';

/// Status of cacheing
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
class CacheState extends Equatable {
  /// Constructor.
  const CacheState({
    this.status = CacheStatus.initial,
    this.cacheSize = 0,
  });

  /// Status.
  final CacheStatus status;
  /// Calculated cache file size.
  final int cacheSize;

  /// Copy with.
  CacheState copyWith({
    CacheStatus? status,
    int? cacheSize,
  }) {
    return CacheState(
      status: status ?? this.status,
      cacheSize: cacheSize ?? this.cacheSize,
    );
  }

  @override
  List<Object?> get props => [status, cacheSize];
}
