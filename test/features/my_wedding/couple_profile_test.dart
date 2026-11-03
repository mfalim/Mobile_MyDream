import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:w51/core/utils/date_helpers.dart';
import 'package:w51/core/utils/formatters.dart';
import 'package:w51/features/my_wedding/domain/entities/couple_profile.dart';
import 'package:w51/features/my_wedding/presentation/providers/couple_provider.dart';

void main() {
  test('daysUntil menghitung selisih hari kalender', () {
    final now = DateTime(2026, 10, 20, 23, 59);
    expect(daysUntil(DateTime(2026, 10, 24), now: now), 4);
    expect(daysUntil(DateTime(2026, 10, 20, 8), now: now), 0);
    expect(daysUntil(DateTime(2026, 10, 19), now: now), -1);
  });

  test('daysUntil tidak terpengaruh pergantian jam musim', () {
    expect(
      daysUntil(DateTime(2026, 3, 30), now: DateTime(2026, 3, 29, 23)),
      1,
    );
  });

  test('formatDateShortId', () {
    expect(formatDateShortId(DateTime(2026, 10, 24)), '24 Okt 2026');
    expect(formatDateShortId(DateTime(2027, 5, 1)), '1 Mei 2027');
  });

  test('nama pasangan: versi singkat dan versi profil', () {
    final c = CoupleProfile(
      brideName: 'Clarissa Wijaya',
      groomName: 'Adrian Pratama',
      weddingDate: DateTime(2026, 10, 24),
    );
    expect(c.shortNames, 'Clarissa & Adrian');
    expect(c.profileNames, 'Clarissa Wijaya & Adrian');
  });

  test('nama satu kata tetap menghasilkan nama yang rapi', () {
    final c = CoupleProfile(
      brideName: 'Dewi',
      groomName: '  Dimas ',
      weddingDate: DateTime(2026, 10, 24),
    );
    expect(c.shortNames, 'Dewi & Dimas');
    expect(c.profileNames, 'Dewi & Dimas');
  });

  test('provider: awalnya kosong, save merapikan data, clear menghapus', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(coupleProvider), isNull);

    container.read(coupleProvider.notifier).save(
          CoupleProfile(
            brideName: '  Dewi Mayang ',
            groomName: ' Dimas ',
            weddingDate: DateTime(2027, 2, 14, 18, 30),
          ),
        );
    final saved = container.read(coupleProvider)!;
    expect(saved.brideName, 'Dewi Mayang');
    expect(saved.groomName, 'Dimas');
    expect(saved.weddingDate, DateTime(2027, 2, 14));

    container.read(coupleProvider.notifier).clear();
    expect(container.read(coupleProvider), isNull);
  });
}
