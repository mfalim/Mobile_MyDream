import 'package:w51/features/support/domain/entities/support_report.dart';

abstract interface class SupportRepository {
  /// Mengirim laporan; mengembalikan nomor tiket. Melempar
  /// `ValidationException` bila ditolak server.
  Future<String> submit(SupportReport report);
}
