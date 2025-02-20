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
final class SettingsMapChanged extends SettingsEvent with SettingsMapChangedMappable {
  /// Constructor.
  const SettingsMapChanged(this.settingsMap) : super();

  /// Latest settings.
  final SettingsMap settingsMap;
}

/// The scroll offset changed.
///
/// Passive event.
@MappableClass()
final class SettingsScrollOffsetChanged extends SettingsEvent with SettingsScrollOffsetChangedMappable {
  /// Constructor.
  const SettingsScrollOffsetChanged(this.offset) : super();

  /// Current scroll offset.
  final Offset offset;
}

/// Event contains changes on settings.
///
/// The changed settings is [settings], new value is [value].
/// Caller MUST guarantee [value] is the value type record in [settings].
@MappableClass()
final class SettingsValueChanged<T> extends SettingsEvent with SettingsValueChangedMappable<T> {
  /// Constructor.
  const SettingsValueChanged(this.settings, this.value) : super();

  /// Settings that changed.
  final SettingsKeys<T> settings;

  /// New value.
  final T value;
}
