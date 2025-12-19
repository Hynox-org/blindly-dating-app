import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

enum AppThemeMode { normal, premium, incognito }

class AppTheme {
  static ThemeData getThemeData(AppThemeMode mode) {
    return switch (mode) {
      AppThemeMode.premium => _premiumTheme,
      AppThemeMode.incognito => _incognitoTheme,
      AppThemeMode.normal => _normalTheme,
    };
  }

  // --- Premium Version ---
  // Theme: 414833, Text: FFFFFF, Cards: FFFFFF, Buttons: E6C97A (bg), 000000 (text)
  static final ThemeData _premiumTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF414833),
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFFE6C97A),
      onPrimary: Color(0xFF000000),
      surface: Color(0xFFFFFFFF),
      onSurface: Color(0xFFFFFFFF),
      secondary: Color(0xFFE6C97A),
    ),
    textTheme: GoogleFonts.interTextTheme(
      ThemeData.dark().textTheme,
    ).apply(bodyColor: Colors.white, displayColor: Colors.white),
    cardTheme: const CardThemeData(
      color: Colors.white,
      surfaceTintColor: Colors.transparent,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFE6C97A),
        foregroundColor: const Color(0xFF000000),
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF414833),
      foregroundColor: Colors.white,
      systemOverlayStyle: SystemUiOverlayStyle.light,
    ),
  );

  // --- Normal Version ---
  // Theme: F5F5F5, Text: 000000, Cards: FFFFFF, Buttons: 414833 (bg), E6C97A (text)
  static final ThemeData _normalTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: const Color(0xFFF5F5F5),
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF414833),
      onPrimary: Color(0xFFE6C97A),
      surface: Color(0xFFFFFFFF),
      onSurface: Color(0xFF000000),
      secondary: Color(0xFF414833),
    ),
    textTheme: GoogleFonts.interTextTheme(
      ThemeData.light().textTheme,
    ).apply(bodyColor: Colors.black, displayColor: Colors.black),
    cardTheme: const CardThemeData(
      color: Colors.white,
      surfaceTintColor: Colors.transparent,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF414833),
        foregroundColor: const Color(0xFFE6C97A),
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFFF5F5F5),
      foregroundColor: Colors.black,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
    ),
  );

  // --- Incognito Mode Version ---
  // Theme: 000000, Text: FFFFFF, Cards: 3E3E3E, Buttons: E6C97A (bg), 000000 (text)
  static final ThemeData _incognitoTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF000000),
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFFE6C97A),
      onPrimary: Color(0xFF000000),
      surface: Color(0xFF3E3E3E),
      onSurface: Color(0xFFFFFFFF),
      secondary: Color(0xFFE6C97A),
    ),
    textTheme: GoogleFonts.interTextTheme(
      ThemeData.dark().textTheme,
    ).apply(bodyColor: Colors.white, displayColor: Colors.white),
    cardTheme: const CardThemeData(
      color: Color(0xFF3E3E3E),
      surfaceTintColor: Colors.transparent,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFE6C97A),
        foregroundColor: const Color(0xFF000000),
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.black,
      foregroundColor: Colors.white,
      systemOverlayStyle: SystemUiOverlayStyle.light,
    ),
  );
}
