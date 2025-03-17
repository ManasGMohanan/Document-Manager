import 'package:flutter/material.dart';

class DMColors {
  // App theme colors
  static const Color primary = Color(0xFF4b68ff);
  static const Color secondary = Color(0xFFFFE24B);
  static const Color accent = Color(0xFFb0c7ff);

  // Dark theme colors
  static const Color darkPrimaryColor = Color(0xFF263238);
  static const Color darkAccentColor = Color(0xFF60D394);
  static const Color darkBackgroundColor = Color(0xFF121212);
  static const Color darkCardColor = Color(0xFF1E1E1E);
  static const Color darkTextColor = Color(0xFFEEEEEE);
  static const Color darkSecondaryTextColor = Color(0xFFB0B0B0);

  // Light theme “card” color (for parity with darkCardColor)
  static const Color lightCardColor = Color(0xFFFFFFFF);
  static const Color lightCardColor2 = Color(0xFFE0E5FF);

  // Text colors
  static const Color textPrimary = Color(0xFF333333);
  static const Color textSecondary = Color(0xFF6C757D);
  static const Color textWhite = Colors.white;

  // Background colors
  static const Color lightBackgroundColor = Color(0xFFF6F6F6);
  static const Color darkBackgroundColor2 = Color(0xFF272727);
  static const Color primaryBackground = Color(0xFFF3F5FF);

  // Background Container colors
  static const Color lightContainer = Color(0xFFF6F6F6);
  // ignore: deprecated_member_use
  static Color darkContainer = DMColors.white.withOpacity(0.1);

  // Button colors
  static const Color buttonPrimary = Color(0xFF4b68ff);
  static const Color buttonSecondary = Color(0xFF6C757D);
  static const Color buttonDisabled = Color(0xFFC4C4C4);

  // Border colors
  static const Color borderPrimary = Color(0xFFD9D9D9);
  static const Color borderSecondary = Color(0xFFE6E6E6);

  // Error and validation colors
  static const Color error = Color(0xFFD32F2F);
  static const Color success = Color(0xFF388E3C);
  static const Color warning = Color(0xFFF57C00);
  static const Color info = Color(0xFF1976D2);

  // Neutral Shades
  static const Color black = Color(0xFF232323);
  static const Color darkerGrey = Color(0xFF4F4F4F);
  static const Color darkGrey = Color(0xFF939393);
  static const Color grey = Color(0xFFE0E0E0);
  static const Color softGrey = Color(0xFFF4F4F4);
  static const Color lightGrey = Color(0xFFF9F9F9);
  static const Color white = Color(0xFFFFFFFF);

  // Additional Material shade 700 colors (added for specific document types)
  static const Color purple700 = Color(0xFF7B1FA2);
  static const Color pink700 = Color(0xFFC2185B);
  static const Color deepOrange700 = Color(0xFFD84315);
  static const Color blueGrey700 = Color(0xFF455A64);
  static const Color grey700 = Color(0xFF616161);
}
