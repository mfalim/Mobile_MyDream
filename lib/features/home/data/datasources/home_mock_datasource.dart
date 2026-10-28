import 'package:w51/features/home/domain/entities/home_entities.dart';

/// MOCK: kemajuan persiapan pernikahan. Belum ada sumbernya di database,
/// jadi saat tersambung API nilainya null dan bagiannya disembunyikan.
class HomeMockDatasource {
  const HomeMockDatasource();

  Future<WeddingCountdown?> fetchProgress() async => const WeddingCountdown(
        readiness: 0.62,
        nextTask: 'Finalisasi Undangan & RSVP',
      );
}
