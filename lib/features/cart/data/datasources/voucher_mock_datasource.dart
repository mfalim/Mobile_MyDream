import 'package:w51/features/cart/domain/entities/voucher.dart';

/// MOCK DATA: contoh untuk prototype, BUKAN data dari server.
class VoucherMockDatasource {
  Future<List<Voucher>> fetch() async => const [
        Voucher(
          code: 'DREAMWEDDING',
          title: 'Potongan Rp 5 Juta',
          description: 'Untuk pemesanan paket pernikahan.',
          type: VoucherType.fixed,
          value: 5000000,
          minSpend: 50000000,
          validUntilLabel: '31 Des 2026',
        ),
        Voucher(
          code: 'BRIDALEXPO',
          title: 'Bridal Expo: Diskon 10%',
          description: 'Maksimal potongan Rp 15.000.000.',
          type: VoucherType.percent,
          value: 10,
          maxDiscount: 15000000,
          minSpend: 300000000,
          validUntilLabel: '30 Nov 2026',
        ),
        Voucher(
          code: 'NEWCOUPLE',
          title: 'Pasangan Baru: Diskon 3%',
          description: 'Maksimal potongan Rp 5.000.000.',
          type: VoucherType.percent,
          value: 3,
          maxDiscount: 5000000,
          minSpend: 20000000,
          validUntilLabel: '31 Jan 2027',
        ),
      ];
}
