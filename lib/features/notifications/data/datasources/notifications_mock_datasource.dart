import 'package:w51/features/notifications/domain/entities/notification_item.dart';

/// MOCK DATA: contoh untuk prototype, BUKAN data dari server.
/// `route` meniru alamat tujuan yang nanti dikirim server.
class NotificationsMockDatasource {
  Future<List<NotificationItem>> fetch() async => const [
        NotificationItem(
          id: 'n-1',
          kind: NotificationKind.booking,
          title: 'Pesanan dikonfirmasi',
          body: 'Vendor menerima pemesananmu dan tanggal acara sudah dikunci.',
          timeLabel: 'Baru saja',
        ),
        NotificationItem(
          id: 'n-2',
          kind: NotificationKind.payment,
          title: 'DP berhasil diterima',
          body: 'Pembayaran uang muka sudah masuk ke rekening bersama.',
          timeLabel: '2 jam lalu',
        ),
        NotificationItem(
          id: 'n-3',
          kind: NotificationKind.reminder,
          title: 'Jadwal konsultasi besok',
          body: 'Konsultasi dengan vendor dijadwalkan besok pukul 10.00 WITA.',
          timeLabel: 'Kemarin',
        ),
        NotificationItem(
          id: 'n-4',
          kind: NotificationKind.promo,
          title: 'Bridal Expo & Vendor Deals',
          body: 'Klaim voucher BRIDALEXPO sebelum 30 November 2026.',
          timeLabel: '2 hari lalu',
          route: '/cart?claim=BRIDALEXPO',
          read: true,
        ),
        NotificationItem(
          id: 'n-5',
          kind: NotificationKind.reminder,
          title: 'Lengkapi data pernikahanmu',
          body: 'Isi nama pasangan dan tanggal agar hitung mundur dan data '
              'pesanan terisi otomatis.',
          timeLabel: '3 hari lalu',
          route: '/couple-setup',
          read: true,
        ),
      ];
}
