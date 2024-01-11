part of 'cache_bloc.dart';

enum CacheStatus {
  initial,
  calculating,
  clearing,
  success,
}

class CacheState extends Equatable {
  const CacheState({
    this.status = CacheStatus.initial,
    this.cacheSize = 0,
  });

  final CacheStatus status;
  final int cacheSize;

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
