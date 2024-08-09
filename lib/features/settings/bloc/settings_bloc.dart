import 'dart:async';
import 'dart:ui';

import 'package:bloc/bloc.dart';
import 'package:dart_mappable/dart_mappable.dart';
import 'package:stream_transform/stream_transform.dart';
import 'package:tsdm_client/features/settings/repositories/settings_repository.dart';
import 'package:tsdm_client/shared/models/models.dart';
import 'package:tsdm_client/shared/repositories/fragments_repository/fragments_repository.dart';

part '../../../generated/features/settings/bloc/settings_bloc.mapper.dart';
part 'settings_event.dart';
part 'settings_state.dart';

const _scrollDebounceDuration = Duration(milliseconds: 300);

/// Emitter.
typedef _Emitter = Emitter<SettingsState>;

/// Debounce of scroll offset changed event.
EventTransformer<Event> debounce<Event>(Duration duration) {
  return (events, mapper) => events.debounce(duration).switchMap(mapper);
}

/// Bloc of app settings.
class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  /// Constructor.
  SettingsBloc({
    required SettingsRepository settingsRepository,
    required FragmentsRepository fragmentsRepository,
  })  : _settingsRepository = settingsRepository,
        _fragmentsRepository = fragmentsRepository,
        super(
          SettingsState(
            settingsMap: settingsRepository.currentSettings,
            scrollOffset: fragmentsRepository.settingsPageScrollOffset,
          ),
        ) {
    // Subscribe to settings map.
    _settingsMapSub = _settingsRepository.settings
        .listen((settings) => add(SettingsMapChanged(settings)));

    on<SettingsMapChanged>(_onSettingsMapChanged);
    on<SettingsScrollOffsetChanged>(
      _onSettingsScrollOffsetChanged,
      transformer: debounce(_scrollDebounceDuration),
    );
    on<SettingsEvent>(
      (event, emit) async => switch (event) {
        final SettingsMapChanged e => _onSettingsMapChanged(e, emit),
        final SettingsScrollOffsetChanged e =>
          _onSettingsScrollOffsetChanged(e, emit),
        final SettingsValueChanged<dynamic> e => _onSettingsValueChanged(
            e,
            emit,
          ),
      },
    );
  }

  final SettingsRepository _settingsRepository;
  final FragmentsRepository _fragmentsRepository;
  late final StreamSubscription<SettingsMap> _settingsMapSub;

  /// Update settings map state.
  Future<void> _onSettingsMapChanged(
    SettingsMapChanged event,
    _Emitter emit,
  ) async {
    emit(state.copyWith(settingsMap: event.settingsMap));
  }

  Future<void> _onSettingsScrollOffsetChanged(
    SettingsScrollOffsetChanged event,
    _Emitter emit,
  ) async {
    _fragmentsRepository.settingsPageScrollOffset = event.offset;
  }

  Future<void> _onSettingsValueChanged<T>(
    SettingsValueChanged<T> event,
    _Emitter emit,
  ) async {
    await _settingsRepository.setValue<T>(event.settings, event.value);
  }

  @override
  Future<void> close() async {
    await _settingsMapSub.cancel();
    await super.close();
  }
}
