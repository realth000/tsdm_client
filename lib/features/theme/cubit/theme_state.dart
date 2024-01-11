part of 'theme_cubit.dart';

final class ThemeState extends Equatable {
  const ThemeState({this.accentColor, this.themeModeIndex = 0});

  final Color? accentColor;

  final int themeModeIndex;

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
