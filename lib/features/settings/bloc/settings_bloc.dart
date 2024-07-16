import 'dart:async';
import 'dart:ui';

import 'package:bloc/bloc.dart';
import 'package:dart_mappable/dart_mappable.dart';
import 'package:stream_transform/stream_transform.dart';
import 'package:tsdm_client/shared/providers/checkin_provider/models/check_in_feeling.dart';
import 'package:tsdm_client/shared/providers/storage_provider/models/models.dart';
import 'package:tsdm_client/shared/repositories/fragments_repository/fragments_repository.dart';
import 'package:tsdm_client/shared/repositories/settings_repository/settings_repository.dart';

part '../../../generated/features/settings/bloc/settings_bloc.mapper.dart';
part 'settings_event.dart';
part 'settings_state.dart';

const _scrollDebounceDuration = Duration(milliseconds: 300);

/// Emitter.
typedef SettingsEmitter = Emitter<SettingsState>;

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

    // TODO: Refactor, use exhaustive switch.
    on<SettingsMapChanged>(_onSettingsMapChanged);
    on<SettingsScrollOffsetChanged>(
      _onSettingsScrollOffsetChanged,
      transformer: debounce(_scrollDebounceDuration),
    );
    on<SettingsChangeThemeModeRequested>(_onSettingsChangeThemeModeRequested);
    on<SettingsChangeLocaleRequested>(_onSettingsChangeLocaleRequested);
    on<SettingsChangeForumCardShortcutRequested>(
      _onSettingsChangeForumCardShortcutRequested,
    );
    on<SettingsChangeAccentColorRequested>(
      _onSettingsChangeAccentColorRequested,
    );
    on<SettingClearAccentColorRequested>(_onSettingsClearAccentColorRequested);
    on<SettingsChangeCheckinFeelingRequested>(
      _onSettingsChangeCheckinFeelingRequested,
    );
    on<SettingsChangeCheckingMessageRequested>(
      _onSettingsChangeCheckinMessageRequested,
    );
    on<SettingsChangeUnreadInfoHintRequested>(
      _onSettingsChangeUnreadInfoHintRequested,
    );
    on<SettingsChangeDoublePressExitRequested>(
      _onSettingsChangeDoublePressExitRequested,
    );
    on<SettingsChangeThreadReverseOrderRequested>(
      _onSettingsChangeThreadReverseOrderRequested,
    );
    on<SettingsChangeThreadCardInfoRowAlignCenterRequested>(
      _onSettingsChangeThreadCardInfoRowAlignCenterRequested,
    );
    on<SettingsChangeThreadCardShowLastReplyAuthorRequested>(
      _onSettingsChangeThreadCardShowLastReplyAuthorRequested,
    );
  }

  final SettingsRepository _settingsRepository;
  final FragmentsRepository _fragmentsRepository;
  late final StreamSubscription<SettingsMap> _settingsMapSub;

  /// Update settings map state.
  Future<void> _onSettingsMapChanged(
    SettingsMapChanged event,
    SettingsEmitter emit,
  ) async {
    emit(state.copyWith(settingsMap: event.settingsMap));
  }

  Future<void> _onSettingsScrollOffsetChanged(
    SettingsScrollOffsetChanged event,
    SettingsEmitter emit,
  ) async {
    _fragmentsRepository.settingsPageScrollOffset = event.offset;
  }

  Future<void> _onSettingsChangeThemeModeRequested(
    SettingsChangeThemeModeRequested event,
    SettingsEmitter emit,
  ) async {
    await _settingsRepository.setThemeMode(event.themeIndex);
  }

  Future<void> _onSettingsChangeLocaleRequested(
    SettingsChangeLocaleRequested event,
    SettingsEmitter emit,
  ) async {
    await _settingsRepository.setLocale(event.locale);
  }

  Future<void> _onSettingsChangeForumCardShortcutRequested(
    SettingsChangeForumCardShortcutRequested event,
    SettingsEmitter emit,
  ) async {
    await _settingsRepository.setShowShortcutInForumCard(
      visible: event.showShortcut,
    );
  }

  Future<void> _onSettingsChangeAccentColorRequested(
    SettingsChangeAccentColorRequested event,
    SettingsEmitter emit,
  ) async {
    await _settingsRepository.setAccentColor(event.color);
  }

  Future<void> _onSettingsClearAccentColorRequested(
    SettingClearAccentColorRequested event,
    SettingsEmitter emit,
  ) async {
    await _settingsRepository.clearAccentColor();
  }

  Future<void> _onSettingsChangeCheckinFeelingRequested(
    SettingsChangeCheckinFeelingRequested event,
    SettingsEmitter emit,
  ) async {
    await _settingsRepository
        .setCheckinFeeling(event.checkinFeeling.toString());
  }

  Future<void> _onSettingsChangeCheckinMessageRequested(
    SettingsChangeCheckingMessageRequested event,
    SettingsEmitter emit,
  ) async {
    await _settingsRepository.setCheckinMessage(event.checkinMessage);
  }

  Future<void> _onSettingsChangeUnreadInfoHintRequested(
    SettingsChangeUnreadInfoHintRequested event,
    SettingsEmitter emit,
  ) async {
    await _settingsRepository.setShowUnreadInfoHint(enabled: event.enabled);
  }

  Future<void> _onSettingsChangeDoublePressExitRequested(
    SettingsChangeDoublePressExitRequested event,
    SettingsEmitter emit,
  ) async {
    await _settingsRepository.setDoublePressExit(enabled: event.enabled);
  }

  Future<void> _onSettingsChangeThreadReverseOrderRequested(
    SettingsChangeThreadReverseOrderRequested event,
    SettingsEmitter emit,
  ) async {
    await _settingsRepository.setThreadReverseOrder(enabled: event.enabled);
  }

  Future<void> _onSettingsChangeThreadCardInfoRowAlignCenterRequested(
    SettingsChangeThreadCardInfoRowAlignCenterRequested event,
    SettingsEmitter emit,
  ) async {
    await _settingsRepository.setThreadCardInfoRowAlignCenter(
      enabled: event.enabled,
    );
  }

  Future<void> _onSettingsChangeThreadCardShowLastReplyAuthorRequested(
    SettingsChangeThreadCardShowLastReplyAuthorRequested event,
    SettingsEmitter emit,
  ) async {
    await _settingsRepository.setThreadCardShowLastReplyAuthor(
      enabled: event.enabled,
    );
  }

  @override
  Future<void> close() async {
    await _settingsMapSub.cancel();
    await super.close();
  }
}
