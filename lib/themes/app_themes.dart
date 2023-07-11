import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:tsdm_client/utils/platform.dart';

/// App themes.
class AppTheme {
  static const _cardTheme = CardTheme(
    elevation: 1,
  );

  static const _chipTheme = ChipThemeData(
    padding: EdgeInsets.all(2),
  );

  static final String? _fontFamily = isWindows ? 'Microsoft YaHei' : null;

  /// Global theme for [ListTile].
  static const _listTileTheme = ListTileThemeData(
    visualDensity: VisualDensity.standard,
    contentPadding: EdgeInsets.symmetric(horizontal: 10),
    horizontalTitleGap: 10,
  );

  /// App light theme.
  static final light = FlexThemeData.light(
    fontFamily: _fontFamily,
    scheme: FlexScheme.bahamaBlue,
    tabBarStyle: FlexTabBarStyle.forBackground,
    tooltipsMatchBackground: true,
    subThemesData: const FlexSubThemesData(
      outlinedButtonPressedBorderWidth: 1.5,
      sliderValueTinted: true,
      sliderTrackHeight: 5,
      inputDecoratorFocusedBorderWidth: 2,
      fabUseShape: true,
      dialogBackgroundSchemeColor: SchemeColor.tertiaryContainer,
      snackBarBackgroundSchemeColor: SchemeColor.tertiaryContainer,
      bottomNavigationBarShowUnselectedLabels: false,
      navigationBarLabelBehavior:
          NavigationDestinationLabelBehavior.onlyShowSelected,
      navigationRailLabelType: NavigationRailLabelType.selected,
    ),
    keyColors: const FlexKeyColors(
      useSecondary: true,
      useTertiary: true,
    ),
    visualDensity: FlexColorScheme.comfortablePlatformDensity,
    useMaterial3: true,
  ).copyWith(
    cardTheme: _cardTheme,
    chipTheme: _chipTheme,
    listTileTheme: _listTileTheme,
  );

  /// App dark themes.
  static final dark = FlexThemeData.dark(
    fontFamily: _fontFamily,
    scheme: FlexScheme.bahamaBlue,
    tabBarStyle: FlexTabBarStyle.forBackground,
    tooltipsMatchBackground: true,
    subThemesData: const FlexSubThemesData(
      outlinedButtonPressedBorderWidth: 1.5,
      sliderValueTinted: true,
      sliderTrackHeight: 5,
      inputDecoratorFocusedBorderWidth: 2,
      fabUseShape: true,
      dialogBackgroundSchemeColor: SchemeColor.tertiaryContainer,
      snackBarBackgroundSchemeColor: SchemeColor.tertiaryContainer,
      bottomNavigationBarShowUnselectedLabels: false,
      navigationBarLabelBehavior:
          NavigationDestinationLabelBehavior.onlyShowSelected,
      navigationRailLabelType: NavigationRailLabelType.selected,
    ),
    keyColors: const FlexKeyColors(
      useSecondary: true,
      useTertiary: true,
    ),
    visualDensity: FlexColorScheme.comfortablePlatformDensity,
    useMaterial3: true,
  ).copyWith(
    cardTheme: _cardTheme,
    chipTheme: _chipTheme,
    listTileTheme: _listTileTheme,
  );
}
// If you do not have a themeMode switch, uncomment this line
// to let the device system mode control the theme mode:
// themeMode: ThemeMode.system,
