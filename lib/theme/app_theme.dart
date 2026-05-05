import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppPalette {
  AppPalette._();

  static const Color skyBlue = Color(0xFF4A90E2);
  static const Color purple = Color(0xFF7C5CFF);
  static const Color navy = Color(0xFF0E1430);
  static const Color softWhite = Color(0xFFF6F8FC);

  // Tuned for white text contrast — lighter cyans and pastels were washing
  // out captions on real devices.
  static const Map<String, List<Color>> moodGradients = {
    'sunny': [Color(0xFFFF9D5C), Color(0xFFE56B1F)],
    'partlyCloudy': [Color(0xFF5B9DF9), Color(0xFF3B6FC7)],
    'cloudy': [Color(0xFF8E9EAB), Color(0xFF5C6B7A)],
    'rainy': [Color(0xFF3A6073), Color(0xFF16222A)],
    'thunderstorm': [Color(0xFF373B44), Color(0xFF1F1C2C)],
    'snowy': [Color(0xFFB8C6DB), Color(0xFF7B8AA0)],
    'foggy': [Color(0xFFBDC3C7), Color(0xFF8E9EAB)],
    'clearNight': [Color(0xFF0F2027), Color(0xFF203A43)],
    'cloudyNight': [Color(0xFF232526), Color(0xFF414345)],
  };
}

class AppTheme {
  AppTheme._();

  static const _cardShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(24)),
  );

  // Cairo pairs cleanly with Latin sans-serifs and renders Arabic glyphs well;
  // Inter is the default for English. The factory rebuilds when locale changes.
  static TextTheme _textThemeFor(Locale? locale, TextTheme base) {
    final isArabic = locale?.languageCode == 'ar';
    return isArabic
        ? GoogleFonts.cairoTextTheme(base)
        : GoogleFonts.interTextTheme(base);
  }

  static ThemeData light({Locale? locale}) {
    final base = ThemeData.light(useMaterial3: true);
    return base.copyWith(
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppPalette.skyBlue,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: AppPalette.softWhite,
      textTheme: _textThemeFor(locale, base.textTheme),
      cardTheme: const CardThemeData(
        elevation: 0,
        shape: _cardShape,
        shadowColor: Color(0x0D000000),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
    );
  }

  static ThemeData dark({Locale? locale}) {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppPalette.purple,
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: AppPalette.navy,
      textTheme: _textThemeFor(locale, base.textTheme),
      cardTheme: const CardThemeData(
        elevation: 0,
        shape: _cardShape,
        shadowColor: Color(0x0D000000),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
    );
  }
}
