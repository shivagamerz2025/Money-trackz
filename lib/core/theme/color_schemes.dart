import 'package:flutter/material.dart';

/// Calm, minimalist color schemes - no gradients, no neon, no bluish purple
/// Neutral slate base with emerald (success/savings) and red (error/overspend)
class AppColorSchemes {
  static const Color _seed = Color(0xFF6B7280); // Neutral slate

  static const ColorScheme light = ColorScheme(
    brightness: Brightness.light,
    primary: Color(0xFF374151),       // Dark slate (primary text/actions)
    onPrimary: Colors.white,
    primaryContainer: Color(0xFFE5E7EB),
    onPrimaryContainer: Color(0xFF1F2937),
    secondary: Color(0xFF9CA3AF),     // Muted slate
    onSecondary: Color(0xFF1F2937),
    secondaryContainer: Color(0xFFF3F4F6),
    onSecondaryContainer: Color(0xFF374151),
    tertiary: Color(0xFF059669),      // Emerald (success, savings, income)
    onTertiary: Colors.white,
    tertiaryContainer: Color(0xFFD1FAE5),
    onTertiaryContainer: Color(0xFF065F46),
    error: Color(0xFFDC2626),         // Red (overspend, errors)
    onError: Colors.white,
    errorContainer: Color(0xFFFEF2F2),
    onErrorContainer: Color(0xFF991B1B),
    surface: Color(0xFFFAFAFA),       // Off-white
    onSurface: Color(0xFF1F2937),
    surfaceContainerHighest: Color(0xFFF3F4F6),
    onSurfaceVariant: Color(0xFF6B7280),
    outline: Color(0xFFE5E7EB),
    outlineVariant: Color(0xFFF3F4F6),
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
    inverseSurface: Color(0xFF1F2937),
    onInverseSurface: Color(0xFFFAFAFA),
    inversePrimary: Color(0xFFD1D5DB),
    surfaceTint: Color(0xFF374151),
  );

  static const ColorScheme dark = ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFFF3F4F6),
    onPrimary: Color(0xFF1F2937),
    primaryContainer: Color(0xFF4B5563),
    onPrimaryContainer: Color(0xFFF3F4F6),
    secondary: Color(0xFF9CA3AF),
    onSecondary: Color(0xFFFAFAFA),
    secondaryContainer: Color(0xFF374151),
    onSecondaryContainer: Color(0xFFE5E7EB),
    tertiary: Color(0xFF34D399),
    onTertiary: Color(0xFF1F2937),
    tertiaryContainer: Color(0xFF064E3B),
    onTertiaryContainer: Color(0xFFD1FAE5),
    error: Color(0xFFEF4444),
    onError: Color(0xFFFAFAFA),
    errorContainer: Color(0xFF7F1D1D),
    onErrorContainer: Color(0xFFFECACA),
    surface: Color(0xFF111827),
    onSurface: Color(0xFFF3F4F6),
    surfaceContainerHighest: Color(0xFF1F2937),
    onSurfaceVariant: Color(0xFF9CA3AF),
    outline: Color(0xFF374151),
    outlineVariant: Color(0xFF1F2937),
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
    inverseSurface: Color(0xFFFAFAFA),
    onInverseSurface: Color(0xFF1F2937),
    inversePrimary: Color(0xFF374151),
    surfaceTint: Color(0xFFF3F4F6),
  );
}