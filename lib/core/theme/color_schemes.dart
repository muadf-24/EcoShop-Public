import 'package:flutter/material.dart';

/// EcoShop Color System
/// A carefully curated, eco-friendly color palette designed for
/// premium e-commerce experiences.
class AppColors {
  AppColors._();

  // ─── Primary Colors ──────────────────────────────────────────
  static const Color primaryGreen = Color(0xFF2D6A4F);
  static const Color primaryLight = Color(0xFF40916C);
  static const Color primaryDark = Color(0xFF1B4332);
  static const Color primaryAccent = Color(0xFF52B788);

  // ─── Secondary Colors ────────────────────────────────────────
  static const Color secondaryBrown = Color(0xFF8B7355);
  static const Color secondaryBeige = Color(0xFFD4A574);
  static const Color secondaryTan = Color(0xFFE8D5C4);

  // ─── Semantic Colors ─────────────────────────────────────────
  static const Color success = Color(0xFF74C69D);
  static const Color warning = Color(0xFFFFB703);
  static const Color error = Color(0xFFD62828);
  static const Color info = Color(0xFF4895EF);

  // ─── Neutral Colors ──────────────────────────────────────────
  static const Color neutral50 = Color(0xFFFAFAFA);
  static const Color neutral100 = Color(0xFFF5F5F5);
  static const Color neutral200 = Color(0xFFEEEEEE);
  static const Color neutral300 = Color(0xFFE0E0E0);
  static const Color neutral400 = Color(0xFFBDBDBD);
  static const Color neutral500 = Color(0xFF9E9E9E);
  static const Color neutral600 = Color(0xFF757575);
  static const Color neutral700 = Color(0xFF616161);
  static const Color neutral800 = Color(0xFF424242);
  static const Color neutral900 = Color(0xFF212121);

  // ─── Surface Colors ──────────────────────────────────────────
  static const Color surfaceLight = Color(0xFFFFFDF7);
  static const Color surfaceMedium = Color(0xFFF8F6F0);
  static const Color surfaceDark = Color(0xFF1A1A2E);
  static const Color surfaceDarkElevated = Color(0xFF252540);

  // ─── Background Colors ───────────────────────────────────────
  static const Color backgroundLight = Color(0xFFFFFDF7);
  static const Color backgroundDark = Color(0xFF121212);

  // ─── Gradients ───────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryGreen, primaryLight],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryAccent, Color(0xFF95D5B2)],
  );

  static const LinearGradient warmGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [secondaryBrown, secondaryBeige],
  );

  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [primaryDark, primaryGreen, primaryLight],
  );

  static const LinearGradient darkSurfaceGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
  );
}

/// Light Color Scheme
class LightColorScheme {
  LightColorScheme._();

  static ColorScheme get scheme => const ColorScheme(
        brightness: Brightness.light,
        primary: AppColors.primaryGreen,
        onPrimary: Colors.white,
        primaryContainer: Color(0xFFB7E4C7),
        onPrimaryContainer: AppColors.primaryDark,
        secondary: AppColors.secondaryBrown,
        onSecondary: Colors.white,
        secondaryContainer: AppColors.secondaryTan,
        onSecondaryContainer: Color(0xFF4A3728),
        tertiary: AppColors.primaryAccent,
        onTertiary: Colors.white,
        tertiaryContainer: Color(0xFFD8F3DC),
        onTertiaryContainer: AppColors.primaryDark,
        error: AppColors.error,
        onError: Colors.white,
        errorContainer: Color(0xFFFFDAD6),
        onErrorContainer: Color(0xFF410002),
        surface: AppColors.surfaceLight,
        onSurface: AppColors.neutral900,
        surfaceContainerHighest: AppColors.neutral200,
        onSurfaceVariant: AppColors.neutral700,
        outline: AppColors.neutral400,
        outlineVariant: AppColors.neutral200,
        shadow: Colors.black,
        scrim: Colors.black,
        inverseSurface: AppColors.neutral800,
        onInverseSurface: AppColors.neutral100,
        inversePrimary: AppColors.primaryAccent,
      );
}

/// Dark Color Scheme
class DarkColorScheme {
  DarkColorScheme._();

  static ColorScheme get scheme => const ColorScheme(
        brightness: Brightness.dark,
        primary: AppColors.primaryAccent,
        onPrimary: AppColors.primaryDark,
        primaryContainer: AppColors.primaryGreen,
        onPrimaryContainer: Color(0xFFD8F3DC),
        secondary: AppColors.secondaryBeige,
        onSecondary: Color(0xFF4A3728),
        secondaryContainer: Color(0xFF6B5744),
        onSecondaryContainer: AppColors.secondaryTan,
        tertiary: Color(0xFF95D5B2),
        onTertiary: AppColors.primaryDark,
        tertiaryContainer: Color(0xFF2D6A4F),
        onTertiaryContainer: Color(0xFFD8F3DC),
        error: Color(0xFFFFB4AB),
        onError: Color(0xFF690005),
        errorContainer: Color(0xFF93000A),
        onErrorContainer: Color(0xFFFFDAD6),
        surface: AppColors.surfaceDark,
        onSurface: Color(0xFFE6E1E5),
        surfaceContainerHighest: AppColors.surfaceDarkElevated,
        onSurfaceVariant: Color(0xFFCAC4D0),
        outline: Color(0xFF938F99),
        outlineVariant: Color(0xFF49454F),
        shadow: Colors.black,
        scrim: Colors.black,
        inverseSurface: Color(0xFFE6E1E5),
        onInverseSurface: Color(0xFF313033),
        inversePrimary: AppColors.primaryGreen,
      );
}
