import 'package:w51/core/errors/app_exceptions.dart';
import 'package:w51/features/support/domain/entities/support_report.dart';

/// MOCK: meniru server (POST /support/reports). Nomor tiket nanti dari server.
class SupportMockDatasource {
  const SupportMockDatasource({
    this.delay = const Duration(milliseconds: 600),
  });

  final Duration delay;
  static int _sequence = 1000;

  Future<String> submit(SupportReport report) async {
    await Future<void>.delayed(delay);
    if (!kReportCategories.contains(report.category)) {
      throw const ValidationException('Kategori tidak valid.');
    }
    final message = report.message.trim();
    if (message.length < 10) {
      throw const ValidationException(
        'Deskripsi terlalu pendek (minimal 10 karakter).',
      );
    }
    if (message.length > 1000) {
      throw const ValidationException('Deskripsi maksimal 1000 karakter.');
    }
    _sequence++;
    return 'LPR-$_sequence';
  }
}
