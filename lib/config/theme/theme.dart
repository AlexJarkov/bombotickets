import 'package:flutter/material.dart';

class AppTheme {
  final bool isDarkMode;

  AppTheme({this.isDarkMode = false});

  // Colors
  static const Color primaryColor = Color(0xFF0C71C3);
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

  // Font sizes (in logical pixels)
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

  ThemeData getTheme({bool reduceMotion = false}) {
    final brightness = isDarkMode ? Brightness.dark : Brightness.light;
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: brightness,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor:
          isDarkMode ? colorScheme.surface : scaffoldBackground,

      pageTransitionsTheme: reduceMotion
          ? const PageTransitionsTheme(builders: {
              TargetPlatform.android: _NoAnimationPageTransitionsBuilder(),
              TargetPlatform.iOS: _NoAnimationPageTransitionsBuilder(),
              TargetPlatform.macOS: _NoAnimationPageTransitionsBuilder(),
              TargetPlatform.linux: _NoAnimationPageTransitionsBuilder(),
              TargetPlatform.windows: _NoAnimationPageTransitionsBuilder(),
              TargetPlatform.fuchsia: _NoAnimationPageTransitionsBuilder(),
            })
          : const PageTransitionsTheme(),

      // Typography – use platform default fonts, only adjust sizes/weights if needed.
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: fontSizeH1,
          fontWeight: FontWeight.w600,
        ),
        displayMedium: TextStyle(
          fontSize: fontSizeH2,
          fontWeight: FontWeight.w600,
        ),
        displaySmall: TextStyle(
          fontSize: fontSizeH3,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(
          fontSize: fontSizeBodyLarge,
          fontWeight: FontWeight.w400,
        ),
        bodyMedium: TextStyle(
          fontSize: fontSizeBodyNormal,
          fontWeight: FontWeight.w400,
        ),
      ),

    /// Buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: highlightBlue,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadiusSmall),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          textStyle: const TextStyle(
            fontSize: fontSizeH2,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

    /// Input decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDarkMode ? colorScheme.surfaceVariant : Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 10.0,
          horizontal: 16.0,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadiusNormal),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadiusNormal),
          borderSide: BorderSide(color: highlightBlue, width: 1.0),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadiusNormal),
          borderSide: const BorderSide(color: Colors.red, width: 1.0),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadiusNormal),
          borderSide: const BorderSide(color: Colors.red, width: 1.0),
        ),
      ),

    /// Card theme
      cardTheme: CardThemeData(
        color: isDarkMode ? colorScheme.surface : Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusNormal),
        ),
        margin: EdgeInsets.zero,
      ),

    /// AppBar theme
      appBarTheme: AppBarTheme(
        backgroundColor: isDarkMode ? colorScheme.surface : scaffoldBackground,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: const TextStyle(
          fontSize: fontSizeH1,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // Helper methods for custom widgets
  static TextStyle dataTitleTextStyle() {
    return const TextStyle(
      fontSize: fontSizeH3,
      fontWeight: FontWeight.w600,
    );
  }

  static TextStyle dataCurrencySmallTextStyle() {
    return const TextStyle(
      fontSize: fontSizeBodyNormal,
      fontWeight: FontWeight.w400,
    );
  }

  static TextStyle dataCurrencyMediumTextStyle() {
    return const TextStyle(
      fontSize: fontSizeBodyMedium,
      fontWeight: FontWeight.w400,
    );
  }

  static TextStyle dataSumLargeTextStyle() {
    return const TextStyle(
      fontSize: fontSizeBodyLarge,
      fontWeight: FontWeight.w400,
    );
  }

  AppTheme copyWith({bool? isDarkMode}) =>
      AppTheme(isDarkMode: isDarkMode ?? this.isDarkMode);
}

class _NoAnimationPageTransitionsBuilder extends PageTransitionsBuilder {
  const _NoAnimationPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return child;
  }
}
