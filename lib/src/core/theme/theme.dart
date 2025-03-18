import 'package:etqan_application_2025/src/core/theme/app_pallete.dart';
import 'package:flutter/material.dart';

class AppTheme {
  static _border([Color color = AppPallete.borderColor]) => OutlineInputBorder(
      borderSide: BorderSide(color: color, width: 2),
      borderRadius: BorderRadius.circular(10));
  static final darkThemeMode = ThemeData(
    brightness: Brightness.dark, // ✅ Use this instead of `ThemeData.dark()`
    fontFamily: 'NotoSans', // ✅ Now it's valid
    textTheme: TextTheme(
      bodyLarge: TextStyle(fontFamily: 'NotoSans'),
      bodyMedium: TextStyle(fontFamily: 'NotoSansArabic'),
    ),
    scaffoldBackgroundColor: AppPallete.backgroundColor,
    chipTheme: const ChipThemeData(
      color: WidgetStatePropertyAll(AppPallete.backgroundColor),
      side: BorderSide.none,
    ),
    inputDecorationTheme: InputDecorationTheme(
      contentPadding: const EdgeInsets.all(27),
      border: _border(),
      enabledBorder: _border(),
      focusedBorder: _border(AppPallete.gradient2),
      errorBorder: _border(AppPallete.errorColor),
    ),
  );

  // static final darkThemeMode = ThemeData.dark().copyWith(
  //     textTheme: TextTheme(
  //       bodyLarge: TextStyle(fontFamily: 'NotoSans'),
  //       bodyMedium: TextStyle(fontFamily: 'NotoSansArabic'),
  //     ),
  //     scaffoldBackgroundColor: AppPallete.backgroundColor,
  //     chipTheme: const ChipThemeData(
  //       color: WidgetStatePropertyAll(AppPallete.backgroundColor),
  //       side: BorderSide.none,
  //     ),
  //     inputDecorationTheme: InputDecorationTheme(
  //       contentPadding: const EdgeInsets.all(27),
  //       border: _border(),
  //       enabledBorder: _border(),
  //       focusedBorder: _border(AppPallete.gradient2),
  //       errorBorder: _border(AppPallete.errorColor),
  //     ));
}
