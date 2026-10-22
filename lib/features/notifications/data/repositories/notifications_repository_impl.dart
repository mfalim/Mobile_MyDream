import 'package:w51/features/notifications/data/datasources/notifications_mock_datasource.dart';
import 'package:w51/features/notifications/domain/entities/notification_item.dart';
import 'package:w51/features/notifications/domain/repositories/notifications_repository.dart';

class NotificationsRepositoryImpl implements NotificationsRepository {
  const NotificationsRepositoryImpl(this._datasource);

  final NotificationsMockDatasource _datasource;

  @override
  Future<List<NotificationItem>> load() => _datasource.fetch();
}
