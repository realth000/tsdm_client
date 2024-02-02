import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tsdm_client/shared/repositories/cache_repository/cache_repository.dart';

part 'cache_event.dart';
part 'cache_state.dart';

/// Bloc of using cached cubit.
class CacheBloc extends Bloc<CacheEvent, CacheState> {
  /// Constructor.
  CacheBloc({
    required CacheRepository cacheRepository,
  })  : _cacheRepository = cacheRepository,
        super(const CacheState()) {
    on<CacheCalculateRequested>(_onCacheCalculateRequested);
    on<CacheClearCacheRequested>(_onCacheClearCacheRequested);
  }

  final CacheRepository _cacheRepository;

  Future<void> _onCacheCalculateRequested(
    CacheCalculateRequested event,
    Emitter<CacheState> emit,
  ) async {
    emit(state.copyWith(status: CacheStatus.calculating));
    final cacheSize = await _cacheRepository.calculateCache();
    emit(
      state.copyWith(
        status: CacheStatus.success,
        cacheSize: cacheSize,
      ),
    );
  }

  Future<void> _onCacheClearCacheRequested(
    CacheClearCacheRequested event,
    Emitter<CacheState> emit,
  ) async {
    emit(state.copyWith(status: CacheStatus.clearing));
    await _cacheRepository.clearCache();
    emit(state.copyWith(status: CacheStatus.calculating));
    final cacheSize = await _cacheRepository.calculateCache();
    emit(
      state.copyWith(
        status: CacheStatus.success,
        cacheSize: cacheSize,
      ),
    );
  }
}
