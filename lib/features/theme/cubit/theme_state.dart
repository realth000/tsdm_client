part of 'theme_cubit.dart';

/// State of theme.
@MappableClass()
final class ThemeState with ThemeStateMappable {
  /// Constructor.
  const ThemeState({this.accentColor, this.themeModeIndex = 0, this.fontFamily = ''});

  /// Current using app accent color.
  final Color? accentColor;

  /// Current using app theme mode index.
  final int themeModeIndex;

  /// Font family
  final String fontFamily;
}
