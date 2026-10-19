import 'package:flutter/material.dart';

abstract final class AppRadius {
  static const double sm = 12;
  static const double md = 16; // tombol, input
  static const double lg = 24; // kartu
  static const double pill = 999;

  static BorderRadius get card => BorderRadius.circular(lg);
  static BorderRadius get button => BorderRadius.circular(md);
  static BorderRadius get chip => BorderRadius.circular(pill);
}
