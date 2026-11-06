import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Inter font - clean, readable, neutral
class AppTypography {
  static TextTheme get textTheme => GoogleFonts.interTextTheme();

  static TextTheme get lightTextTheme => GoogleFonts.interTextTheme(
        ThemeData.light().textTheme,
      );

  static TextTheme get darkTextTheme => GoogleFonts.interTextTheme(
        ThemeData.dark().textTheme,
      );
}