import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// PRD 「디자인 토큰 (기존 목업 계승)」.
class Tokens {
  static const ivory = Color(0xFFF5EFE3);
  static const ivoryDark = Color(0xFF15130F);
  static const ink = Color(0xFF1F1B17);
  static const inkOnDark = Color(0xFFF5EFE3);
  static const temple = Color(0xFF2E3B33);
  static const saffron = Color(0xFFD98B2B);
  static const seal = Color(0xFF9B2226);

  /// 수행중 화면은 검정 배경 + 30% 아이보리 (FR-2.4).
  static const runningBg = Color(0xFF000000);
  static const runningText = Color(0x4DF5EFE3);

  static const minTap = 44.0;
  static const gutter = 20.0;
}

class AppTheme {
  static ThemeData light() => _build(Brightness.light);
  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final bg = isDark ? Tokens.ivoryDark : Tokens.ivory;
    final fg = isDark ? Tokens.inkOnDark : Tokens.ink;

    final scheme = ColorScheme(
      brightness: brightness,
      primary: Tokens.saffron,
      onPrimary: Tokens.ink,
      secondary: Tokens.temple,
      onSecondary: Tokens.ivory,
      error: Tokens.seal,
      onError: Tokens.ivory,
      surface: bg,
      onSurface: fg,
    );

    final body = GoogleFonts.notoSansKrTextTheme(
      ThemeData(brightness: brightness).textTheme,
    ).apply(bodyColor: fg, displayColor: fg);

    final textTheme = body.copyWith(
      displayLarge: GoogleFonts.gowunBatang(
        fontSize: 34, height: 1.35, color: fg, fontWeight: FontWeight.w700),
      displayMedium: GoogleFonts.gowunBatang(
        fontSize: 28, height: 1.4, color: fg, fontWeight: FontWeight.w700),
      headlineMedium: GoogleFonts.gowunBatang(
        fontSize: 22, height: 1.45, color: fg, fontWeight: FontWeight.w700),
      titleLarge: GoogleFonts.gowunBatang(
        fontSize: 19, height: 1.45, color: fg, fontWeight: FontWeight.w700),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: bg,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: bg,
        foregroundColor: fg,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge,
      ),
      dividerTheme: DividerThemeData(
        color: fg.withValues(alpha: 0.12),
        thickness: 1,
        space: 1,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: Tokens.saffron,
          foregroundColor: Tokens.ink,
          minimumSize: const Size.fromHeight(Tokens.minTap),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: GoogleFonts.notoSansKr(
              fontSize: 17, fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: fg,
          minimumSize: const Size.fromHeight(Tokens.minTap),
          side: BorderSide(color: fg.withValues(alpha: 0.28)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: GoogleFonts.notoSansKr(
              fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: fg.withValues(alpha: 0.72),
          minimumSize: const Size(Tokens.minTap, Tokens.minTap),
          textStyle: GoogleFonts.notoSansKr(fontSize: 15),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: fg.withValues(alpha: 0.04),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: fg.withValues(alpha: 0.18)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: fg.withValues(alpha: 0.18)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Tokens.saffron, width: 1.6),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: fg.withValues(alpha: 0.05),
        selectedColor: Tokens.temple.withValues(alpha: isDark ? 0.5 : 0.16),
        side: BorderSide(color: fg.withValues(alpha: 0.16)),
        labelStyle: GoogleFonts.notoSansKr(fontSize: 15, color: fg),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
    );
  }
}
