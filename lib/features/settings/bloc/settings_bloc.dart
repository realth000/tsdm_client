import 'dart:async';
import 'dart:ui';

import 'package:bloc/bloc.dart';
import 'package:dart_mappable/dart_mappable.dart';
import 'package:stream_transform/stream_transform.dart';
import 'package:tsdm_client/features/settings/repositories/settings_repository.dart';
import 'package:tsdm_client/shared/models/models.dart';
import 'package:tsdm_client/shared/repositories/fragments_repository/fragments_repository.dart';
import 'package:tsdm_client/utils/logger.dart';

part 'settings_bloc.mapper.dart';

part 'settings_event.dart';

part 'settings_state.dart';

/// Emitter.
typedef _Emitter = Emitter<SettingsState>;

/// Debounce of scroll offset changed event.
EventTransformer<Event> debounce<Event>(Duration duration) {
  return (events, mapper) => events.debounce(duration).switchMap(mapper);
}

/// Bloc of app settings.
class SettingsBloc extends Bloc<SettingsEvent, SettingsState> with LoggerMixin {
  /// Constructor.
  SettingsBloc({required SettingsRepository settingsRepository, required FragmentsRepository fragmentsRepository})
    : _settingsRepository = settingsRepository,
      _fragmentsRepository = fragmentsRepository,
      super(
        SettingsState(
          settingsMap: settingsRepository.currentSettings,
          scrollOffset: fragmentsRepository.settingsPageScrollOffset,
        ),
      ) {
    // Subscribe to settings map.
    _settingsMapSub = _settingsRepository.settings.listen((settings) => add(SettingsMapChanged(settings)));

    on<SettingsEvent>(
      (event, emit) async => switch (event) {
        final SettingsMapChanged e => _onSettingsMapChanged(e, emit),
        final SettingsScrollOffsetChanged e => _onSettingsScrollOffsetChanged(e, emit),
        final SettingsValueChanged<int> e => _onValueChanged<int>(e),
        final SettingsValueChanged<double> e => _onValueChanged<double>(e),
        final SettingsValueChanged<bool> e => _onValueChanged<bool>(e),
        final SettingsValueChanged<String> e => _onValueChanged<String>(e),
        final SettingsValueChanged<DateTime> e => _onValueChanged<DateTime>(e),
        final SettingsValueChanged<Offset> e => _onValueChanged<Offset>(e),
        final SettingsValueChanged<Size> e => _onValueChanged<Size>(e),
        final SettingsValueChanged<List<String>> e => _onValueChanged<List<String>>(e),
        final SettingsValueChanged<List<int>> e => _onValueChanged<List<int>>(e),
        final SettingsValueChanged<dynamic> e =>
          throw Exception(
            'Unsupported settings change event '
            'type(${e.runtimeType}): $e',
          ),
      },
    );
  }

  final SettingsRepository _settingsRepository;
  final FragmentsRepository _fragmentsRepository;
  late final StreamSubscription<SettingsMap> _settingsMapSub;

  /// Update settings map state.
  Future<void> _onSettingsMapChanged(SettingsMapChanged event, _Emitter emit) async {
    emit(state.copyWith(settingsMap: event.settingsMap));
  }

  Future<void> _onSettingsScrollOffsetChanged(SettingsScrollOffsetChanged event, _Emitter emit) async {
    _fragmentsRepository.settingsPageScrollOffset = event.offset;
  }

  Future<void> _onValueChanged<T>(SettingsValueChanged<T> event) async {
    debug('settings value changed: ${event.settings.name}<$T>: ${event.value}');
    await _settingsRepository.setValue<T>(event.settings, event.value);
  }

  @override
  Future<void> close() async {
    await _settingsMapSub.cancel();
    await super.close();
  }
}
