import 'package:flutter_test/flutter_test.dart';
import 'package:w51/core/utils/formatters.dart';

void main() {
  test('formatRupiah memakai titik sebagai pemisah ribuan', () {
    expect(formatRupiah(247459800), 'IDR 247.459.800');
    expect(formatRupiah(1000000), 'IDR 1.000.000');
    expect(formatRupiah(850000, prefix: 'Rp'), 'Rp 850.000');
    expect(formatRupiah(999), 'IDR 999');
    expect(formatRupiah(0), 'IDR 0');
  });

  test('formatNumber tanpa awalan', () {
    expect(formatNumber(61865), '61.865');
    expect(formatNumber(384), '384');
  });

  test('formatDateId memakai nama hari dan bulan Indonesia', () {
    expect(formatDateId(DateTime(2026, 10, 24)), 'Sabtu, 24 Oktober 2026');
    expect(formatDateId(DateTime(2026, 1, 5)), 'Senin, 5 Januari 2026');
  });

  test('formatTimeWita menambah nol di depan', () {
    expect(formatTimeWita(15, 30), '15:30 WITA');
    expect(formatTimeWita(8, 5), '08:05 WITA');
  });
}
