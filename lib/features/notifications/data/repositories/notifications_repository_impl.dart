import 'package:w51/features/notifications/data/datasources/notifications_datasource.dart';
import 'package:w51/features/notifications/domain/entities/notification_item.dart';
import 'package:w51/features/notifications/domain/repositories/notifications_repository.dart';

class NotificationsRepositoryImpl implements NotificationsRepository {
  const NotificationsRepositoryImpl(this._datasource);

  final NotificationsDatasource _datasource;

  @override
  Future<List<NotificationItem>> load() => _datasource.fetch();

  @override
  Future<void> markRead(String id) => _datasource.markRead(id);

  @override
  Future<void> markAllRead() => _datasource.markAllRead();
}
