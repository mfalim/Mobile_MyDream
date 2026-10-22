import 'package:w51/features/notifications/domain/entities/notification_item.dart';

abstract interface class NotificationsRepository {
  Future<List<NotificationItem>> load();
}
