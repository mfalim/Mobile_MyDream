import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Satu-satunya sumber tanggal pernikahan untuk semua layar.
/// MOCK: nilai awal tetap. Nanti diambil dari data pasangan di server.
final weddingDateProvider = NotifierProvider<WeddingDateController, DateTime>(
  WeddingDateController.new,
);

class WeddingDateController extends Notifier<DateTime> {
  @override
  DateTime build() => DateTime(2026, 10, 24);

  void setDate(DateTime date) =>
      state = DateTime(date.year, date.month, date.day);
}
