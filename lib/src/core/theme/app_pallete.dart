import 'package:flutter/material.dart';

/// Keep your original name to avoid breaking imports.
class AppPallete {
  // 🎯 Brand — Cool Lavender core
  static const Color lavender = Color(0xFF7F79F0); // #7F79F0

  // 🌈 Brand gradient (tints/shades of lavender)
  static const Color gradient1 = lavender; // base
  static const Color gradient2 = Color(0xFF9D98F5); // lighter tint
  static const Color gradient3 = Color(0xFFC1BEFA); // soft tint

  // 🎨 Theme / Background
  static const Color backgroundColor = Color(0xFFF6F7FB); // light cool bg
  static const Color surfaceColor = Colors.white;
  static const Color cardColor = Color(0xFFFEFEFF);
  static const Color cardColorLavenderTint =
      Color(0xFFF2F2FF); // subtle lavender wash
  static const Color cardColorWhite = Colors.white;

  // 🧱 Borders / Dividers
  static const Color borderColor = Color(0xFFE6E7EE);
  static const Color dividerColor = Color(0xFFDFE2EA);

  // 📝 Text & Neutral
  static const Color whiteColor = Colors.white;
  static const Color greyColor = Colors.grey;
  static const Color textPrimary = Color(0xFF111827); // near-black neutral
  static const Color textSecondary = Color(0xFF6B7280); // gray 500

  // 🚦 Status (new unified set)
  static const Color infoColor = lavender; // brand = info
  static const Color warningColor = Color(0xFFFFB020); // modern amber
  static const Color successColor = Color(0xFF22C55E); // emerald
  static const Color errorColor = Color(0xFFE11D48); // rose

  // 🧩 Legacy aliases (to avoid refactor pain)
  static const Color inProgressColor = warningColor; // was amber
  static const Color completedColor = successColor; // was green
  static const Color rejectColor = errorColor; // was red

  // 🔵 Primary for buttons and actions (alias)
  static const Color primaryLavender = lavender;

  // 🧩 Others
  static const Color transparentColor = Colors.transparent;
}

/// Optional: allow both spellings to work without changing imports.
typedef AppPalette = AppPallete;
