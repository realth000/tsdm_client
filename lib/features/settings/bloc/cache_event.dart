part of 'cache_bloc.dart';

sealed class CacheEvent extends Equatable {
  const CacheEvent() : super();

  @override
  List<Object?> get props => [];
}

final class CacheCalculateRequested extends CacheEvent {}

final class CacheClearCacheRequested extends CacheEvent {}
