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
  static ThemeData makeLight([Color? seedColor]) {
    ColorScheme? seedScheme;
    if (seedColor != null) {
      seedScheme = ColorScheme.fromSeed(seedColor: seedColor);
    }
    return FlexThemeData.light(
      primary: seedScheme?.primary,
      onPrimary: seedScheme?.onPrimary,
      primaryContainer: seedScheme?.primaryContainer,
      onPrimaryContainer: seedScheme?.onPrimaryContainer,
      secondary: seedScheme?.secondary,
      onSecondary: seedScheme?.onSecondary,
      secondaryContainer: seedScheme?.secondaryContainer,
      onSecondaryContainer: seedScheme?.onSecondaryContainer,
      tertiary: seedScheme?.tertiary,
      onTertiary: seedScheme?.onTertiary,
      tertiaryContainer: seedScheme?.tertiaryContainer,
      onTertiaryContainer: seedScheme?.onTertiaryContainer,
      error: seedScheme?.error,
      onError: seedScheme?.onError,
      surface: seedScheme?.surface,
      onSurface: seedScheme?.onSurface,
      background: seedScheme?.surface,
      onBackground: seedScheme?.onSurface,
      surfaceTint: seedScheme?.surfaceTint,
      fontFamily: _fontFamily,
      scheme: seedColor == null
          ? FlexScheme.bahamaBlue
          : FlexScheme.materialBaseline,
      tabBarStyle: FlexTabBarStyle.forBackground,
      tooltipsMatchBackground: true,
      subThemesData: const FlexSubThemesData(
        outlinedButtonPressedBorderWidth: 1.5,
        sliderValueTinted: true,
        sliderTrackHeight: 5,
        inputDecoratorFocusedBorderWidth: 2,
        fabUseShape: true,
        bottomNavigationBarShowUnselectedLabels: false,
        navigationBarLabelBehavior:
            NavigationDestinationLabelBehavior.onlyShowSelected,
        navigationRailLabelType: NavigationRailLabelType.selected,
      ),
      keyColors: const FlexKeyColors(
        useKeyColors: false,
        useSecondary: true,
        useTertiary: true,
      ),
      visualDensity: FlexColorScheme.comfortablePlatformDensity,
      useMaterial3: true,
    ).copyWith(
      colorScheme: seedScheme,
      cardTheme: _cardTheme,
      chipTheme: _chipTheme,
      listTileTheme: _listTileTheme,
    );
  }

  /// App dark themes.
  static ThemeData makeDark([Color? seedColor]) {
    ColorScheme? seedScheme;
    if (seedColor != null) {
      seedScheme = ColorScheme.fromSeed(
        seedColor: seedColor,
        brightness: Brightness.dark,
      );
    }
    return FlexThemeData.dark(
      primary: seedScheme?.primary,
      onPrimary: seedScheme?.onPrimary,
      primaryContainer: seedScheme?.primaryContainer,
      onPrimaryContainer: seedScheme?.onPrimaryContainer,
      secondary: seedScheme?.secondary,
      onSecondary: seedScheme?.onSecondary,
      secondaryContainer: seedScheme?.secondaryContainer,
      onSecondaryContainer: seedScheme?.onSecondaryContainer,
      tertiary: seedScheme?.tertiary,
      onTertiary: seedScheme?.onTertiary,
      tertiaryContainer: seedScheme?.tertiaryContainer,
      onTertiaryContainer: seedScheme?.onTertiaryContainer,
      error: seedScheme?.error,
      onError: seedScheme?.onError,
      surface: seedScheme?.surface,
      onSurface: seedScheme?.onSurface,
      background: seedScheme?.surface,
      onBackground: seedScheme?.onSurface,
      surfaceTint: seedScheme?.surfaceTint,
      fontFamily: _fontFamily,
      scheme: seedColor == null ? FlexScheme.bahamaBlue : FlexScheme.material,
      tabBarStyle: FlexTabBarStyle.forBackground,
      tooltipsMatchBackground: true,
      subThemesData: const FlexSubThemesData(
        outlinedButtonPressedBorderWidth: 1.5,
        sliderValueTinted: true,
        sliderTrackHeight: 5,
        inputDecoratorFocusedBorderWidth: 2,
        fabUseShape: true,
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
      colorScheme: seedScheme,
      cardTheme: _cardTheme,
      chipTheme: _chipTheme,
      listTileTheme: _listTileTheme,
    );
  }
}
// If you do not have a themeMode switch, uncomment this line
// to let the device system mode control the theme mode:
// themeMode: ThemeMode.system,
