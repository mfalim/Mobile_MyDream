import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:w51/features/auth/presentation/providers/auth_provider.dart';
import 'package:w51/features/notifications/data/datasources/notifications_mock_datasource.dart';
import 'package:w51/features/notifications/data/repositories/notifications_repository_impl.dart';
import 'package:w51/features/notifications/domain/entities/notification_item.dart';
import 'package:w51/features/notifications/domain/repositories/notifications_repository.dart';

final notificationsRepositoryProvider = Provider<NotificationsRepository>(
  (ref) => NotificationsRepositoryImpl(NotificationsMockDatasource()),
);

final notificationsProvider =
    AsyncNotifierProvider<NotificationsController, List<NotificationItem>>(
  NotificationsController.new,
);

class NotificationsController extends AsyncNotifier<List<NotificationItem>> {
  @override
  Future<List<NotificationItem>> build() {
    // Daftar milik akun yang sedang login: berganti akun -> dimuat ulang.
    ref.watch(authProvider);
    return ref.watch(notificationsRepositoryProvider).load();
  }

  void markRead(String id) =>
      _update((n) => n.id == id ? n.copyWith(read: true) : n);

  void markAllRead() => _update((n) => n.copyWith(read: true));

  void _update(NotificationItem Function(NotificationItem) change) {
    final current = state.value;
    if (current == null) return;
    state = AsyncData([for (final n in current) change(n)]);
  }
}

final unreadCountProvider = Provider<int>(
  (ref) =>
      ref.watch(notificationsProvider).value?.where((n) => !n.read).length ?? 0,
);
