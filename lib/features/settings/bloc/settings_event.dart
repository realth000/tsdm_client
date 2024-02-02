part of 'settings_bloc.dart';

/// Event of app settings.
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

/// User requested to change the the mode.
final class SettingsChangeThemeModeRequested extends SettingsEvent {
  /// Constructor.
  const SettingsChangeThemeModeRequested(this.themeIndex) : super();

  /// Theme mode index to use.
  final int themeIndex;

  @override
  List<Object?> get props => [themeIndex];
}

/// User required to changed the app locale.
final class SettingsChangeLocaleRequested extends SettingsEvent {
  /// Constructor.
  const SettingsChangeLocaleRequested(this.locale) : super();

  /// Locale to use.
  final String locale;

  @override
  List<Object?> get props => [locale];
}

/// User required to change the visibility of shortcuts on forum card.
final class SettingsChangeForumCardShortcutRequested extends SettingsEvent {
  /// Constructor.
  const SettingsChangeForumCardShortcutRequested({required this.showShortcut})
      : super();

  /// Show shortcuts or not.
  final bool showShortcut;

  @override
  List<Object?> get props => [showShortcut];
}

/// User required to changed the accent color of the app.
final class SettingsChangeAccentColorRequested extends SettingsEvent {
  /// Constructor.
  const SettingsChangeAccentColorRequested(this.color) : super();

  /// Color to seed theme from.
  final Color color;

  @override
  List<Object?> get props => [color];
}

/// User required to unset the current app accent color.
final class SettingClearAccentColorRequested extends SettingsEvent {
  /// Constructor.
  const SettingClearAccentColorRequested() : super();
}

/// User required to change the feeing paramter in checkin.
final class SettingsChangeCheckinFeelingRequested extends SettingsEvent {
  /// Constructor.
  const SettingsChangeCheckinFeelingRequested(this.checkinFeeling) : super();

  /// Feeling to use in checkin.
  final CheckinFeeling checkinFeeling;

  @override
  List<Object?> get props => [checkinFeeling];
}

/// User required to change the message paramter in checkin.
final class SettingsChangeCheckingMessageRequested extends SettingsEvent {
  /// Constructor.
  const SettingsChangeCheckingMessageRequested(this.checkinMessage) : super();

  /// Message to use in checkin.
  final String checkinMessage;

  @override
  List<Object?> get props => [checkinMessage];
}
