import 'package:dart_mappable/dart_mappable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tsdm_client/features/settings/models/models.dart';
import 'package:tsdm_client/features/settings/repositories/settings_cache_repository.dart';

part 'settings_cache_bloc.mapper.dart';

part 'settings_cache_event.dart';

part 'settings_cache_state.dart';

/// Bloc of using cached cubit.
class SettingsCacheBloc extends Bloc<SettingsCacheEvent, SettingsCacheState> {
  /// Constructor.
  SettingsCacheBloc({required SettingsCacheRepository cacheRepository})
    : _cacheRepository = cacheRepository,
      super(const SettingsCacheState()) {
    on<SettingsCacheCalculateRequested>(_onCacheCalculateRequested);
    on<SettingsCacheClearCacheRequested>(_onCacheClearCacheRequested);
    on<SettingsCacheUpdateClearInfoRequested>(_onSettingsCacheUpdateClearInfoRequested);
  }

  final SettingsCacheRepository _cacheRepository;

  Future<void> _onCacheCalculateRequested(
    SettingsCacheCalculateRequested event,
    Emitter<SettingsCacheState> emit,
  ) async {
    emit(state.copyWith(status: SettingsCacheStatus.calculating));
    final storageInfo = await _cacheRepository.calculateCache();
    emit(state.copyWith(status: SettingsCacheStatus.loaded, storageInfo: storageInfo));
  }

  Future<void> _onCacheClearCacheRequested(
    SettingsCacheClearCacheRequested event,
    Emitter<SettingsCacheState> emit,
  ) async {
    emit(state.copyWith(status: SettingsCacheStatus.clearing));
    await _cacheRepository.clearCache(event.clearInfo);
    emit(state.copyWith(status: SettingsCacheStatus.calculating));
    final storageInfo = await _cacheRepository.calculateCache();
    emit(state.copyWith(status: SettingsCacheStatus.cleared, storageInfo: storageInfo));
  }

  Future<void> _onSettingsCacheUpdateClearInfoRequested(
    SettingsCacheUpdateClearInfoRequested event,
    Emitter<SettingsCacheState> emit,
  ) async {
    emit(state.copyWith(clearInfo: event.clearInfo));
  }
}
