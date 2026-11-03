import 'package:flutter/material.dart';

/// Palet mengikuti Figma "MyDream" (maroon). Nilai hex masih estimasi
/// dari screenshot; ganti dengan hex asli dari Figma bila ada selisih.
abstract final class AppColors {
  // Brand
  static const primary = Color(0xFF8E3F3F);
  static const onPrimary = Color(0xFFFFFFFF);
  static const coral = Color(0xFFE08C84);
  static const gold = Color(0xFFFAE8A4);
  static const onGold = Color(0xFF6B5300);

  // Surfaces
  static const background = Color(0xFFFFF6F4);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceTint = Color(0xFFF8EAE7);
  static const outline = Color(0xFFE6D3CF);

  // Text
  static const textPrimary = Color(0xFF2B1E1E);
  static const textSecondary = Color(0xFF6E5B58);

  // Status
  static const error = Color(0xFFB3261E);
  static const success = Color(0xFF2E7D4F);

  // ---- Alias untuk kode lama (hapus bertahap saat halaman ditulis ulang) ----
  static const coralDark = primary;
  static const ink = textPrimary;
  static const muted = textSecondary;
  static const canvas = background;
  static const line = outline;
  static const blush = surfaceTint;
  static const sage = Color(0xFF788C77); // belum ada padanan di Figma
}
