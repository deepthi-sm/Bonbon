import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Bonbon palette. Teal + magenta identity from the Stitch design system,
/// with the cool blue-grey canvas swapped for a warm paper tone so the
/// brand colours and the book's blue-ink illustrations sit together.
class C {
  static const teal = Color(0xFF0A6B6B);
  static const tealDark = Color(0xFF074C4C);
  static const tealSoft = Color(0xFFE3F1F0);
  static const tealMid = Color(0xFFB7DEDB);

  static const magenta = Color(0xFFC51C4E);
  static const magentaDark = Color(0xFF8E1236);
  static const magentaSoft = Color(0xFFFBE7EC);

  static const gold = Color(0xFFF59E0B);
  static const goldDeep = Color(0xFF9A5B00);
  static const goldSoft = Color(0xFFFEF3D7);

  static const canvas = Color(0xFFFBF8F3);
  static const surface = Color(0xFFFFFFFF);
  static const border = Color(0xFFE8E2D9);
  static const ink = Color(0xFF1F2937);
  static const inkSoft = Color(0xFF4B5563);
  static const locked = Color(0xFFD9D4CC);

  static const success = Color(0xFF15803D);
  static const successSoft = Color(0xFFDCFCE7);
}

TextStyle cursive(double size, {Color color = C.ink}) =>
    GoogleFonts.playwriteFrModerne(fontSize: size, color: color, height: 1.6);

ThemeData buildTheme() {
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: C.teal,
      primary: C.teal,
      secondary: C.magenta,
      tertiary: C.gold,
      surface: C.surface,
    ),
    scaffoldBackgroundColor: C.canvas,
  );
  final text = GoogleFonts.plusJakartaSansTextTheme(base.textTheme).apply(
    bodyColor: C.ink,
    displayColor: C.ink,
  );
  return base.copyWith(
    textTheme: text.copyWith(
      headlineLarge: text.headlineLarge
          ?.copyWith(fontSize: 32, fontWeight: FontWeight.w800, letterSpacing: -0.6),
      headlineMedium: text.headlineMedium
          ?.copyWith(fontSize: 26, fontWeight: FontWeight.w700),
      headlineSmall: text.headlineSmall
          ?.copyWith(fontSize: 22, fontWeight: FontWeight.w700),
      bodyLarge: text.bodyLarge?.copyWith(fontSize: 19, fontWeight: FontWeight.w500),
      bodyMedium: text.bodyMedium?.copyWith(fontSize: 17, fontWeight: FontWeight.w500),
      bodySmall: text.bodySmall
          ?.copyWith(fontSize: 15, fontWeight: FontWeight.w500, color: C.inkSoft),
      labelLarge: text.labelLarge?.copyWith(fontSize: 18, fontWeight: FontWeight.w700),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: C.canvas,
      foregroundColor: C.ink,
      elevation: 0,
      scrolledUnderElevation: 0,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? Colors.white : C.inkSoft),
      trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? C.teal : C.border),
    ),
  );
}
