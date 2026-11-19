import 'package:w51/app/router/route_names.dart';
import 'package:w51/core/network/api_client.dart';
import 'package:w51/core/utils/formatters.dart';
import 'package:w51/core/utils/json_helpers.dart';
import 'package:w51/features/notifications/data/datasources/notifications_datasource.dart';
import 'package:w51/features/notifications/domain/entities/notification_item.dart';

class NotificationsRemoteDatasource implements NotificationsDatasource {
  NotificationsRemoteDatasource(this._api);

  final ApiClient _api;
  final Set<String> _readIds = <String>{};

  @override
  Future<List<NotificationItem>> fetch() async {
    // 1. Coba panggil endpoint /notifications jika tersedia
    try {
      final items = await _api.getList('/notifications');
      return [for (final json in items) _fromJson(json)];
    } catch (_) {
      // 2. Bangun notifikasi secara real-time dari data dashboard klien di Laravel (/client/dashboard)
      return _fetchFromClientDashboard();
    }
  }

  Future<List<NotificationItem>> _fetchFromClientDashboard() async {
    try {
      final dashboard = await _api.getObject('/client/dashboard');
      final items = <NotificationItem>[];

      final rawBookings = dashboard['recent_bookings'];
      if (rawBookings is List) {
        for (final b in rawBookings.whereType<Map>()) {
          final bookingId = '${b['id']}';
          final invoice = jsonString(b['invoice_number']) ?? 'Pesanan #$bookingId';
          final status = jsonString(b['status']) ?? 'pending';
          final createdAt = jsonString(b['created_at']);
          final date = createdAt == null ? null : DateTime.tryParse(createdAt);

          final id = 'booking-$bookingId';
          items.add(
            NotificationItem(
              id: id,
              kind: NotificationKind.booking,
              title: status == 'confirmed' || status == 'completed'
                  ? 'Pesanan $invoice Dikonfirmasi'
                  : 'Status Pesanan $invoice: ${status.toUpperCase()}',
              body: 'Lokasi: ${jsonString(b['venue_name']) ?? '-'} • Tamu: ${b['guest_count'] ?? '-'} orang.',
              timeLabel: date == null ? '' : formatDateShortId(date),
              route: AppRoutes.myWedding,
              read: _readIds.contains(id) || status == 'completed',
            ),
          );

          final rawPayments = b['payments'];
          if (rawPayments is List) {
            for (final p in rawPayments.whereType<Map>()) {
              final paymentId = 'payment-${p['id']}';
              final pStatus = jsonString(p['status']) ?? 'pending';
              final amount = jsonInt(p['amount']) ?? 0;
              final pDateStr = jsonString(p['verified_at'] ?? p['created_at']);
              final pDate = pDateStr == null ? null : DateTime.tryParse(pDateStr);

              items.add(
                NotificationItem(
                  id: paymentId,
                  kind: NotificationKind.payment,
                  title: pStatus == 'verified'
                      ? 'Pembayaran Diverifikasi Admin'
                      : pStatus == 'rejected'
                          ? 'Pembayaran Ditolak'
                          : 'Pembayaran Menunggu Verifikasi',
                  body:
                      'Tagihan $invoice sebesar ${formatRupiah(amount, prefix: 'Rp ')}'
                      '${jsonString(p['admin_note']) != null ? ' • Catatan: ${p['admin_note']}' : ''}',
                  timeLabel: pDate == null ? '' : formatDateShortId(pDate),
                  route: AppRoutes.myWedding,
                  read: _readIds.contains(paymentId) || pStatus == 'verified',
                ),
              );
            }
          }
        }
      }

      final rawEvents = dashboard['upcoming_events'];
      if (rawEvents is List) {
        for (final e in rawEvents.whereType<Map>()) {
          final eventId = 'event-${e['id']}';
          final name = jsonString(e['name']) ?? 'Acara Pernikahan';
          final eventDateStr = jsonString(e['event_date']);
          final eventDate =
              eventDateStr == null ? null : DateTime.tryParse(eventDateStr);

          items.add(
            NotificationItem(
              id: eventId,
              kind: NotificationKind.reminder,
              title: 'Pengingat Acara: $name',
              body: eventDate == null
                  ? 'Jadwal acara mendatang.'
                  : 'Dijadwalkan pada ${formatDateShortId(eventDate)}.',
              timeLabel: eventDate == null ? '' : formatDateShortId(eventDate),
              route: AppRoutes.myWedding,
              read: _readIds.contains(eventId),
            ),
          );
        }
      }

      return items;
    } catch (_) {
      return const [];
    }
  }

  @override
  Future<void> markRead(String id) async {
    _readIds.add(id);
    try {
      await _api.post('/notifications/${Uri.encodeComponent(id)}/read');
    } catch (_) {
      // Abaikan jika disimpan secara lokal dari /client/dashboard
    }
  }

  @override
  Future<void> markAllRead() async {
    try {
      await _api.post('/notifications/read-all');
    } catch (_) {
      // Abaikan jika disimpan secara lokal dari /client/dashboard
    }
  }

  NotificationItem _fromJson(Map<String, dynamic> json) {
    final createdAt = jsonString(json['created_at']);
    final date = createdAt == null ? null : DateTime.tryParse(createdAt);
    final kind = switch (jsonString(json['kind'])) {
      'booking' => NotificationKind.booking,
      'payment' => NotificationKind.payment,
      'reminder' => NotificationKind.reminder,
      'promo' => NotificationKind.promo,
      _ => throw const FormatException('Jenis notifikasi tidak dikenali.'),
    };
    return NotificationItem(
      id: jsonString(json['id']) ??
          (throw const FormatException('Notifikasi tidak memiliki id.')),
      kind: kind,
      title: jsonString(json['title']) ??
          (throw const FormatException('Notifikasi tidak memiliki judul.')),
      body: jsonString(json['body']) ?? '',
      timeLabel: date == null ? createdAt ?? '' : formatDateShortId(date),
      route: jsonString(json['route']),
      read: json['read_at'] != null,
    );
  }
}
