part of 'settings_bloc.dart';

/// Event of app settings.
@MappableClass()
sealed class SettingsEvent with SettingsEventMappable {
  const SettingsEvent();
}

/// Settings value changed.
///
/// This is a passive event triggered in bloc.
@MappableClass()
final class SettingsMapChanged extends SettingsEvent
    with SettingsMapChangedMappable {
  /// Constructor.
  const SettingsMapChanged(this.settingsMap) : super();

  /// Latest settings.
  final SettingsMap settingsMap;
}

/// The scroll offset changed.
///
/// Passive event.
@MappableClass()
final class SettingsScrollOffsetChanged extends SettingsEvent
    with SettingsScrollOffsetChangedMappable {
  /// Constructor.
  const SettingsScrollOffsetChanged(this.offset) : super();

  /// Current scroll offset.
  final Offset offset;
}

/// User requested to change the the mode.
@MappableClass()
final class SettingsChangeThemeModeRequested extends SettingsEvent
    with SettingsChangeThemeModeRequestedMappable {
  /// Constructor.
  const SettingsChangeThemeModeRequested(this.themeIndex) : super();

  /// Theme mode index to use.
  final int themeIndex;
}

/// User required to changed the app locale.
@MappableClass()
final class SettingsChangeLocaleRequested extends SettingsEvent
    with SettingsChangeLocaleRequestedMappable {
  /// Constructor.
  const SettingsChangeLocaleRequested(this.locale) : super();

  /// Locale to use.
  final String locale;
}

/// User required to change the visibility of shortcuts on forum card.
@MappableClass()
final class SettingsChangeForumCardShortcutRequested extends SettingsEvent
    with SettingsChangeForumCardShortcutRequestedMappable {
  /// Constructor.
  const SettingsChangeForumCardShortcutRequested({required this.showShortcut})
      : super();

  /// Show shortcuts or not.
  final bool showShortcut;
}

/// User required to changed the accent color of the app.
@MappableClass()
final class SettingsChangeAccentColorRequested extends SettingsEvent
    with SettingsChangeAccentColorRequestedMappable {
  /// Constructor.
  const SettingsChangeAccentColorRequested(this.color) : super();

  /// Color to seed theme from.
  final Color color;
}

/// User required to unset the current app accent color.
@MappableClass()
final class SettingClearAccentColorRequested extends SettingsEvent
    with SettingClearAccentColorRequestedMappable {
  /// Constructor.
  const SettingClearAccentColorRequested() : super();
}

/// User required to change the feeling parameter in checkin.
@MappableClass()
final class SettingsChangeCheckinFeelingRequested extends SettingsEvent
    with SettingsChangeCheckinFeelingRequestedMappable {
  /// Constructor.
  const SettingsChangeCheckinFeelingRequested(this.checkinFeeling) : super();

  /// Feeling to use in checkin.
  final CheckinFeeling checkinFeeling;
}

/// User required to change the message parameter in checkin.
@MappableClass()
final class SettingsChangeCheckingMessageRequested extends SettingsEvent
    with SettingsChangeCheckingMessageRequestedMappable {
  /// Constructor.
  const SettingsChangeCheckingMessageRequested(this.checkinMessage) : super();

  /// Message to use in checkin.
  final String checkinMessage;
}

/// User required to change the visibility of unread info hint.
@MappableClass()
final class SettingsChangeUnreadInfoHintRequested extends SettingsEvent
    with SettingsChangeUnreadInfoHintRequestedMappable {
  /// Constructor.
  const SettingsChangeUnreadInfoHintRequested({required this.enabled})
      : super();

  /// Enable shortcuts or not.
  final bool enabled;
}

/// User requested to change the confirm exit action feature.
@MappableClass()
final class SettingsChangeDoublePressExitRequested extends SettingsEvent
    with SettingsChangeDoublePressExitRequestedMappable {
  /// Constructor.
  const SettingsChangeDoublePressExitRequested({required this.enabled})
      : super();

  /// Enable the second exit check or not.
  final bool enabled;
}
