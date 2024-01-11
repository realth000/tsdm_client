part of 'settings_bloc.dart';

sealed class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object?> get props => [];
}

/// Settings value changed.
///
/// This is a passive event triggered in bloc.
final class _SettingsMapChanged extends SettingsEvent {
  const _SettingsMapChanged(this.settingsMap) : super();
  final SettingsMap settingsMap;
}

final class _SettingsScrollOffsetChanged extends SettingsEvent {
  const _SettingsScrollOffsetChanged(this.offset) : super();
  final Offset offset;
}

final class SettingsChangeThemeModeRequested extends SettingsEvent {
  const SettingsChangeThemeModeRequested(this.themeIndex) : super();

  final int themeIndex;

  @override
  List<Object?> get props => [themeIndex];
}

final class SettingsChangeLocaleRequested extends SettingsEvent {
  const SettingsChangeLocaleRequested(this.locale) : super();
  final String locale;

  @override
  List<Object?> get props => [locale];
}

final class SettingsChangeForumCardShortcutRequested extends SettingsEvent {
  const SettingsChangeForumCardShortcutRequested({required this.showShortcut})
      : super();
  final bool showShortcut;

  @override
  List<Object?> get props => [showShortcut];
}

final class SettingsChangeAccentColorRequested extends SettingsEvent {
  const SettingsChangeAccentColorRequested(this.color) : super();
  final Color color;

  @override
  List<Object?> get props => [color];
}

final class SettingClearAccentColorRequested extends SettingsEvent {
  const SettingClearAccentColorRequested() : super();
}

final class SettingsChangeCheckinFeelingRequested extends SettingsEvent {
  const SettingsChangeCheckinFeelingRequested(this.checkinFeeling) : super();
  final CheckinFeeling checkinFeeling;

  @override
  List<Object?> get props => [checkinFeeling];
}

final class SettingsChangeCheckingMessageRequested extends SettingsEvent {
  const SettingsChangeCheckingMessageRequested(this.checkinMessage) : super();
  final String checkinMessage;

  @override
  List<Object?> get props => [checkinMessage];
}

// final class SettingsClearCacheRequested extends SettingsEvent {}
