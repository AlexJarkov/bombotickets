import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
  static const double fontSizeH2 = 18.0;
  static const double fontSizeH3 = 14.0;
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

  ThemeData getTheme() => ThemeData(
    useMaterial3: true,
    brightness: isDarkMode ? Brightness.dark : Brightness.light,
    colorSchemeSeed: primaryColor,
    scaffoldBackgroundColor: scaffoldBackground,

    /// Typography
    textTheme: TextTheme(
      displayLarge: GoogleFonts.poppins(
        fontSize: fontSizeH1,
        fontWeight: FontWeight.w600,
        color: bodyFontColor,
      ),
      displayMedium: GoogleFonts.poppins(
        fontSize: fontSizeH2,
        fontWeight: FontWeight.w600,
        color: bodyFontColor,
      ),
      displaySmall: GoogleFonts.poppins(
        fontSize: fontSizeH3,
        fontWeight: FontWeight.w600,
        color: bodyFontColor,
      ),
      bodyLarge: GoogleFonts.poppins(
        fontSize: fontSizeBodyLarge,
        fontWeight: FontWeight.w400,
        color: bodyFontColor,
      ),
      bodyMedium: GoogleFonts.poppins(
        fontSize: fontSizeBodyNormal,
        fontWeight: FontWeight.w400,
        color: bodyFontColor,
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
        textStyle: GoogleFonts.poppins(
          fontSize: fontSizeH2,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    /// Input decoration
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
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
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadiusNormal),
      ),
      margin: EdgeInsets.zero,
    ),

    /// AppBar theme
    appBarTheme: AppBarTheme(
      backgroundColor: scaffoldBackground,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: GoogleFonts.poppins(
        fontSize: fontSizeH1,
        fontWeight: FontWeight.w600,
        color: bodyFontColor,
      ),
    ),
  );

  // Helper methods for custom widgets
  static TextStyle dataTitleTextStyle() {
    return GoogleFonts.poppins(
      fontSize: fontSizeH3,
      fontWeight: FontWeight.w600,
      color: bodyFontColor,
    );
  }

  static TextStyle dataCurrencySmallTextStyle() {
    return GoogleFonts.poppins(
      fontSize: fontSizeBodyNormal,
      fontWeight: FontWeight.w400,
      color: bodyFontColor,
    );
  }

  static TextStyle dataCurrencyMediumTextStyle() {
    return GoogleFonts.poppins(
      fontSize: fontSizeBodyMedium,
      fontWeight: FontWeight.w400,
      color: bodyFontColor,
    );
  }

  static TextStyle dataSumLargeTextStyle() {
    return GoogleFonts.poppins(
      fontSize: fontSizeBodyLarge,
      fontWeight: FontWeight.w400,
      color: bodyFontColor,
    );
  }

  AppTheme copyWith({bool? isDarkMode}) =>
      AppTheme(isDarkMode: isDarkMode ?? this.isDarkMode);
}
