part of 'settings_bloc.dart';

/// Settings page only have success status.
enum SettingsStatus {
  /// Initial.
  initial,

  /// Success.
  success,
}

/// State of settings page.
@MappableClass()
class SettingsState with SettingsStateMappable {
  /// Constructor.
  const SettingsState({
    required this.settingsMap,
    this.status = SettingsStatus.initial,
    this.scrollOffset = Offset.zero,
  });

  /// Status.
  final SettingsStatus status;

  /// Current settings values.
  final SettingsMap settingsMap;

  /// Scroll offset.
  final Offset scrollOffset;
}
