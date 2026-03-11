import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../sabitler/uygulama_renkleri.dart';

class Tema {
  static const double spacingXS = 4.0;
  static const double spacingSM = 8.0;
  static const double spacingMD = 16.0;
  static const double spacingLG = 24.0;
  static const double spacingXL = 32.0;
  static const double spacingXXL = 48.0;

  static const double radiusSM = 12.0;
  static const double radiusMD = 16.0;
  static const double radiusLG = 24.0;
  static const double radiusXL = 30.0;

  static const double cardRadius = 20.0;
  static const double buttonRadius = 14.0;

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: Renkler.primary,
    scaffoldBackgroundColor: Renkler.backgroundLight,
    colorScheme: const ColorScheme.light(
      primary: Renkler.secondary,
      onPrimary: Colors.white,
      secondary: Renkler.accent,
      onSecondary: Colors.white,
      tertiary: Renkler.teal,
      surface: Renkler.surfaceLight,
      onSurface: Renkler.textPrimaryLight,
      error: Renkler.error,
    ),
    textTheme: GoogleFonts.interTextTheme().copyWith(
      displayLarge: GoogleFonts.inter(fontSize: 34, fontWeight: FontWeight.w700, color: Renkler.textPrimaryLight, letterSpacing: -0.5, height: 1.2),
      displayMedium: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w700, color: Renkler.textPrimaryLight, letterSpacing: -0.3, height: 1.2),
      headlineLarge: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w600, color: Renkler.textPrimaryLight, height: 1.3),
      headlineMedium: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w600, color: Renkler.textPrimaryLight, height: 1.3),
      titleLarge: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: Renkler.textPrimaryLight, height: 1.4),
      titleMedium: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: Renkler.textPrimaryLight, height: 1.4),
      bodyLarge: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w400, color: Renkler.textPrimaryLight, height: 1.5),
      bodyMedium: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w400, color: Renkler.textSecondaryLight, height: 1.5),
      bodySmall: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w400, color: Renkler.textSecondaryLight, height: 1.5),
      labelLarge: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: Renkler.textSecondaryLight),
    ),
    cardTheme: CardThemeData(
      color: Renkler.cardLight,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(cardRadius)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Renkler.secondary,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(buttonRadius)),
        textStyle: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: Renkler.secondary,
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(buttonRadius)),
        side: const BorderSide(color: Renkler.secondary, width: 1.5),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: Renkler.secondary,
        textStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w600, color: Renkler.textPrimaryLight),
      iconTheme: const IconThemeData(color: Renkler.textPrimaryLight),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.transparent,
      selectedItemColor: Renkler.secondary,
      unselectedItemColor: Renkler.textSecondaryLight,
      elevation: 0,
    ),
    sliderTheme: SliderThemeData(
      activeTrackColor: Renkler.secondary,
      inactiveTrackColor: Renkler.secondary.withOpacity(0.15),
      thumbColor: Renkler.secondary,
      overlayColor: Renkler.secondary.withOpacity(0.1),
      trackHeight: 6,
      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: Renkler.secondary,
      linearTrackColor: Renkler.cardBorderLight,
    ),
    dividerTheme: const DividerThemeData(color: Renkler.cardBorderLight, thickness: 1),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Renkler.surfaceLight,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(radiusMD), borderSide: const BorderSide(color: Renkler.cardBorderLight)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(radiusMD), borderSide: const BorderSide(color: Renkler.cardBorderLight)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(radiusMD), borderSide: const BorderSide(color: Renkler.secondary, width: 2)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      elevation: 4,
      backgroundColor: Renkler.secondary,
      foregroundColor: Colors.white,
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: Renkler.primaryDarkTheme,
    scaffoldBackgroundColor: Renkler.backgroundDark,
    colorScheme: const ColorScheme.dark(
      primary: Renkler.secondaryDarkTheme,
      onPrimary: Renkler.backgroundDark,
      secondary: Renkler.accentDarkTheme,
      onSecondary: Renkler.backgroundDark,
      tertiary: Renkler.tealDarkTheme,
      surface: Renkler.surfaceDark,
      onSurface: Renkler.textPrimaryDark,
      error: Renkler.error,
    ),
    textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).copyWith(
      displayLarge: GoogleFonts.inter(fontSize: 34, fontWeight: FontWeight.w700, color: Renkler.textPrimaryDark, letterSpacing: -0.5, height: 1.2),
      displayMedium: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w700, color: Renkler.textPrimaryDark, letterSpacing: -0.3, height: 1.2),
      headlineLarge: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w600, color: Renkler.textPrimaryDark, height: 1.3),
      headlineMedium: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w600, color: Renkler.textPrimaryDark, height: 1.3),
      titleLarge: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: Renkler.textPrimaryDark, height: 1.4),
      titleMedium: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: Renkler.textPrimaryDark, height: 1.4),
      bodyLarge: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w400, color: Renkler.textPrimaryDark, height: 1.5),
      bodyMedium: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w400, color: Renkler.textSecondaryDark, height: 1.5),
      bodySmall: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w400, color: Renkler.textSecondaryDark, height: 1.5),
      labelLarge: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: Renkler.textSecondaryDark),
    ),
    cardTheme: CardThemeData(
      color: Renkler.cardDark,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(cardRadius), side: const BorderSide(color: Renkler.cardBorderDark, width: 1)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Renkler.secondaryDarkTheme,
        foregroundColor: Renkler.backgroundDark,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(buttonRadius)),
        textStyle: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: Renkler.secondaryDarkTheme,
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(buttonRadius)),
        side: const BorderSide(color: Renkler.secondaryDarkTheme, width: 1.5),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: Renkler.secondaryDarkTheme,
        textStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w600, color: Renkler.textPrimaryDark),
      iconTheme: const IconThemeData(color: Renkler.textPrimaryDark),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.transparent,
      selectedItemColor: Renkler.secondaryDarkTheme,
      unselectedItemColor: Renkler.textSecondaryDark,
      elevation: 0,
    ),
    sliderTheme: SliderThemeData(
      activeTrackColor: Renkler.secondaryDarkTheme,
      inactiveTrackColor: Renkler.secondaryDarkTheme.withOpacity(0.2),
      thumbColor: Renkler.secondaryDarkTheme,
      overlayColor: Renkler.secondaryDarkTheme.withOpacity(0.1),
      trackHeight: 6,
      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: Renkler.secondaryDarkTheme,
      linearTrackColor: Renkler.cardBorderDark,
    ),
    dividerTheme: const DividerThemeData(color: Renkler.cardBorderDark, thickness: 1),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Renkler.surfaceDark,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(radiusMD), borderSide: const BorderSide(color: Renkler.cardBorderDark)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(radiusMD), borderSide: const BorderSide(color: Renkler.cardBorderDark)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(radiusMD), borderSide: const BorderSide(color: Renkler.secondaryDarkTheme, width: 2)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      elevation: 4,
      backgroundColor: Renkler.secondaryDarkTheme,
      foregroundColor: Renkler.backgroundDark,
    ),
  );
}
