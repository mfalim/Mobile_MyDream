import 'package:w51/features/notifications/domain/entities/notification_item.dart';

abstract interface class NotificationsDatasource {
  Future<List<NotificationItem>> fetch();
  Future<void> markRead(String id);
  Future<void> markAllRead();
}
