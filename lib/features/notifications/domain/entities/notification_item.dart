enum NotificationKind { booking, payment, reminder, promo }

class NotificationItem {
  const NotificationItem({
    required this.id,
    required this.kind,
    required this.title,
    required this.body,
    required this.timeLabel,
    this.route,
    this.read = false,
  });

  final String id;
  final NotificationKind kind;
  final String title;
  final String body;
  final String timeLabel;

  /// Alamat tujuan di dalam aplikasi saat notifikasi diketuk (dari server).
  final String? route;
  final bool read;

  NotificationItem copyWith({bool? read}) => NotificationItem(
        id: id,
        kind: kind,
        title: title,
        body: body,
        timeLabel: timeLabel,
        route: route,
        read: read ?? this.read,
      );
}
