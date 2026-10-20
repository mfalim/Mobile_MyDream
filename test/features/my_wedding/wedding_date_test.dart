import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:w51/core/utils/date_helpers.dart';
import 'package:w51/core/utils/formatters.dart';
import 'package:w51/features/my_wedding/presentation/providers/wedding_date_provider.dart';

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

  test('tanggal pernikahan bisa diubah dan jamnya dibuang', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(weddingDateProvider), DateTime(2026, 10, 24));
    container
        .read(weddingDateProvider.notifier)
        .setDate(DateTime(2027, 2, 14, 18, 30));
    expect(container.read(weddingDateProvider), DateTime(2027, 2, 14));
  });
}
