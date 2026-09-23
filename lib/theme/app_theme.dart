import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData light({required bool highContrast}) {
    final scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF2B7A78),
      brightness: Brightness.light,
    );
    return _base(scheme, highContrast: highContrast).copyWith(
      scaffoldBackgroundColor:
          highContrast ? Colors.white : const Color(0xFFF5F7FA),
    );
  }

  static ThemeData dark({required bool highContrast}) {
    final scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF5BC0BE),
      brightness: Brightness.dark,
    );
    return _base(scheme, highContrast: highContrast).copyWith(
      scaffoldBackgroundColor:
          highContrast ? Colors.black : const Color(0xFF101820),
    );
  }

  static ThemeData _base(
    ColorScheme scheme, {
    required bool highContrast,
  }) {
    final borderRadius = BorderRadius.circular(18);
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      visualDensity: VisualDensity.standard,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        border: OutlineInputBorder(borderRadius: borderRadius),
      ),
      cardTheme: CardThemeData(
        elevation: highContrast ? 0 : 1,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: borderRadius,
          side: BorderSide(
            color: highContrast ? scheme.outline : scheme.outlineVariant,
            width: highContrast ? 2 : 1,
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}
