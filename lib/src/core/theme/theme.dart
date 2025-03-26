import 'package:flutter/material.dart';
import 'app_pallete.dart';

class AppTheme {
  /// Input Border Style (shared)
  static OutlineInputBorder _border([Color color = AppPallete.borderColor]) =>
      OutlineInputBorder(
        borderSide: BorderSide(color: color, width: 2),
        borderRadius: BorderRadius.circular(10),
      );

  /// ✅ Light Theme with Lavender ERP identity
  static final ThemeData lightThemeMode = ThemeData(
    brightness: Brightness.light,
    fontFamily: 'NotoSans',

    scaffoldBackgroundColor: AppPallete.backgroundColor,
    primaryColor: AppPallete.primaryLavender,
    useMaterial3: true,

    // ✅ Text theme with support for Arabic
    textTheme: const TextTheme(
      titleLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        fontFamily: 'NotoSans',
        color: AppPallete.textPrimary,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        fontFamily: 'NotoSans',
        color: AppPallete.textPrimary,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontFamily: 'NotoSansArabic',
        color: AppPallete.textSecondary,
      ),
    ),

    // ✅ Chip styling
    chipTheme: ChipThemeData(
      backgroundColor: AppPallete.primaryLavender.withAlpha(20),
      selectedColor: AppPallete.primaryLavender.withAlpha(46),
      disabledColor: Colors.grey.shade300,
      labelStyle: const TextStyle(
        fontSize: 14,
        color: AppPallete.textPrimary,
        fontWeight: FontWeight.w500,
      ),
      secondaryLabelStyle: const TextStyle(color: AppPallete.textSecondary),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: const StadiumBorder(), // 🟣 Clean pill shape
      side: BorderSide.none, // ✅ Remove any weird outline
    ),

    // ✅ Input field styles
    inputDecorationTheme: InputDecorationTheme(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      filled: true,
      fillColor: Colors.white,
      border: _border(),
      enabledBorder: _border(),
      focusedBorder: _border(AppPallete.gradient2),
      errorBorder: _border(AppPallete.errorColor),
      labelStyle: const TextStyle(color: AppPallete.textSecondary),
    ),

    // ✅ Button styles
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppPallete.primaryLavender,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    // ✅ AppBar theme
    appBarTheme: const AppBarTheme(
      backgroundColor: AppPallete.primaryLavender,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    ),

    // ✅ Card style
    cardTheme: CardTheme(
      color: AppPallete.cardColor,
      elevation: 3,
      margin: const EdgeInsets.all(12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),

    // ✅ Global color scheme
    colorScheme: ColorScheme.light(
      primary: AppPallete.primaryLavender,
      secondary: AppPallete.gradient2,
      error: AppPallete.errorColor,
      // background: AppPallete.backgroundColor,
      onPrimary: Colors.white,
      onSurface: AppPallete.textPrimary,
    ),
  );
}
