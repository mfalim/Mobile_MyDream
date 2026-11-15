import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:w51/app/providers/api_providers.dart';
import 'package:w51/core/config/app_config.dart';
import 'package:w51/features/auth/presentation/providers/auth_provider.dart';
import 'package:w51/features/notifications/data/datasources/notifications_mock_datasource.dart';
import 'package:w51/features/notifications/data/datasources/notifications_remote_datasource.dart';
import 'package:w51/features/notifications/data/repositories/notifications_repository_impl.dart';
import 'package:w51/features/notifications/domain/entities/notification_item.dart';
import 'package:w51/features/notifications/domain/repositories/notifications_repository.dart';

final notificationsRepositoryProvider = Provider<NotificationsRepository>(
  (ref) => NotificationsRepositoryImpl(
    AppConfig.useMockData
        ? NotificationsMockDatasource()
        : NotificationsRemoteDatasource(ref.watch(apiClientProvider)),
  ),
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

  Future<void> markRead(String id) {
    final item = state.value?.where((n) => n.id == id).firstOrNull;
    if (item == null || item.read) return Future<void>.value();
    _update((n) => n.id == id ? n.copyWith(read: true) : n);
    return _persistRead(id);
  }

  Future<void> markAllRead() {
    final previous = state.value;
    if (previous == null || !previous.any((n) => !n.read)) {
      return Future<void>.value();
    }
    _update((n) => n.copyWith(read: true));
    return _persistAllRead(previous);
  }

  Future<void> _persistRead(String id) async {
    try {
      await ref.read(notificationsRepositoryProvider).markRead(id);
    } catch (_) {
      _update((n) => n.id == id ? n.copyWith(read: false) : n);
      rethrow;
    }
  }

  Future<void> _persistAllRead(List<NotificationItem> previous) async {
    try {
      await ref.read(notificationsRepositoryProvider).markAllRead();
    } catch (_) {
      state = AsyncData(previous);
      rethrow;
    }
  }

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
