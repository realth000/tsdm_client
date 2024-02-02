part of 'theme_cubit.dart';

/// State of theme.
final class ThemeState extends Equatable {
  /// Constructor.
  const ThemeState({this.accentColor, this.themeModeIndex = 0});

  /// Currnet using app accent color.
  final Color? accentColor;

  /// Current using app theme mode index.
  final int themeModeIndex;

  /// Copy with.
  ThemeState copyWith({
    Color? accentColor,
    int? themeModeIndex,
  }) {
    return ThemeState(
      accentColor: accentColor ?? this.accentColor,
      themeModeIndex: themeModeIndex ?? this.themeModeIndex,
    );
  }

  @override
  List<Object?> get props => [accentColor, themeModeIndex];
}
