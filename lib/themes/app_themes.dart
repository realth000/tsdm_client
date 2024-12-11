import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';

/// App themes.
class AppTheme {
  static const FlexSubThemesData _subThemesData = FlexSubThemesData(
    interactionEffects: true,
    tintedDisabledControls: true,
    blendOnLevel: 10,
    outlinedButtonPressedBorderWidth: 1.5,
    sliderValueTinted: true,
    sliderTrackHeight: 5,
    inputDecoratorFocusedBorderWidth: 2,
    inputDecoratorBorderType: FlexInputBorderType.outline,
    fabUseShape: true,
    bottomNavigationBarShowUnselectedLabels: false,
    alignedDropdown: true,

    // Navigation bar
    navigationBarSelectedLabelSchemeColor: SchemeColor.primary,
    navigationBarSelectedIconSchemeColor: SchemeColor.primary,
    navigationBarMutedUnselectedLabel: false,
    navigationBarMutedUnselectedIcon: false,
    navigationBarLabelBehavior: NavigationDestinationLabelBehavior.alwaysShow,

    // Navigation rail
    navigationRailSelectedLabelSchemeColor: SchemeColor.primary,
    navigationRailSelectedIconSchemeColor: SchemeColor.primary,
    navigationRailUseIndicator: true,
    navigationRailMutedUnselectedLabel: false,
    navigationRailMutedUnselectedIcon: false,
    navigationRailLabelType: NavigationRailLabelType.all,
    drawerRadius: 0,
  );

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

  /// Global theme for [TabBar].
  static TabBarTheme _buildTabBarTheme() => const TabBarTheme(
        dividerHeight: 0,
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
      colors: seedScheme != null
          ? FlexSchemeColor(
              primary: seedScheme.primary,
              primaryContainer: seedScheme.primaryContainer,
              secondary: seedScheme.secondary,
              secondaryContainer: seedScheme.secondaryContainer,
              tertiary: seedScheme.tertiary,
              tertiaryContainer: seedScheme.tertiaryContainer,
              error: seedScheme.error,
            )
          : null,
      scheme: seedColor == null ? FlexScheme.bahamaBlue : null,
      tabBarStyle: FlexTabBarStyle.forBackground,
      tooltipsMatchBackground: true,
      surfaceMode: FlexSurfaceMode.level,
      subThemesData: _subThemesData,
      keyColors: const FlexKeyColors(),
      visualDensity: FlexColorScheme.comfortablePlatformDensity,
    ).copyWith(
      colorScheme: seedScheme,
      cardTheme: _buildCardTheme(),
      chipTheme: _buildChipTheme(),
      listTileTheme: _buildListTileTheme(),
      navigationDrawerTheme: _buildNavigationDrawerTheme(seedScheme),
      tabBarTheme: _buildTabBarTheme(),
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
      colors: seedScheme != null
          ? FlexSchemeColor(
              primary: seedScheme.primary,
              primaryContainer: seedScheme.primaryContainer,
              secondary: seedScheme.secondary,
              secondaryContainer: seedScheme.secondaryContainer,
              tertiary: seedScheme.tertiary,
              tertiaryContainer: seedScheme.tertiaryContainer,
              error: seedScheme.error,
            )
          : null,
      scheme: seedColor == null ? FlexScheme.bahamaBlue : null,
      tabBarStyle: FlexTabBarStyle.forBackground,
      tooltipsMatchBackground: true,
      surfaceMode: FlexSurfaceMode.level,
      subThemesData: _subThemesData,
      keyColors: const FlexKeyColors(),
      visualDensity: FlexColorScheme.comfortablePlatformDensity,
    ).copyWith(
      colorScheme: seedScheme,
      cardTheme: _buildCardTheme(),
      chipTheme: _buildChipTheme(),
      listTileTheme: _buildListTileTheme(),
      navigationDrawerTheme: _buildNavigationDrawerTheme(seedScheme),
      tabBarTheme: _buildTabBarTheme(),
    );
  }
}
// If you do not have a themeMode switch, uncomment this line
// to let the device system mode control the theme mode:
// themeMode: ThemeMode.system,
