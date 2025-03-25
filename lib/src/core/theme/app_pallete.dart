import 'package:flutter/material.dart';

class AppPallete {
  // 🌐 Brand Blue Gradient Colors (replacing lavender)
  static const Color gradient1 = Color(0xFF3A7AFE); // Blue (Primary)
  static const Color gradient2 = Color(0xFF00B9AE); // Teal
  static const Color gradient3 = Color(0xFF4DD0E1); // Cyan/Accent

  // 🎨 Theme / Background
  static const Color backgroundColor =
      Color(0xFFF4F6F8); // Light gray for ERP background
  static const Color surfaceColor = Colors.white;
  static const Color borderColor = Color(0xFFE0E0E0); // Subtle light border
  static const Color cardColor =
      Color(0xFFFDFEFF); // Light off-white with cool tone
  static const Color cardColorLavenderTint =
      Color(0xFFF0F4FF); // Soft blue tint (was lavender)
  static const Color cardColorWhite = Colors.white;

  // 📝 Text & Neutral
  static const Color whiteColor = Colors.white;
  static const Color greyColor = Colors.grey;
  static const Color textPrimary = Color(0xFF1C1C1E); // Dark neutral text
  static const Color textSecondary = Color(0xFF6B7280); // Medium gray text

  // 🚦 Status Colors
  static const Color inProgressColor = Color(0xFFFFC107); // Yellow/Amber
  static const Color completedColor = Color(0xFF4CAF50); // Green
  static const Color rejectColor = Color(0xFFF44336); // Red
  static const Color errorColor = Color(0xFFE53935); // Strong red

  // 🧩 Others
  static const Color transparentColor = Colors.transparent;

  // 🔵 Primary for buttons and actions
  static const Color primaryLavender =
      gradient1; // 🧠 Alias for your old naming
}
