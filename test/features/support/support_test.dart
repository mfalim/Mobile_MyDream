import 'package:flutter_test/flutter_test.dart';
import 'package:w51/core/errors/app_exceptions.dart';
import 'package:w51/features/support/data/datasources/support_mock_datasource.dart';
import 'package:w51/features/support/domain/entities/support_report.dart';

void main() {
  const datasource = SupportMockDatasource(delay: Duration.zero);

  test('laporan valid menghasilkan nomor tiket yang berbeda-beda', () async {
    const report = SupportReport(
      category: 'Pembayaran',
      message: 'Tombol kirim pesanan tidak merespons.',
    );
    final a = await datasource.submit(report);
    final b = await datasource.submit(report);
    expect(a, startsWith('LPR-'));
    expect(a, isNot(b));
  });

  test('ditolak: kategori tidak dikenal, deskripsi pendek atau terlalu panjang',
      () async {
    for (final report in [
      const SupportReport(
          category: 'Lain-lain', message: 'Deskripsi yang cukup panjang'),
      const SupportReport(category: 'Pesanan', message: 'pendek'),
      SupportReport(category: 'Pesanan', message: 'x' * 1001),
    ]) {
      await expectLater(
        datasource.submit(report),
        throwsA(isA<ValidationException>()),
      );
    }
  });
}
