import 'package:w51/core/network/api_client.dart';
import 'package:w51/core/utils/formatters.dart';
import 'package:w51/core/utils/json_helpers.dart';
import 'package:w51/features/notifications/data/datasources/notifications_datasource.dart';
import 'package:w51/features/notifications/domain/entities/notification_item.dart';

class NotificationsRemoteDatasource implements NotificationsDatasource {
  const NotificationsRemoteDatasource(this._api);

  final ApiClient _api;

  @override
  Future<List<NotificationItem>> fetch() async {
    final items = await _api.getList('/notifications');
    return [for (final json in items) _fromJson(json)];
  }

  @override
  Future<void> markRead(String id) async {
    await _api.post('/notifications/${Uri.encodeComponent(id)}/read');
  }

  @override
  Future<void> markAllRead() async {
    await _api.post('/notifications/read-all');
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
