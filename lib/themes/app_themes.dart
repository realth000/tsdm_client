import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';

/// App themes.
class AppTheme {
  static CardTheme _buildCardTheme() => const CardTheme(
        elevation: 0,
      );

  static ChipThemeData _buildChipTheme() => const ChipThemeData(
        padding: EdgeInsets.all(2),
      );

  /// Global theme for [ListTile].
  static ListTileThemeData _buildListTileTheme() => const ListTileThemeData(
        visualDensity: VisualDensity.standard,
        contentPadding: EdgeInsets.symmetric(horizontal: 10),
        horizontalTitleGap: 10,
      );

  static NavigationDrawerThemeData _buildNavigationDrawerTheme(
    ColorScheme? colorScheme,
  ) =>
      NavigationDrawerThemeData(
        labelTextStyle: WidgetStateProperty.resolveWith((state) {
          if (state.contains(WidgetState.selected)) {
            return TextStyle(color: colorScheme?.primary);
          }
          return null;
        }),
        iconTheme: WidgetStateProperty.resolveWith((state) {
          if (state.contains(WidgetState.selected)) {
            return IconThemeData(color: colorScheme?.primary);
          }
          return null;
        }),
      );

  /// App light theme.
  static ThemeData makeLight(BuildContext context, [Color? seedColor]) {
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
            NavigationDestinationLabelBehavior.alwaysShow,
        navigationRailLabelType: NavigationRailLabelType.all,
        drawerRadius: 0,
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
      cardTheme: _buildCardTheme(),
      chipTheme: _buildChipTheme(),
      listTileTheme: _buildListTileTheme(),
      navigationDrawerTheme: _buildNavigationDrawerTheme(seedScheme),
    );
  }

  /// App dark themes.
  static ThemeData makeDark(BuildContext context, [Color? seedColor]) {
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
            NavigationDestinationLabelBehavior.alwaysShow,
        navigationRailLabelType: NavigationRailLabelType.all,
        drawerRadius: 0,
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
      cardTheme: _buildCardTheme(),
      chipTheme: _buildChipTheme(),
      listTileTheme: _buildListTileTheme(),
      navigationDrawerTheme: _buildNavigationDrawerTheme(seedScheme),
    );
  }
}
// If you do not have a themeMode switch, uncomment this line
// to let the device system mode control the theme mode:
// themeMode: ThemeMode.system,
