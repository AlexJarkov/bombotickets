import 'package:flutter/material.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Colors principales (mantenemos la identidad de Bombotickets)
  static const Color primaryColor = Color(0xFF0C71C3);
  static const Color secondaryColor = Color(0xFF2176FF);

  // Método para tema claro
  static ThemeData lightTheme() {
    return FlexThemeData.light(
      scheme: FlexScheme.blue,
      primary: primaryColor,
      secondary: secondaryColor,
      surface: const Color(0xFFF8F9FA),
      background: const Color(0xFFFFFFFF),
      scaffoldBackground: const Color(0xFFF6F6EF),
      appBarStyle: FlexAppBarStyle.background,
      subThemesData: const FlexSubThemesData(
        blendOnLevel: 10,
        blendOnColors: false,
        useTextTheme: true,
        useM2StyleDividerInM3: true,
        alignedDropdown: true,
        useInputDecoratorThemeInDialogs: true,
        // Bottom Navigation Bar mejorado
        bottomNavigationBarMutedUnselectedLabel: false,
        bottomNavigationBarMutedUnselectedIcon: false,
        bottomNavigationBarShowSelectedLabels: true,
        bottomNavigationBarShowUnselectedLabels: true,
        bottomNavigationBarType: BottomNavigationBarType.fixed,
        bottomNavigationBarBackgroundSchemeColor: SchemeColor.surface,
        bottomNavigationBarSelectedLabelSchemeColor: SchemeColor.primary,
        bottomNavigationBarUnselectedLabelSchemeColor: SchemeColor.onSurface,
        bottomNavigationBarSelectedIconSchemeColor: SchemeColor.primary,
        bottomNavigationBarUnselectedIconSchemeColor: SchemeColor.onSurface,
        // Cards y superficies
        cardRadius: 16.0,
        elevatedButtonRadius: 12.0,
        filledButtonRadius: 12.0,
        outlinedButtonRadius: 12.0,
        textButtonRadius: 12.0,
        inputDecoratorRadius: 12.0,
        fabRadius: 16.0,
        chipRadius: 8.0,
        dialogRadius: 20.0,
        timePickerDialogRadius: 20.0,
        snackBarRadius: 8.0,
        tabBarIndicatorWeight: 3.0,
        tabBarIndicatorTopRadius: 3.0,
        tabBarDividerColor: Colors.transparent,
      ),
      keyColors: const FlexKeyColors(
        useSecondary: true,
        useTertiary: true,
        keepPrimary: true,
      ),
      visualDensity: FlexColorScheme.comfortablePlatformDensity,
      useMaterial3: true,
      textTheme: GoogleFonts.interTextTheme(),
      primaryTextTheme: GoogleFonts.interTextTheme(),
    );
  }

  // Método para tema oscuro
  static ThemeData darkTheme() {
    return FlexThemeData.dark(
      scheme: FlexScheme.blue,
      primary: primaryColor,
      secondary: secondaryColor,
      surface: const Color(0xFF121212),
      background: const Color(0xFF0A0A0A),
      scaffoldBackground: const Color(0xFF0B1E3B),
      appBarStyle: FlexAppBarStyle.background,
      subThemesData: const FlexSubThemesData(
        blendOnLevel: 20,
        blendOnColors: false,
        useTextTheme: true,
        useM2StyleDividerInM3: true,
        alignedDropdown: true,
        useInputDecoratorThemeInDialogs: true,
        // Bottom Navigation Bar mejorado
        bottomNavigationBarMutedUnselectedLabel: false,
        bottomNavigationBarMutedUnselectedIcon: false,
        bottomNavigationBarShowSelectedLabels: true,
        bottomNavigationBarShowUnselectedLabels: true,
        bottomNavigationBarType: BottomNavigationBarType.fixed,
        bottomNavigationBarBackgroundSchemeColor: SchemeColor.surface,
        bottomNavigationBarSelectedLabelSchemeColor: SchemeColor.primary,
        bottomNavigationBarUnselectedLabelSchemeColor: SchemeColor.onSurface,
        bottomNavigationBarSelectedIconSchemeColor: SchemeColor.primary,
        bottomNavigationBarUnselectedIconSchemeColor: SchemeColor.onSurface,
        // Cards y superficies
        cardRadius: 16.0,
        elevatedButtonRadius: 12.0,
        filledButtonRadius: 12.0,
        outlinedButtonRadius: 12.0,
        textButtonRadius: 12.0,
        inputDecoratorRadius: 12.0,
        fabRadius: 16.0,
        chipRadius: 8.0,
        dialogRadius: 20.0,
        timePickerDialogRadius: 20.0,
        snackBarRadius: 8.0,
        tabBarIndicatorWeight: 3.0,
        tabBarIndicatorTopRadius: 3.0,
        tabBarDividerColor: Colors.transparent,
      ),
      keyColors: const FlexKeyColors(
        useSecondary: true,
        useTertiary: true,
        keepPrimary: true,
      ),
      visualDensity: FlexColorScheme.comfortablePlatformDensity,
      useMaterial3: true,
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
      primaryTextTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
    );
  }

  // Método para obtener tema con colores dinámicos del sistema (Android 12+)
  static Future<ThemeData> dynamicLightTheme(
    ColorScheme? lightColorScheme,
  ) async {
    return FlexThemeData.light(
      colorScheme: lightColorScheme,
      primary: lightColorScheme?.primary ?? primaryColor,
      subThemesData: const FlexSubThemesData(
        blendOnLevel: 10,
        blendOnColors: false,
        useTextTheme: true,
        // Bottom Navigation Bar
        bottomNavigationBarType: BottomNavigationBarType.fixed,
        bottomNavigationBarBackgroundSchemeColor: SchemeColor.surface,
        bottomNavigationBarSelectedLabelSchemeColor: SchemeColor.primary,
        bottomNavigationBarSelectedIconSchemeColor: SchemeColor.primary,
        // Bordes redondeados
        cardRadius: 16.0,
        elevatedButtonRadius: 12.0,
        inputDecoratorRadius: 12.0,
      ),
      useMaterial3: true,
      textTheme: GoogleFonts.interTextTheme(),
    );
  }

  static Future<ThemeData> dynamicDarkTheme(
    ColorScheme? darkColorScheme,
  ) async {
    return FlexThemeData.dark(
      colorScheme: darkColorScheme,
      primary: darkColorScheme?.primary ?? primaryColor,
      subThemesData: const FlexSubThemesData(
        blendOnLevel: 20,
        blendOnColors: false,
        useTextTheme: true,
        // Bottom Navigation Bar
        bottomNavigationBarType: BottomNavigationBarType.fixed,
        bottomNavigationBarBackgroundSchemeColor: SchemeColor.surface,
        bottomNavigationBarSelectedLabelSchemeColor: SchemeColor.primary,
        bottomNavigationBarSelectedIconSchemeColor: SchemeColor.primary,
        // Bordes redondeados
        cardRadius: 16.0,
        elevatedButtonRadius: 12.0,
        inputDecoratorRadius: 12.0,
      ),
      useMaterial3: true,
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
    );
  }

  // Constantes heredadas para compatibilidad
  static const Color highlightBlue = Color(0xFF2176FF);
  static const Color highlightBlueHover = Color(0xFF3F88FF);
  static const Color bodyFontColor = Color(0xFF333333);
  static const Color greyBtnColor = Color(0xFFD3D3D3);
  static const Color greyCardColor = Color(0xFFDEDEDE);
  static const Color greyInputBg = Color(0xFFF2F2F2);
  static const Color greyInputDisabled = Color(0xFFBFBFBF);
  static const Color grey1 = Color(0xFF8D8D8D);
  static const Color grey2 = Color(0xFF303030);
  static const Color scaffoldBackground = Color(0xFFF6F6EF);
  static const Color lineColor = Color(0xFFCCCCCC);
  static const Color navBorderColor = Color(0xFFDCDCDC);

  // Font sizes (mantener compatibilidad)
  static const double fontSizeH1 = 24.0;
  static const double fontSizeH2 = 20.0;
  static const double fontSizeH3 = 16.0;
  static const double fontSizeBodyNormal = 14.0;
  static const double fontSizeBodyMedium = 19.0;
  static const double fontSizeBodyLarge = 26.0;

  // Spacing
  static const double spacingSmall = 8.0;
  static const double spacingNormal = 12.0;
  static const double spacingMedium = 24.0;
  static const double spacingLarge = 32.0;

  // Border radius
  static const double borderRadiusSmall = 8.0;
  static const double borderRadiusNormal = 12.0;
  static const double borderRadiusLarge = 24.0;
}
