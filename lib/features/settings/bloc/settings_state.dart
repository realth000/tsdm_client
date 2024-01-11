part of 'settings_bloc.dart';

/// Settings page only have success status.
enum SettingsStatus {
  initial,
  success,
}

/// State of settings page.
class SettingsState extends Equatable {
  const SettingsState({
    required this.settingsMap,
    this.status = SettingsStatus.initial,
    this.scrollOffset = Offset.zero,
  });

  final SettingsStatus status;

  /// Current settings values.
  final SettingsMap settingsMap;

  /// Scroll offset.
  final Offset scrollOffset;

  SettingsState copyWith({
    SettingsStatus? status,
    SettingsMap? settingsMap,
    Offset? scrollOffset,
  }) {
    return SettingsState(
      status: status ?? this.status,
      settingsMap: settingsMap ?? this.settingsMap,
      scrollOffset: scrollOffset ?? this.scrollOffset,
    );
  }

  @override
  List<Object?> get props => [status, settingsMap, scrollOffset];
}
