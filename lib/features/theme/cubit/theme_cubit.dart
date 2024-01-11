import 'dart:ui';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'theme_state.dart';

class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit({
    Color? accentColor,
    int themeModeIndex = 0,
  }) : super(ThemeState(
          accentColor: accentColor,
          themeModeIndex: themeModeIndex,
        ));

  void setAccentColor(Color accentColor) =>
      emit(state.copyWith(accentColor: accentColor));

  void clearAccentColor() =>
      emit(ThemeState(accentColor: null, themeModeIndex: state.themeModeIndex));

  void setThemeModeIndex(int themeModeIndex) =>
      emit(state.copyWith(themeModeIndex: themeModeIndex));
}
