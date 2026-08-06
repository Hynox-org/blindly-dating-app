import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  /// Poppins has no Devanagari/Tamil/Telugu/Bengali glyphs, so Indic locales
  /// get the matching Noto Sans face instead.
  static TextTheme _textTheme(String? languageCode) {
    final base = ThemeData.light().textTheme;
    switch (languageCode) {
      case 'hi':
      case 'mr':
        return GoogleFonts.notoSansDevanagariTextTheme(base);
      case 'ta':
        return GoogleFonts.notoSansTamilTextTheme(base);
      case 'te':
        return GoogleFonts.notoSansTeluguTextTheme(base);
      case 'bn':
        return GoogleFonts.notoSansBengaliTextTheme(base);
      default:
        return GoogleFonts.poppinsTextTheme(base);
    }
  }

  /// [languageCode] null = device default, which Poppins handles for Latin and
  /// the platform font falls back for anything else.
  static ThemeData themeFor(String? languageCode) =>
      theme.copyWith(
        textTheme: _textTheme(
          languageCode,
        ).apply(bodyColor: Colors.black, displayColor: Colors.black),
      );

  // --- Normal Version (Default) ---
  // Theme: F5F5F5, Text: 000000, Cards: FFFFFF, Buttons: 414833 (bg), E6C97A (text)
  static final ThemeData theme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: Colors.white,
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF414833),
      onPrimary: Color(0xFFE6C97A),
      surface: Color(0xFFF5F5F5),
      onSurface: Color(0xFF000000),
      secondary: Color(0xFFE6C97A),
    ),
    textTheme: GoogleFonts.poppinsTextTheme(
      ThemeData.light().textTheme,
    ).apply(bodyColor: Colors.black, displayColor: Colors.black),
    cardTheme: const CardThemeData(
      color: Color(0xFFF5F5F5),
      surfaceTintColor: Colors.transparent,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF414833),
        foregroundColor: const Color(0xFFE6C97A),
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
    ),
  );
}
