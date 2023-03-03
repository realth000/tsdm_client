import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';

/// App themes.
class AppTheme {
  /// App light theme.
  static final light = FlexThemeData.light(
    colors: const FlexSchemeColor(
      primary: Color(0xff66bbff),
      primaryContainer: Color(0xffa4c4ed),
      secondary: Color(0xff08803a),
      secondaryContainer: Color(0xff50c27f),
      tertiary: Color(0xff836d5b),
      tertiaryContainer: Color(0xffa99686),
      appBarColor: Color(0xff50c27f),
      error: Color(0xffb00020),
    ),
    surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
    blendLevel: 20,
    tabBarStyle: FlexTabBarStyle.forBackground,
    tooltipsMatchBackground: true,
    subThemesData: const FlexSubThemesData(
      thickBorderWidth: 1.5,
      defaultRadius: 26,
      inputDecoratorIsFilled: false,
      inputDecoratorBorderType: FlexInputBorderType.underline,
      fabUseShape: true,
      popupMenuOpacity: 0.98,
      dialogBackgroundSchemeColor: SchemeColor.inversePrimary,
      bottomNavigationBarShowUnselectedLabels: false,
      navigationBarMutedUnselectedLabel: false,
      navigationBarMutedUnselectedIcon: false,
      navigationBarHeight: 630,
      navigationBarLabelBehavior:
          NavigationDestinationLabelBehavior.onlyShowSelected,
      navigationRailMutedUnselectedLabel: false,
      navigationRailMutedUnselectedIcon: false,
      navigationRailOpacity: 0.99,
    ),
    keyColors: const FlexKeyColors(
      useSecondary: true,
      useTertiary: true,
      keepSecondary: true,
      keepPrimaryContainer: true,
      keepSecondaryContainer: true,
    ),
    visualDensity: FlexColorScheme.comfortablePlatformDensity,
    useMaterial3: true,
    swapLegacyOnMaterial3: true,
    // To use the playground font, add GoogleFonts package and uncomment
    // fontFamily: GoogleFonts.notoSans().fontFamily,
  );

  /// App dark themes.
  static final dark = FlexThemeData.dark(
    colors: const FlexSchemeColor(
      primary: Color(0xff66bbff),
      primaryContainer: Color(0xff004b74),
      secondary: Color(0xff40c498),
      secondaryContainer: Color(0xff354b41),
      tertiary: Color(0xffeebd93),
      tertiaryContainer: Color(0xffa99686),
      appBarColor: Color(0xff354b41),
      error: Color(0xffcf6679),
    ),
    surfaceMode: FlexSurfaceMode.highScaffoldLevelSurface,
    blendLevel: 19,
    appBarOpacity: 0.98,
    tabBarStyle: FlexTabBarStyle.forBackground,
    tooltipsMatchBackground: true,
    subThemesData: const FlexSubThemesData(
      defaultRadius: 26,
      thickBorderWidth: 1.5,
      inputDecoratorIsFilled: false,
      inputDecoratorBorderType: FlexInputBorderType.underline,
      fabUseShape: true,
      popupMenuOpacity: 0.98,
      dialogBackgroundSchemeColor: SchemeColor.inversePrimary,
      bottomNavigationBarShowUnselectedLabels: false,
      navigationBarMutedUnselectedLabel: false,
      navigationBarMutedUnselectedIcon: false,
      navigationBarHeight: 63,
      navigationBarLabelBehavior:
          NavigationDestinationLabelBehavior.onlyShowSelected,
      navigationRailMutedUnselectedLabel: false,
      navigationRailMutedUnselectedIcon: false,
      navigationRailOpacity: 0.99,
    ),
    keyColors: const FlexKeyColors(
      useSecondary: true,
      useTertiary: true,
      keepSecondary: true,
    ),
    visualDensity: FlexColorScheme.comfortablePlatformDensity,
    useMaterial3: true,
    swapLegacyOnMaterial3: true,
    // To use the Playground font, add GoogleFonts package and uncomment
    // fontFamily: GoogleFonts.notoSans().fontFamily,
  );
}
// If you do not have a themeMode switch, uncomment this line
// to let the device system mode control the theme mode:
// themeMode: ThemeMode.system,
