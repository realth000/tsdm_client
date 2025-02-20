import 'dart:ui';

import 'package:bloc/bloc.dart';
import 'package:dart_mappable/dart_mappable.dart';

part 'theme_cubit.mapper.dart';
part 'theme_state.dart';

/// Cubit controlling app theme.
class ThemeCubit extends Cubit<ThemeState> {
  /// Constructor.
  ThemeCubit({Color? accentColor, int themeModeIndex = 0, String fontFamily = ''})
    : super(ThemeState(accentColor: accentColor, themeModeIndex: themeModeIndex, fontFamily: fontFamily));

  /// Set the accent color.
  void setAccentColor(Color accentColor) => emit(state.copyWith(accentColor: accentColor));

  /// Set the app the mode by its index.
  void setThemeModeIndex(int themeModeIndex) => emit(state.copyWith(themeModeIndex: themeModeIndex));

  /// Set the font family to [fontFamily].
  void setFontFamily(String fontFamily) => emit(state.copyWith(fontFamily: fontFamily));
}
