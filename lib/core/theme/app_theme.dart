// mostly exact copy of flex color scheme 7.1's fabulous 12 theme
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:hiddify/core/theme/app_theme_mode.dart';
import 'package:hiddify/core/theme/theme_extensions.dart';

class AppTheme {
  AppTheme(
    this.mode,
    this.fontFamily,
  );

  final AppThemeMode mode;
  final String fontFamily;

  ThemeData light() {
    return FlexThemeData.light(
      scheme: FlexScheme.indigoM3,
      surfaceMode: FlexSurfaceMode.highScaffoldLowSurface,
      useMaterial3: true,
      swapLegacyOnMaterial3: true,
      useMaterial3ErrorColors: true,
      blendLevel: 1,
      subThemesData: const FlexSubThemesData(
        useTextTheme: true,
        useM2StyleDividerInM3: true,
        elevatedButtonSchemeColor: SchemeColor.onPrimaryContainer,
        elevatedButtonSecondarySchemeColor: SchemeColor.primaryContainer,
        outlinedButtonOutlineSchemeColor: SchemeColor.primary,
        toggleButtonsBorderSchemeColor: SchemeColor.primary,
        segmentedButtonSchemeColor: SchemeColor.primary,
        segmentedButtonBorderSchemeColor: SchemeColor.primary,
        unselectedToggleIsColored: true,
        sliderValueTinted: true,
        inputDecoratorSchemeColor: SchemeColor.primary,
        inputDecoratorBackgroundAlpha: 43,
        inputDecoratorUnfocusedHasBorder: false,
        inputDecoratorFocusedBorderWidth: 1.0,
        inputDecoratorPrefixIconSchemeColor: SchemeColor.primary,
        popupMenuRadius: 8.0,
        popupMenuElevation: 3.0,
        drawerIndicatorSchemeColor: SchemeColor.primary,
        bottomNavigationBarMutedUnselectedLabel: false,
        bottomNavigationBarMutedUnselectedIcon: false,
        menuRadius: 8.0,
        menuElevation: 3.0,
        menuBarRadius: 0.0,
        menuBarElevation: 2.0,
        menuBarShadowColor: Color(0x00000000),
        navigationBarSelectedLabelSchemeColor: SchemeColor.primary,
        navigationBarMutedUnselectedLabel: false,
        navigationBarSelectedIconSchemeColor: SchemeColor.onPrimary,
        navigationBarMutedUnselectedIcon: false,
        navigationBarIndicatorSchemeColor: SchemeColor.primary,
        navigationBarIndicatorOpacity: 1.00,
        navigationRailSelectedLabelSchemeColor: SchemeColor.primary,
        navigationRailMutedUnselectedLabel: false,
        navigationRailSelectedIconSchemeColor: SchemeColor.onPrimary,
        navigationRailMutedUnselectedIcon: false,
        navigationRailIndicatorSchemeColor: SchemeColor.primary,
        navigationRailIndicatorOpacity: 1.00,
        navigationRailBackgroundSchemeColor: SchemeColor.surface,
      ),
      keyColors: const FlexKeyColors(
        useSecondary: true,
        useTertiary: true,
        keepPrimary: true,
      ),
      tones: FlexTones.jolly(Brightness.light),
      visualDensity: FlexColorScheme.comfortablePlatformDensity,
      fontFamily: fontFamily,
      extensions: <ThemeExtension<dynamic>>{
        ConnectionButtonTheme.light,
      },
    );
  }

  ThemeData dark() {
    return FlexThemeData.dark(
      scheme: FlexScheme.indigoM3,
      useMaterial3: true,
      swapLegacyOnMaterial3: true,
      useMaterial3ErrorColors: true,
      darkIsTrueBlack: mode.trueBlack,
      surfaceMode: FlexSurfaceMode.highScaffoldLowSurface,
      // blendLevel: 1,
      subThemesData: const FlexSubThemesData(
        blendTextTheme: true,
        useTextTheme: true,
        useM2StyleDividerInM3: true,
        elevatedButtonSchemeColor: SchemeColor.onPrimaryContainer,
        elevatedButtonSecondarySchemeColor: SchemeColor.primaryContainer,
        outlinedButtonOutlineSchemeColor: SchemeColor.primary,
        toggleButtonsBorderSchemeColor: SchemeColor.primary,
        segmentedButtonSchemeColor: SchemeColor.primary,
        segmentedButtonBorderSchemeColor: SchemeColor.primary,
        unselectedToggleIsColored: true,
        sliderValueTinted: true,
        inputDecoratorSchemeColor: SchemeColor.primary,
        inputDecoratorBackgroundAlpha: 43,
        inputDecoratorUnfocusedHasBorder: false,
        inputDecoratorFocusedBorderWidth: 1.0,
        inputDecoratorPrefixIconSchemeColor: SchemeColor.primary,
        popupMenuRadius: 8.0,
        popupMenuElevation: 3.0,
        drawerIndicatorSchemeColor: SchemeColor.primary,
        bottomNavigationBarMutedUnselectedLabel: false,
        bottomNavigationBarMutedUnselectedIcon: false,
        menuRadius: 8.0,
        menuElevation: 3.0,
        menuBarRadius: 0.0,
        menuBarElevation: 2.0,
        menuBarShadowColor: Color(0x00000000),
        navigationBarSelectedLabelSchemeColor: SchemeColor.primary,
        navigationBarMutedUnselectedLabel: false,
        navigationBarSelectedIconSchemeColor: SchemeColor.onPrimary,
        navigationBarMutedUnselectedIcon: false,
        navigationBarIndicatorSchemeColor: SchemeColor.primary,
        navigationBarIndicatorOpacity: 1.00,
        navigationRailSelectedLabelSchemeColor: SchemeColor.primary,
        navigationRailMutedUnselectedLabel: false,
        navigationRailSelectedIconSchemeColor: SchemeColor.onPrimary,
        navigationRailMutedUnselectedIcon: false,
        navigationRailIndicatorSchemeColor: SchemeColor.primary,
        navigationRailIndicatorOpacity: 1.00,
        navigationRailBackgroundSchemeColor: SchemeColor.surface,
      ),
      keyColors: const FlexKeyColors(
        useSecondary: true,
        useTertiary: true,
      ),
      // tones: FlexTones.jolly(Brightness.dark),
      visualDensity: FlexColorScheme.comfortablePlatformDensity,
      fontFamily: fontFamily,
      extensions: <ThemeExtension<dynamic>>{
        ConnectionButtonTheme.light,
      },
    );
  }
}
