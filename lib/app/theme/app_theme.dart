import 'package:flutter/material.dart';
import 'package:w51/app/theme/app_colors.dart';

abstract final class AppTheme {
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.canvas,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.coral,
          primary: AppColors.coralDark,
          surface: AppColors.canvas,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.canvas,
          foregroundColor: AppColors.ink,
          elevation: 0,
          centerTitle: false,
        ),
        textTheme: const TextTheme(
          headlineSmall: TextStyle(
            color: AppColors.ink,
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
          titleMedium: TextStyle(
            color: AppColors.ink,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          bodyMedium: TextStyle(color: AppColors.ink, fontSize: 14),
        ),
      );
}
