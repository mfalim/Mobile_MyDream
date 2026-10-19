import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

abstract final class AppTypography {
  // Serif untuk judul (Playfair Display)
  static TextStyle heading(double size) => GoogleFonts.playfairDisplay(
        fontSize: size,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        height: 1.2,
      );

  // Label kecil uppercase di atas judul, mis. "KURASI SPESIALIS"
  static TextStyle get eyebrow => GoogleFonts.plusJakartaSans(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.0,
        color: AppColors.primary,
      );

  /// TextTheme Flutter + font Plus Jakarta Sans. Dibangun manual karena
  /// GoogleFonts.*TextTheme() mengembalikan tipe TextTheme milik material_ui,
  /// bukan milik Flutter.
  static TextTheme get textTheme {
    final base = ThemeData(useMaterial3: true).textTheme.apply(
          bodyColor: AppColors.textPrimary,
          displayColor: AppColors.textPrimary,
        );

    TextStyle? font(TextStyle? style) =>
        style == null ? null : GoogleFonts.plusJakartaSans(textStyle: style);

    return base.copyWith(
      displayLarge: font(base.displayLarge),
      displayMedium: font(base.displayMedium),
      displaySmall: font(base.displaySmall),
      headlineLarge: font(base.headlineLarge),
      headlineMedium: heading(28),
      headlineSmall: heading(24),
      titleLarge: heading(22),
      titleMedium: font(base.titleMedium),
      titleSmall: font(base.titleSmall),
      bodyLarge: font(base.bodyLarge),
      bodyMedium: font(base.bodyMedium),
      bodySmall: font(base.bodySmall),
      labelLarge: font(base.labelLarge),
      labelMedium: font(base.labelMedium),
      labelSmall: font(base.labelSmall),
    );
  }
}
