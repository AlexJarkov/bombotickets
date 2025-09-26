import 'package:flutter/material.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Paleta principal - púrpura como base
  static const Color primaryColor = Color(
    0xFFA855F7,
  ); // Purple 500 - color principal
  static const Color secondaryColor = Color(
    0xFF6366F1,
  ); // Indigo 500 - complementario
  static const Color errorColor = Color(0xFFEF4444); // Red 500

  // Estados semáforo - necesarios para home_screen.dart
  static const Color successColor = Color(0xFF22C55E); // Green 500
  static const Color warningColor = Color(0xFFF59E0B); // Amber 500

  // Estados para toast y notificaciones
  static const Color successColorLight = Color(0xFF4ADE80); // Green 400
  static const Color warningColorLight = Color(0xFFFBBF24); // Amber 400
  static const Color infoColorLight = Color(0xFF60A5FA); // Blue 400
  static const Color errorColorLight = Color(0xFFF87171); // Red 400

  // Colores de texto para los toast
  static const Color onSuccessLight = Color(0xFF064E3B);
  static const Color onWarningLight = Color(0xFF92400E);
  static const Color onInfoLight = Color(0xFF1E3A8A);
  static const Color onErrorLight = Color(0xFFFFFFFF);

  // Superficies
  static const Color surfaceDark = Color(0xFF0B1020);
  static const Color surfaceCardDark = Color(0xFF0F172A);
  static const Color surfaceLight = Color(0xFFF8FAFC);
  static const Color surfaceCardLight = Color(0xFFFFFFFF);

  // Gradientes necesarios
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryColor, secondaryColor],
  );

  // Método para tema claro
  static ThemeData lightTheme() {
    return FlexThemeData.light(
      colors: const FlexSchemeColor(
        primary: primaryColor,
        primaryContainer: Color(
          0xFFF3E8FF,
        ), // Purple 50 - container para púrpura
        secondary: secondaryColor,
        secondaryContainer: Color(
          0xFFEEF2FF,
        ), // Indigo 50 - container para indigo
        tertiary: primaryColor, // Usar primaryColor como tertiary
        tertiaryContainer: Color(0xFFF3E8FF),
        error: errorColor,
      ),
      useMaterial3: true,
      surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
      blendLevel: 8,
      visualDensity: VisualDensity.standard,
      scaffoldBackground: surfaceLight,
      surface: surfaceCardLight,
      appBarStyle: FlexAppBarStyle.background,
      subThemesData: const FlexSubThemesData(
        blendOnLevel: 10,
        blendOnColors: false,
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
      textTheme: GoogleFonts.interTextTheme(),
      primaryTextTheme: GoogleFonts.interTextTheme(),
    );
  }

  // Método para tema oscuro
  static ThemeData darkTheme() {
    return FlexThemeData.dark(
      colors: const FlexSchemeColor(
        primary: primaryColor,
        primaryContainer: Color(0xFF581C87), // Purple 900 - container oscuro
        secondary: secondaryColor,
        secondaryContainer: Color(0xFF312E81), // Indigo 800 - container oscuro
        tertiary: primaryColor, // Usar primaryColor como tertiary
        tertiaryContainer: Color(0xFF581C87),
        error: errorColor,
      ),
      useMaterial3: true,
      surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
      blendLevel: 15,
      visualDensity: VisualDensity.standard,
      scaffoldBackground: surfaceDark,
      surface: surfaceCardDark,
      appBarStyle: FlexAppBarStyle.background,
      subThemesData: const FlexSubThemesData(
        blendOnLevel: 20,
        blendOnColors: false,
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

  // Border radius - Patrón profesional
  static const double borderRadiusSmall = 8.0;
  static const double borderRadiusNormal = 16.0; // Cards modernas
  static const double borderRadiusLarge = 20.0; // Cards grandes
  static const double borderRadiusPremium = 24.0; // Modales/sheets
  static const double borderRadiusMaxPremium =
      28.0; // QR viewer/sheets especiales

  // Toast color helpers
  static Map<String, Color> get toastColors => {
    'success': successColorLight,
    'warning': warningColorLight,
    'info': infoColorLight,
    'error': errorColorLight,
  };

  static Map<String, Color> get toastTextColors => {
    'success': onSuccessLight,
    'warning': onWarningLight,
    'info': onInfoLight,
    'error': onErrorLight,
  };

  // Método helper para obtener colores de toast
  static Color getToastColor(String type) {
    return toastColors[type] ?? successColorLight;
  }

  static Color getToastTextColor(String type) {
    return toastTextColors[type] ?? onSuccessLight;
  }
}
